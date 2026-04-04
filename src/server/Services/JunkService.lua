local JunkService = {}
JunkService.__index = JunkService

local Workspace = game:GetService("Workspace")

function JunkService:Init()
	self.SpawnFolder = Workspace:WaitForChild("JunkSpawnPoints")
	self.TireTemplate = Workspace:WaitForChild("Tire")
end

function JunkService:SpawnTire()
	local points = self.SpawnFolder:GetChildren()
	local point = points[math.random(1, #points)]

	local tire = self.TireTemplate:Clone()
	tire.Position = point.Position
	tire.Parent = Workspace

	return tire
end

return JunkService
