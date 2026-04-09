--[[
	TireDefinitions.lua
	
	Defines tire modifiers and loot generation tables.
	Each modifier adds special properties to a tire (visual effects, stat bonuses).
]]

local TireDefinitions = {}

-- Tire Modifiers (apply on top of base tire stats)
TireDefinitions.Modifiers = {
	{
		ID = "Normal",
		Name = "", -- No prefix for normal
		RewardMultiplier = 1.0,
		StatMultiplier = 1.0,
		DropChance = 65, -- Most common
		Color = Color3.fromRGB(100, 100, 100),
	},
	{
		ID = "Fire",
		Name = "🔥 Fire",
		RewardMultiplier = 1.2,
		StatMultiplier = 1.1, -- Slight speed boost
		DropChance = 15,
		Color = Color3.fromRGB(255, 100, 0),
	},
	{
		ID = "Ice",
		Name = "❄️ Ice",
		RewardMultiplier = 1.15,
		StatMultiplier = 1.15, -- Extra stability
		DropChance = 10,
		Color = Color3.fromRGB(100, 200, 255),
	},
	{
		ID = "Metal",
		Name = "⚙️ Metal",
		RewardMultiplier = 1.3,
		StatMultiplier = 1.25, -- Durable, goes far
		DropChance = 5,
		Color = Color3.fromRGB(200, 200, 200),
	},
	{
		ID = "Gold",
		Name = "✨ Gold",
		RewardMultiplier = 1.8,
		StatMultiplier = 1.4,
		DropChance = 3,
		Color = Color3.fromRGB(255, 215, 0),
	},
	{
		ID = "Glitch",
		Name = "🌀 Glitch",
		RewardMultiplier = 2.0, -- Unpredictable but very rewarding
		StatMultiplier = 1.5, -- Chaotic but high reward
		DropChance = 2,
		Color = Color3.fromRGB(150, 0, 255),
	},
}

-- Lookup table
TireDefinitions.ModifiersByID = {}
for _, modifier in ipairs(TireDefinitions.Modifiers) do
	TireDefinitions.ModifiersByID[modifier.ID] = modifier
end

-- Helper: Get total modifier drop chance
function TireDefinitions:GetTotalModifierChance()
	local total = 0
	for _, mod in ipairs(self.Modifiers) do
		total = total + mod.DropChance
	end
	return total
end

-- Helper: Get random modifier
function TireDefinitions:GetRandomModifier()
	local total = self:GetTotalModifierChance()
	local random = math.random(1, total)
	local cumulative = 0

	for _, modifier in ipairs(self.Modifiers) do
		cumulative = cumulative + modifier.DropChance
		if random <= cumulative then
			return modifier
		end
	end

	return self.Modifiers[1] -- Fallback
end

-- ===== LOOT TABLES =====
-- Defines spawn rates for different locations/contexts

-- Junkyard loot: respawning tires found in the environment
TireDefinitions.LootTables = {
	Junkyard = {
		-- Tier distribution (respawn locations)
		TierDistribution = {
			Toy = 45, -- 45% chance
			Car = 35, -- 35% chance
			Truck = 12, -- 12% chance
			Tractor = 5, -- 5% chance
			Aircraft = 2, -- 2% chance
			Spaceship = 1, -- 1% chance (ultra rare)
		},

		-- Spawn rate parameters
		SpawnRate = 3, -- New tire spawns every 3 seconds
		MaxTiresInWorld = 20, -- Never more than 20 tires active
		SpawnLocations = {
			-- These would be defined by actual spawn points in Workspace
			-- For now, just metadata
			GroupCount = 5, -- 5 spawn groups scattered in junkyard
		},
	},

	-- Boss drops (when defeating a boss)
	BossDrop = {
		TierDistribution = {
			Toy = 10,
			Car = 20,
			Truck = 30,
			Tractor = 20,
			Aircraft = 15,
			Spaceship = 5, -- Slightly higher chance from boss
		},
	},

	-- Rebirth reward
	RebirthReward = {
		TierDistribution = {
			Toy = 5,
			Car = 10,
			Truck = 20,
			Tractor = 25,
			Aircraft = 25,
			Spaceship = 15, -- Much higher for rebirth milestone
		},
	},
}

-- Helper: Generate a random tire from loot table
function TireDefinitions:GetRandomTireFromTable(tableName)
	local table = self.LootTables[tableName]
	if not table then
		return nil
	end

	local tierDist = table.TierDistribution
	local total = 0

	for _, chance in pairs(tierDist) do
		total = total + chance
	end

	local random = math.random(1, total)
	local cumulative = 0

	for tierID, chance in pairs(tierDist) do
		cumulative = cumulative + chance
		if random <= cumulative then
			return tierID -- Return tier ID, not full tier object
		end
	end

	return "Car" -- Fallback
end

-- Helper: Generate complete random tire (tier + modifier)
function TireDefinitions:GenerateRandomTire(tableName)
	tableName = tableName or "Junkyard"

	local tierID = self:GetRandomTireFromTable(tableName)
	local modifier = self:GetRandomModifier()

	return {
		TierID = tierID,
		Modifier = modifier.ID,
	}
end

return TireDefinitions
