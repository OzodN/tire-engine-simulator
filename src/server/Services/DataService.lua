--[[
	DataService - Server-side player data management
	Uses ProfileService for persistence with automatic save/load
	Provides data access and change tracking
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ProfileService = require(ServerScriptService:WaitForChild("ServerPackages"):WaitForChild("ProfileService"))
local PlayerDataSchema = require(ReplicatedStorage.Shared.Types.PlayerDataSchema)

local DataService = {}
DataService.__index = DataService

-- ProfileService store configuration
local ProfileStore = ProfileService.GetProfileStore(
	"PlayerData_v1", -- Store name (increment on breaking changes)
	PlayerDataSchema.CreateBlank()
)

-- Runtime profile cache { playerId: profileObject }
local activeProfiles = {}

-- Data change listeners { playerId: { [eventName]: callback[] } }
local changeListeners = {}

-- ======================
-- INITIALIZATION
-- ======================

function DataService:Init()
	-- Load profiles for existing players
	for _, player in pairs(Players:GetPlayers()) do
		self:LoadPlayer(player)
	end

	-- Load profiles for new players
	Players.PlayerAdded:Connect(function(player)
		self:LoadPlayer(player)
	end)

	-- Save and release profiles on logout
	Players.PlayerRemoving:Connect(function(player)
		self:SavePlayer(player)
	end)

	-- Auto-save every 5 minutes as safety backup
	task.spawn(function()
		while true do
			task.wait(300)
			for playerId, profile in pairs(activeProfiles) do
				if profile then
					profile:Reconcile() -- ProfileService auto-save
				end
			end
		end
	end)
end

-- ======================
-- PROFILE LIFECYCLE
-- ======================

function DataService:LoadPlayer(player)
	if activeProfiles[player.UserId] then
		return -- Already loaded
	end

	local profile = ProfileStore:LoadProfileAsync("Player_" .. player.UserId)

	if not profile then
		warn("Failed to load profile for player:", player.Name, player.UserId)
		player:Kick("Failed to load profile. Try again.")
		return
	end

	-- Migrate if old version
	profile.Data = PlayerDataSchema.Migrate(profile.Data)

	-- Validate structure
	local valid, err = PlayerDataSchema.Validate(profile.Data)
	if not valid then
		warn("Invalid profile data:", err)
		player:Kick("Corrupted profile data.")
		profile:Release()
		return
	end

	-- Set up release on disconnect (auto-save)
	profile:Reconcile()
	profile:ListenToRelease(function()
		activeProfiles[player.UserId] = nil
		changeListeners[player.UserId] = nil
	end)

	-- Cache profile
	activeProfiles[player.UserId] = profile

	-- Initialize change listener table
	changeListeners[player.UserId] = {}

	print(player.Name, "profile loaded - Coins:", profile.Data.data.Economy.Coins)
end

function DataService:SavePlayer(player)
	local profile = activeProfiles[player.UserId]
	if profile then
		profile:Release() -- Auto-saves on release
	end
end

-- ======================
-- DATA ACCESS
-- ======================

function DataService:Get(player)
	local profile = activeProfiles[player.UserId]
	if not profile then
		warn("Profile not found for player:", player.Name)
		return nil
	end
	return profile.Data.data
end

function DataService:GetRaw(player)
	return activeProfiles[player.UserId]
end

-- ======================
-- CURRENCY OPERATIONS
-- ======================

function DataService:AddCoins(player, amount)
	local profile = activeProfiles[player.UserId]
	if not profile then
		return false
	end

	amount = math.floor(amount)
	if amount < 0 then
		return false
	end

	profile.Data.data.Economy.Coins += amount
	profile.Data.data.Economy.TotalCoinsEarned += amount
	profile:Reconcile()

	self:_NotifyChange(player, "CoinsChanged", amount)
	return true
end

function DataService:RemoveCoins(player, amount)
	local profile = activeProfiles[player.UserId]
	if not profile then
		return false
	end

	amount = math.floor(amount)
	if amount < 0 then
		return false
	end

	if profile.Data.data.Economy.Coins < amount then
		return false -- Not enough coins
	end

	profile.Data.data.Economy.Coins -= amount
	profile:Reconcile()

	self:_NotifyChange(player, "CoinsChanged", amount)
	return true
end

function DataService:GetCoins(player)
	local data = self:Get(player)
	return data and data.Economy.Coins or 0
end

-- ======================
-- TIRE OPERATIONS
-- ======================

function DataService:AddTire(player, tireData)
	local profile = activeProfiles[player.UserId]
	if not profile then
		return false
	end

	if not tireData or not tireData.TierID or not tireData.Modifier then
		warn("Invalid tire data:", tireData)
		return false
	end

	local data = profile.Data.data
	local inventory = data.Inventory.Tires

	-- Check carry capacity
	if #inventory >= data.Inventory.CarryCapacity then
		warn(player.Name, "inventory full!")
		return false
	end

	-- Add tire with metadata
	table.insert(inventory, {
		TierID = tireData.TierID,
		Modifier = tireData.Modifier,
		PickedUpAt = os.time(),
	})

	profile:Reconcile()
	self:_NotifyChange(player, "TiresChanged")

	return true
end

function DataService:GetTires(player)
	local data = self:Get(player)
	return data and data.Inventory.Tires or {}
end

function DataService:GetCarryCapacity(player)
	local data = self:Get(player)
	return data and data.Inventory.CarryCapacity or 5
end

function DataService:RemoveTire(player, tireIndex)
	local profile = activeProfiles[player.UserId]
	if not profile then
		return false
	end

	local inventory = profile.Data.data.Inventory.Tires
	if not inventory or tireIndex < 1 or tireIndex > #inventory then
		return false
	end

	table.remove(inventory, tireIndex)
	profile:Reconcile()
	self:_NotifyChange(player, "TiresChanged")

	return true
end

function DataService:Rebirth(player)
	local profile = activeProfiles[player.UserId]
	if not profile then
		return false
	end

	local data = profile.Data.data

	-- Calculate new multiplier
	local oldMultiplier = data.Economy.RebirthMultiplier
	data.Economy.Rebirths += 1
	data.Economy.RebirthMultiplier = 1 + (0.25 * math.pow(data.Economy.Rebirths, 0.85))

	-- Reset progress but keep collections
	data.Economy.Coins = 0
	data.Inventory.Tires = {}
	data.Upgrades.Power = 1 -- Reset power upgrade
	data.Upgrades.Carry = 1 -- Reset carry upgrade
	data.Engines.Levels = { engine_toy = 1 }
	data.Engines.Fuel = { engine_toy = 0 }

	profile:Reconcile()
	self:_NotifyChange(player, "Rebirth", data.Economy.RebirthMultiplier)

	print(player.Name, "rebirthed! Multiplier:", data.Economy.RebirthMultiplier)
	return true
end

-- ======================
-- CHANGE NOTIFICATION
-- ======================

function DataService:OnChange(player, eventName, callback)
	if not changeListeners[player.UserId] then
		changeListeners[player.UserId] = {}
	end

	if not changeListeners[player.UserId][eventName] then
		changeListeners[player.UserId][eventName] = {}
	end

	table.insert(changeListeners[player.UserId][eventName], callback)

	-- Return cleanup function
	return function()
		local listeners = changeListeners[player.UserId] and changeListeners[player.UserId][eventName]
		if listeners then
			for i, cb in ipairs(listeners) do
				if cb == callback then
					table.remove(listeners, i)
					break
				end
			end
		end
	end
end

function DataService:_NotifyChange(player, eventName, ...)
	local listeners = changeListeners[player.UserId] and changeListeners[player.UserId][eventName]
	if listeners then
		for _, callback in ipairs(listeners) do
			task.spawn(callback, ...)
		end
	end
end

return DataService
