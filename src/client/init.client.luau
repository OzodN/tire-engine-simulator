local RunService = game:GetService("RunService")

local Parts = {}

local Speed = 2
local Amplitude = 3
local Frequency = 0.15
local BaseHeight = 10

local Folder = Instance.new("Folder")
Folder.Name = "WaveParts"
Folder.Parent = workspace

for X = 0, 20 do
	for Z = 0, 20 do
		local Part = Instance.new("Part")
		Part.Name = "P_" .. X .. "_" .. Z
		Part.Size = Vector3.new(1.8, 1, 1.8)
		Part.Anchored = true
		Part.Position = Vector3.new(X * 2, 5, Z * 2)
		Part.Parent = Folder

		table.insert(Parts, { Part = Part, X = X, Z = Z })
	end
end

local eTime = 0

RunService.PreRender:Connect(function(deltaTime: number)
	eTime += deltaTime

	for _, info in Parts do
		local Wave = math.sin(Frequency * info.X - Speed * eTime) + math.sin(Frequency * info.Z - Speed * eTime)

		info.Part.Position = Vector3.new(info.Part.Position.X, BaseHeight + Amplitude * Wave, info.Part.Position.Z)
	end
end)
