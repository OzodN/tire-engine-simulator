local Workspace = game:GetService("Workspace")

local CameraController = {}

local camera = Workspace.CurrentCamera

function CameraController:SetScriptable()
	camera.CameraType = Enum.CameraType.Scriptable
end

function CameraController:SetDefault()
	camera.CameraType = Enum.CameraType.Custom
end

function CameraController:Follow(position)
	camera.CFrame = camera.CFrame:Lerp(CFrame.new(position + Vector3.new(0, 10, 15), position), 0.1)
end

function CameraController:Get()
	return camera
end

return CameraController
