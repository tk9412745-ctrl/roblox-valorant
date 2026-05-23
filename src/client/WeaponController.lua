local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer

local Shared = ReplicatedStorage:WaitForChild("Shared")
local WeaponDatabase = require(Shared:WaitForChild("WeaponDatabase"))
local RecoilPattern = require(Shared:WaitForChild("RecoilPattern"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local FPSCamera = require(script.Parent:WaitForChild("FPSCamera"))

local WeaponController = {}

local currentWeapon = "Vandal"
local isFiring = false
local lastFireTime = 0
local magazine = WeaponDatabase.Vandal.MagazineSize
local reserve = WeaponDatabase.Vandal.ReserveAmmo
local isReloading = false
local lastHit = nil
local shotIndex = 0
local pendingRecoilV = 0
local pendingRecoilH = 0
local lastShotTime = 0

local function tryFire()
	local cfg = WeaponDatabase[currentWeapon]
	local now = tick()
	local interval = 1 / cfg.FireRate

	if now - lastFireTime < interval then return end
	if isReloading then return end
	if magazine <= 0 then
		-- Auto reload when empty
		if reserve > 0 then
			Remotes.Reload:FireServer()
		end
		return
	end

	-- Reset shot index if previous shot too long ago
	if now - lastShotTime > 0.5 then
		shotIndex = 0
	end
	lastShotTime = now
	shotIndex += 1

	lastFireTime = now
	magazine -= 1

	local origin = FPSCamera.GetCameraPosition()
	local direction = FPSCamera.GetLookVector()

	-- Visual camera recoil kick (deterministic client-side)
	local vKick, hKick = RecoilPattern.GetOffset(currentWeapon, shotIndex)
	pendingRecoilV += vKick
	pendingRecoilH += hKick

	Remotes.FireWeapon:FireServer(origin, direction)
end

local function tryReload()
	if isReloading then return end
	if magazine >= WeaponDatabase[currentWeapon].MagazineSize then return end
	if reserve <= 0 then return end
	Remotes.Reload:FireServer()
end

local function onInputBegan(input, processed)
	if processed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		isFiring = true
	elseif input.KeyCode == Enum.KeyCode.R then
		tryReload()
	end
end

local function onInputEnded(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		isFiring = false
	end
end

local function onHeartbeat()
	if isFiring then
		tryFire()
	end
end

local function drawTracer(from, to)
	local distance = (to - from).Magnitude
	if distance < 0.1 then return end

	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(255, 220, 100)
	part.Size = Vector3.new(0.08, 0.08, distance)
	part.CFrame = CFrame.lookAt(from, to) * CFrame.new(0, 0, -distance / 2)
	part.Parent = workspace

	Debris:AddItem(part, 0.06)
end

local function flashHitMarker(category, damage, killed)
	lastHit = {
		time = tick(),
		category = category,
		damage = damage,
		killed = killed,
	}
end

local function applyRecoilOffset(dt)
	if math.abs(pendingRecoilV) > 0.01 or math.abs(pendingRecoilH) > 0.01 then
		local camera = workspace.CurrentCamera
		-- Apply portion of pending recoil this frame (smooth kick over multiple frames)
		local frameRate = math.min(dt * 30, 1)
		local applyV = pendingRecoilV * frameRate
		local applyH = pendingRecoilH * frameRate
		camera.CFrame = camera.CFrame * CFrame.fromOrientation(math.rad(applyV), math.rad(-applyH), 0)
		pendingRecoilV -= applyV
		pendingRecoilH -= applyH
	end
	-- Recovery: drift pending recoil toward zero when not firing
	if not isFiring and (tick() - lastShotTime) > RecoilPattern.RecoveryDelay then
		pendingRecoilV *= RecoilPattern.RecoveryRate ^ (dt * 60)
		pendingRecoilH *= RecoilPattern.RecoveryRate ^ (dt * 60)
		shotIndex = 0
	end
end

function WeaponController.Start()
	UserInputService.InputBegan:Connect(onInputBegan)
	UserInputService.InputEnded:Connect(onInputEnded)
	RunService.Heartbeat:Connect(onHeartbeat)
	RunService:BindToRenderStep("Recoil", Enum.RenderPriority.Camera.Value + 1, applyRecoilOffset)

	Remotes.UpdateAmmo.OnClientEvent:Connect(function(newMagazine, newReserve, reloading)
		magazine = newMagazine
		reserve = newReserve
		isReloading = reloading
	end)

	Remotes.WeaponFired.OnClientEvent:Connect(function(_, from, to)
		drawTracer(from, to)
	end)

	Remotes.HitMarker.OnClientEvent:Connect(flashHitMarker)

	LocalPlayer.CharacterAdded:Connect(function()
		magazine = WeaponDatabase[currentWeapon].MagazineSize
		reserve = WeaponDatabase[currentWeapon].ReserveAmmo
		isReloading = false
	end)
end

function WeaponController.SetWeapon(weaponName)
	if not WeaponDatabase[weaponName] then return end
	currentWeapon = weaponName
	magazine = WeaponDatabase[weaponName].MagazineSize
	reserve = WeaponDatabase[weaponName].ReserveAmmo
	isReloading = false
end

function WeaponController.GetCurrentWeapon()
	return currentWeapon
end

function WeaponController.GetAmmo()
	return magazine, reserve, isReloading
end

function WeaponController.GetLastHit()
	return lastHit
end

return WeaponController
