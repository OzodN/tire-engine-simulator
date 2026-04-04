local InteractionService = {}
InteractionService.__index = InteractionService

function InteractionService:Init(services)
	self.PlayerService = services.PlayerService

	self:BindTires()
end

function InteractionService:BindTires()
	local Workspace = game:GetService("Workspace")

	for _, tire in ipairs(Workspace:GetDescendants()) do
		if tire.Name == "Tire" then
			self:SetupTire(tire)
		end
	end

	-- если будут новые появляться
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
	if not tire or not tire:IsDescendantOf(workspace) then
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
	if distance > 12 then
		return
	end -- анти-чит

	local success = self.PlayerService:AddTire(player)
	if not success then
		return
	end

	print(player.Name .. " picked tire")

	tire:Destroy()
end

return InteractionService
