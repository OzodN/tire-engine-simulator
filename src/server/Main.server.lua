local ServerScriptService = game:GetService("ServerScriptService")
local ServicesFolder = ServerScriptService:WaitForChild("Services")

local Loader = require(game.ReplicatedStorage.Shared.Modules.Loader)

local services = Loader.LoadFolder(ServicesFolder)

-- init order
services.DataService:Init()

for _, service in pairs(services) do
	if service.Init then
		service:Init(services)
	end
end
