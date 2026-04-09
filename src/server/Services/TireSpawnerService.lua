--[[
	TireSpawnerService - Manages tire spawning and respawning in the junkyard
	
	Responsibilities:
	- Spawn tires at defined spawn points
	- Respawn when player picks up
	- Maintain max tire count
	- Track active tires
]]

local TireSpawnerService = {}
TireSpawnerService.__index = TireSpawnerService

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TireConfig = require(ReplicatedStorage.Shared.Config.TireConfig)
local TireDefinitions = require(ReplicatedStorage.Shared.Config.TireDefinitions)

function TireSpawnerService:Init(services)
	self.Services = services
	self.ActiveTires = 0
	self.MaxTires = 15
	self.SpawnRate = 3 -- Spawn every 3 seconds

	-- Find or create junkyard folder
	self:FindSpawnPoints()

	-- Start spawning loop
	self:StartSpawning()
end

function TireSpawnerService:FindSpawnPoints()
	local junkyard = Workspace:FindFirstChild("Junkyard")
	if not junkyard then
		warn("⚠️ Junkyard folder not found!")
		return
	end

	-- Find all spawn points (parts named "TireSpawnPoint")
	self.SpawnPoints = {}
	for _, point in ipairs(junkyard:GetDescendants()) do
		if point:IsA("BasePart") and point.Name == "TireSpawnPoint" then
			table.insert(self.SpawnPoints, point)
		end
	end

	if #self.SpawnPoints == 0 then
		warn("⚠️ No TireSpawnPoints found in Junkyard! Creating manual spawn point...")
		-- Fallback: use junkyard center
		self.SpawnPoints = { junkyard }
	end

	print("✅ Found " .. #self.SpawnPoints .. " spawn points")
end

function TireSpawnerService:StartSpawning()
	task.spawn(function()
		while true do
			task.wait(self.SpawnRate)

			if self.ActiveTires < self.MaxTires then
				self:SpawnTire()
			end
		end
	end)

	print("🎯 Tire spawner started (max " .. self.MaxTires .. " tires)")
end

function TireSpawnerService:SpawnTire()
	-- Generate random tire
	local tireData = TireDefinitions:GenerateRandomTire("Junkyard")
	local tierData = TireConfig.ByID[tireData.TierID]
	local modifierData = TireDefinitions.ModifiersByID[tireData.Modifier]

	if not tierData or not modifierData then
		warn("❌ Invalid tire generation!")
		return
	end

	-- Pick random spawn point
	local spawnPoint = self.SpawnPoints[math.random(1, #self.SpawnPoints)]
	local spawnPos = spawnPoint.Position + Vector3.new(math.random(-5, 5), 2, math.random(-5, 5))

	-- Create tire part
	local tire = Instance.new("Part")
	tire.Name = "Tire"
	tire.Shape = Enum.PartType.Cylinder
	tire.Size = Vector3.new(1, 1, 3)
	tire.CanCollide = true
	tire.TopSurface = Enum.SurfaceType.Smooth
	tire.BottomSurface = Enum.SurfaceType.Smooth
	tire.Position = spawnPos
	tire.Rotation = Vector3.new(90, 0, 0)
	tire.Color = modifierData.Color
	tire.Material = Enum.Material.Rubber
	tire.Parent = Workspace.Junkyard

	-- Add metadata
	local tireLabel = Instance.new("StringValue")
	tireLabel.Name = "TireData"
	tireLabel.Value = tireData.TierID .. "|" .. tireData.Modifier
	tireLabel.Parent = tire

	-- Add proximity prompt for pickup
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "PickupPrompt"
	prompt.ActionText = "Pick up"
	prompt.ObjectText = tierData.Name .. " " .. modifierData.Name
	prompt.MaxActivationDistance = 20
	prompt.Parent = tire

	-- Track tire
	self.ActiveTires = self.ActiveTires + 1

	-- Cleanup when tire is destroyed (picked up or despawned)
	local connection
	connection = tire.Destroying:Connect(function()
		self.ActiveTires = self.ActiveTires - 1
		connection:Disconnect()
	end)

	print(
		"🔄 Spawned: "
			.. tierData.Name
			.. " "
			.. modifierData.Name
			.. " ("
			.. self.ActiveTires
			.. "/"
			.. self.MaxTires
			.. ")"
	)

	return tire
end

-- Helper: Get tire data from part
function TireSpawnerService:GetTireData(tirePart)
	if not tirePart then
		return nil
	end

	local dataValue = tirePart:FindFirstChild("TireData")
	if not dataValue or dataValue.ClassName ~= "StringValue" then
		return nil
	end

	local parts = string.split(dataValue.Value, "|")
	if #parts ~= 2 then
		return nil
	end

	return {
		TierID = parts[1],
		Modifier = parts[2],
	}
end

return TireSpawnerService
