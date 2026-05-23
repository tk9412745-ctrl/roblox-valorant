-- SkinEffectsController: tier-specific visual effects dla equipped skinów
-- Tier 3+: custom fire VFX (muzzle particles)
-- Tier 4+: kill banner UI popup
-- Tier 5: evolving form (color shifts per kill)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
local SkinDatabase = require(ReplicatedStorage.Shared:WaitForChild("SkinDatabase"))

local SkinEffectsController = {}

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local equippedSkins = {}  -- [weaponName] = skinData
local killsWithSkin = {}  -- [skinId] = count (for evolving form + counter)
local killBannerGui

-- ============================================================
-- KILL BANNER (Tier 4+)
-- ============================================================
local function buildKillBanner()
	killBannerGui = Instance.new("ScreenGui")
	killBannerGui.Name = "KillBanner"
	killBannerGui.ResetOnSpawn = false
	killBannerGui.IgnoreGuiInset = true
	killBannerGui.Parent = PlayerGui

	local banner = Instance.new("Frame")
	banner.Name = "Banner"
	banner.AnchorPoint = Vector2.new(0.5, 0)
	banner.Position = UDim2.new(0.5, 0, 0, 130)
	banner.Size = UDim2.fromOffset(400, 80)
	banner.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	banner.BackgroundTransparency = 1
	banner.BorderSizePixel = 0
	banner.Visible = false
	banner.Parent = killBannerGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = banner

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2
	stroke.Color = Color3.fromRGB(255, 215, 0)
	stroke.Transparency = 1
	stroke.Parent = banner

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0.5, 0)
	title.Position = UDim2.new(0, 0, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "ELIMINATED"
	title.TextColor3 = Color3.fromRGB(255, 200, 80)
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 28
	title.TextTransparency = 1
	title.Parent = banner

	local subtitle = Instance.new("TextLabel")
	subtitle.Name = "Subtitle"
	subtitle.Size = UDim2.new(1, 0, 0.5, 0)
	subtitle.Position = UDim2.new(0, 0, 0.5, 0)
	subtitle.BackgroundTransparency = 1
	subtitle.Text = ""
	subtitle.TextColor3 = Color3.fromRGB(220, 220, 240)
	subtitle.Font = Enum.Font.GothamBold
	subtitle.TextSize = 16
	subtitle.TextTransparency = 1
	subtitle.Parent = banner
end

local function showKillBanner(skinData, victimName, isHeadshot)
	if not killBannerGui then return end
	local banner = killBannerGui:FindFirstChild("Banner")
	if not banner then return end

	local title = banner:FindFirstChild("Title")
	local subtitle = banner:FindFirstChild("Subtitle")
	local stroke = banner:FindFirstChildOfClass("UIStroke")

	title.Text = (isHeadshot and "★ HEADSHOT KILL ★" or "ELIMINATED")
	subtitle.Text = (skinData.DisplayName or "?") .. " ▸ " .. (victimName or "?")
	banner.Visible = true

	-- Fade in
	banner.BackgroundTransparency = 0.4
	stroke.Transparency = 0
	title.TextTransparency = 0
	subtitle.TextTransparency = 0

	-- Pop animation
	banner.Size = UDim2.fromOffset(380, 80)
	TweenService:Create(banner, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
		Size = UDim2.fromOffset(420, 80),
	}):Play()

	-- Fade out after 2s
	task.delay(2, function()
		TweenService:Create(banner, TweenInfo.new(0.5), {
			BackgroundTransparency = 1,
		}):Play()
		TweenService:Create(stroke, TweenInfo.new(0.5), { Transparency = 1 }):Play()
		TweenService:Create(title, TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
		TweenService:Create(subtitle, TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
		task.wait(0.5)
		banner.Visible = false
	end)
end

-- ============================================================
-- FIRE VFX (Tier 3+) — muzzle particle on shot
-- ============================================================
local function spawnMuzzleFireVFX(barrelPosition, skinData)
	if not barrelPosition then return end
	if not skinData.HasFireVFX then return end

	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CastShadow = false
	part.Transparency = 1
	part.Size = Vector3.new(0.1, 0.1, 0.1)
	part.CFrame = CFrame.new(barrelPosition)
	part.Parent = Workspace

	local color = skinData.Color or Color3.fromRGB(255, 200, 50)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	emitter.Lifetime = NumberRange.new(0.15, 0.3)
	emitter.Rate = 0
	emitter.Speed = NumberRange.new(4, 10)
	emitter.SpreadAngle = Vector2.new(40, 40)
	emitter.Color = ColorSequence.new(color)
	emitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(1, 0),
	})
	emitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 1),
	})
	emitter.LightEmission = 0.9
	emitter.Parent = part
	emitter:Emit(15)

	Debris:AddItem(part, 0.5)
end

-- ============================================================
-- EVOLVING FORM (Tier 5) — color shift per kill
-- ============================================================
local EVOLVE_COLOR_STAGES = {
	Color3.fromRGB(80, 80, 100),     -- 0 kills
	Color3.fromRGB(180, 80, 40),     -- 5 kills
	Color3.fromRGB(220, 60, 20),     -- 10 kills
	Color3.fromRGB(255, 120, 0),     -- 25 kills
	Color3.fromRGB(255, 200, 0),     -- 50+ kills (golden)
}

local function evolvingColor(killCount)
	if killCount < 5 then return EVOLVE_COLOR_STAGES[1] end
	if killCount < 10 then return EVOLVE_COLOR_STAGES[2] end
	if killCount < 25 then return EVOLVE_COLOR_STAGES[3] end
	if killCount < 50 then return EVOLVE_COLOR_STAGES[4] end
	return EVOLVE_COLOR_STAGES[5]
end

-- ============================================================
-- WIRE UP
-- ============================================================
local function getEquippedSkin(weaponName)
	return equippedSkins[weaponName]
end

function SkinEffectsController.Start()
	buildKillBanner()

	-- Listen to skin equip events to track equipped skin
	Remotes.SkinEquipped.OnClientEvent:Connect(function(userId, weaponName, skinId)
		if userId == LocalPlayer.UserId then
			local skin = SkinDatabase.Get(skinId)
			if skin then equippedSkins[weaponName] = skin end
		end
	end)

	-- Fire VFX on each shot
	Remotes.WeaponFired.OnClientEvent:Connect(function(shooter, from, to, weaponName)
		if shooter == LocalPlayer and weaponName then
			local skin = equippedSkins[weaponName]
			if skin and skin.Tier >= 3 then
				-- Barrel position approx — own camera looking direction
				local barrelPos = from + workspace.CurrentCamera.CFrame.LookVector * 1.5
				spawnMuzzleFireVFX(barrelPos, skin)
			end
		end
	end)

	-- Kill banner + counter + evolving form on hit kill
	Remotes.HitMarker.OnClientEvent:Connect(function(category, damage, killed)
		if not killed then return end

		-- Find equipped skin for current weapon (from WeaponController)
		local PlayerScripts = LocalPlayer:FindFirstChild("PlayerScripts")
		if not PlayerScripts then return end
		local WeaponController = require(PlayerScripts:WaitForChild("WeaponController"))
		local currentWeapon = WeaponController.GetCurrentWeapon and WeaponController.GetCurrentWeapon() or nil
		if not currentWeapon then return end

		local skin = equippedSkins[currentWeapon]
		if not skin then return end

		-- Increment kill counter
		killsWithSkin[skin.Id] = (killsWithSkin[skin.Id] or 0) + 1

		-- Tier 4+: kill banner popup
		if skin.Tier >= 4 then
			local isHeadshot = category == "Head"
			showKillBanner(skin, "Enemy", isHeadshot)
		end

		-- Tier 5: evolving form — update viewmodel color
		if skin.Tier >= 5 then
			local ViewmodelController = require(PlayerScripts:WaitForChild("ViewmodelController"))
			-- Clone skin with new color stage
			local newSkin = table.clone(skin)
			newSkin.Color = evolvingColor(killsWithSkin[skin.Id])
			ViewmodelController.ApplySkin(newSkin)
		end
	end)
end

function SkinEffectsController.GetKillCount(skinId)
	return killsWithSkin[skinId] or 0
end

return SkinEffectsController
