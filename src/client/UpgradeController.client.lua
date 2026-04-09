local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local mainUI = playerGui:WaitForChild("MainUI")
local upgradeFrame = mainUI:WaitForChild("UpgradeFrame")

local powerLabel = upgradeFrame:WaitForChild("PowerLabel")
local carryLabel = upgradeFrame:WaitForChild("CarryLabel")

local powerButton = upgradeFrame:WaitForChild("PowerUp")
local carryButton = upgradeFrame:WaitForChild("CarryUp")

local upgradeRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("UpgradeRequest")
local getInfoRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("GetUpgradeInfo")

local data = player:WaitForChild("Data")
local coins = data:WaitForChild("Coins")

local function updateUI()
	local info = getInfoRemote:InvokeServer()

	local power = info.Power
	local carry = info.Carry

	-- Power
	powerLabel.Text = string.format(
		"Power Lv.%d → %d\n+%d | Cost: %d",
		power.level,
		power.level + 1,
		power.nextValue - power.value,
		power.cost
	)

	-- Carry
	carryLabel.Text = string.format(
		"Carry Lv.%d → %d\n+%d | Cost: %d",
		carry.level,
		carry.level + 1,
		carry.nextValue - carry.value,
		carry.cost
	)

	if coins.Value < power.cost then
		powerLabel.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	else
		powerLabel.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	end

	if coins.Value < carry.cost then
		carryLabel.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	else
		carryLabel.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	end
end

coins:GetPropertyChangedSignal("Value"):Connect(function()
	updateUI()
end)

-- 🔥 НАЖАТИЯ

powerButton.MouseButton1Click:Connect(function()
	upgradeRemote:FireServer("Power")
	updateUI()
end)

carryButton.MouseButton1Click:Connect(function()
	upgradeRemote:FireServer("Carry")
	updateUI()
end)

updateUI()
