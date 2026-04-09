--[[
	TargetSelector - Intelligent target selection based on launch range
	Algorithm:
	1. If LastSelectedTarget exists and Distance >= its.Distance → use it
	2. Otherwise, find closest target within range
]]

local TargetConfig = require(script.Parent.Parent.Config.TargetConfig)

local TargetSelector = {}

-- Select best target for launch
-- Returns: target (table) or nil if no valid target
function TargetSelector:SelectTarget(launchDistance, lastSelectedTargetID)
	local targets = TargetConfig.Targets
	
	-- If player has last selected target, try to use it
	if lastSelectedTargetID then
		local lastTarget = TargetConfig:GetTargetByID(lastSelectedTargetID)
		if lastTarget and launchDistance >= lastTarget.Distance then
			return lastTarget
		end
	end
	
	-- Find closest target within range
	local bestTarget = nil
	local smallestGap = math.huge
	
	for _, target in ipairs(targets) do
		if launchDistance >= target.Distance then
			-- This target is reachable
			-- Keep track of closest reachable target
			if target.Distance > (bestTarget and bestTarget.Distance or -1) then
				bestTarget = target
			end
		end
	end
	
	return bestTarget
end

-- Get target by ID (helper wrapper)
function TargetSelector:GetTargetByID(id)
	return TargetConfig:GetTargetByID(id)
end

-- Get all targets
function TargetSelector:GetAllTargets()
	return TargetConfig.Targets
end

return TargetSelector
