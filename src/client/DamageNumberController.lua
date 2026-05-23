-- DamageNumberController: floating damage numbers przy strzelaniu w enemies
-- Pojawiają się przy hit point i unoszą się w górę

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local DamageNumberController = {}

local LocalPlayer = Players.LocalPlayer

local function spawnDamageNumber(amount, category, killed)
	-- Spawn floating BillboardGui at character position
	local character = LocalPlayer.Character
	if not character then return end
	local camera = workspace.CurrentCamera

	-- Find target — raycast forward to find hit character
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local cameraCFrame = camera.CFrame
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = { character }
	params.FilterType = Enum.RaycastFilterType.Exclude
	local result = workspace:Raycast(cameraCFrame.Position, cameraCFrame.LookVector * 200, params)
	if not result then return end

	-- Spawn at hit position
	local anchor = Instance.new("Part")
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.Transparency = 1
	anchor.Size = Vector3.new(0.1, 0.1, 0.1)
	anchor.Position = result.Position + Vector3.new(0, 2, 0)
	anchor.Parent = workspace

	local bg = Instance.new("BillboardGui")
	bg.AlwaysOnTop = true
	bg.Size = UDim2.fromOffset(120, 40)
	bg.LightInfluence = 0
	bg.Parent = anchor

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.fromScale(1, 1)
	lbl.BackgroundTransparency = 1
	lbl.Text = tostring(math.floor(amount))
	lbl.Font = Enum.Font.GothamBlack
	lbl.TextSize = 32
	lbl.TextStrokeTransparency = 0
	lbl.Parent = bg

	-- Color based on category
	if killed then
		lbl.TextColor3 = Color3.fromRGB(255, 60, 60)
		lbl.Text = "KILLED"
		lbl.TextSize = 28
	elseif category == "Head" then
		lbl.TextColor3 = Color3.fromRGB(255, 220, 80)
		lbl.Text = math.floor(amount) .. " ★"
	elseif category == "Leg" then
		lbl.TextColor3 = Color3.fromRGB(180, 180, 200)
	else
		lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	end

	-- Float up + fade
	local startPos = anchor.Position
	local floatTween = TweenService:Create(anchor, TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = startPos + Vector3.new(0, 4, 0),
	})
	local fadeTween = TweenService:Create(lbl, TweenInfo.new(1.0, Enum.EasingStyle.Linear), {
		TextTransparency = 1,
		TextStrokeTransparency = 1,
	})
	floatTween:Play()
	fadeTween:Play()

	Debris:AddItem(anchor, 1.2)
end

function DamageNumberController.Start()
	Remotes.HitMarker.OnClientEvent:Connect(function(category, damage, killed)
		spawnDamageNumber(damage, category, killed)
	end)
end

return DamageNumberController
