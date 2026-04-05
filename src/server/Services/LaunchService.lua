local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LaunchConfig = require(ReplicatedStorage.Shared.Config.LaunchConfig)

local LaunchService = {}
LaunchService.__index = LaunchService

-- зоны
local PERFECT_START = 0.45
local PERFECT_END = 0.55

local GOOD_START = 0.35
local GOOD_END = 0.65

function LaunchService:Init(services)
	self.DataService = services.DataService
	self.LaunchRemote = game.ReplicatedStorage.Remotes.LaunchRequest

	self.LaunchRemote.OnServerEvent:Connect(function(player, result, position)
		self:HandleLaunch(player, result, position)
	end)
end

function LaunchService:HandleLaunch(player, result, position)
	local data = self.DataService:Get(player)

	-- сервер пересчитывает
	local finalResult = self:Recalculate(position)

	local config = LaunchConfig.Results[finalResult]

	-- 🔥 сила запуска
	local power = config.power

	-- 🔥 дистанция (упрощённо)
	local distance = power * 2

	-- 🔥 награда
	local reward = math.floor(distance * config.multiplier)

	data.Coins += reward

	--временно для синхронизации монет после запуска, потом вынести в утилиту и юзать везде
	local dataFolder = player:FindFirstChild("Data")
	if dataFolder then
		local _coins = dataFolder:FindFirstChild("Coins")
		if _coins then
			_coins.Value = data.Coins
		end
	end

	print(player.Name .. " launch:", finalResult)
	print("Power:", power)
	print("Distance:", distance)
	print("Reward:", reward)
end

function LaunchService:Recalculate(position)
	if position >= PERFECT_START and position <= PERFECT_END then
		return "Perfect"
	elseif position >= GOOD_START and position <= GOOD_END then
		return "Good"
	end

	return "Miss"
end

return LaunchService
