local PlayerService = {}
PlayerService.__index = PlayerService

function PlayerService:Init(services)
	self.DataService = services.DataService
	self.UpgradeService = services.UpgradeService
end

-- Add tire to player inventory (respects carry capacity)
function PlayerService:AddTire(player)
	local data = self.DataService:Get(player)
	if not data then
		return false
	end

	local carry = self.UpgradeService:GetValue(player, "Carry")

	if #data.Inventory.Tires >= carry then
		return false -- Inventory full
	end

	-- For MVP: simple tire (just count, no tier/rarity yet)
	table.insert(data.Inventory.Tires, { tierId = "tire_basic", rarity = 1 })

	-- Trigger save
	local profile = self.DataService:GetRaw(player)
	if profile then
		profile:Reconcile()
	end

	return true
end

-- Drop tires from inventory (sell)
function PlayerService:DropTires(player)
	local data = self.DataService:Get(player)
	if not data then
		return 0
	end

	local amount = #data.Inventory.Tires
	data.Inventory.Tires = {}

	-- Trigger save
	local profile = self.DataService:GetRaw(player)
	if profile then
		profile:Reconcile()
	end

	return amount
end

return PlayerService
