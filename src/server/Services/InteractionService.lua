local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InteractionService = {}
InteractionService.__index = InteractionService

function InteractionService:Init(services)
	self.PlayerService = services.PlayerService
	self.TireSpawnerService = services.TireSpawnerService
	self.DataService = services.DataService

	self:BindTires()
end

function InteractionService:BindTires()
	for _, tire in ipairs(Workspace:GetDescendants()) do
		if tire.Name == "Tire" then
			self:SetupTire(tire)
		end
	end

	-- Handle new tires spawning
	Workspace.DescendantAdded:Connect(function(obj)
		if obj.Name == "Tire" then
			self:SetupTire(obj)
		end
	end)
end

function InteractionService:SetupTire(tire)
	local prompt = tire:FindFirstChildOfClass("ProximityPrompt")
	if not prompt then
		return
	end

	prompt.Triggered:Connect(function(player)
		self:HandlePickup(player, tire)
	end)
end

function InteractionService:HandlePickup(player, tire)
	if not tire or not tire:IsDescendantOf(Workspace) then
		return
	end

	local character = player.Character
	if not character then
		return
	end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	local distance = (root.Position - tire.Position).Magnitude
	if distance > 20 then
		return
	end -- Anti-cheat

	-- Get tire data
	local tireData = self:GetTireDataFromPart(tire)
	if not tireData then
		warn("❌ Could not extract tire data from part")
		return
	end

	-- Add tire to inventory
	local success = self.DataService:AddTire(player, tireData)
	if not success then
		return
	end

	print(player.Name .. " picked up: " .. tireData.TierID .. " " .. tireData.Modifier)

	tire:Destroy()
end

-- Helper: Extract tire data from physical tire part
function InteractionService:GetTireDataFromPart(tirePart)
	if not tirePart then
		return nil
	end

	local dataValue = tirePart:FindFirstChild("TireData")
	if not dataValue or dataValue.ClassName ~= "StringValue" then
		return nil
	end

	local parts = string.split(dataValue.Value, "|")
	if #parts ~= 2 then
		return nil
	end

	return {
		TierID = parts[1],
		Modifier = parts[2],
	}
end

return InteractionService
