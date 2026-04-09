local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LaunchConfig = require(ReplicatedStorage.Shared.Config.LaunchConfig)
local TireConfig = require(ReplicatedStorage.Shared.Config.TireConfig)
local TireDefinitions = require(ReplicatedStorage.Shared.Config.TireDefinitions)

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

	-- Calculate distance with tire multiplier
	local power = self.UpgradeService:GetValue(player, "Power")
	local baseDistance = power * 2
	local tireSpeedMultiplier = tierData.SpeedMultiplier
	local finalDistance = baseDistance * tireSpeedMultiplier

	-- Calculate final reward with accuracy scaling
	local accuracyMultiplier = 1.0 -- Will be computed based on actual launch

	-- Hit detection (simple version - can be expanded)
	local hitTarget = self.TargetService:GetHitTarget(Vector3.new(0, 0, -finalDistance))
	if hitTarget then
		accuracyMultiplier = 2.0 -- Bonus for hit
	end

	local reward = math.floor(baseReward * accuracyMultiplier)

	-- Add coins to player
	self.DataService:AddCoins(player, reward)

	-- Send result to client with tire-specific data
	self.ResultRemote:FireClient(player, "Perfect", power, finalDistance, {
		TireTierID = tireData.TierID,
		TireModifier = tireData.Modifier,
		TireSpeedMultiplier = tireSpeedMultiplier,
		TireArcHeight = tierData.ArcHeight,
		TireStability = tierData.Stability,
	})

	print(player.Name, "launched:", tierData.Name, modifierData.Name, "| Reward:", reward)
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
