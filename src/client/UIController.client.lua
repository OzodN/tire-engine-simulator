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

-- Client-side data cache (listen to server updates)
local playerData = {
	coins = 0,
	tires = 0,
}

-- Update upgrade UI
local function updateUpgradeUI()
	local info = getInfoRemote:InvokeServer()
	if not info then
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

-- Initial setup
local function setupUI()
	updateUpgradeUI()
end

-- Upgrade button handlers
upgradeFrame.PowerUp.MouseButton1Click:Connect(function()
	upgradeRemote:FireServer("Power")
	task.wait(0.1) -- Brief delay for server processing
	updateUpgradeUI()
end)

upgradeFrame.CarryUp.MouseButton1Click:Connect(function()
	upgradeRemote:FireServer("Carry")
	task.wait(0.1)
	updateUpgradeUI()
end)

-- Listen for data updates from client-side events
-- For MVP: we'll use a polling system since ProfileService is server-only
-- In production, you'd implement proper client-server data sync
task.spawn(function()
	while true do
		task.wait(0.5)
		updateUpgradeUI()
	end
end)

setupUI()
