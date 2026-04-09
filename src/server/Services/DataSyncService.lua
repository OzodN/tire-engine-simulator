--[[
	DataSyncService - Синхронизация данных игрока с клиентом
	Отправляет Coins и Tires обновления когда они меняются на сервере
]]

local DataSyncService = {}
DataSyncService.__index = DataSyncService

local ReplicatedStorage = game:GetService("ReplicatedStorage")

function DataSyncService:Init(services)
	self.DataService = services.DataService

	-- Создаём RemoteEvent для синхронизации
	local remotes = ReplicatedStorage.Remotes
	if not remotes:FindFirstChild("DataChanged") then
		local dataChangedEvent = Instance.new("RemoteEvent")
		dataChangedEvent.Name = "DataChanged"
		dataChangedEvent.Parent = remotes
	end

	self.DataChangedEvent = remotes:WaitForChild("DataChanged")

	-- Слушаем изменения coins из DataService
	local Players = game:GetService("Players")

	Players.PlayerAdded:Connect(function(player)
		task.wait(0.5) -- Даём время загрузиться профилю

		-- Слушаем изменения coins
		self.DataService:OnChange(player, "CoinsChanged", function(_amount)
			local data = self.DataService:Get(player)
			if data then
				self.DataChangedEvent:FireClient(player, "Coins", data.Economy.Coins)
			end
		end)

		-- Слушаем изменения tires
		self.DataService:OnChange(player, "TiresChanged", function()
			local data = self.DataService:Get(player)
			if data then
				self.DataChangedEvent:FireClient(player, "Tires", #data.Inventory.Tires)
			end
		end)

		-- Слушаем rebirth
		self.DataService:OnChange(player, "Rebirth", function()
			local data = self.DataService:Get(player)
			if data then
				self.DataChangedEvent:FireClient(player, "Rebirth", data.Economy.Rebirths)
			end
		end)

		-- Отправляем начальные значения
		local data = self.DataService:Get(player)
		if data then
			self.DataChangedEvent:FireClient(player, "Coins", data.Economy.Coins)
			self.DataChangedEvent:FireClient(player, "Tires", #data.Inventory.Tires)
		end
	end)
end

return DataSyncService
