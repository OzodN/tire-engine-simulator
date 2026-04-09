--[[
	EngineConfig - 6 engine types with progression stats
	Each engine has:
	- Base stats (damage, speed, range)
	- Multipliers applied at each level
	- Visual/sound properties
]]

local EngineConfig = {
	-- 1️⃣ Starter Engine
	Starter = {
		ID = "Starter",
		Name = "🔧 Starter",
		Emoji = "🔧",
		Rarity = "Common",
		BaseRange = 50, -- Base distance in studs
		RangePerLevel = 5, -- +5 per level (50→100 at max)
		BaseDamage = 10,
		DamagePerLevel = 2,
		BaseFireRate = 1.0, -- seconds
		SpeedMultiplier = 1.0,
		BurstCount = 1, -- How many tires can be fired
	},

	-- 2️⃣ Standard Engine
	Standard = {
		ID = "Standard",
		Name = "⚙️ Standard",
		Emoji = "⚙️",
		Rarity = "Common",
		BaseRange = 75,
		RangePerLevel = 7.5,
		BaseDamage = 15,
		DamagePerLevel = 3,
		BaseFireRate = 0.8,
		SpeedMultiplier = 1.2,
		BurstCount = 1,
	},

	-- 3️⃣ Performance Engine
	Performance = {
		ID = "Performance",
		Name = "🏁 Performance",
		Emoji = "🏁",
		Rarity = "Uncommon",
		BaseRange = 100,
		RangePerLevel = 10,
		BaseDamage = 20,
		DamagePerLevel = 4,
		BaseFireRate = 0.6,
		SpeedMultiplier = 1.4,
		BurstCount = 2,
	},

	-- 4️⃣ Turbo Engine
	Turbo = {
		ID = "Turbo",
		Name = "💨 Turbo",
		Emoji = "💨",
		Rarity = "Rare",
		BaseRange = 125,
		RangePerLevel = 12.5,
		BaseDamage = 25,
		DamagePerLevel = 5,
		BaseFireRate = 0.5,
		SpeedMultiplier = 1.6,
		BurstCount = 2,
	},

	-- 5️⃣ Supercharged Engine
	Supercharged = {
		ID = "Supercharged",
		Name = "⚡ Supercharged",
		Emoji = "⚡",
		Rarity = "Epic",
		BaseRange = 150,
		RangePerLevel = 15,
		BaseDamage = 30,
		DamagePerLevel = 6,
		BaseFireRate = 0.4,
		SpeedMultiplier = 1.8,
		BurstCount = 3,
	},

	-- 6️⃣ Legendary Engine
	Legendary = {
		ID = "Legendary",
		Name = "🚀 Legendary",
		Emoji = "🚀",
		Rarity = "Legendary",
		BaseRange = 200,
		RangePerLevel = 20,
		BaseDamage = 40,
		DamagePerLevel = 8,
		BaseFireRate = 0.3,
		SpeedMultiplier = 2.0,
		BurstCount = 3,
	},
}

-- Index by ID for quick lookup
EngineConfig.ByID = {}
for engineName, config in pairs(EngineConfig) do
	if config.ID then
		EngineConfig.ByID[config.ID] = config
	end
end

-- Helper: Calculate range at specific level (1-10)
function EngineConfig:GetRangeAtLevel(engineID, level)
	local engine = self.ByID[engineID]
	if not engine then
		return 0
	end
	level = math.clamp(level or 1, 1, 10)
	return engine.BaseRange + (level - 1) * engine.RangePerLevel
end

-- Helper: Calculate damage at specific level
function EngineConfig:GetDamageAtLevel(engineID, level)
	local engine = self.ByID[engineID]
	if not engine then
		return 0
	end
	level = math.clamp(level or 1, 1, 10)
	return engine.BaseDamage + (level - 1) * engine.DamagePerLevel
end

-- Helper: Get all engines for UI
function EngineConfig:GetAllEngines()
	local engines = {}
	for name, config in pairs(self) do
		if config.ID then
			table.insert(engines, config)
		end
	end
	return engines
end

return EngineConfig
