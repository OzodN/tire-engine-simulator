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

print("✅ All services initialized")
