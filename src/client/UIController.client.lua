local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local mainUI = playerGui:WaitForChild("MainUI")
local upgradeFrame = mainUI:WaitForChild("UpgradeFrame")

local coinsLabel = mainUI:WaitForChild("CoinsLabel")
local tiresLabel = mainUI:WaitForChild("TiresLabel")

local powerLabel = upgradeFrame:WaitForChild("PowerLabel")
local carryLabel = upgradeFrame:WaitForChild("CarryLabel")

local function bindData()
	local data = player:WaitForChild("Data")

	local coins = data:WaitForChild("Coins")
	local tires = data:WaitForChild("Tires")

	local power = data:WaitForChild("Upgrades"):WaitForChild("Power")
	local carry = data:WaitForChild("Upgrades"):WaitForChild("Carry")

	-- начальное значение
	coinsLabel.Text = "Coins: " .. coins.Value
	tiresLabel.Text = "Tires: " .. tires.Value
	powerLabel.Text = "Power: " .. power.Value
	carryLabel.Text = "Carry: " .. carry.Value

	-- 🔥 обновления
	coins:GetPropertyChangedSignal("Value"):Connect(function()
		coinsLabel.Text = "Coins: " .. coins.Value
	end)

	tires:GetPropertyChangedSignal("Value"):Connect(function()
		tiresLabel.Text = "Tires: " .. tires.Value
	end)

	power:GetPropertyChangedSignal("Value"):Connect(function()
		powerLabel.Text = "Power: " .. power.Value
	end)

	carry:GetPropertyChangedSignal("Value"):Connect(function()
		carryLabel.Text = "Carry: " .. carry.Value
	end)
end

bindData()
