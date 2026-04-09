--[[
	LaunchPadService - Manages launch pad interactions
	
	Responsibilities:
	- Detect when player approaches launch pad
	- Display available tires from inventory
	- Allow player to select and launch a tire
	- Remove tire from inventory after launch
]]

local LaunchPadService = {}
LaunchPadService.__index = LaunchPadService

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TireConfig = require(ReplicatedStorage.Shared.Config.TireConfig)
local TireDefinitions = require(ReplicatedStorage.Shared.Config.TireDefinitions)

function LaunchPadService:Init(services)
	self.DataService = services.DataService
	self.LaunchService = services.LaunchService

	local remotes = ReplicatedStorage.Remotes
	
	-- Create RemoteEvent for tire selection
	if not remotes:FindFirstChild("SelectTireToLaunch") then
		local selectRemote = Instance.new("RemoteEvent")
		selectRemote.Name = "SelectTireToLaunch"
		selectRemote.Parent = remotes
	end

	self.SelectTireRemote = remotes:WaitForChild("SelectTireToLaunch")

	-- Listen for selections
	self.SelectTireRemote.OnServerEvent:Connect(function(player, tireIndex)
		self:LaunchTireFromInventory(player, tireIndex)
	end)

	-- Handle GetPlayerTires RemoteFunction
	local getTiresRemote = remotes:WaitForChild("GetPlayerTires")
	getTiresRemote.OnServerInvoke = function(player)
		return self.DataService:GetTires(player)
	end

	self:BindLaunchPads()
	
	-- Create ShowInventory RemoteEvent
	if not remotes:FindFirstChild("ShowInventory") then
		local showInvRemote = Instance.new("RemoteEvent")
		showInvRemote.Name = "ShowInventory"
		showInvRemote.Parent = remotes
	end
end

function LaunchPadService:BindLaunchPads()
	local launchArea = Workspace:FindFirstChild("LaunchArea")
	if not launchArea then
		warn("⚠️ LaunchArea not found in Workspace!")
		return
	end

	-- Find all launch pads (parts named "LaunchPad")
	for _, pad in ipairs(launchArea:GetDescendants()) do
		if pad:IsA("BasePart") and pad.Name == "LaunchPad" then
			self:SetupLaunchPad(pad)
		end
	end

	-- Handle new launch pads
	launchArea.DescendantAdded:Connect(function(obj)
		if obj:IsA("BasePart") and obj.Name == "LaunchPad" then
			self:SetupLaunchPad(obj)
		end
	end)

	print("✅ Launch pads configured")
end

function LaunchPadService:SetupLaunchPad(pad)
	-- Add proximity detection
	local proximity = pad:FindFirstChildOfClass("ProximityPrompt")
	if not proximity then
		proximity = Instance.new("ProximityPrompt")
		proximity.ActionText = "Ready to launch"
		proximity.ObjectText = "Open inventory"
		proximity.MaxActivationDistance = 50
		proximity.Parent = pad
	end

	proximity.Triggered:Connect(function(player)
		-- Show inventory UI on client
		local showInvRemote = ReplicatedStorage.Remotes:FindFirstChild("ShowInventory")
		if showInvRemote then
			showInvRemote:FireClient(player)
		end
	end)
end

function LaunchPadService:SendInventoryToClient(player, tires)
	-- Convert tire objects to display-friendly format
	local inventory = {}

	for index, tire in ipairs(tires) do
		local tierData = TireConfig.ByID[tire.TierID]
		local modifierData = TireDefinitions.ModifiersByID[tire.Modifier]

		if tierData and modifierData then
			table.insert(inventory, {
				Index = index,
				TierID = tire.TierID,
				Modifier = tire.Modifier,
				DisplayName = tierData.Name .. " " .. modifierData.Name,
				Reward = self:CalculateLaunchReward(player, tierData, modifierData),
			})
		end
	end

	-- Send to client (client will show UI)
	local sendRemote = ReplicatedStorage.Remotes:FindFirstChild("SendInventory")
	if sendRemote then
		sendRemote:FireClient(player, inventory)
	end
end

function LaunchPadService:LaunchTireFromInventory(player, tireIndex)
	local tires = self.DataService:GetTires(player)

	if not tires or tireIndex < 1 or tireIndex > #tires then
		warn("Invalid tire index:", tireIndex)
		return
	end

	local tire = tires[tireIndex]
	local tierData = TireConfig.ByID[tire.TierID]
	local modifierData = TireDefinitions.ModifiersByID[tire.Modifier]

	if not tierData or not modifierData then
		warn("Invalid tire data")
		return
	end

	-- Calculate reward with tire modifiers
	local baseReward = self:CalculateLaunchReward(player, tierData, modifierData)

	-- Trigger launch with tire data
	if self.LaunchService.HandleLaunchWithTire then
		self.LaunchService:HandleLaunchWithTire(player, tire, baseReward)
	else
		-- Fallback to standard launch
		self.LaunchService:HandleLaunch(player, "Perfect", 0.5)
	end

	-- Remove tire from inventory
	self.DataService:RemoveTire(player, tireIndex)

	print(player.Name, "launched:", tierData.Name, modifierData.Name)
end

function LaunchPadService:CalculateLaunchReward(player, tierData, modifierData)
	if not tierData or not modifierData then
		return 0
	end

	local data = self.DataService:Get(player)
	if not data then
		return 0
	end

	-- Base reward from tire tier
	local baseReward = tierData.BaseReward

	-- Apply modifier multiplier
	local withModifier = baseReward * modifierData.RewardMultiplier

	-- Apply rebirth multiplier
	local rebirthMultiplier = data.Economy.RebirthMultiplier or 1.0
	local withRebirth = withModifier * rebirthMultiplier

	return math.floor(withRebirth)
end

return LaunchPadService
