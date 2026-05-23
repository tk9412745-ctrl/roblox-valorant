-- DamageIndicatorController: arc HUD pointing toward damage source

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local DamageIndicatorController = {}

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

local gui
local indicators = {}  -- active indicators

local function buildGui()
	gui = Instance.new("ScreenGui")
	gui.Name = "DamageIndicators"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = PlayerGui
end

local function showIndicator(sourcePosition, damage)
	if not gui then return end

	local character = LocalPlayer.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	-- Calculate angle from camera to damage source
	local toSource = (sourcePosition - hrp.Position)
	local camLook = camera.CFrame.LookVector
	local camRight = camera.CFrame.RightVector

	-- 2D angle in camera space
	local flatToSource = Vector3.new(toSource.X, 0, toSource.Z)
	local flatLook = Vector3.new(camLook.X, 0, camLook.Z).Unit
	local flatRight = Vector3.new(camRight.X, 0, camRight.Z).Unit

	if flatToSource.Magnitude < 0.1 then return end
	flatToSource = flatToSource.Unit

	local dotForward = flatToSource:Dot(flatLook)
	local dotRight = flatToSource:Dot(flatRight)
	local angle = math.atan2(dotRight, dotForward)  -- -π to π

	-- Spawn arc indicator at corresponding screen position
	local indicator = Instance.new("Frame")
	indicator.AnchorPoint = Vector2.new(0.5, 0.5)
	indicator.Size = UDim2.fromOffset(100, 12)
	indicator.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
	indicator.BorderSizePixel = 0
	indicator.Rotation = math.deg(angle)
	indicator.Parent = gui

	-- Position around center based on angle
	local distance = 130  -- pixels from center
	local screenX = math.sin(angle) * distance
	local screenY = -math.cos(angle) * distance
	indicator.Position = UDim2.new(0.5, screenX, 0.5, screenY)

	local indCorner = Instance.new("UICorner")
	indCorner.CornerRadius = UDim.new(0, 4)
	indCorner.Parent = indicator

	-- Add glow effect
	local glow = Instance.new("UIStroke")
	glow.Thickness = 2
	glow.Color = Color3.fromRGB(255, 200, 200)
	glow.Transparency = 0.4
	glow.Parent = indicator

	-- Fade out
	local intensity = math.min(1, damage / 50)
	indicator.BackgroundTransparency = 0
	TweenService:Create(indicator, TweenInfo.new(1.5), {
		BackgroundTransparency = 1,
	}):Play()
	TweenService:Create(glow, TweenInfo.new(1.5), {
		Transparency = 1,
	}):Play()

	Debris:AddItem(indicator, 1.7)
end

function DamageIndicatorController.Start()
	buildGui()

	Remotes.TookDamage.OnClientEvent:Connect(function(sourcePosition, damage)
		if typeof(sourcePosition) == "Vector3" then
			showIndicator(sourcePosition, damage or 25)
		end
	end)
end

return DamageIndicatorController
