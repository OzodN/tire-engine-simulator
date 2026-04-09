local Workspace = game:GetService("Workspace")

local TargetService = {}
TargetService.__index = TargetService

function TargetService:Init()
	self.Targets = Workspace:WaitForChild("Targets")
end

function TargetService:GetHitTarget(position)
	for _, target in ipairs(self.Targets:GetChildren()) do
		local distance = (position - target.Position).Magnitude

		if distance < 5 then
			return target
		end
	end

	return nil
end

return TargetService
