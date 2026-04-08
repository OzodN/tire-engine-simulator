local ServerScriptService = game:GetService("ServerScriptService")
local DataService = require(ServerScriptService.Services.DataService)

local LabelUpdateUtil = {}

function LabelUpdateUtil:GetPlayer(player)
	local playerData = DataService:Get(player)
	if not playerData then
		return
	end
	return playerData
end

function LabelUpdateUtil:SyncTires(player)
	local dataFolder = player:WaitForChild("Data")
	if not dataFolder then
		return
	end

	local tires = dataFolder:FindFirstChild("Tires")
	if not tires then
		return
	end

	tires.Value = LabelUpdateUtil:GetPlayer(player).Inventory.Tires
end

function LabelUpdateUtil:SyncCoins(player)
	local dataFolder = player:WaitForChild("Data")
	if not dataFolder then
		return
	end

	local coins = dataFolder:FindFirstChild("Coins")
	if not coins then
		return
	end

	coins.Value = LabelUpdateUtil:GetPlayer(player).Coins
end

function LabelUpdateUtil:SyncPower(player)
	local dataFolder = player:WaitForChild("Data")
	if not dataFolder then
		return
	end

	local upgrades = dataFolder:FindFirstChild("Upgrades")
	if not upgrades then
		return
	end

	local power = upgrades:FindFirstChild("Power")
	if not power then
		return
	end

	power.Value = LabelUpdateUtil:GetPlayer(player).Upgrades.Power
end

function LabelUpdateUtil:SyncCarry(player)
	local dataFolder = player:WaitForChild("Data")
	if not dataFolder then
		return
	end

	local upgrades = dataFolder:FindFirstChild("Upgrades")
	if not upgrades then
		return
	end

	local carry = upgrades:FindFirstChild("Carry")
	if not carry then
		return
	end

	carry.Value = LabelUpdateUtil:GetPlayer(player).Upgrades.Carry
end

return LabelUpdateUtil
