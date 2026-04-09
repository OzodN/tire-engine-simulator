--[[
	LaunchCalculator - Extensible distance calculation system
	
	Calculates effective firing range based on multiple factors:
	- Engine type & level
	- Tire type & modifier  
	- Power level & accuracy
	- Player boosts & multipliers
	
	Architecture allows easy addition of new multiplier sources
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EngineConfig = require(ReplicatedStorage.Shared.Config.EngineConfig)
local TireConfig = require(ReplicatedStorage.Shared.Config.TireConfig)
local TireDefinitions = require(ReplicatedStorage.Shared.Config.TireDefinitions)

local LaunchCalculator = {}

-- ======================
-- DISTANCE CALCULATION
-- ======================

--[[
	Calculate effective firing distance
	
	Distance = BaseEngineRange × EngineMultiplier × TireMultiplier × PowerMultiplier × AccuracyMultiplier × Boosts
	
	This formula is extensible - add more multiplier sources as needed
]]
function LaunchCalculator:CalculateDistance(engineData, tireData, playerData, accuracyResult)
	-- Validate inputs
	if not engineData or not engineData.EngineID or not engineData.Level then
		warn("❌ Invalid engine data for distance calculation")
		return 0
	end
	
	if not tireData or not tireData.TierID or not tireData.Modifier then
		warn("❌ Invalid tire data for distance calculation")
		return 0
	end
	
	if not playerData then
		warn("❌ No player data for distance calculation")
		return 0
	end
	
	-- Get base range from engine
	local baseRange = EngineConfig:GetRangeAtLevel(engineData.EngineID, engineData.Level)
	if baseRange <= 0 then
		warn("❌ Invalid engine range")
		return 0
	end
	
	-- Calculate multipliers
	local engineMult = self:GetEngineMultiplier(engineData)          -- Engine level 1-10
	local tireMult = self:GetTireMultiplier(tireData)                -- Tire type + modifier
	local powerMult = self:GetPowerMultiplier(playerData.Power)      -- Power upgrade level
	local accuracyMult = self:GetAccuracyMultiplier(accuracyResult)  -- Perfect/Good/Miss
	local boostMult = self:GetBoostMultiplier(playerData)            -- Player boosts (extensible)
	
	-- Final calculation
	local distance = baseRange * engineMult * tireMult * powerMult * accuracyMult * boostMult
	
	return math.floor(distance)
end

-- ======================
-- MULTIPLIER FUNCTIONS
-- ======================

--[[
	Engine multiplier - based on level (1-10)
	Level 1 = 1.0x, Level 10 = 1.9x (scales to 2.0x at max)
]]
function LaunchCalculator:GetEngineMultiplier(engineData)
	local level = math.clamp(engineData.Level or 1, 1, 10)
	-- Linear scaling: 1.0 at L1, 1.9 at L10
	return 1.0 + (level - 1) * 0.1
end

--[[
	Tire multiplier - base speed × modifier bonus
	Example: 1.2 (car tire) × 1.5 (fire modifier) = 1.8x
]]
function LaunchCalculator:GetTireMultiplier(tireData)
	local tier = TireConfig.ByID[tireData.TierID]
	local modifier = TireDefinitions.ModifiersByID[tireData.Modifier]
	
	if not tier or not modifier then
		warn("❌ Invalid tire config for multiplier")
		return 1.0
	end
	
	local tierMult = tier.SpeedMultiplier or 1.0
	local modMult = modifier.RewardMultiplier or 1.0  -- Assuming modifier also has speed bonus
	
	-- Combine: tier speed × (1 + modifier bonus)
	return tierMult * (1 + (modMult - 1) * 0.5)
end

--[[
	Power multiplier - based on upgrade level (1-10)
	Level 1 = 1.0x, Level 10 = 2.0x
]]
function LaunchCalculator:GetPowerMultiplier(powerLevel)
	local level = math.clamp(powerLevel or 1, 1, 10)
	-- 0.1x per level starting from 1.0x
	return 1.0 + (level - 1) * 0.1
end

--[[
	Accuracy multiplier - affects distance based on timing result
	Perfect = 1.0x (full distance)
	Good = 0.9x (90% distance)
	Miss = 0.7x (70% distance)
]]
function LaunchCalculator:GetAccuracyMultiplier(accuracyResult)
	if accuracyResult == "Perfect" then
		return 1.0
	elseif accuracyResult == "Good" then
		return 0.9
	elseif accuracyResult == "Miss" then
		return 0.7
	end
	return 1.0
end

--[[
	Boost multiplier - extensible for future bonuses
	Examples: rebirth multiplier, event boosts, cosmetics, etc.
]]
function LaunchCalculator:GetBoostMultiplier(playerData)
	-- Start with base 1.0x
	local multiplier = 1.0
	
	-- Rebirth multiplier (if implemented)
	if playerData.Rebirths and playerData.Rebirths > 0 then
		multiplier = multiplier * (1.0 + playerData.Rebirths * 0.05)
	end
	
	-- Future: Add seasonal boosts, battle pass bonuses, etc.
	-- multiplier = multiplier * (seasonalBoost or 1.0)
	-- multiplier = multiplier * (battlePassBonus or 1.0)
	
	return multiplier
end

-- ======================
-- TARGET SELECTION
-- ======================

--[[
	Select target based on effective distance
	Priority: closest target that is WITHIN calculated distance
]]
function LaunchCalculator:SelectTarget(distance, launchPos, targetsFolder)
	if not targetsFolder then
		return nil
	end
	
	if distance <= 0 then
		return nil
	end
	
	local selectedTarget = nil
	local minDistance = distance  -- Only targets within range
	
	for _, target in ipairs(targetsFolder:GetChildren()) do
		if target:IsA("BasePart") then
			local distToTarget = (launchPos - target.Position).Magnitude
			
			-- Target is in range and closer than current selection
			if distToTarget <= distance and distToTarget < minDistance then
				minDistance = distToTarget
				selectedTarget = target
			end
		end
	end
	
	return selectedTarget
end

-- ======================
-- DEBUG
-- ======================

--[[
	Debug: Print distance breakdown
]]
function LaunchCalculator:PrintBreakdown(engineData, tireData, playerData, accuracyResult)
	local baseRange = EngineConfig:GetRangeAtLevel(engineData.EngineID, engineData.Level)
	local engineMult = self:GetEngineMultiplier(engineData)
	local tireMult = self:GetTireMultiplier(tireData)
	local powerMult = self:GetPowerMultiplier(playerData.Power)
	local accuracyMult = self:GetAccuracyMultiplier(accuracyResult)
	local boostMult = self:GetBoostMultiplier(playerData)
	
	print(string.format(
		"📏 Distance Breakdown:\n" ..
		"  Base: %.0f\n" ..
		"  Engine (Lv.%d): %.2f×\n" ..
		"  Tire: %.2f×\n" ..
		"  Power (Lv.%d): %.2f×\n" ..
		"  Accuracy (%s): %.2f×\n" ..
		"  Boosts: %.2f×\n" ..
		"  = %.0f studs",
		baseRange,
		engineData.Level or 1, engineMult,
		tireMult,
		playerData.Power or 1, powerMult,
		accuracyResult or "N/A", accuracyMult,
		boostMult,
		self:CalculateDistance(engineData, tireData, playerData, accuracyResult)
	))
end

return LaunchCalculator
