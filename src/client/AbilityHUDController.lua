-- AbilityHUDController: HUD widget pokazujący 4 abilities (C/Q/E/X) + charges/ult ready

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local AbilityHUDController = {}

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local gui
local boxes = {}  -- [key] = { box, label, charges }
local KEYS = { "C", "Q", "E", "X" }
local ultMax = 7
local ultCurrent = 0

local function buildGui()
	gui = Instance.new("ScreenGui")
	gui.Name = "AbilityHUD"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = PlayerGui

	local container = Instance.new("Frame")
	container.AnchorPoint = Vector2.new(0.5, 1)
	container.Position = UDim2.new(0.5, 0, 1, -130)
	container.Size = UDim2.fromOffset(360, 80)
	container.BackgroundTransparency = 1
	container.Parent = gui

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Padding = UDim.new(0, 8)
	layout.Parent = container

	for _, key in ipairs(KEYS) do
		local box = Instance.new("Frame")
		box.Name = "Ability_" .. key
		box.Size = UDim2.fromOffset(72, 80)
		box.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
		box.BackgroundTransparency = 0.3
		box.BorderSizePixel = 0
		box.Parent = container
		local bCorner = Instance.new("UICorner")
		bCorner.CornerRadius = UDim.new(0, 6)
		bCorner.Parent = box

		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 2
		stroke.Color = Color3.fromRGB(80, 80, 100)
		stroke.Transparency = 0.5
		stroke.Parent = box

		-- Key label (large center)
		local keyLbl = Instance.new("TextLabel")
		keyLbl.Size = UDim2.fromScale(1, 0.6)
		keyLbl.Position = UDim2.fromScale(0, 0)
		keyLbl.BackgroundTransparency = 1
		keyLbl.Text = key
		keyLbl.TextColor3 = Color3.fromRGB(220, 220, 240)
		keyLbl.Font = Enum.Font.GothamBlack
		keyLbl.TextSize = 32
		keyLbl.Parent = box

		-- Charges/cost row
		local infoLbl = Instance.new("TextLabel")
		infoLbl.Name = "Info"
		infoLbl.Size = UDim2.fromScale(1, 0.35)
		infoLbl.Position = UDim2.fromScale(0, 0.6)
		infoLbl.BackgroundTransparency = 1
		infoLbl.Text = "—"
		infoLbl.TextColor3 = Color3.fromRGB(180, 180, 200)
		infoLbl.Font = Enum.Font.GothamBold
		infoLbl.TextSize = 12
		infoLbl.Parent = box

		boxes[key] = { box = box, keyLbl = keyLbl, infoLbl = infoLbl, stroke = stroke }
	end
end

local function refresh(agent, charges, ultUsed)
	for _, key in ipairs(KEYS) do
		local b = boxes[key]
		if not b then continue end

		local box = b.box
		local infoLbl = b.infoLbl
		local stroke = b.stroke
		local keyLbl = b.keyLbl

		if key == "X" then
			-- Ultimate
			if ultUsed then
				infoLbl.Text = "USED"
				infoLbl.TextColor3 = Color3.fromRGB(120, 120, 130)
				box.BackgroundColor3 = Color3.fromRGB(40, 30, 50)
				stroke.Color = Color3.fromRGB(80, 80, 100)
				keyLbl.TextColor3 = Color3.fromRGB(120, 120, 130)
			elseif ultCurrent >= ultMax then
				infoLbl.Text = "READY!"
				infoLbl.TextColor3 = Color3.fromRGB(255, 220, 80)
				box.BackgroundColor3 = Color3.fromRGB(80, 60, 100)
				stroke.Color = Color3.fromRGB(255, 215, 0)
				stroke.Transparency = 0
				keyLbl.TextColor3 = Color3.fromRGB(255, 215, 0)
			else
				infoLbl.Text = ultCurrent .. " / " .. ultMax
				infoLbl.TextColor3 = Color3.fromRGB(180, 100, 220)
				box.BackgroundColor3 = Color3.fromRGB(30, 25, 45)
				stroke.Color = Color3.fromRGB(180, 100, 220)
				stroke.Transparency = 0.5
				keyLbl.TextColor3 = Color3.fromRGB(180, 100, 220)
			end
		else
			-- Basic ability
			local count = (charges and charges[key]) or 0
			if count > 0 then
				infoLbl.Text = count .. (count > 1 and "x" or "")
				infoLbl.TextColor3 = Color3.fromRGB(80, 220, 120)
				box.BackgroundColor3 = Color3.fromRGB(30, 40, 35)
				stroke.Color = Color3.fromRGB(80, 220, 120)
				stroke.Transparency = 0.3
				keyLbl.TextColor3 = Color3.fromRGB(220, 240, 230)
			else
				infoLbl.Text = "—"
				infoLbl.TextColor3 = Color3.fromRGB(100, 100, 120)
				box.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
				stroke.Color = Color3.fromRGB(80, 80, 100)
				stroke.Transparency = 0.5
				keyLbl.TextColor3 = Color3.fromRGB(120, 120, 140)
			end
		end
	end
end

function AbilityHUDController.Start()
	buildGui()

	Remotes.UpdateAbilityState.OnClientEvent:Connect(function(agent, charges, ultUsed)
		refresh(agent, charges or {}, ultUsed or false)
	end)

	Remotes.UpdateUltPoints.OnClientEvent:Connect(function(current, max)
		ultCurrent = current or 0
		ultMax = max or 7
		refresh(nil, nil, false)
	end)
end

return AbilityHUDController
