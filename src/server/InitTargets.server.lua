--[[
	InitTargets.server.lua - Scans Workspace/Targets and initializes TargetConfig
	Runs once on server start before any services
]]

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for shared modules to be available
local TargetConfig = require(ReplicatedStorage.Shared.Config.TargetConfig)

-- Find LaunchPad
local function findLaunchPad()
	local launchArea = Workspace:FindFirstChild("LaunchArea")
	if not launchArea then
		warn("⚠️ LaunchArea not found in Workspace!")
		return nil
	end

	for _, obj in ipairs(launchArea:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name == "LaunchPad" then
			return obj
		end
	end

	warn("⚠️ LaunchPad not found in LaunchArea!")
	return nil
end

-- Find all target objects in Workspace/Targets
local function findTargets()
	local targetsFolder = Workspace:FindFirstChild("Targets")
	if not targetsFolder then
		warn("⚠️ Targets folder not found in Workspace!")
		return {}
	end

	local targets = {}
	for _, obj in ipairs(targetsFolder:GetChildren()) do
		if obj:IsA("BasePart") then
			table.insert(targets, obj)
		end
	end

	if #targets == 0 then
		warn("⚠️ No targets found in Workspace/Targets!")
	end

	return targets
end

-- Initialize targets
local launchPad = findLaunchPad()
if launchPad then
	local targets = findTargets()
	if #targets > 0 then
		TargetConfig:Initialize(launchPad.Position, targets)
		print("🎯 Target system ready! Targets:", #TargetConfig.Targets)
	else
		warn("⚠️ Failed to initialize targets - folder is empty")
	end
else
	warn("⚠️ Cannot initialize targets without LaunchPad")
end

-- Monitor for new targets added at runtime
local targetsFolder = Workspace:FindFirstChild("Targets")
if targetsFolder then
	targetsFolder.ChildAdded:Connect(function(newTarget)
		if newTarget:IsA("BasePart") then
			print("🆕 New target detected:", newTarget.Name)
			-- Reinitialize to pick up new target
			local launchPad = findLaunchPad()
			if launchPad then
				local allTargets = findTargets()
				TargetConfig:Initialize(launchPad.Position, allTargets)
			end
		end
	end)
end
