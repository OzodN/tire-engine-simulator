local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ui = playerGui:WaitForChild("MainUI")

local coinsLabel = ui:WaitForChild("CoinsLabel")
local tiresLabel = ui:WaitForChild("TiresLabel")

-- 🔥 ВРЕМЕННО (потом заменим на нормальную синхронизацию)
while true do
	task.wait(0.5)

	local data = player:FindFirstChild("Data")
	if data then
		local coins = data:FindFirstChild("Coins")
		if coins then
			coinsLabel.Text = "Coins: " .. coins.Value
		end

		local tires = data:FindFirstChild("Tires")
		if tires then
			tiresLabel.Text = "Tires: " .. tires.Value
		end
	end
end
