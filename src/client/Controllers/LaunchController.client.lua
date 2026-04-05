local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local launchRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("LaunchRequest")

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
