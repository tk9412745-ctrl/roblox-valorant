-- SettingsController: ESC menu z crosshair customizer + game settings
-- Settings persisted via SaveSettings remote → PlayerData

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local SettingsController = {}

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Default settings
local DEFAULT_SETTINGS = {
	crosshairColor = { 0, 255, 180 },
	crosshairThickness = 2,
	crosshairGap = 8,
	crosshairLineLength = 8,
	crosshairDot = true,
	crosshairOutline = false,
	sensitivity = 1.0,
	masterVolume = 0.7,
	musicVolume = 0.5,
	sfxVolume = 0.7,
	voiceVolume = 0.7,
	fov = 70,
	showFPS = false,
	colorBlindMode = "Normal",  -- Sprint 75
}

local ColorBlindPalette = require(ReplicatedStorage.Shared:WaitForChild("ColorBlindPalette"))

local settings = {}
for k, v in pairs(DEFAULT_SETTINGS) do
	if type(v) == "table" then settings[k] = { table.unpack(v) } else settings[k] = v end
end

local gui
local menuOpen = false
local previewCrosshair  -- live preview frame

-- ============================================================
-- LIVE CROSSHAIR APPLICATION
-- ============================================================
local function applyCrosshair()
	local hud = PlayerGui:FindFirstChild("HUD")
	if not hud then return end
	local crosshair = hud:FindFirstChild("Crosshair")
	if not crosshair then return end

	local color = Color3.fromRGB(settings.crosshairColor[1], settings.crosshairColor[2], settings.crosshairColor[3])

	for _, line in ipairs(crosshair:GetChildren()) do
		if line:IsA("Frame") then
			line.BackgroundColor3 = color
			if line.Name == "Top" or line.Name == "Bottom" then
				line.Size = UDim2.fromOffset(settings.crosshairThickness, settings.crosshairLineLength)
				local sign = line.Name == "Top" and -1 or 1
				line:SetAttribute("BaseOffsetY", sign * settings.crosshairGap)
				line:SetAttribute("BaseOffsetX", 0)
				line.Position = UDim2.new(0.5, 0, 0.5, sign * settings.crosshairGap)
			elseif line.Name == "Left" or line.Name == "Right" then
				line.Size = UDim2.fromOffset(settings.crosshairLineLength, settings.crosshairThickness)
				local sign = line.Name == "Left" and -1 or 1
				line:SetAttribute("BaseOffsetX", sign * settings.crosshairGap)
				line:SetAttribute("BaseOffsetY", 0)
				line.Position = UDim2.new(0.5, sign * settings.crosshairGap, 0.5, 0)
			elseif line.Name == "Dot" then
				line.Visible = settings.crosshairDot
				line.Size = UDim2.fromOffset(settings.crosshairThickness, settings.crosshairThickness)
			end
		end
	end
end

-- ============================================================
-- GUI BUILD
-- ============================================================
local function buildGui()
	gui = Instance.new("ScreenGui")
	gui.Name = "SettingsMenu"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Enabled = false
	gui.Parent = PlayerGui

	local backdrop = Instance.new("Frame")
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	backdrop.BackgroundTransparency = 0.4
	backdrop.BorderSizePixel = 0
	backdrop.Parent = gui

	local panel = Instance.new("Frame")
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.Size = UDim2.fromOffset(900, 560)
	panel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	panel.BorderSizePixel = 0
	panel.Parent = backdrop
	local pCorner = Instance.new("UICorner")
	pCorner.CornerRadius = UDim.new(0, 12)
	pCorner.Parent = panel

	-- Title
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 50)
	title.BackgroundTransparency = 1
	title.Text = "SETTINGS"
	title.TextColor3 = Color3.fromRGB(255, 100, 80)
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 28
	title.Parent = panel

	-- Left panel: settings list
	local settingsList = Instance.new("ScrollingFrame")
	settingsList.Name = "SettingsList"
	settingsList.Position = UDim2.fromOffset(20, 60)
	settingsList.Size = UDim2.fromOffset(500, 470)
	settingsList.BackgroundTransparency = 1
	settingsList.BorderSizePixel = 0
	settingsList.CanvasSize = UDim2.fromScale(0, 0)
	settingsList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	settingsList.ScrollBarThickness = 6
	settingsList.Parent = panel

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 12)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = settingsList

	-- Right panel: crosshair preview
	local previewPanel = Instance.new("Frame")
	previewPanel.Position = UDim2.fromOffset(540, 60)
	previewPanel.Size = UDim2.fromOffset(340, 340)
	previewPanel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	previewPanel.BorderSizePixel = 0
	previewPanel.Parent = panel
	local pvCorner = Instance.new("UICorner")
	pvCorner.CornerRadius = UDim.new(0, 8)
	pvCorner.Parent = previewPanel

	local previewLabel = Instance.new("TextLabel")
	previewLabel.Size = UDim2.new(1, 0, 0, 24)
	previewLabel.BackgroundTransparency = 1
	previewLabel.Text = "PREVIEW"
	previewLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
	previewLabel.Font = Enum.Font.GothamBold
	previewLabel.TextSize = 14
	previewLabel.Parent = previewPanel

	previewCrosshair = Instance.new("Frame")
	previewCrosshair.Name = "PreviewCrosshair"
	previewCrosshair.AnchorPoint = Vector2.new(0.5, 0.5)
	previewCrosshair.Position = UDim2.fromScale(0.5, 0.5)
	previewCrosshair.Size = UDim2.fromOffset(60, 60)
	previewCrosshair.BackgroundTransparency = 1
	previewCrosshair.Parent = previewPanel

	-- Build preview lines
	for _, side in ipairs({ "Top", "Bottom", "Left", "Right", "Dot" }) do
		local f = Instance.new("Frame")
		f.Name = side
		f.AnchorPoint = Vector2.new(0.5, 0.5)
		f.BackgroundColor3 = Color3.fromRGB(0, 255, 180)
		f.BorderSizePixel = 0
		f.Parent = previewCrosshair
	end

	local function updatePreview()
		local c = Color3.fromRGB(settings.crosshairColor[1], settings.crosshairColor[2], settings.crosshairColor[3])
		local th = settings.crosshairThickness
		local len = settings.crosshairLineLength
		local gap = settings.crosshairGap

		for _, child in ipairs(previewCrosshair:GetChildren()) do
			if child:IsA("Frame") then
				child.BackgroundColor3 = c
				if child.Name == "Top" then
					child.Size = UDim2.fromOffset(th, len)
					child.Position = UDim2.new(0.5, 0, 0.5, -gap)
				elseif child.Name == "Bottom" then
					child.Size = UDim2.fromOffset(th, len)
					child.Position = UDim2.new(0.5, 0, 0.5, gap)
				elseif child.Name == "Left" then
					child.Size = UDim2.fromOffset(len, th)
					child.Position = UDim2.new(0.5, -gap, 0.5, 0)
				elseif child.Name == "Right" then
					child.Size = UDim2.fromOffset(len, th)
					child.Position = UDim2.new(0.5, gap, 0.5, 0)
				elseif child.Name == "Dot" then
					child.Size = UDim2.fromOffset(th, th)
					child.Position = UDim2.fromScale(0.5, 0.5)
					child.Visible = settings.crosshairDot
				end
			end
		end
	end

	-- ============================================================
	-- SLIDER + COLOR + TOGGLE HELPERS
	-- ============================================================
	local function addSlider(name, min, max, step, currentValue, onChange)
		local container = Instance.new("Frame")
		container.Size = UDim2.new(1, 0, 0, 60)
		container.BackgroundTransparency = 1
		container.Parent = settingsList

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(0.5, 0, 0, 20)
		label.BackgroundTransparency = 1
		label.Text = name
		label.TextColor3 = Color3.fromRGB(200, 200, 220)
		label.Font = Enum.Font.GothamBold
		label.TextSize = 14
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = container

		local valueLbl = Instance.new("TextLabel")
		valueLbl.Size = UDim2.new(0.5, -10, 0, 20)
		valueLbl.Position = UDim2.fromScale(0.5, 0)
		valueLbl.BackgroundTransparency = 1
		valueLbl.Text = tostring(currentValue)
		valueLbl.TextColor3 = Color3.fromRGB(255, 220, 80)
		valueLbl.Font = Enum.Font.GothamBold
		valueLbl.TextSize = 14
		valueLbl.TextXAlignment = Enum.TextXAlignment.Right
		valueLbl.Parent = container

		-- Slider bar
		local barBg = Instance.new("Frame")
		barBg.Position = UDim2.fromOffset(0, 28)
		barBg.Size = UDim2.new(1, 0, 0, 8)
		barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
		barBg.BorderSizePixel = 0
		barBg.Parent = container
		local bbCorner = Instance.new("UICorner")
		bbCorner.CornerRadius = UDim.new(0, 4)
		bbCorner.Parent = barBg

		local barFill = Instance.new("Frame")
		barFill.Size = UDim2.fromScale((currentValue - min) / (max - min), 1)
		barFill.BackgroundColor3 = Color3.fromRGB(0, 200, 150)
		barFill.BorderSizePixel = 0
		barFill.Parent = barBg
		local bfCorner = Instance.new("UICorner")
		bfCorner.CornerRadius = UDim.new(0, 4)
		bfCorner.Parent = barFill

		-- Click handler
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.fromScale(1, 1)
		btn.BackgroundTransparency = 1
		btn.Text = ""
		btn.Parent = barBg

		local dragging = false
		local function updateValue(input)
			local relX = (input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X
			relX = math.clamp(relX, 0, 1)
			local newVal = min + relX * (max - min)
			if step then newVal = math.floor(newVal / step + 0.5) * step end
			newVal = math.clamp(newVal, min, max)
			barFill.Size = UDim2.fromScale((newVal - min) / (max - min), 1)
			valueLbl.Text = tostring(newVal)
			onChange(newVal)
			updatePreview()
			applyCrosshair()
		end

		btn.MouseButton1Down:Connect(function()
			dragging = true
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)
		btn.MouseMoved:Connect(function(x, y)
			if dragging then
				updateValue({ Position = Vector2.new(x, y) })
			end
		end)
		btn.MouseButton1Click:Connect(function()
			local pos = UserInputService:GetMouseLocation()
			updateValue({ Position = pos })
		end)
	end

	local function addToggle(name, currentValue, onChange)
		local container = Instance.new("Frame")
		container.Size = UDim2.new(1, 0, 0, 36)
		container.BackgroundTransparency = 1
		container.Parent = settingsList

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(0.7, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = name
		label.TextColor3 = Color3.fromRGB(200, 200, 220)
		label.Font = Enum.Font.GothamBold
		label.TextSize = 14
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = container

		local btn = Instance.new("TextButton")
		btn.AnchorPoint = Vector2.new(1, 0.5)
		btn.Position = UDim2.new(1, 0, 0.5, 0)
		btn.Size = UDim2.fromOffset(60, 28)
		btn.BackgroundColor3 = currentValue and Color3.fromRGB(0, 200, 150) or Color3.fromRGB(80, 80, 90)
		btn.BorderSizePixel = 0
		btn.Text = currentValue and "ON" or "OFF"
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 12
		btn.AutoButtonColor = false
		btn.Parent = container
		local bCorner = Instance.new("UICorner")
		bCorner.CornerRadius = UDim.new(0, 6)
		bCorner.Parent = btn

		btn.Activated:Connect(function()
			currentValue = not currentValue
			btn.Text = currentValue and "ON" or "OFF"
			btn.BackgroundColor3 = currentValue and Color3.fromRGB(0, 200, 150) or Color3.fromRGB(80, 80, 90)
			onChange(currentValue)
			updatePreview()
			applyCrosshair()
		end)
	end

	local function addColorPicker(name, currentColor, onChange)
		local container = Instance.new("Frame")
		container.Size = UDim2.new(1, 0, 0, 36)
		container.BackgroundTransparency = 1
		container.Parent = settingsList

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(0.5, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = name
		label.TextColor3 = Color3.fromRGB(200, 200, 220)
		label.Font = Enum.Font.GothamBold
		label.TextSize = 14
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = container

		-- Color buttons row
		local presets = {
			{ 0, 255, 180 },   -- cyan default
			{ 255, 255, 255 }, -- white
			{ 255, 60, 60 },   -- red
			{ 60, 255, 60 },   -- green
			{ 60, 60, 255 },   -- blue
			{ 255, 200, 80 },  -- gold
			{ 255, 60, 200 },  -- pink
		}
		for i, color in ipairs(presets) do
			local btn = Instance.new("TextButton")
			btn.AnchorPoint = Vector2.new(1, 0.5)
			btn.Position = UDim2.new(1, -(i - 1) * 30, 0.5, 0)
			btn.Size = UDim2.fromOffset(24, 24)
			btn.BackgroundColor3 = Color3.fromRGB(color[1], color[2], color[3])
			btn.BorderSizePixel = 0
			btn.Text = ""
			btn.Parent = container
			local bCorner = Instance.new("UICorner")
			bCorner.CornerRadius = UDim.new(0, 4)
			bCorner.Parent = btn
			btn.Activated:Connect(function()
				onChange(color)
				updatePreview()
				applyCrosshair()
			end)
		end
	end

	-- Build settings entries
	addColorPicker("Crosshair color", settings.crosshairColor, function(c)
		settings.crosshairColor = c
	end)
	addSlider("Crosshair thickness", 1, 6, 1, settings.crosshairThickness, function(v)
		settings.crosshairThickness = v
	end)
	addSlider("Crosshair gap", 0, 20, 1, settings.crosshairGap, function(v)
		settings.crosshairGap = v
	end)
	addSlider("Crosshair line length", 4, 20, 1, settings.crosshairLineLength, function(v)
		settings.crosshairLineLength = v
	end)
	addToggle("Center dot", settings.crosshairDot, function(v)
		settings.crosshairDot = v
	end)
	addSlider("Mouse sensitivity", 0.1, 3.0, 0.1, settings.sensitivity, function(v)
		settings.sensitivity = v
	end)
	addSlider("Master volume", 0, 1, 0.05, settings.masterVolume, function(v)
		settings.masterVolume = v
		game:GetService("SoundService").Volume = v
	end)
	addSlider("Field of view", 50, 90, 5, settings.fov, function(v)
		settings.fov = v
	end)
	addSlider("SFX volume", 0, 1, 0.05, settings.sfxVolume, function(v)
		settings.sfxVolume = v
	end)
	addSlider("Voice volume", 0, 1, 0.05, settings.voiceVolume, function(v)
		settings.voiceVolume = v
	end)
	-- Color blind mode cycle
	local function nextCBMode()
		local modes = ColorBlindPalette.GetAvailableModes()
		for i, m in ipairs(modes) do
			if m == settings.colorBlindMode then
				return modes[(i % #modes) + 1]
			end
		end
		return "Normal"
	end
	addToggle("Color blind: " .. settings.colorBlindMode, false, function()
		settings.colorBlindMode = nextCBMode()
		ColorBlindPalette.SetMode(settings.colorBlindMode)
	end)

	-- Save button
	local saveBtn = Instance.new("TextButton")
	saveBtn.AnchorPoint = Vector2.new(0.5, 1)
	saveBtn.Position = UDim2.new(0.5, 0, 1, -20)
	saveBtn.Size = UDim2.fromOffset(200, 42)
	saveBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 150)
	saveBtn.BorderSizePixel = 0
	saveBtn.Text = "SAVE & CLOSE"
	saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	saveBtn.Font = Enum.Font.GothamBlack
	saveBtn.TextSize = 16
	saveBtn.Parent = panel
	local sbCorner = Instance.new("UICorner")
	sbCorner.CornerRadius = UDim.new(0, 8)
	sbCorner.Parent = saveBtn

	saveBtn.Activated:Connect(function()
		Remotes.SaveSettings:FireServer(settings)
		gui.Enabled = false
		menuOpen = false
	end)

	updatePreview()
end

function SettingsController.GetSettings()
	return settings
end

function SettingsController.Start()
	buildGui()

	-- ESC toggles menu
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.Escape then
			menuOpen = not menuOpen
			gui.Enabled = menuOpen
		end
	end)

	-- Load settings from server on join
	Remotes.LoadSettings.OnClientEvent:Connect(function(savedSettings)
		if not savedSettings then return end
		for k, v in pairs(savedSettings) do
			if settings[k] ~= nil then
				settings[k] = v
			end
		end
		-- Apply color blind mode
		if settings.colorBlindMode then
			ColorBlindPalette.SetMode(settings.colorBlindMode)
		end
		applyCrosshair()
	end)
	-- Request initial settings load
	task.delay(2, function()
		Remotes.SaveSettings:FireServer(nil)  -- nil = request load
	end)

	-- Apply default crosshair
	task.delay(1, applyCrosshair)
end

return SettingsController
