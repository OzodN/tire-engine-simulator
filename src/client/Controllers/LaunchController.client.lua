local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local resultRemote = ReplicatedStorage.Remotes.LaunchResult

local dummy = Workspace:WaitForChild("LaunchDummy")

local launchRemote = ReplicatedStorage.Remotes.LaunchRequest

local isTiming = false
local position = 0
local speed = 2

-- зоны
local PERFECT_START = 0.45
local PERFECT_END = 0.55

local GOOD_START = 0.35
local GOOD_END = 0.65

-- запуск системы
function StartTiming()
	isTiming = true
	position = 0

	task.spawn(function()
		while isTiming do
			task.wait(0.016)
			position += 0.016 * speed

			if position > 1 then
				position = 0
			end

			print("Timing:", math.floor(position * 100))
		end
	end)
end

-- нажатие
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end

	if input.KeyCode == Enum.KeyCode.F then
		if not isTiming then
			StartTiming()
		else
			isTiming = false

			-- определяем результат
			local result = "Miss"

			if position >= PERFECT_START and position <= PERFECT_END then
				result = "Perfect"
			elseif position >= GOOD_START and position <= GOOD_END then
				result = "Good"
			end

			print("Result:", result)

			launchRemote:FireServer(result, position)
		end
	end
end)

-- обработка результата
resultRemote.OnClientEvent:Connect(function(result, power, distance)
	local camera = Workspace.CurrentCamera

	local startPos = dummy.Position
	local direction = Vector3.new(0, 0, -1)

	local duration = 1 -- время полёта
	local elapsed = 0

	local height = power * 0.3

	camera.CameraType = Enum.CameraType.Scriptable

	local connection
	connection = RunService.RenderStepped:Connect(function(dt)
		elapsed += dt

		local t = math.clamp(elapsed / duration, 0, 1)

		-- 🔥 ПАРАБОЛА (самое важное)
		local horizontal = startPos + direction * (distance * t)
		local vertical = height * 4 * t * (1 - t)

		local newPos = horizontal + Vector3.new(0, vertical, 0)
		dummy.Position = newPos

		-- 🎥 камера
		camera.CFrame = camera.CFrame:Lerp(CFrame.new(newPos + Vector3.new(0, 10, 15), newPos), 0.1)

		if t >= 1 then
			connection:Disconnect()
			camera.CameraType = Enum.CameraType.Custom
		end
	end)
end)
