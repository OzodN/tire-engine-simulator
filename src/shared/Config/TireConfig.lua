--[[
	TireConfig.lua
	
	Defines 6 tire tiers with their gameplay and economy characteristics.
	Each tier affects:
	- Flight trajectory and distance
	- Reward multiplier
	- Rarity (drop chance)
	- Visual presentation
]]

local TireConfig = {}

-- Tire Tiers (Index 1 = Tier 1 Toy, Index 6 = Tier 6 Spaceship)
TireConfig.Tiers = {
	{
		ID = "Toy",
		Name = "🧸 Toy Tire",
		Index = 1,
		Rarity = "Common",
		RarityValue = 1,

		-- Economy
		BaseReward = 5,
		RewardMultiplier = 0.5,

		-- Flight Physics
		SpeedMultiplier = 0.6, -- Slower, shorter distance
		ArcHeight = 0.15, -- Low arc
		Stability = 0.8, -- Wobbles a bit

		-- Drop rates (for loot tables)
		DropChance = 40, -- 40% of drops
	},
	{
		ID = "Car",
		Name = "🚗 Car Tire",
		Index = 2,
		Rarity = "Common",
		RarityValue = 1,

		BaseReward = 10,
		RewardMultiplier = 1.0, -- Baseline

		SpeedMultiplier = 1.0, -- Standard distance
		ArcHeight = 0.2,
		Stability = 1.0,

		DropChance = 35, -- 35% of drops
	},
	{
		ID = "Truck",
		Name = "🚚 Truck Tire",
		Index = 3,
		Rarity = "Uncommon",
		RarityValue = 2,

		BaseReward = 25,
		RewardMultiplier = 1.5,

		SpeedMultiplier = 1.2, -- Goes further
		ArcHeight = 0.25,
		Stability = 0.95,

		DropChance = 15, -- 15% of drops
	},
	{
		ID = "Tractor",
		Name = "🚜 Tractor Tire",
		Index = 4,
		Rarity = "Uncommon",
		RarityValue = 2,

		BaseReward = 40,
		RewardMultiplier = 2.0,

		SpeedMultiplier = 0.9, -- Heavy, doesn't go as far but valuable
		ArcHeight = 0.3,
		Stability = 1.1, -- Very stable

		DropChance = 5, -- 5% of drops
	},
	{
		ID = "Aircraft",
		Name = "✈️ Aircraft Tire",
		Index = 5,
		Rarity = "Rare",
		RarityValue = 3,

		BaseReward = 75,
		RewardMultiplier = 3.0,

		SpeedMultiplier = 1.4, -- Very fast, goes far
		ArcHeight = 0.18, -- Sleek trajectory
		Stability = 0.85, -- Bit twitchy but rewarding

		DropChance = 3, -- 3% of drops
	},
	{
		ID = "Spaceship",
		Name = "🚀 Spaceship Tire",
		Index = 6,
		Rarity = "Legendary",
		RarityValue = 4,

		BaseReward = 200,
		RewardMultiplier = 5.0,

		SpeedMultiplier = 1.6, -- Incredibly fast
		ArcHeight = 0.35, -- High, dramatic arc
		Stability = 1.2, -- Perfectly stable

		DropChance = 2, -- 2% of drops (very rare)
	},
}

-- Lookup tables for quick access
TireConfig.ByID = {}
TireConfig.ByIndex = {}

for _, tier in ipairs(TireConfig.Tiers) do
	TireConfig.ByID[tier.ID] = tier
	TireConfig.ByIndex[tier.Index] = tier
end

-- Helper function: Get total drop chance (for normalization)
function TireConfig:GetTotalDropChance()
	local total = 0
	for _, tier in ipairs(self.Tiers) do
		total = total + tier.DropChance
	end
	return total
end

-- Helper function: Normalize drop chances to percentages
function TireConfig:GetNormalizedDropChances()
	local total = self:GetTotalDropChance()
	local normalized = {}

	for index, tier in ipairs(self.Tiers) do
		normalized[index] = (tier.DropChance / total) * 100
	end

	return normalized
end

-- Helper function: Get random tire by rarity
-- Returns a tier that was randomly selected based on drop chances
function TireConfig:GetRandomTire()
	local total = self:GetTotalDropChance()
	local random = math.random(1, total)
	local cumulative = 0

	for _, tier in ipairs(self.Tiers) do
		cumulative = cumulative + tier.DropChance
		if random <= cumulative then
			return tier
		end
	end

	-- Fallback (should never happen)
	return self.Tiers[1]
end

return TireConfig
