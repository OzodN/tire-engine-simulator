local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local mainUI = playerGui:WaitForChild("MainUI")
local upgradeFrame = mainUI:WaitForChild("UpgradeFrame")

local coinsLabel = mainUI:WaitForChild("CoinsLabel")
local tiresLabel = mainUI:WaitForChild("TiresLabel")

local powerLabel = upgradeFrame:WaitForChild("PowerLabel")
local carryLabel = upgradeFrame:WaitForChild("CarryLabel")

local remotes = ReplicatedStorage.Remotes
local getInfoRemote = remotes:WaitForChild("GetUpgradeInfo")
local upgradeRemote = remotes:WaitForChild("UpgradeRequest")
local dataChangedEvent = remotes:WaitForChild("DataChanged")

-- Client-side data cache
local playerData = {
	coins = 0,
	tires = 0,
}

-- Update coins and tires labels
local function updateResourceLabels()
	coinsLabel.Text = "Coins: " .. playerData.coins
	tiresLabel.Text = "Tires: " .. playerData.tires
end

-- Update upgrade UI
local function updateUpgradeUI()
	local info = getInfoRemote:InvokeServer()
	if not info then
		warn("⚠️ GetUpgradeInfo returned nil!")
		return
	end

	local power = info.Power or {}
	local carry = info.Carry or {}

	-- Power
	powerLabel.Text = string.format(
		"Power Lv.%d → %d\n+%d | Cost: %d",
		power.level or 0,
		(power.level or 0) + 1,
		(power.nextValue or 0) - (power.value or 0),
		power.cost or 0
	)

	-- Carry
	carryLabel.Text = string.format(
		"Carry Lv.%d → %d\n+%d | Cost: %d",
		carry.level or 0,
		(carry.level or 0) + 1,
		(carry.nextValue or 0) - (carry.value or 0),
		carry.cost or 0
	)

	-- Button affordability
	if playerData.coins < (power.cost or 0) then
		powerLabel.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	else
		powerLabel.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	end

	if playerData.coins < (carry.cost or 0) then
		carryLabel.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	else
		carryLabel.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	end
end

-- Слушаем обновления от сервера
dataChangedEvent.OnClientEvent:Connect(function(key, value)
	if key == "Coins" then
		playerData.coins = value
		coinsLabel.Text = "Coins: " .. playerData.coins
		-- Пересчитаем стоимость кнопок и их доступность
		updateUpgradeUI()
	elseif key == "Tires" then
		playerData.tires = value
		tiresLabel.Text = "Tires: " .. playerData.tires
	end
end)

-- Initial setup
local function setupUI()
	updateResourceLabels()
	updateUpgradeUI()
end

-- Upgrade button handlers
upgradeFrame.PowerUp.MouseButton1Click:Connect(function()
	upgradeRemote:FireServer("Power")
	task.wait(0.5)  -- Даём серверу время обработать запрос
	updateUpgradeUI()
end)

upgradeFrame.CarryUp.MouseButton1Click:Connect(function()
	upgradeRemote:FireServer("Carry")
	task.wait(0.5)  -- Даём серверу время обработать запрос
	updateUpgradeUI()
end)

-- Polling for upgrade UI updates
task.spawn(function()
	while true do
		task.wait(0.5)
		updateUpgradeUI()
	end
end)

setupUI()
