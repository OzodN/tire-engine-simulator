local EconomyConfig = require(game.ReplicatedStorage.Shared.Config.EconomyConfig)

local TireService = {}
TireService.__index = TireService

function TireService:Init(services)
	self.DataService = services.DataService
end

-- 🔥 ГЛАВНАЯ ТОЧКА РАСШИРЕНИЯ
function TireService:ProcessTires(player, amount)
	if amount <= 0 then
		return
	end

	local data = self.DataService:Get(player)

	local reward = amount * EconomyConfig.Tire.BaseReward

	data.Coins += reward

	return {
		coins = reward,
	}
end

return TireService
