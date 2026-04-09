local EconomyConfig = require(game.ReplicatedStorage.Shared.Config.EconomyConfig)

local TireService = {}
TireService.__index = TireService

function TireService:Init(services)
	self.DataService = services.DataService
end

-- Calculate reward from tire processing
function TireService:CalculateReward(player, amount)
	if amount <= 0 then
		return 0
	end

	local data = self.DataService:Get(player)
	if not data then
		return 0
	end

	local baseReward = amount * EconomyConfig.Tire.BaseReward
	local rebirthMultiplier = data.Economy.RebirthMultiplier or 1.0

	return math.floor(baseReward * rebirthMultiplier)
end

-- Process tires: sell them for coins
function TireService:ProcessTires(player, amount)
	if amount <= 0 then
		return { coins = 0 }
	end

	local reward = self:CalculateReward(player, amount)

	-- Add coins (auto-saves via DataService)
	self.DataService:AddCoins(player, reward)

	return {
		coins = reward,
		count = amount,
	}
end

return TireService
