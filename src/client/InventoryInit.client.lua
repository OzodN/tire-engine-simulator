--[[
	Inventory System Initializer
	Loads and initializes InventoryController when game starts
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InventoryController = require(script.Parent:WaitForChild("InventoryController"))

-- Wait for MainUI to be created by UIController
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainUI = playerGui:WaitForChild("MainUI")  -- Wait for UIController to create it

-- Now initialize
task.wait(0.1)  -- Small delay to ensure UI is ready
InventoryController:Init()

print("🛞 Inventory system loaded")
