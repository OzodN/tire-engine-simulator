local Workspace = game:GetService("Workspace")
local ServerScriptService = game:GetService("ServerScriptService")
local ServicesFolder = ServerScriptService.Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Loader = require(game.ReplicatedStorage.Shared.Modules.Loader)

-- Initialize targets FIRST before services load
require(script.Parent:FindFirstChild("InitTargets"))

local services = Loader.LoadFolder(ServicesFolder)

-- Create critical Remotes EARLY (before clients connect)
local remotes = ReplicatedStorage:FindFirstChild("Remotes")
if not remotes then
	remotes = Instance.new("Folder")
	remotes.Name = "Remotes"
	remotes.Parent = ReplicatedStorage
end

-- Ensure DataChanged exists for early UI clients
if not remotes:FindFirstChild("DataChanged") then
	local dataChanged = Instance.new("RemoteEvent")
	dataChanged.Name = "DataChanged"
	dataChanged.Parent = remotes
end

-- Create GetPlayerTires RemoteFunction
if not remotes:FindFirstChild("GetPlayerTires") then
	local getTires = Instance.new("RemoteFunction")
	getTires.Name = "GetPlayerTires"
	getTires.Parent = remotes
end

-- Initialize DataService first (handles persistence)
services.DataService:Init()

-- Initialize ONLY active services (skip deprecated ones)
local SKIP_SERVICES = {
	DataService = true, -- Already initialized
	JunkService = true, -- Deprecated (use TireSpawnerService)
	PlayerService = true, -- Deprecated (use DataService)
	BaseService = true, -- Deprecated (old tire selling system)
	TireService = true, -- Deprecated (replaced by economy formulas)
}

for serviceName, service in pairs(services) do
	if service.Init and not SKIP_SERVICES[serviceName] then
		service:Init(services)
	end
end

-- Initialize DataSyncService last (after all other services)
if services.DataSyncService and services.DataSyncService.Init then
	services.DataSyncService:Init(services)
end

print("✅ All services initialized")

