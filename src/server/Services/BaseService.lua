local BaseService = {}
BaseService.__index = BaseService

local SELL_RADIUS = 10

function BaseService:Init(services)
	self.PlayerService = services.PlayerService
	self.DataService = services.DataService
	self.TireService = services.TireService

	self.cooldowns = {}

	local Workspace = game:GetService("Workspace")
	self.BaseZone = Workspace:WaitForChild("BaseZone")

	self:StartChecking()
end

function BaseService:StartChecking()
	task.spawn(function()
		while true do
			task.wait(1)

			for _, player in pairs(game.Players:GetPlayers()) do
				self:CheckPlayer(player)
			end
		end
	end)
end

function BaseService:CheckPlayer(player)
	local character = player.Character
	if not character then
		return
	end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	local distance = (root.Position - self.BaseZone.Position).Magnitude

	if distance < SELL_RADIUS then
		self:SellTires(player)
	end
end

function BaseService:SellTires(player)
	if self.cooldowns[player] then
		return
	end

	self.cooldowns[player] = true

	task.delay(1, function()
		self.cooldowns[player] = nil
	end)

	local amount = self.PlayerService:DropTires(player)
	if amount <= 0 then
		return
	end

	local data = self.DataService:Get(player)

	local result = self.TireService:ProcessTires(player, amount)

	print(player.Name .. " processed tires:", result.coins)
	print("Coins:", data.Coins)
end

return BaseService
