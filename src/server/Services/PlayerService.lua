local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LabelUpdateUtil = require(ReplicatedStorage.Shared.Utils.LabelUpdateUtil)

local PlayerService = {}
PlayerService.__index = PlayerService

function PlayerService:Init(services)
	self.DataService = services.DataService
	self.UpgradeService = services.UpgradeService
end

function PlayerService:AddTire(player)
	local data = self.DataService:Get(player)
	local carry = self.UpgradeService:GetValue(player, "Carry")

	if data.Inventory.Tires >= carry then
		return false
	end

	data.Inventory.Tires += 1

	-- обновляем TiresLabel
	LabelUpdateUtil:SyncTires(player)

	return true
end

function PlayerService:DropTires(player)
	local data = self.DataService:Get(player)

	local amount = data.Inventory.Tires

	data.Inventory.Tires = 0

	-- обновляем TiresLabel
	LabelUpdateUtil:SyncTires(player)

	return amount
end

return PlayerService
