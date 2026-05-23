-- SpikeTimerHUDController: centered HUD widget showing spike countdown after plant

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local SpikeTimerHUDController = {}

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local gui
local timerLabel
local widget
local spikePlanted = false
local plantedAt = 0

local function buildGui()
	gui = Instance.new("ScreenGui")
	gui.Name = "SpikeTimerHUD"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = PlayerGui

	widget = Instance.new("Frame")
	widget.AnchorPoint = Vector2.new(0.5, 0)
	widget.Position = UDim2.new(0.5, 0, 0, 110)
	widget.Size = UDim2.fromOffset(180, 50)
	widget.BackgroundColor3 = Color3.fromRGB(100, 20, 20)
	widget.BackgroundTransparency = 0.2
	widget.BorderSizePixel = 0
	widget.Visible = false
	widget.Parent = gui
	local wCorner = Instance.new("UICorner")
	wCorner.CornerRadius = UDim.new(0, 8)
	wCorner.Parent = widget

	local stroke = Instance.new("UIStroke")
	stroke.Name = "Stroke"
	stroke.Thickness = 2
	stroke.Color = Color3.fromRGB(255, 80, 30)
	stroke.Parent = widget

	-- Spike icon (💣)
	local icon = Instance.new("TextLabel")
	icon.Size = UDim2.fromOffset(40, 50)
	icon.BackgroundTransparency = 1
	icon.Text = "💣"
	icon.TextColor3 = Color3.fromRGB(255, 80, 30)
	icon.Font = Enum.Font.GothamBlack
	icon.TextSize = 32
	icon.Parent = widget

	timerLabel = Instance.new("TextLabel")
	timerLabel.Position = UDim2.fromOffset(40, 0)
	timerLabel.Size = UDim2.new(1, -40, 1, 0)
	timerLabel.BackgroundTransparency = 1
	timerLabel.Text = "0.0"
	timerLabel.TextColor3 = Color3.fromRGB(255, 220, 80)
	timerLabel.Font = Enum.Font.GothamBlack
	timerLabel.TextSize = 32
	timerLabel.TextXAlignment = Enum.TextXAlignment.Center
	timerLabel.Parent = widget
end

local function update()
	if not spikePlanted or not widget then return end
	local elapsed = tick() - plantedAt
	local remaining = math.max(0, 45 - elapsed)
	if timerLabel then
		timerLabel.Text = string.format("%.1f", remaining)
		if remaining < 10 then
			timerLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
			-- Pulse widget background
			local pulse = math.abs(math.sin(tick() * 6))
			widget.BackgroundColor3 = Color3.fromRGB(150 + pulse * 50, 20, 20)
		else
			timerLabel.TextColor3 = Color3.fromRGB(255, 220, 80)
			widget.BackgroundColor3 = Color3.fromRGB(100, 20, 20)
		end
	end
end

function SpikeTimerHUDController.Start()
	buildGui()

	Remotes.SpikeStateChanged.OnClientEvent:Connect(function(newState)
		if newState == "Planted" then
			spikePlanted = true
			plantedAt = tick()
			if widget then widget.Visible = true end
		else
			spikePlanted = false
			if widget then widget.Visible = false end
		end
	end)

	RunService.Heartbeat:Connect(update)
end

return SpikeTimerHUDController
