local PlayerService = {}
PlayerService.__index = PlayerService

function PlayerService:Init(services)
	self.DataService = services.DataService
end

function PlayerService:AddTire(player)
	local data = self.DataService:Get(player)

	if data.Inventory.Tires >= data.CarryCapacity then
		return false
	end

	data.Inventory.Tires += 1

	self:_SyncTires(player)

	return true
end

function PlayerService:DropTires(player)
	local data = self.DataService:Get(player)

	local amount = data.Inventory.Tires

	data.Inventory.Tires = 0

	self:_SyncTires(player)

	return amount
end

function PlayerService:_SyncTires(player)
	local data = self.DataService:Get(player)

	local dataFolder = player:FindFirstChild("Data")
	if not dataFolder then
		return
	end

	local tires = dataFolder:FindFirstChild("Tires")
	if not tires then
		return
	end

	tires.Value = data.Inventory.Tires
end

return PlayerService
