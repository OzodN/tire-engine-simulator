local ServerScriptService = game:GetService("ServerScriptService")
local ServicesFolder = ServerScriptService.Services

local Loader = require(game.ReplicatedStorage.Shared.Modules.Loader)

local services = Loader.LoadFolder(ServicesFolder)

-- Initialize DataService first (handles persistence)
services.DataService:Init()

-- Initialize all other services
for _, service in pairs(services) do
	if service.Init and service ~= services.DataService then
		service:Init(services)
	end
end

-- Initialize DataSyncService last (after all other services)
if services.DataSyncService and services.DataSyncService.Init then
	services.DataSyncService:Init(services)
end

print("✅ All services initialized")
