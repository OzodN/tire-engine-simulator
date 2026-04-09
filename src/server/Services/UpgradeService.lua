local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UpgradeConfig = require(ReplicatedStorage.Shared.Config.UpgradeConfig)
local LabelUpdateUtil = require(ReplicatedStorage.Shared.Utils.LabelUpdateUtil)

local remotes = ReplicatedStorage:WaitForChild("Remotes")

local UpgradeService = {}
UpgradeService.__index = UpgradeService

function UpgradeService:Init(services)
	self.DataService = services.DataService

	self.UpgradeRemote = remotes:WaitForChild("UpgradeRequest")
	self.UpgradeRemote.OnServerEvent:Connect(function(player, upgradeType)
		self:HandleUpgrade(player, upgradeType)
	end)

	self.GetInfoRemote = remotes:WaitForChild("GetUpgradeInfo")
	self.GetInfoRemote.OnServerInvoke = function(player)
		return self:GetAllUpgradeInfo(player)
	end
end

function UpgradeService:HandleUpgrade(player, upgradeType)
	print(player.Name, "requested upgrade:", upgradeType)

	-- защита (ОБЯЗАТЕЛЬНО)
	if upgradeType ~= "Power" and upgradeType ~= "Carry" then
		warn("Invalid upgrade type:", upgradeType)
		return
	end

	self:Upgrade(player, upgradeType)
end

function UpgradeService:Upgrade(player, upgradeType)
	local data = self.DataService:Get(player)

	local upgrade = data.Upgrades[upgradeType]
	local config = UpgradeConfig[upgradeType]

	local cost = config.Cost(upgrade)

	if data.Coins < cost then
		return false
	end

	data.Coins -= cost
	data.Upgrades[upgradeType] += 1

	-- обновляем Stats Label
	LabelUpdateUtil:SyncCoins(player)
	LabelUpdateUtil:SyncTires(player)
	LabelUpdateUtil:SyncPower(player)
	LabelUpdateUtil:SyncCarry(player)

	print(player.Name, "upgraded", upgradeType, "to", data.Upgrades[upgradeType])

	return true
end

function UpgradeService:GetValue(player, upgradeType)
	local data = self.DataService:Get(player)
	local level = data.Upgrades[upgradeType]
	local config = UpgradeConfig[upgradeType]

	return config.Base + (level - 1) * config.PerLevel
end

function UpgradeService:GetAllUpgradeInfo(player)
	local data = self.DataService:Get(player)

	local result = {}

	for _upgradeType, _config in pairs(UpgradeConfig) do
		local _level = data.Upgrades[_upgradeType]
		local _cost = _config.Cost(_level)
		local _value = _config.Base + (_level - 1) * _config.PerLevel

		result[_upgradeType] = {
			level = _level,
			cost = _cost,
			value = _value,
			nextValue = _config.Base + _level * _config.PerLevel,
		}
	end

	return result
end

return UpgradeService
