local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LaunchConfig = require(ReplicatedStorage.Shared.Config.LaunchConfig)
local TireConfig = require(ReplicatedStorage.Shared.Config.TireConfig)
local TireDefinitions = require(ReplicatedStorage.Shared.Config.TireDefinitions)
local EngineConfig = require(ReplicatedStorage.Shared.Config.EngineConfig)
local LaunchCalculator = require(ReplicatedStorage.Shared.Modules.LaunchCalculator)
local TargetSelector = require(ReplicatedStorage.Shared.Modules.TargetSelector)

local LaunchService = {}
LaunchService.__index = LaunchService

-- Timing zones
local PERFECT_START = 0.45
local PERFECT_END = 0.55

local GOOD_START = 0.35
local GOOD_END = 0.65

-- Anti-spam: minimum time between launches (seconds)
local LAUNCH_COOLDOWN = 1.0

-- Rate limiting storage: { playerId: lastLaunchTime }
local launchCooldowns = {}

function LaunchService:Init(services)
	local remotes = ReplicatedStorage.Remotes

	self.DataService = services.DataService
	self.UpgradeService = services.UpgradeService
	self.TargetService = services.TargetService
	self.EngineService = services.EngineService
	self.LaunchRemote = remotes.LaunchRequest
	self.ResultRemote = remotes.LaunchResult

	self.LaunchRemote.OnServerEvent:Connect(function(player, result, position)
		self:HandleLaunch(player, result, position)
	end)
end

function LaunchService:ValidateLaunch(player)
	local now = tick()
	local lastLaunch = launchCooldowns[player.UserId]

	if lastLaunch and (now - lastLaunch) < LAUNCH_COOLDOWN then
		return false -- On cooldown
	end

	launchCooldowns[player.UserId] = now
	return true
end

-- New method: Launch specific tire with rewards
function LaunchService:HandleLaunchWithTire(player, tireData, baseReward)
	-- Rate limiting
	if not self:ValidateLaunch(player) then
		warn("Launch spam detected:", player.Name)
		return
	end

	-- Get tire stats
	local tierData = TireConfig.ByID[tireData.TierID]
	local modifierData = TireDefinitions.ModifiersByID[tireData.Modifier]

	if not tierData or not modifierData then
		warn("Invalid tire data in launch")
		return
	end

	-- Get player stats
	local playerData = self.DataService:Get(player)
	local powerLevel = self.UpgradeService:GetValue(player, "Power")
	local accuracyResult = "Perfect" -- TODO: Get from skill check when timing system added

	-- Get player's selected engine
	local selectedEngineID = self.EngineService:GetSelectedEngine(player)
	local engineData = {
		EngineID = selectedEngineID,
		Level = 1,  -- TODO: Add engine level progression
	}

	-- Calculate launch distance using LaunchCalculator
	local launchDistance = LaunchCalculator:CalculateDistance(
		engineData,
		tireData,
		{ Power = powerLevel },
		accuracyResult
	)

	-- Select best target based on distance
	local lastTargetID = playerData.LastSelectedTargetID
	local selectedTarget = TargetSelector:SelectTarget(launchDistance, lastTargetID)

	-- Remember this target for next launch
	if selectedTarget then
		local profile = self.DataService:GetRaw(player)
		if profile then
			profile.Data.data.LastSelectedTargetID = selectedTarget.ID
			profile:Reconcile()
		end
	end

	-- Calculate reward
	local reward = selectedTarget and selectedTarget.Reward or math.floor(baseReward * 0.5)
	self.DataService:AddCoins(player, reward)

	-- Send result to client with tire-specific data
	self.ResultRemote:FireClient(player, "Perfect", powerLevel, launchDistance, {
		TireTierID = tireData.TierID,
		TireModifier = tireData.Modifier,
		TireSpeedMultiplier = tierData.SpeedMultiplier,
		TireArcHeight = tierData.ArcHeight,
		TireStability = tierData.Stability,
		TargetID = selectedTarget and selectedTarget.ID or nil,
	})

	print(
		player.Name,
		"launched:",
		tierData.Name,
		modifierData.Name,
		"| Distance:",
		launchDistance,
		"| Reward:",
		reward
	)
end

-- Original method: Timing-based launch (from skill check)
function LaunchService:HandleLaunch(player, _result, position)
	-- Rate limiting & anti-cheat FIRST
	if not self:ValidateLaunch(player) then
		warn("Launch spam detected:", player.Name)
		return
	end

	-- Server-side validation: recalculate result from client input
	local finalResult = self:Recalculate(position)

	local config = LaunchConfig.Results[finalResult]

	local power = self.UpgradeService:GetValue(player, "Power")
	local distance = power * 2
	local reward = math.floor(distance * config.multiplier)

	-- Hit detection
	local hitTarget = self.TargetService:GetHitTarget(Vector3.new(0, 0, -distance))
	if hitTarget then
		reward *= 2
		print("🎯 HIT TARGET! BONUS x2")
	end

	-- Add reward to player profile (automatic save via DataService)
	self.DataService:AddCoins(player, reward)

	self.ResultRemote:FireClient(player, finalResult, power, distance)

	print(player.Name, "launch:", finalResult, "| Reward:", reward)
end

function LaunchService:Recalculate(position)
	if position >= PERFECT_START and position <= PERFECT_END then
		return "Perfect"
	elseif position >= GOOD_START and position <= GOOD_END then
		return "Good"
	end

	return "Miss"
end

return LaunchService
