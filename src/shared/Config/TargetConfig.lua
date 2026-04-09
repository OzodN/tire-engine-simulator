--[[
	TargetConfig - Dynamically populated from Workspace/Targets
	Targets are scanned at runtime and ordered by distance
	InitTargets.server.lua populates this config on server start
]]

local TargetConfig = {
	-- Launch pad position (set by InitTargets)
	LaunchPadPosition = nil,
	
	-- All targets ordered by distance (populated at runtime)
	Targets = {},
}

-- Helper: Get target by ID
function TargetConfig:GetTargetByID(id)
	for _, target in ipairs(self.Targets) do
		if target.ID == id then
			return target
		end
	end
	return nil
end

-- Helper: Get all target positions
function TargetConfig:GetAllPositions()
	local positions = {}
	for _, target in ipairs(self.Targets) do
		table.insert(positions, target.Position)
	end
	return positions
end

-- Initialize targets from Workspace (called by InitTargets.server.lua)
function TargetConfig:Initialize(launchPadPosition, targetObjects)
	self.LaunchPadPosition = launchPadPosition
	self.Targets = {}
	
	local targetData = {}
	
	-- Scan all target objects and calculate distances
	for _, target in ipairs(targetObjects) do
		if target:IsA("BasePart") then
			local distance = (target.Position - launchPadPosition).Magnitude
			table.insert(targetData, {
				Object = target,
				Position = target.Position,
				Distance = distance,
				Name = target.Name,
			})
		end
	end
	
	-- Sort by distance
	table.sort(targetData, function(a, b)
		return a.Distance < b.Distance
	end)
	
	-- Assign IDs and populate Targets
	for id, data in ipairs(targetData) do
		local reward = 10 + (id - 1) * 25  -- Escalating rewards
		table.insert(self.Targets, {
			ID = id,
			Name = data.Name,
			Position = data.Position,
			Distance = math.round(data.Distance),
			Reward = reward,
		})
	end
	
	print("✅ TargetConfig initialized with " .. #self.Targets .. " targets")
end

return TargetConfig
