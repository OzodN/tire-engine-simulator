--[[
	PlayerDataSchema - Versioned player data structure
	Supports migration between versions for backward compatibility
]]

local PlayerDataSchema = {}

-- CURRENT VERSION
PlayerDataSchema.CURRENT_VERSION = 1

-- Version 1.0 - Initial MVP schema
PlayerDataSchema.v1 = {
	Economy = {
		Coins = 0,
		Rebirths = 0,
		RebirthMultiplier = 1.0,
		TotalCoinsEarned = 0,
	},

	Inventory = {
		-- Each tire is stored with tier and modifier
		-- { { TierID = "Car", Modifier = "Gold", PickedUpAt = 12345 }, ... }
		Tires = {},
		CarryCapacity = 5,
	},

	Engines = {
		Owned = { "engine_toy" }, -- Default start engine
		Equipped = "engine_toy",
		Levels = { engine_toy = 1 },
		Fuel = { engine_toy = 0 },
	},

	Pets = {
		Owned = {}, -- { { petId = "pet_rat", level = 1 }, ... }
		Equipped = {},
	},

	Upgrades = {
		Power = 1, -- Launch power (will be replaced by engines in future)
		Carry = 1, -- Inventory carry capacity
	},

	Cosmetics = {
		PetSkins = {},
		EngineSkins = {},
	},

	Stats = {
		TotalLaunches = 0,
		TotalHits = 0,
		PerfectHits = 0,
		BossesDefeated = 0,
		TotalDistanceTraveled = 0,
	},

	Progress = {
		TutorialCompleted = false,
		FirstRebirthCompleted = false,
		ZonesUnlocked = { "outer_yard" },
		BossesDefeated = {},
	},
}

-- Create blank profile (default new player)
function PlayerDataSchema.CreateBlank()
	return {
		version = PlayerDataSchema.CURRENT_VERSION,
		createdAt = os.time(),
		lastUpdatedAt = os.time(),
		data = table.clone(PlayerDataSchema.v1),
	}
end

-- Migrate from old version to new version
function PlayerDataSchema.Migrate(oldProfile)
	if not oldProfile then
		return PlayerDataSchema.CreateBlank()
	end

	local version = oldProfile.version or 0

	-- Migration path: v0 → v1
	if version < 1 then
		local newProfile = PlayerDataSchema.CreateBlank()

		-- Copy over compatible data from old structure
		if oldProfile.Coins then
			newProfile.data.Economy.Coins = oldProfile.Coins
		end
		if oldProfile.Rebirths then
			newProfile.data.Economy.Rebirths = oldProfile.Rebirths
		end
		if oldProfile.Inventory and oldProfile.Inventory.Tires then
			newProfile.data.Inventory.Tires = oldProfile.Inventory.Tires
		end
		if oldProfile.Upgrades then
			if oldProfile.Upgrades.Power then
				newProfile.data.Upgrades.Power = oldProfile.Upgrades.Power
			end
			if oldProfile.Upgrades.Carry then
				newProfile.data.Upgrades.Carry = oldProfile.Upgrades.Carry
			end
		end

		newProfile.migratedFrom = version
		newProfile.lastUpdatedAt = os.time()
		return newProfile
	end

	return oldProfile
end

-- Validate profile structure
function PlayerDataSchema.Validate(profile)
	if not profile then
		return false, "Profile is nil"
	end

	if not profile.version or profile.version > PlayerDataSchema.CURRENT_VERSION then
		return false, "Invalid or future version"
	end

	if not profile.data then
		return false, "No data field"
	end

	return true, nil
end

return PlayerDataSchema
