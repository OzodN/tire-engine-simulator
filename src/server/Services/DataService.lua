local DataService = {}
DataService.__index = DataService

local Players = game:GetService("Players")

local playerData = {}

function DataService:Init()
	Players.PlayerAdded:Connect(function(player)
		self:LoadPlayer(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self:SavePlayer(player)
	end)
end

function DataService:LoadPlayer(player)
	local folder = Instance.new("Folder")
	folder.Name = "Data"
	folder.Parent = player

	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = 0
	coins.Parent = folder

	local tires = Instance.new("IntValue")
	tires.Name = "Tires"
	tires.Value = 0
	tires.Parent = folder

	playerData[player] = {
		Coins = 0,
		EngineLevel = 1,
		CarryCapacity = 1,
		Rebirths = 0,
		Inventory = { Tires = 0 },
	}
end

function DataService:Get(player)
	return playerData[player]
end

function DataService:SavePlayer(player)
	-- MVP: пока без DataStore
end

return DataService
