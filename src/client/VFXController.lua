-- VFXController: muzzle flash, bullet impact decals + sparks, hit feedback
-- Wszystkie efekty cleientside (tylko gracz widzi swoje muzzle flash)
-- Bullet impacts są fired przez serwer przez WeaponFired (każdy klient renderuje)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
local SoundIds = require(ReplicatedStorage.Shared:WaitForChild("SoundIds"))
local WeaponDatabase = require(ReplicatedStorage.Shared:WaitForChild("WeaponDatabase"))

local VFXController = {}

local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ============================================================
-- MUZZLE FLASH (own shots only — attached to camera)
-- ============================================================
local muzzleFlashPart  -- reusable
local function ensureMuzzleFlash()
	if muzzleFlashPart and muzzleFlashPart.Parent then return muzzleFlashPart end
	muzzleFlashPart = Instance.new("Part")
	muzzleFlashPart.Name = "MuzzleFlash"
	muzzleFlashPart.Anchored = true
	muzzleFlashPart.CanCollide = false
	muzzleFlashPart.CastShadow = false
	muzzleFlashPart.Size = Vector3.new(0.5, 0.5, 0.5)
	muzzleFlashPart.Material = Enum.Material.Neon
	muzzleFlashPart.Color = Color3.fromRGB(255, 230, 120)
	muzzleFlashPart.Transparency = 0.1
	muzzleFlashPart.Parent = camera

	local light = Instance.new("PointLight")
	light.Name = "FlashLight"
	light.Color = Color3.fromRGB(255, 220, 100)
	light.Range = 12
	light.Brightness = 0
	light.Parent = muzzleFlashPart

	return muzzleFlashPart
end

function VFXController.PlayMuzzleFlash()
	local part = ensureMuzzleFlash()
	-- Position in front of camera (gun barrel approximation)
	part.CFrame = camera.CFrame * CFrame.new(0.5, -0.4, -1.5)
	part.Transparency = 0
	local light = part:FindFirstChild("FlashLight")
	if light then light.Brightness = 2 end
	-- Fade out fast
	task.spawn(function()
		for i = 0, 1, 0.15 do
			part.Transparency = i
			if light then light.Brightness = 2 * (1 - i) end
			task.wait(0.01)
		end
		part.Transparency = 1
		if light then light.Brightness = 0 end
	end)
end

-- ============================================================
-- BULLET TRACER (improved — actual beam line)
-- ============================================================
function VFXController.SpawnTracer(from, to, isOwnShot)
	local distance = (to - from).Magnitude
	if distance < 0.5 then return end

	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.Color = isOwnShot and Color3.fromRGB(255, 220, 100) or Color3.fromRGB(255, 240, 200)
	part.Size = Vector3.new(0.06, 0.06, distance)
	part.CFrame = CFrame.lookAt(from, to) * CFrame.new(0, 0, -distance / 2)
	part.Transparency = 0.2
	part.Parent = Workspace

	-- Fade out
	local tween = TweenService:Create(part, TweenInfo.new(0.08, Enum.EasingStyle.Linear), {
		Transparency = 1,
	})
	tween:Play()
	Debris:AddItem(part, 0.1)
end

-- ============================================================
-- BULLET IMPACT (decal + sparks at hit point)
-- ============================================================
local function spawnImpactSparks(position, normal, color)
	local sparkPart = Instance.new("Part")
	sparkPart.Anchored = true
	sparkPart.CanCollide = false
	sparkPart.CastShadow = false
	sparkPart.Transparency = 1
	sparkPart.Size = Vector3.new(0.1, 0.1, 0.1)
	sparkPart.CFrame = CFrame.new(position, position + normal)
	sparkPart.Parent = Workspace

	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	emitter.Lifetime = NumberRange.new(0.2, 0.4)
	emitter.Rate = 0
	emitter.Speed = NumberRange.new(8, 14)
	emitter.SpreadAngle = Vector2.new(60, 60)
	emitter.Color = ColorSequence.new(color or Color3.fromRGB(255, 220, 120))
	emitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.4),
		NumberSequenceKeypoint.new(1, 0),
	})
	emitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 1),
	})
	emitter.LightEmission = 0.8
	emitter.Parent = sparkPart
	emitter:Emit(8)

	Debris:AddItem(sparkPart, 0.6)
end

local function spawnImpactDecal(position, normal)
	-- Bullet hole decal — simple dark spot via SurfaceGui or just a small dark part
	local hole = Instance.new("Part")
	hole.Anchored = true
	hole.CanCollide = false
	hole.CastShadow = false
	hole.Size = Vector3.new(0.4, 0.4, 0.05)
	hole.CFrame = CFrame.new(position + normal * 0.025, position + normal * 1)
	hole.Material = Enum.Material.SmoothPlastic
	hole.Color = Color3.fromRGB(20, 20, 25)
	hole.Transparency = 0.1
	hole.Parent = Workspace

	-- Fade away over 8 seconds
	local tween = TweenService:Create(hole, TweenInfo.new(8, Enum.EasingStyle.Linear), {
		Transparency = 1,
	})
	tween:Play()
	Debris:AddItem(hole, 8.5)
end

function VFXController.SpawnImpact(hitPosition, hitNormal, hitMaterial, isCharacterHit)
	if isCharacterHit then
		-- Blood/flesh spark (red)
		spawnImpactSparks(hitPosition, hitNormal or Vector3.new(0, 1, 0), Color3.fromRGB(200, 30, 30))
	else
		-- Material-based spark color
		local color = Color3.fromRGB(255, 220, 120)  -- default yellow spark
		if hitMaterial == Enum.Material.Metal then
			color = Color3.fromRGB(255, 230, 150)
		elseif hitMaterial == Enum.Material.Wood or hitMaterial == Enum.Material.WoodPlanks then
			color = Color3.fromRGB(180, 130, 80)
		elseif hitMaterial == Enum.Material.Concrete or hitMaterial == Enum.Material.Brick then
			color = Color3.fromRGB(200, 200, 210)
		end
		spawnImpactSparks(hitPosition, hitNormal or Vector3.new(0, 1, 0), color)
		spawnImpactDecal(hitPosition, hitNormal or Vector3.new(0, 1, 0))
	end
end

-- ============================================================
-- HIT SOUND (own kills/hits)
-- ============================================================
local function playSound(soundId, parent, volume)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = volume or 0.7
	sound.Parent = parent or SoundService
	sound:Play()
	sound.Ended:Connect(function() sound:Destroy() end)
	Debris:AddItem(sound, 5)
	return sound
end

function VFXController.PlayHitSound(category, killed)
	if killed then
		playSound(SoundIds.Hit.Kill, nil, 0.8)
	elseif category == "Head" then
		playSound(SoundIds.Hit.Head, nil, 0.8)
	else
		playSound(SoundIds.Hit.Body, nil, 0.6)
	end
end

-- ============================================================
-- WEAPON SOUND (3D positioned)
-- ============================================================
function VFXController.PlayWeaponSound(weaponName, fromPosition)
	local soundId = SoundIds.Weapon[weaponName] or SoundIds.Weapon.Vandal
	-- Spawn a part at position for 3D audio
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Size = Vector3.new(0.1, 0.1, 0.1)
	part.Position = fromPosition
	part.Parent = Workspace

	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = 0.5
	sound.RollOffMaxDistance = 200
	sound.RollOffMinDistance = 10
	sound.Parent = part
	sound:Play()
	Debris:AddItem(part, 1.5)
end

-- ============================================================
-- KILL FLASH (red screen edge on kill)
-- ============================================================
function VFXController.FlashKillIndicator()
	local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
	local existing = PlayerGui:FindFirstChild("KillFlashGui")
	if existing then existing:Destroy() end

	local gui = Instance.new("ScreenGui")
	gui.Name = "KillFlashGui"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = PlayerGui

	-- Red vignette
	local frame = Instance.new("ImageLabel")
	frame.Size = UDim2.fromScale(1, 1)
	frame.Image = "rbxasset://textures/ui/Controls/DefaultImage.png"  -- simple frame
	frame.ImageColor3 = Color3.fromRGB(255, 60, 60)
	frame.ImageTransparency = 0.4
	frame.BackgroundTransparency = 1
	frame.Parent = gui

	-- Fade out
	TweenService:Create(frame, TweenInfo.new(0.5), { ImageTransparency = 1 }):Play()
	Debris:AddItem(gui, 0.6)
end

-- ============================================================
-- DAMAGE SHAKE (camera shake on taking damage)
-- ============================================================
local shakeIntensity = 0
function VFXController.ApplyShake(amount)
	shakeIntensity = math.min(shakeIntensity + amount, 5)
end

RunService.RenderStepped:Connect(function(dt)
	if shakeIntensity > 0.01 then
		local mag = shakeIntensity
		local offset = CFrame.fromOrientation(
			math.rad((math.random() - 0.5) * mag),
			math.rad((math.random() - 0.5) * mag),
			math.rad((math.random() - 0.5) * mag * 0.5)
		)
		camera.CFrame = camera.CFrame * offset
		shakeIntensity *= 0.85  -- decay
	else
		shakeIntensity = 0
	end
end)

-- ============================================================
-- Wire up to remotes
-- ============================================================
function VFXController.Start()
	-- WeaponFired event (from any player) — spawn tracer + sound at origin
	Remotes.WeaponFired.OnClientEvent:Connect(function(shooter, from, to, weaponName)
		local isOwn = shooter == LocalPlayer
		VFXController.SpawnTracer(from, to, isOwn)
		if isOwn then
			VFXController.PlayMuzzleFlash()
		end
		-- 3D weapon sound at origin
		if weaponName then
			VFXController.PlayWeaponSound(weaponName, from)
		end

		-- Detect if hit a character (raycast for hit detection at `to`)
		local hitCharacter = false
		local hitNormal = Vector3.new(0, 1, 0)
		local hitMaterial = nil
		local params = RaycastParams.new()
		params.FilterDescendantsInstances = { shooter and shooter.Character or nil }
		params.FilterType = Enum.RaycastFilterType.Exclude
		local dir = (to - from)
		if dir.Magnitude > 0.5 then
			local result = workspace:Raycast(from, dir * 1.01, params)
			if result then
				hitNormal = result.Normal
				hitMaterial = result.Material
				local model = result.Instance:FindFirstAncestorWhichIsA("Model")
				if model and model:FindFirstChildOfClass("Humanoid") then
					hitCharacter = true
				end
			end
		end
		VFXController.SpawnImpact(to, hitNormal, hitMaterial, hitCharacter)
	end)

	-- Own hits — play hit sound + screen flash on kill
	Remotes.HitMarker.OnClientEvent:Connect(function(category, damage, killed)
		VFXController.PlayHitSound(category, killed)
		if killed then VFXController.FlashKillIndicator() end
	end)

	-- Damage taken — camera shake
	LocalPlayer.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		local lastHealth = humanoid.Health
		humanoid.HealthChanged:Connect(function(newHealth)
			if newHealth < lastHealth then
				VFXController.ApplyShake((lastHealth - newHealth) / 10)
			end
			lastHealth = newHealth
		end)
	end)
end

return VFXController
