local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local WeaponController = require(script.Parent:WaitForChild("WeaponController"))

local HUDController = {}

local gui
local ammoLabel
local healthLabel
local armorLabel
local crosshairFrame
local hitMarker
local crosshairLines = {}
local ultLabel
local roleLabel

local crosshairExpansion = 0  -- 0-12 pixels expansion from base
local hitFlashTime = 0

local function buildGui()
	gui = Instance.new("ScreenGui")
	gui.Name = "HUD"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = PlayerGui

	-- Bottom bar background
	local bottomBar = Instance.new("Frame")
	bottomBar.Name = "BottomBar"
	bottomBar.Size = UDim2.new(1, 0, 0, 100)
	bottomBar.Position = UDim2.new(0, 0, 1, -100)
	bottomBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	bottomBar.BackgroundTransparency = 0.7
	bottomBar.BorderSizePixel = 0
	bottomBar.Parent = gui

	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromRGB(20, 20, 30))
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(1, 0.5),
	})
	gradient.Rotation = 90
	gradient.Parent = bottomBar

	-- Ammo (bottom right)
	ammoLabel = Instance.new("TextLabel")
	ammoLabel.Name = "Ammo"
	ammoLabel.Size = UDim2.fromOffset(280, 80)
	ammoLabel.Position = UDim2.new(1, -300, 1, -90)
	ammoLabel.BackgroundTransparency = 1
	ammoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	ammoLabel.Font = Enum.Font.GothamBlack
	ammoLabel.TextSize = 42
	ammoLabel.TextXAlignment = Enum.TextXAlignment.Right
	ammoLabel.Text = "25 / 75"
	ammoLabel.TextStrokeTransparency = 0.5
	ammoLabel.Parent = gui

	-- Health (bottom left) — with bar
	local healthBg = Instance.new("Frame")
	healthBg.Name = "HealthBg"
	healthBg.Size = UDim2.fromOffset(280, 36)
	healthBg.Position = UDim2.new(0, 20, 1, -56)
	healthBg.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	healthBg.BackgroundTransparency = 0.3
	healthBg.BorderSizePixel = 0
	healthBg.Parent = gui
	local hpCorner = Instance.new("UICorner")
	hpCorner.CornerRadius = UDim.new(0, 4)
	hpCorner.Parent = healthBg

	local healthBar = Instance.new("Frame")
	healthBar.Name = "HealthBar"
	healthBar.Size = UDim2.fromScale(1, 1)
	healthBar.BackgroundColor3 = Color3.fromRGB(80, 220, 120)
	healthBar.BorderSizePixel = 0
	healthBar.Parent = healthBg
	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(0, 4)
	barCorner.Parent = healthBar

	healthLabel = Instance.new("TextLabel")
	healthLabel.Name = "HealthLabel"
	healthLabel.Size = UDim2.fromScale(1, 1)
	healthLabel.BackgroundTransparency = 1
	healthLabel.Text = "100"
	healthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	healthLabel.Font = Enum.Font.GothamBlack
	healthLabel.TextSize = 22
	healthLabel.TextXAlignment = Enum.TextXAlignment.Center
	healthLabel.TextStrokeTransparency = 0
	healthLabel.Parent = healthBg
	healthLabel:SetAttribute("HealthBar", true)

	-- Armor (above health) — separate bar
	local armorBg = Instance.new("Frame")
	armorBg.Name = "ArmorBg"
	armorBg.Size = UDim2.fromOffset(280, 12)
	armorBg.Position = UDim2.new(0, 20, 1, -72)
	armorBg.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	armorBg.BackgroundTransparency = 0.3
	armorBg.BorderSizePixel = 0
	armorBg.Parent = gui
	local armorCorner = Instance.new("UICorner")
	armorCorner.CornerRadius = UDim.new(0, 2)
	armorCorner.Parent = armorBg

	armorLabel = Instance.new("Frame")
	armorLabel.Name = "ArmorBar"
	armorLabel.Size = UDim2.fromScale(0, 1)
	armorLabel.BackgroundColor3 = Color3.fromRGB(150, 200, 255)
	armorLabel.BorderSizePixel = 0
	armorLabel.Parent = armorBg
	local armBarCorner = Instance.new("UICorner")
	armBarCorner.CornerRadius = UDim.new(0, 2)
	armBarCorner.Parent = armorLabel

	-- Ult label (bottom center)
	ultLabel = Instance.new("TextLabel")
	ultLabel.Name = "UltLabel"
	ultLabel.Size = UDim2.fromOffset(200, 30)
	ultLabel.Position = UDim2.new(0.5, -100, 1, -90)
	ultLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	ultLabel.BackgroundTransparency = 0.3
	ultLabel.TextColor3 = Color3.fromRGB(180, 100, 255)
	ultLabel.Font = Enum.Font.GothamBold
	ultLabel.TextSize = 18
	ultLabel.Text = "ULT 0 / 7"
	ultLabel.TextStrokeTransparency = 0.6
	ultLabel.Parent = gui
	local ultCorner = Instance.new("UICorner")
	ultCorner.CornerRadius = UDim.new(0, 4)
	ultCorner.Parent = ultLabel

	-- Agent role indicator (top left)
	roleLabel = Instance.new("TextLabel")
	roleLabel.Name = "Role"
	roleLabel.Size = UDim2.fromOffset(160, 28)
	roleLabel.Position = UDim2.fromOffset(20, 20)
	roleLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	roleLabel.BackgroundTransparency = 0.3
	roleLabel.TextColor3 = Color3.fromRGB(220, 220, 240)
	roleLabel.Font = Enum.Font.GothamBold
	roleLabel.TextSize = 14
	roleLabel.Text = "Select agent"
	roleLabel.Parent = gui
	local roleCorner = Instance.new("UICorner")
	roleCorner.CornerRadius = UDim.new(0, 4)
	roleCorner.Parent = roleLabel

	-- ====== CROSSHAIR ======
	crosshairFrame = Instance.new("Frame")
	crosshairFrame.Name = "Crosshair"
	crosshairFrame.Size = UDim2.fromOffset(40, 40)
	crosshairFrame.Position = UDim2.new(0.5, -20, 0.5, -20)
	crosshairFrame.BackgroundTransparency = 1
	crosshairFrame.Parent = gui

	local crossColor = Color3.fromRGB(0, 255, 180)
	local function makeLine(name, baseSize, baseOffset)
		local f = Instance.new("Frame")
		f.Name = name
		f.AnchorPoint = Vector2.new(0.5, 0.5)
		f.Size = baseSize
		f.Position = UDim2.new(0.5, baseOffset.X, 0.5, baseOffset.Y)
		f.BackgroundColor3 = crossColor
		f.BorderSizePixel = 0
		f:SetAttribute("BaseOffsetX", baseOffset.X)
		f:SetAttribute("BaseOffsetY", baseOffset.Y)
		f.Parent = crosshairFrame
		table.insert(crosshairLines, f)
		return f
	end

	-- 4 lines + center dot
	makeLine("Top", UDim2.fromOffset(2, 8), Vector2.new(0, -8))
	makeLine("Bottom", UDim2.fromOffset(2, 8), Vector2.new(0, 8))
	makeLine("Left", UDim2.fromOffset(8, 2), Vector2.new(-8, 0))
	makeLine("Right", UDim2.fromOffset(8, 2), Vector2.new(8, 0))
	local dot = Instance.new("Frame")
	dot.Name = "Dot"
	dot.AnchorPoint = Vector2.new(0.5, 0.5)
	dot.Size = UDim2.fromOffset(2, 2)
	dot.Position = UDim2.fromScale(0.5, 0.5)
	dot.BackgroundColor3 = crossColor
	dot.BorderSizePixel = 0
	dot.Parent = crosshairFrame

	-- ====== HIT MARKER (X shape) ======
	hitMarker = Instance.new("Frame")
	hitMarker.Name = "HitMarker"
	hitMarker.Size = UDim2.fromOffset(28, 28)
	hitMarker.Position = UDim2.new(0.5, -14, 0.5, -14)
	hitMarker.BackgroundTransparency = 1
	hitMarker.Visible = false
	hitMarker.Parent = gui
	for _, rot in ipairs({ 45, -45 }) do
		local f = Instance.new("Frame")
		f.Size = UDim2.fromOffset(2, 28)
		f.Position = UDim2.new(0.5, -1, 0, 0)
		f.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		f.BorderSizePixel = 0
		f.Rotation = rot
		f.Parent = hitMarker
	end
end

local function getHealth()
	local character = LocalPlayer.Character
	if not character then return 0, 100 end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return 0, 100 end
	return math.floor(humanoid.Health), humanoid.MaxHealth
end

local function expandCrosshair(amount)
	crosshairExpansion = math.min(crosshairExpansion + amount, 16)
end

local function updateCrosshair(dt)
	for _, line in ipairs(crosshairLines) do
		local baseX = line:GetAttribute("BaseOffsetX") or 0
		local baseY = line:GetAttribute("BaseOffsetY") or 0
		local newX = baseX + (baseX > 0 and crosshairExpansion or (baseX < 0 and -crosshairExpansion or 0))
		local newY = baseY + (baseY > 0 and crosshairExpansion or (baseY < 0 and -crosshairExpansion or 0))
		line.Position = UDim2.new(0.5, newX, 0.5, newY)
	end
	-- Decay
	crosshairExpansion *= math.max(0, 1 - dt * 5)
end

local function update(dt)
	if not gui then return end

	-- Ammo
	local mag, res, reloading = WeaponController.GetAmmo()
	if reloading then
		ammoLabel.Text = "RELOADING..."
		ammoLabel.TextColor3 = Color3.fromRGB(255, 180, 80)
	else
		ammoLabel.Text = string.format("%d / %d", mag, res)
		ammoLabel.TextColor3 = mag == 0 and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(255, 255, 255)
	end

	-- Health bar
	local hp, maxHp = getHealth()
	local hpBg = gui:FindFirstChild("HealthBg")
	if hpBg then
		local bar = hpBg:FindFirstChild("HealthBar")
		local lbl = hpBg:FindFirstChild("HealthLabel")
		if bar then
			bar:TweenSize(UDim2.fromScale(hp / maxHp, 1), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
			if hp < 30 then
				bar.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
			elseif hp < 70 then
				bar.BackgroundColor3 = Color3.fromRGB(255, 200, 80)
			else
				bar.BackgroundColor3 = Color3.fromRGB(80, 220, 120)
			end
		end
		if lbl then lbl.Text = tostring(hp) end
	end

	-- Armor bar — pull from character attribute (set by CombatService)
	local armorAttr = LocalPlayer:GetAttribute("ArmorHP") or 0
	local armorMaxAttr = LocalPlayer:GetAttribute("ArmorMax") or 50
	if armorLabel then
		armorLabel:TweenSize(UDim2.fromScale(armorAttr / armorMaxAttr, 1), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
	end

	-- Crosshair expansion (based on movement + firing — get state from WeaponController)
	local character = LocalPlayer.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			local moveDir = humanoid.MoveDirection.Magnitude
			if moveDir > 0.1 then
				expandCrosshair(dt * 30)
			end
		end
	end
	updateCrosshair(dt)

	-- Hit marker fade
	local lastHit = WeaponController.GetLastHit()
	if lastHit then
		local age = tick() - lastHit.time
		if age < 0.35 then
			hitMarker.Visible = true
			local alpha = 1 - (age / 0.35)
			for _, child in ipairs(hitMarker:GetChildren()) do
				if child:IsA("Frame") then
					child.BackgroundTransparency = 1 - alpha
					if lastHit.killed then
						child.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
					elseif lastHit.category == "Head" then
						child.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
					else
						child.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					end
				end
			end
		else
			hitMarker.Visible = false
		end
	end
end

function HUDController.ExpandCrosshair(amount)
	expandCrosshair(amount)
end

function HUDController.UpdateUltText(current, max, agent)
	if not ultLabel then return end
	ultLabel.Text = string.format("ULT %d / %d", current or 0, max or 7)
	if current and max and current >= max then
		ultLabel.TextColor3 = Color3.fromRGB(255, 200, 80)
		ultLabel.Text = "ULTIMATE READY (X)"
	else
		ultLabel.TextColor3 = Color3.fromRGB(180, 100, 255)
	end
	if roleLabel and agent then
		roleLabel.Text = agent
	end
end

function HUDController.Start()
	buildGui()
	RunService.Heartbeat:Connect(update)

	-- Listen to ult updates
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
	Remotes.UpdateUltPoints.OnClientEvent:Connect(function(current, max)
		HUDController.UpdateUltText(current, max, nil)
	end)
	Remotes.UpdateAbilityState.OnClientEvent:Connect(function(agent, charges, ultUsed)
		if agent and roleLabel then
			roleLabel.Text = agent
		end
	end)

	-- Crosshair expand on firing
	Remotes.WeaponFired.OnClientEvent:Connect(function(shooter, from, to)
		if shooter == LocalPlayer then
			HUDController.ExpandCrosshair(4)
		end
	end)
end

return HUDController
