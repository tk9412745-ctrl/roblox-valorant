-- RoundCounterController: 13 dots per team z light-up po wygranej rundzie (Valorant-style)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local RoundCounterController = {}

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local gui
local atkDots = {}  -- 13 frames for attacker wins
local defDots = {}  -- 13 frames for defender wins

local function buildGui()
	gui = Instance.new("ScreenGui")
	gui.Name = "RoundCounter"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = PlayerGui

	-- Attacker dots row (above score bar, left side)
	local atkRow = Instance.new("Frame")
	atkRow.AnchorPoint = Vector2.new(0.5, 0)
	atkRow.Position = UDim2.new(0.5, -110, 0, 80)
	atkRow.Size = UDim2.fromOffset(200, 10)
	atkRow.BackgroundTransparency = 1
	atkRow.Parent = gui

	local atkLayout = Instance.new("UIListLayout")
	atkLayout.FillDirection = Enum.FillDirection.Horizontal
	atkLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	atkLayout.Padding = UDim.new(0, 2)
	atkLayout.Parent = atkRow

	for i = 1, 13 do
		local dot = Instance.new("Frame")
		dot.LayoutOrder = 14 - i  -- reverse so rightmost = first round
		dot.Size = UDim2.fromOffset(12, 12)
		dot.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
		dot.BorderSizePixel = 0
		dot.Parent = atkRow
		local dCorner = Instance.new("UICorner")
		dCorner.CornerRadius = UDim.new(1, 0)
		dCorner.Parent = dot
		table.insert(atkDots, dot)
	end

	-- Defender dots row (above score bar, right side)
	local defRow = Instance.new("Frame")
	defRow.AnchorPoint = Vector2.new(0.5, 0)
	defRow.Position = UDim2.new(0.5, 110, 0, 80)
	defRow.Size = UDim2.fromOffset(200, 10)
	defRow.BackgroundTransparency = 1
	defRow.Parent = gui

	local defLayout = Instance.new("UIListLayout")
	defLayout.FillDirection = Enum.FillDirection.Horizontal
	defLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	defLayout.Padding = UDim.new(0, 2)
	defLayout.Parent = defRow

	for i = 1, 13 do
		local dot = Instance.new("Frame")
		dot.LayoutOrder = i
		dot.Size = UDim2.fromOffset(12, 12)
		dot.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
		dot.BorderSizePixel = 0
		dot.Parent = defRow
		local dCorner = Instance.new("UICorner")
		dCorner.CornerRadius = UDim.new(1, 0)
		dCorner.Parent = dot
		table.insert(defDots, dot)
	end
end

local function refresh(atkScore, defScore)
	for i, dot in ipairs(atkDots) do
		if i <= atkScore then
			dot.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
		else
			dot.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
		end
	end
	for i, dot in ipairs(defDots) do
		if i <= defScore then
			dot.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
		else
			dot.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
		end
	end
end

function RoundCounterController.Start()
	buildGui()

	Remotes.UpdateScore.OnClientEvent:Connect(function(atk, def)
		refresh(atk or 0, def or 0)
	end)
end

return RoundCounterController
