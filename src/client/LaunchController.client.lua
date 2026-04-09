print("LaunchController started")

--// SERVICES
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

--// REMOTES
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local launchRemote = remotes:WaitForChild("LaunchRequest")
local resultRemote = remotes:WaitForChild("LaunchResult")

--// MODULES
local CameraController = require(script.Parent.Controllers.CameraController)
local FXController = require(script.Parent.FX.FXController)

--// OBJECTS
local dummy = Workspace:WaitForChild("LaunchDummy")

--// STATE
local isTiming = false
local position = 0

--// CONFIG
local SPEED = 2

local PERFECT_START = 0.45
local PERFECT_END = 0.55

local GOOD_START = 0.35
local GOOD_END = 0.65

-- ======================
-- TIMING
-- ======================

local function getTimingResult(pos)
	if pos >= PERFECT_START and pos <= PERFECT_END then
		return "Perfect"
	elseif pos >= GOOD_START and pos <= GOOD_END then
		return "Good"
	end

	return "Miss"
end

local function startTiming()
	isTiming = true
	position = 0

	task.spawn(function()
		while isTiming do
			task.wait(0.016)

			position += 0.016 * SPEED

			if position > 1 then
				position = 0
			end

			print("Timing:", math.floor(position * 100))
		end
	end)
end

-- ======================
-- INPUT
-- ======================

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end

	if input.KeyCode == Enum.KeyCode.F then
		if not isTiming then
			startTiming()
		else
			isTiming = false

			local result = getTimingResult(position)
			launchRemote:FireServer(result, position)
		end
	end
end)

-- ======================
-- LAUNCH
-- ======================

local function playLaunch(result, _power, distance, tireData)
	-- Apply tire physics if provided
	local arcHeightMultiplier = 1.0
	local stabilityMultiplier = 1.0

	if tireData then
		arcHeightMultiplier = tireData.TireArcHeight or 0.2
		stabilityMultiplier = tireData.TireStability or 1.0
	end

	local startPos = dummy.Position

	local duration = math.clamp(distance / 100, 0.5, 1.5)
	local elapsed = 0

	local targetsFolder = Workspace:WaitForChild("Targets")

	local function getClosestTarget()
		local closest = nil
		local minDist = math.huge

		for _, targetObj in ipairs(targetsFolder:GetChildren()) do
			local dist = (dummy.Position - targetObj.Position).Magnitude

			if dist < minDist then
				minDist = dist
				closest = targetObj
			end
		end

		return closest
	end

	local target = getClosestTarget()

	local direction

	if target then
		direction = (target.Position - dummy.Position).Unit
	else
		direction = Vector3.new(0, 0, -1)
	end

	-- Create a perpendicular basis for lateral deviation
	local perpendicular1 = (direction:Cross(Vector3.new(0, 1, 0))).Unit
	local perpendicular2 = (direction:Cross(perpendicular1)).Unit

	local distToTarget = (target.Position - startPos).Magnitude
	local height = distToTarget * arcHeightMultiplier -- Use tire arc height

	-- Calculate accuracy-based deviation magnitude
	local deviationMagnitude = 0
	if result == "Perfect" then
		deviationMagnitude = 0 -- Perfect hit, no deviation
	elseif result == "Good" then
		-- Good hit: small random deviation (±2-3 studs)
		deviationMagnitude = math.random(20, 30) / 10
	else -- Miss
		-- Miss: large random deviation (±5-8 studs)
		deviationMagnitude = math.random(50, 80) / 10
	end

	-- Apply tire stability to deviation (stable tires deviate less unpredictably)
	deviationMagnitude = deviationMagnitude / stabilityMultiplier

	-- Random lateral offsets
	local lateralOffset1 = (math.random(-100, 100) / 100) * perpendicular1 * deviationMagnitude
	local lateralOffset2 = (math.random(-100, 100) / 100) * perpendicular2 * deviationMagnitude

	-- anticipation
	dummy.Position -= Vector3.new(0, 0, 2)
	task.wait(0.05)
	dummy.Position += Vector3.new(0, 0, 2)

	FXController:PlayLaunch()
	CameraController:SetScriptable()

	local connection
	connection = RunService.RenderStepped:Connect(function(dt)
		elapsed += dt

		local t = math.clamp(elapsed / duration, 0, 1)

		local horizontal = startPos + direction * (distance * t) + lateralOffset1 + lateralOffset2
		local vertical = height * 4 * t * (1 - t)

		local newPos = horizontal + Vector3.new(0, vertical, 0)
		dummy.Position = newPos

		CameraController:Follow(newPos)

		-- 🔥 ПРОВЕРКА ПОПАДАНИЯ
		for _, target in ipairs(targetsFolder:GetChildren()) do
			local distanceToTarget = (dummy.Position - target.Position).Magnitude

			if distanceToTarget < 5 then
				print("🎯 HIT TARGET!")

				connection:Disconnect()

				FXController:PlayImpact("Perfect")

				task.spawn(function()
					local camera = CameraController:Get()
					FXController:ShakeCamera(camera, 2, 0.4)
				end)

				CameraController:SetDefault()
				return
			end
		end

		-- обычное завершение полёта
		if t >= 1 then
			connection:Disconnect()

			FXController:PlayImpact(result)

			task.spawn(function()
				local camera = CameraController:Get()

				if result == "Perfect" then
					FXController:ShakeCamera(camera, 1.5, 0.3)
				elseif result == "Good" then
					FXController:ShakeCamera(camera, 0.7, 0.2)
				else
					FXController:ShakeCamera(camera, 0.3, 0.1)
				end
			end)

			CameraController:SetDefault()
		end
	end)
end

-- ======================
-- SERVER RESPONSE
-- ======================

resultRemote.OnClientEvent:Connect(function(result, power, distance, tireData)
	playLaunch(result, power, distance, tireData)
end)
