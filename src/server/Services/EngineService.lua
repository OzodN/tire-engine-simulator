--[[
	EngineService - Manages engine selection for players
	Stores and retrieves selected engine from player data
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EngineConfig = require(ReplicatedStorage.Shared.Config.EngineConfig)

local EngineService = {}
EngineService.__index = EngineService

function EngineService:Init(services)
	self.DataService = services.DataService

	local remotes = ReplicatedStorage.Remotes
	local selectEngineRemote = remotes:WaitForChild("SelectEngine")

	-- Listen for engine selection from client
	selectEngineRemote.OnServerEvent:Connect(function(player, engineID)
		self:SetSelectedEngine(player, engineID)
	end)

	print("✅ EngineService initialized")
end

-- Get player's selected engine
function EngineService:GetSelectedEngine(player)
	local data = self.DataService:Get(player)
	return data and data.SelectedEngineID or "Starter"
end

-- Set player's selected engine
function EngineService:SetSelectedEngine(player, engineID)
	-- Validate engine exists
	if not EngineConfig.ByID[engineID] then
		warn("Invalid engine ID:", engineID)
		return false
	end

	-- Update player data
	local profile = self.DataService:GetRaw(player)
	if profile then
		profile.Data.data.SelectedEngineID = engineID
		profile:Reconcile()
		print(player.Name, "selected engine:", engineID)
		return true
	end

	return false
end

-- Get engine config by player
function EngineService:GetPlayerEngine(player)
	local engineID = self:GetSelectedEngine(player)
	return EngineConfig.ByID[engineID]
end

return EngineService
