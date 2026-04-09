local BaseService = {}
BaseService.__index = BaseService

local SELL_RADIUS = 10

-- Sell cooldown: prevent spam selling
local sellCooldowns = {}
local SELL_COOLDOWN = 1.0

function BaseService:Init(services)
	self.PlayerService = services.PlayerService
	self.DataService = services.DataService
	self.TireService = services.TireService

	local Workspace = game:GetService("Workspace")
	self.BaseZone = Workspace:WaitForChild("BaseZone")

	self:StartChecking()
end

function BaseService:StartChecking()
	task.spawn(function()
		while true do
			task.wait(0.5)

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
		self:TrySellTires(player)
	end
end

function BaseService:TrySellTires(player)
	-- Rate limiting
	local now = tick()
	local lastSell = sellCooldowns[player.UserId]

	if lastSell and (now - lastSell) < SELL_COOLDOWN then
		return
	end

	sellCooldowns[player.UserId] = now

	local amount = self.PlayerService:DropTires(player)
	if amount <= 0 then
		return
	end

	local result = self.TireService:ProcessTires(player, amount)

	print(player.Name, "sold", amount, "tires for", result.coins, "coins")
end

return BaseService
