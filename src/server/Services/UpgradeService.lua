local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UpgradeConfig = require(ReplicatedStorage.Shared.Config.UpgradeConfig)

local remotes = ReplicatedStorage:WaitForChild("Remotes")

-- Anti-spam: minimum time between upgrades (ms)
local UPGRADE_COOLDOWN = 0.5
local upgradeCooldowns = {}

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

function UpgradeService:ValidateUpgradeRequest(player)
	local now = tick()
	local lastUpgrade = upgradeCooldowns[player.UserId]

	if lastUpgrade and (now - lastUpgrade) < UPGRADE_COOLDOWN then
		return false -- On cooldown
	end

	upgradeCooldowns[player.UserId] = now
	return true
end

function UpgradeService:HandleUpgrade(player, upgradeType)
	-- Rate limiting
	if not self:ValidateUpgradeRequest(player) then
		warn("Upgrade spam detected:", player.Name)
		return
	end

	-- Input validation
	if upgradeType ~= "Power" and upgradeType ~= "Carry" then
		warn("Invalid upgrade type:", upgradeType)
		return
	end

	self:Upgrade(player, upgradeType)
end

function UpgradeService:Upgrade(player, upgradeType)
	local data = self.DataService:Get(player)
	if not data then
		return false
	end

	local upgrade = data.Upgrades[upgradeType]
	local config = UpgradeConfig[upgradeType]

	local cost = config.Cost(upgrade)

	-- Check funds (server-validated)
	if self.DataService:GetCoins(player) < cost then
		return false
	end

	-- Deduct coins (auto-saves via DataService)
	local success = self.DataService:RemoveCoins(player, cost)
	if not success then
		return false
	end

	-- Apply upgrade
	data.Upgrades[upgradeType] += 1

	print(player.Name, "upgraded", upgradeType, "to", data.Upgrades[upgradeType])

	return true
end

function UpgradeService:GetValue(player, upgradeType)
	local data = self.DataService:Get(player)
	if not data then
		return 0
	end

	local level = data.Upgrades[upgradeType]
	local config = UpgradeConfig[upgradeType]

	return config.Base + (level - 1) * config.PerLevel
end

function UpgradeService:GetAllUpgradeInfo(player)
	local data = self.DataService:Get(player)
	if not data then
		return {}
	end

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
