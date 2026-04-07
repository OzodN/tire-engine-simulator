--// SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

--// OBJECTS
local dummy = Workspace:WaitForChild("LaunchDummy")

--// SOUNDS
local soundsFolder = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Sounds")

local Sounds = {
	Launch = soundsFolder:WaitForChild("Launch"),
	Impact = soundsFolder:WaitForChild("Impact"),
	Perfect = soundsFolder:WaitForChild("Perfect"),
}

local FXController = {}

-- 🔊 звук запуска
function FXController:PlayLaunch()
	Sounds.Launch:Play()
end

-- 💥 эффекты удара
function FXController:PlayImpact(result)
	Sounds.Impact:Play()

	if result == "Perfect" then
		Sounds.Perfect:Play()
	end

	-- частицы
	local particles = dummy:FindFirstChild("ImpactParticles")
	if particles then
		particles:Emit(30)
	end

	-- масштаб
	local originalSize = dummy.Size
	dummy.Size = originalSize * 1.3

	task.delay(0.1, function()
		dummy.Size = originalSize
	end)

	-- цвет
	if result == "Perfect" then
		dummy.Color = Color3.fromRGB(255, 215, 0)
	elseif result == "Good" then
		dummy.Color = Color3.fromRGB(0, 170, 255)
	else
		dummy.Color = Color3.fromRGB(150, 150, 150)
	end
end

-- 🎥 тряска камеры (временно тут, потом можно вынести)
function FXController:ShakeCamera(camera, intensity, duration)
	local start = tick()

	while tick() - start < duration do
		RunService.RenderStepped:Wait()

		local offset = Vector3.new(
			(math.random() - 0.5) * intensity,
			(math.random() - 0.5) * intensity,
			(math.random() - 0.5) * intensity
		)

		camera.CFrame *= CFrame.new(offset)
	end
end

return FXController
