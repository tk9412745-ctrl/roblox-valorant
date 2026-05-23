-- ADSController: right-click to aim down sights / scope
-- For snipers (HasScope) shows fullscreen scope overlay
-- For ADS-capable weapons (HasADS) just zooms camera FOV

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
local WeaponDatabase = require(ReplicatedStorage.Shared:WaitForChild("WeaponDatabase"))

local ADSController = {}

local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

local ViewmodelController

local DEFAULT_FOV = 70
local currentFOV = DEFAULT_FOV
local targetFOV = DEFAULT_FOV
local isADSActive = false
local currentWeapon = "Vandal"
local scopeGui  -- ScreenGui for sniper scope

local function buildScopeUI()
	local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
	scopeGui = Instance.new("ScreenGui")
	scopeGui.Name = "ScopeOverlay"
	scopeGui.ResetOnSpawn = false
	scopeGui.IgnoreGuiInset = true
	scopeGui.Enabled = false
	scopeGui.Parent = PlayerGui

	-- Black corners (mask) — 4 quadrants
	for _, corner in ipairs({
		{ Anchor = Vector2.new(0, 0), Pos = UDim2.new(0, 0, 0, 0), Size = UDim2.new(0.5, -160, 0.5, -160) },     -- top-left
		{ Anchor = Vector2.new(1, 0), Pos = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0.5, -160, 0.5, -160) },     -- top-right
		{ Anchor = Vector2.new(0, 1), Pos = UDim2.new(0, 0, 1, 0), Size = UDim2.new(0.5, -160, 0.5, -160) },     -- bottom-left
		{ Anchor = Vector2.new(1, 1), Pos = UDim2.new(1, 0, 1, 0), Size = UDim2.new(0.5, -160, 0.5, -160) },     -- bottom-right
	}) do
		local f = Instance.new("Frame")
		f.AnchorPoint = corner.Anchor
		f.Position = corner.Pos
		f.Size = corner.Size
		f.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		f.BorderSizePixel = 0
		f.Parent = scopeGui
	end

	-- Top bar
	local topBar = Instance.new("Frame")
	topBar.AnchorPoint = Vector2.new(0.5, 0)
	topBar.Position = UDim2.fromScale(0.5, 0)
	topBar.Size = UDim2.new(0, 0, 0.5, -160)
	topBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	topBar.BorderSizePixel = 0
	-- (the corners already cover top sides; this is just visual cohesion)
	-- Skip; corners are enough

	-- Scope ring (circle)
	local ring = Instance.new("Frame")
	ring.AnchorPoint = Vector2.new(0.5, 0.5)
	ring.Position = UDim2.fromScale(0.5, 0.5)
	ring.Size = UDim2.fromOffset(320, 320)
	ring.BackgroundTransparency = 1
	ring.BorderSizePixel = 0
	ring.Parent = scopeGui

	local outerCircle = Instance.new("UICorner")
	outerCircle.CornerRadius = UDim.new(1, 0)
	outerCircle.Parent = ring

	local ringStroke = Instance.new("UIStroke")
	ringStroke.Thickness = 6
	ringStroke.Color = Color3.fromRGB(20, 20, 30)
	ringStroke.Transparency = 0
	ringStroke.Parent = ring

	-- Crosshair lines inside scope
	local function makeLine(name, size, pos)
		local l = Instance.new("Frame")
		l.AnchorPoint = Vector2.new(0.5, 0.5)
		l.Size = size
		l.Position = pos
		l.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
		l.BorderSizePixel = 0
		l.Parent = scopeGui
		return l
	end
	makeLine("HLine", UDim2.fromOffset(280, 1), UDim2.fromScale(0.5, 0.5))
	makeLine("VLine", UDim2.fromOffset(1, 280), UDim2.fromScale(0.5, 0.5))
	-- Center dot
	local dot = Instance.new("Frame")
	dot.AnchorPoint = Vector2.new(0.5, 0.5)
	dot.Size = UDim2.fromOffset(4, 4)
	dot.Position = UDim2.fromScale(0.5, 0.5)
	dot.BackgroundColor3 = Color3.fromRGB(200, 50, 30)
	dot.BorderSizePixel = 0
	dot.Parent = scopeGui
end

local function enterADS()
	if isADSActive then return end
	local w = WeaponDatabase[currentWeapon]
	if not w then return end
	if not w.HasADS and not w.HasScope then return end

	isADSActive = true
	if ViewmodelController then ViewmodelController.SetADS(true) end

	-- Server notification
	Remotes.SetADS:FireServer(true)

	-- FOV change
	if w.HasScope then
		-- Sniper: heavy zoom + scope overlay
		local zoom = type(w.ScopeZoom) == "table" and w.ScopeZoom[1] or (w.ScopeZoom or 2.5)
		targetFOV = DEFAULT_FOV / zoom
		if scopeGui then scopeGui.Enabled = true end
		-- Slow walk while scoped
		local character = LocalPlayer.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.WalkSpeed = humanoid.WalkSpeed * 0.5
			end
		end
		-- Hide viewmodel during scope
		if ViewmodelController then
			local vm = workspace.CurrentCamera:FindFirstChild("Viewmodel")
			if vm then
				for _, p in ipairs(vm:GetDescendants()) do
					if p:IsA("BasePart") then
						p.LocalTransparencyModifier = 1
					end
				end
			end
		end
	else
		-- ADS rifle (Guardian, Bulldog 3-burst, Phantom/Vandal etc)
		targetFOV = DEFAULT_FOV / (w.ADSZoom or 1.4)
		-- Slow walk while ADS
		local character = LocalPlayer.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.WalkSpeed = humanoid.WalkSpeed * 0.8
			end
		end
	end
end

local function exitADS()
	if not isADSActive then return end
	isADSActive = false
	if ViewmodelController then ViewmodelController.SetADS(false) end

	Remotes.SetADS:FireServer(false)

	targetFOV = DEFAULT_FOV
	if scopeGui then scopeGui.Enabled = false end

	-- Restore walkspeed
	local character = LocalPlayer.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = 16  -- base
		end
	end

	-- Restore viewmodel visibility
	local vm = workspace.CurrentCamera:FindFirstChild("Viewmodel")
	if vm then
		for _, p in ipairs(vm:GetDescendants()) do
			if p:IsA("BasePart") then
				p.LocalTransparencyModifier = 0
			end
		end
	end
end

function ADSController.SetCurrentWeapon(weaponName)
	if isADSActive then exitADS() end
	currentWeapon = weaponName
end

function ADSController.Start()
	-- Late-bind ViewmodelController
	local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts")
	ViewmodelController = require(PlayerScripts:WaitForChild("ViewmodelController"))

	buildScopeUI()

	-- Input: right-click toggle ADS (hold mode)
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			enterADS()
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			exitADS()
		end
	end)

	-- FOV interpolation
	RunService.RenderStepped:Connect(function(dt)
		currentFOV = currentFOV + (targetFOV - currentFOV) * math.min(dt * 12, 1)
		camera.FieldOfView = currentFOV
	end)

	-- Sync current weapon with WeaponController on buy
	Remotes.BuyResult.OnClientEvent:Connect(function(success, message)
		if success and message and message:find("^Bought ") then
			local weaponName = message:gsub("^Bought ", "")
			ADSController.SetCurrentWeapon(weaponName)
		end
	end)

	-- Reset on respawn
	LocalPlayer.CharacterAdded:Connect(function()
		exitADS()
	end)
end

return ADSController
