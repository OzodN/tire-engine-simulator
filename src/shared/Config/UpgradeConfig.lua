local UpgradeConfig = {}

UpgradeConfig.Power = {
	Base = 100,
	PerLevel = 25,
	Cost = function(level)
		return 50 * level
	end,
}

UpgradeConfig.Carry = {
	Base = 1,
	PerLevel = 1,
	Cost = function(level)
		return 30 * level
	end,
}

return UpgradeConfig
