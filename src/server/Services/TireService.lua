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

	local dataFolder = player:FindFirstChild("Data")
	if dataFolder then
		local _coins = dataFolder:FindFirstChild("Coins")
		if _coins then
			_coins.Value = data.Coins
		end
	end

	return {
		coins = reward,
	}
end

return TireService
