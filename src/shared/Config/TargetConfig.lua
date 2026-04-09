--[[
	TargetConfig - Defines all target positions in the game
	Targets are ordered by distance from LaunchPad
	Each target has a fixed position that never changes
]]

local TargetConfig = {
	-- Launch pad position (reference point)
	LaunchPadPosition = Vector3.new(0, 5, 0),
	
	-- All targets ordered by distance
	Targets = {
		{
			ID = 1,
			Name = "🎯 Target 1",
			Position = Vector3.new(0, 5, 20),
			Distance = 20,  -- Distance from LaunchPad
			Reward = 10,    -- Base reward for hitting this target
		},
		{
			ID = 2,
			Name = "🎯 Target 2",
			Position = Vector3.new(0, 5, 50),
			Distance = 50,
			Reward = 25,
		},
		{
			ID = 3,
			Name = "🎯 Target 3",
			Position = Vector3.new(0, 5, 100),
			Distance = 100,
			Reward = 50,
		},
		{
			ID = 4,
			Name = "🎯 Target 4",
			Position = Vector3.new(0, 5, 150),
			Distance = 150,
			Reward = 100,
		},
		{
			ID = 5,
			Name = "🎯 Target 5",
			Position = Vector3.new(0, 5, 200),
			Distance = 200,
			Reward = 150,
		},
	},
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

return TargetConfig
