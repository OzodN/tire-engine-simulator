print("UpgradeController started")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local mainUI = playerGui:WaitForChild("MainUI")
local upgradeFrame = mainUI:WaitForChild("UpgradeFrame")

local powerButton = upgradeFrame:WaitForChild("PowerUp")
local carryButton = upgradeFrame:WaitForChild("CarryUp")

local upgradeRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("UpgradeRequest")

-- 🔥 НАЖАТИЯ

powerButton.MouseButton1Click:Connect(function()
	upgradeRemote:FireServer("Power")
end)

carryButton.MouseButton1Click:Connect(function()
	upgradeRemote:FireServer("Carry")
end)
