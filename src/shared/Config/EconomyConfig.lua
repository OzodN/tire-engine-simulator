--[[
	EconomyConfig.lua
	
	Defines all economy multipliers and formulas
	Used to calculate rewards for launches, sales, and other income sources
]]

local EconomyConfig = {}

-- ==================== TIRE REWARDS ====================
-- Base reward for selling a tire (before modifiers)
EconomyConfig.Tire = {
	BaseReward = 10,
}

-- ==================== ACCURACY MULTIPLIERS ====================
-- Applied based on launch accuracy result
EconomyConfig.Accuracy = {
	Perfect = 1.5, -- Perfect = +50% bonus
	Good = 1.0, -- Good = baseline
	Miss = 0.25, -- Miss = 25% of baseline (some reward)
}

-- ==================== DISTANCE BONUS ====================
-- Additional multiplier based on distance traveled
EconomyConfig.Distance = {
	BaseLine = 20, -- Base distance (100%)
	BonusPerStud = 0.02, -- +2% per stud above baseline
}

-- ==================== HIT TARGET BONUS ====================
-- Extra multiplier for hitting targets
EconomyConfig.HitBonus = 2.0 -- 2x multiplier when hitting target

-- ==================== REBIRTH MULTIPLIER ====================
-- Applied to all income after rebirth
-- Formula: 1 + (0.25 × RebirthCount^0.85)
EconomyConfig.Rebirth = {
	BaseMultiplier = 1.0,
	RebirthCoefficent = 0.25,
	RebirthExponent = 0.85,
}

-- ==================== UPGRADE COSTS ====================
-- Cost scaling for upgrades
EconomyConfig.Upgrades = {
	Power = {
		BasePrice = 50,
		Increment = 25, -- +25 coins per level
	},
	Carry = {
		BasePrice = 30,
		Increment = 15, -- +15 coins per level
	},
}

-- ==================== MONETIZATION ====================
-- GamePass and DevProduct income modifiers
EconomyConfig.GamePass = {
	CoinMultiplier = 1.5, -- Coins x1.5 with active booster
	DropMultiplier = 1.3, -- Tire drop rate x1.3
	ExpMultiplier = 1.2, -- Experience x1.2 (future)
}

-- ==================== HELPER FUNCTIONS ====================

function EconomyConfig:CalculateLaunchReward(baseTireReward, accuracy, distance, hitTarget, rebirthMultiplier)
	-- Apply accuracy multiplier
	local accuracyMult = self.Accuracy[accuracy] or self.Accuracy.Miss
	local withAccuracy = baseTireReward * accuracyMult

	-- Apply distance bonus
	local distanceBonus = 1.0
	if distance > self.Distance.BaseLine then
		distanceBonus = 1.0 + ((distance - self.Distance.BaseLine) * self.Distance.BonusPerStud)
	end
	local withDistance = withAccuracy * distanceBonus

	-- Apply hit bonus
	local withHit = hitTarget and (withDistance * self.HitBonus) or withDistance

	-- Apply rebirth multiplier
	local rebirthMult = rebirthMultiplier or 1.0
	local final = withHit * rebirthMult

	return math.floor(final)
end

function EconomyConfig:GetUpgradeCost(upgradeType, currentLevel)
	local config = self.Upgrades[upgradeType]
	if not config then
		return 0
	end

	-- Cost = BasePrice + (Increment × CurrentLevel)
	return config.BasePrice + (config.Increment * currentLevel)
end

function EconomyConfig:GetUpgradeValue(upgradeType, level)
	-- Standard formula: Base + (PerLevel × Level)
	local config = self.Upgrades[upgradeType]
	if not config then
		return 1
	end

	-- We define initial stat as "1" and increase from there
	return 1 + (level - 1) * 0.1 -- Each level adds 10% to base
end

return EconomyConfig
