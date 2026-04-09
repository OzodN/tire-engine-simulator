--[[
	InventoryController - UI for tire selection at launch pad
	
	Responsibilities:
	- Show list of collected tires
	- Handle tire selection
	- Display selected tire stats
	- Send selection to server for launch
]]

local InventoryController = {}
InventoryController.__index = InventoryController

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for Remotes folder
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local getTiresRemote = remotes:WaitForChild("GetPlayerTires")
local showInvRemote = remotes:WaitForChild("ShowInventory")
local selectTireRemote = remotes:WaitForChild("SelectTireToLaunch")

-- Config
local TireConfig = require(ReplicatedStorage.Shared.Config.TireConfig)
local TireDefinitions = require(ReplicatedStorage.Shared.Config.TireDefinitions)

-- State (must be defined before methods)
local STATE = {
	inventoryOpen = false,
	selectedTireIndex = nil,
	tires = {},
}

function InventoryController:Init()
	if not self.UI then
		self:CreateInventoryUI()
	end
	self:BindEvents()
end

-- ======================
-- UI CREATION
-- ======================

function InventoryController:CreateInventoryUI()
	-- MainUI должна быть создана UIController'ом перед этим вызовом
	local mainUI = playerGui:WaitForChild("MainUI", 5)  -- Wait up to 5 seconds
	if not mainUI then
		warn("❌ MainUI not found even after waiting!")
		return
	end

	-- Create InventoryFrame
	local inventoryFrame = Instance.new("Frame")
	inventoryFrame.Name = "InventoryFrame"
	inventoryFrame.Size = UDim2.new(0, 300, 0, 400)
	inventoryFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
	inventoryFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	inventoryFrame.BorderSizePixel = 0
	inventoryFrame.Visible = false
	inventoryFrame.ZIndex = 100
	inventoryFrame.Parent = mainUI

	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 40)
	title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	title.TextColor3 = Color3.new(1, 1, 1)
	title.TextSize = 20
	title.Font = Enum.Font.GothamBold
	title.Text = "🛞 Select Tire"
	title.BorderSizePixel = 0
	title.Parent = inventoryFrame

	-- List container (scrollable)
	local listContainer = Instance.new("ScrollingFrame")
	listContainer.Name = "ListContainer"
	listContainer.Size = UDim2.new(1, -10, 1, -110)
	listContainer.Position = UDim2.new(0, 5, 0, 50)
	listContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	listContainer.BorderSizePixel = 1
	listContainer.BorderColor3 = Color3.fromRGB(100, 100, 100)
	listContainer.ScrollBarThickness = 8
	listContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
	listContainer.Parent = inventoryFrame

	local layoutList = Instance.new("UIListLayout")
	layoutList.Padding = UDim.new(0, 5)
	layoutList.FillDirection = Enum.FillDirection.Vertical
	layoutList.SortOrder = Enum.SortOrder.LayoutOrder
	layoutList.Parent = listContainer

	-- Launch button
	local launchBtn = Instance.new("TextButton")
	launchBtn.Name = "LaunchButton"
	launchBtn.Size = UDim2.new(1, -10, 0, 40)
	launchBtn.Position = UDim2.new(0, 5, 1, -50)
	launchBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	launchBtn.TextColor3 = Color3.new(1, 1, 1)
	launchBtn.TextSize = 16
	launchBtn.Font = Enum.Font.GothamBold
	launchBtn.Text = "🚀 Launch"
	launchBtn.BorderSizePixel = 0
	launchBtn.Parent = inventoryFrame

	-- Close button (X)
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseButton"
	closeBtn.Size = UDim2.new(0, 30, 0, 30)
	closeBtn.Position = UDim2.new(1, -35, 0, 5)
	closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	closeBtn.TextColor3 = Color3.new(1, 1, 1)
	closeBtn.TextSize = 18
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.Text = "×"
	closeBtn.BorderSizePixel = 0
	closeBtn.Parent = inventoryFrame

	-- Store UI elements
	self.UI = {
		Frame = inventoryFrame,
		ListContainer = listContainer,
		LaunchButton = launchBtn,
		CloseButton = closeBtn,
	}
end

-- ======================
-- INVENTORY MANAGEMENT
-- ======================

function InventoryController:RefreshInventoryList()
	-- Validate UI exists
	if not self.UI or not self.UI.ListContainer then
		warn("⚠️ UI not initialized")
		return
	end

	-- Get player's tires from server
	local tires = getTiresRemote:InvokeServer()
	if not tires then
		warn("⚠️ Failed to get tires from server")
		return
	end

	STATE.tires = tires

	-- Clear existing items
	for _, child in ipairs(self.UI.ListContainer:GetChildren()) do
		if child:IsA("GuiObject") and child.Name ~= "UIListLayout" then
			child:Destroy()
		end
	end

	-- Create tire buttons
	for index, tireData in ipairs(tires) do
		self:CreateTireButton(index, tireData)
	end

	-- Update canvas size
	local layoutList = self.UI.ListContainer:FindFirstChild("UIListLayout")
	if layoutList then
		layoutList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			self.UI.ListContainer.CanvasSize = UDim2.new(0, 0, 0, layoutList.AbsoluteContentSize.Y)
		end)
	end
end

function InventoryController:CreateTireButton(index, tireData)
	local tier = TireConfig.ByID[tireData.TierID]
	local modifier = TireDefinitions.ModifiersByID[tireData.Modifier]

	if not tier or not modifier then
		return
	end

	-- Button
	local btn = Instance.new("TextButton")
	btn.Name = "TireButton_" .. index
	btn.Size = UDim2.new(1, -10, 0, 50)
	btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.TextSize = 14
	btn.Font = Enum.Font.Gotham
	btn.Text = string.format("%s %s %s", tier.Emoji or "🛞", tier.Name, modifier.Emoji or "")
	btn.BorderSizePixel = 1
	btn.BorderColor3 = Color3.fromRGB(100, 100, 100)
	btn.Parent = self.UI.ListContainer

	-- Selection logic
	btn.MouseButton1Click:Connect(function()
		self:SelectTire(index, btn)
	end)

	-- Hover effect
	btn.MouseEnter:Connect(function()
		btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	end)

	btn.MouseLeave:Connect(function()
		if STATE.selectedTireIndex ~= index then
			btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		end
	end)
end

function InventoryController:SelectTire(index, btn)
	-- Deselect previous
	if STATE.selectedTireIndex then
		local prevBtn = self.UI.ListContainer:FindFirstChild("TireButton_" .. STATE.selectedTireIndex)
		if prevBtn then
			prevBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		end
	end

	-- Select new
	STATE.selectedTireIndex = index
	btn.BackgroundColor3 = Color3.fromRGB(0, 150, 150)
end

-- ======================
-- EVENTS & BINDINGS
-- ======================

function InventoryController:BindEvents()
	-- Validate UI exists
	if not self.UI then
		warn("⚠️ UI not created")
		return
	end

	-- Close button
	self.UI.CloseButton.MouseButton1Click:Connect(function()
		self:HideInventory()
	end)

	-- Launch button
	self.UI.LaunchButton.MouseButton1Click:Connect(function()
		if STATE.selectedTireIndex then
			self:LaunchTire(STATE.selectedTireIndex)
		else
			warn("⚠️ Select a tire first!")
		end
	end)

	-- ESC key to close
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end
		if input.KeyCode == Enum.KeyCode.Escape and STATE.inventoryOpen then
			self:HideInventory()
		end
	end)

	-- Server signal to show inventory
	showInvRemote.OnClientEvent:Connect(function()
		self:ShowInventory()
	end)
end

function InventoryController:ShowInventory()
	if STATE.inventoryOpen then
		return
	end

	STATE.inventoryOpen = true
	self:RefreshInventoryList()
	self.UI.Frame.Visible = true
end

function InventoryController:HideInventory()
	STATE.inventoryOpen = false
	STATE.selectedTireIndex = nil
	self.UI.Frame.Visible = false
end

function InventoryController:LaunchTire(tireIndex)
	if not STATE.tires[tireIndex] then
		warn("❌ Invalid tire index:", tireIndex)
		return
	end

	local tireData = STATE.tires[tireIndex]
	print("🚀 Launching Tire #" .. tireIndex .. ":", tireData.TierID, tireData.Modifier)

	-- Send to server for launch
	selectTireRemote:FireServer(tireIndex)

	self:HideInventory()
end

return InventoryController
