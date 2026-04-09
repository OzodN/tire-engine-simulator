local ServerScriptService = game:GetService("ServerScriptService")
local ServicesFolder = ServerScriptService.Services

local Loader = require(game.ReplicatedStorage.Shared.Modules.Loader)
local LabelUpdateUtil = require(game.ReplicatedStorage.Shared.Utils.LabelUpdateUtil)

local services = Loader.LoadFolder(ServicesFolder)

-- init order
services.DataService:Init()
LabelUpdateUtil:Init(services.DataService)

for _, service in pairs(services) do
	if service.Init then
		service:Init(services)
	end
end
