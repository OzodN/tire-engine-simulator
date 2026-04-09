--[[
	EngineInit.client.lua - Waits for MainUI before loading EngineSelector
]]

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for MainUI to be created by UIController
local mainUI = playerGui:WaitForChild("MainUI")
task.wait(0.1)

-- Load EngineSelector
local EngineSelector = require(script.Parent:WaitForChild("EngineSelector"))
EngineSelector:Init()

print("✅ Engine system loaded")
