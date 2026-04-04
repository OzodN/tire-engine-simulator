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
	return true
end

function PlayerService:DropTires(player)
	local data = self.DataService:Get(player)

	local amount = data.Inventory.Tires
	data.Inventory.Tires = 0

	return amount
end

return PlayerService
