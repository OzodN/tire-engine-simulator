--[[
	EngineSelector - UI for selecting engine type before launch
	Displays all 6 engines with their stats and current selection
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EngineConfig = require(ReplicatedStorage.Shared.Config.EngineConfig)

local EngineSelector = {}
EngineSelector.__index = EngineSelector

local STATE = {
	UI = nil,
	SelectedEngine = "Starter",
	IsVisible = false,
}

-- ======================
-- UI CREATION
-- ======================

function EngineSelector:CreateEngineUI()
	if STATE.UI then
		return STATE.UI
	end

	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	local mainUI = playerGui:WaitForChild("MainUI")

	-- Main frame
	local frame = Instance.new("Frame")
	frame.Name = "EngineSelector"
	frame.Size = UDim2.new(0, 400, 0, 500)
	frame.Position = UDim2.new(0.5, -200, 0.5, -250)
	frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	frame.BorderSizePixel = 0
	frame.Visible = false
	frame.ZIndex = 100
	frame.Parent = mainUI

	-- Corner radius
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = frame

	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 40)
	title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	title.BorderSizePixel = 0
	title.Font = Enum.Font.GothamBold
	title.TextSize = 18
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Text = "🔧 Select Engine"
	title.Parent = frame

	-- Scrolling frame for engines
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "EngineList"
	scrollFrame.Size = UDim2.new(1, -20, 1, -100)
	scrollFrame.Position = UDim2.new(0, 10, 0, 50)
	scrollFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	scrollFrame.BorderSizePixel = 0
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollFrame.ScrollBarThickness = 6
	scrollFrame.Parent = frame

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 8)
	listLayout.Parent = scrollFrame

	-- Store reference
	STATE.UI = {
		Frame = frame,
		ScrollFrame = scrollFrame,
		ListLayout = listLayout,
		Buttons = {},
	}

	return STATE.UI
end

function EngineSelector:CreateEngineButton(engine, ui)
	local button = Instance.new("TextButton")
	button.Name = engine.ID
	button.Size = UDim2.new(1, -12, 0, 70)
	button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	button.BorderSizePixel = 0
	button.Font = Enum.Font.Gotham
	button.TextSize = 14
	button.TextColor3 = Color3.fromRGB(200, 200, 200)
	button.Parent = ui.ScrollFrame

	-- Corner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = button

	-- Engine info text
	local infoText = string.format(
		"%s %s (Range: %d-%d)",
		engine.Emoji,
		engine.Name,
		engine.BaseRange,
		engine.BaseRange + (10 - 1) * engine.RangePerLevel
	)
	button.Text = infoText

	-- Store engine ID
	button:SetAttribute("EngineID", engine.ID)

	-- Click handler
	button.MouseButton1Click:Connect(function()
		self:SelectEngine(engine.ID)
	end)

	-- Hover effects
	button.MouseEnter:Connect(function()
		if STATE.SelectedEngine ~= engine.ID then
			button.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
		end
	end)

	button.MouseLeave:Connect(function()
		if STATE.SelectedEngine ~= engine.ID then
			button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		end
	end)

	ui.Buttons[engine.ID] = button
	return button
end

-- ======================
-- ENGINE SELECTION
-- ======================

function EngineSelector:SelectEngine(engineID)
	STATE.SelectedEngine = engineID

	-- Update button visuals
	local ui = STATE.UI
	for id, button in pairs(ui.Buttons) do
		if id == engineID then
			button.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
			button.TextColor3 = Color3.fromRGB(255, 255, 255)
		else
			button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
			button.TextColor3 = Color3.fromRGB(200, 200, 200)
		end
	end

	-- Send to server
	local selectRemote = ReplicatedStorage.Remotes:WaitForChild("SelectEngine")
	selectRemote:FireServer(engineID)

	print("✅ Selected engine:", engineID)
end

-- ======================
-- UI VISIBILITY
-- ======================

function EngineSelector:ShowEngineSelector()
	if not STATE.UI then
		self:CreateEngineUI()
	end

	-- Populate engines if not already done
	if next(STATE.UI.Buttons) == nil then
		local engines = EngineConfig:GetAllEngines()
		for _, engine in ipairs(engines) do
			self:CreateEngineButton(engine, STATE.UI)
		end

		-- Update canvas size
		STATE.UI.ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			STATE.UI.ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, STATE.UI.ListLayout.AbsoluteContentSize.Y)
		end)
	end

	STATE.UI.Frame.Visible = true
	STATE.IsVisible = true
end

function EngineSelector:HideEngineSelector()
	if STATE.UI then
		STATE.UI.Frame.Visible = false
		STATE.IsVisible = false
	end
end

function EngineSelector:ToggleEngineSelector()
	if STATE.IsVisible then
		self:HideEngineSelector()
	else
		self:ShowEngineSelector()
	end
end

-- ======================
-- INITIALIZATION
-- ======================

function EngineSelector:Init()
	-- Listen for show events
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	local showRemote = remotes:WaitForChild("ShowEngineSelector")

	showRemote.OnClientEvent:Connect(function()
		self:ShowEngineSelector()
	end)

	-- Close on ESC
	local UserInputService = game:GetService("UserInputService")
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end
		if input.KeyCode == Enum.KeyCode.Escape and STATE.IsVisible then
			self:HideEngineSelector()
		end
	end)

	print("✅ EngineSelector initialized")
end

return EngineSelector
