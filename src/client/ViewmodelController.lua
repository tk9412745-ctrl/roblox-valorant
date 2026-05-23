-- ViewmodelController: prosty weapon model widoczny w first person + ADS + reload anim + shell ejection

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
local WeaponDatabase = require(ReplicatedStorage.Shared:WaitForChild("WeaponDatabase"))

local ViewmodelController = {}

local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

local viewmodel
local gunPart
local currentWeapon = "Vandal"
local currentSkin = nil  -- skin data applied
local swayOffset = Vector3.new(0, 0, 0)
local bobTime = 0
local pendingKick = Vector3.new(0, 0, 0)
local isADS = false
local isReloading = false
local reloadAnimStart = 0

-- Weapon visuals per category (multi-part). Each: receiver, barrel, stock, mag, sight, grip
local WEAPON_VISUAL = {
	Sidearm = {
		receiver = { Vector3.new(0.2, 0.4, 0.6) },
		barrel = { Vector3.new(0.1, 0.1, 0.4), offset = Vector3.new(0, 0.05, -0.5) },
		grip = { Vector3.new(0.2, 0.4, 0.2), offset = Vector3.new(0, -0.3, 0.15) },
		mag = { Vector3.new(0.18, 0.3, 0.18), offset = Vector3.new(0, -0.3, 0.15) },
		sight = { Vector3.new(0.04, 0.06, 0.12), offset = Vector3.new(0, 0.22, 0) },
		color = Color3.fromRGB(40, 40, 50),
	},
	SMG = {
		receiver = { Vector3.new(0.22, 0.4, 0.9) },
		barrel = { Vector3.new(0.1, 0.1, 0.45), offset = Vector3.new(0, 0.05, -0.65) },
		stock = { Vector3.new(0.15, 0.35, 0.45), offset = Vector3.new(0, -0.05, 0.65) },
		grip = { Vector3.new(0.22, 0.5, 0.22), offset = Vector3.new(0, -0.35, 0.2) },
		foregrip = { Vector3.new(0.1, 0.2, 0.15), offset = Vector3.new(0, -0.2, -0.3) },
		mag = { Vector3.new(0.2, 0.35, 0.18), offset = Vector3.new(0, -0.35, 0.2) },
		sight = { Vector3.new(0.04, 0.08, 0.14), offset = Vector3.new(0, 0.24, 0) },
		color = Color3.fromRGB(50, 50, 60),
	},
	Shotgun = {
		receiver = { Vector3.new(0.28, 0.45, 1.0) },
		barrel = { Vector3.new(0.18, 0.18, 0.6), offset = Vector3.new(0, 0.05, -0.7) },
		stock = { Vector3.new(0.2, 0.4, 0.5), offset = Vector3.new(0, -0.05, 0.7) },
		grip = { Vector3.new(0.25, 0.5, 0.25), offset = Vector3.new(0, -0.4, 0.25) },
		foregrip = { Vector3.new(0.18, 0.18, 0.3), offset = Vector3.new(0, -0.18, -0.3) },
		sight = { Vector3.new(0.06, 0.1, 0.1), offset = Vector3.new(0, 0.28, 0.4) },
		color = Color3.fromRGB(60, 40, 30),
	},
	Rifle = {
		receiver = { Vector3.new(0.25, 0.42, 1.1) },
		barrel = { Vector3.new(0.1, 0.1, 0.55), offset = Vector3.new(0, 0.06, -0.8) },
		stock = { Vector3.new(0.2, 0.36, 0.55), offset = Vector3.new(0, -0.05, 0.8) },
		grip = { Vector3.new(0.25, 0.5, 0.25), offset = Vector3.new(0, -0.4, 0.3) },
		foregrip = { Vector3.new(0.12, 0.2, 0.2), offset = Vector3.new(0, -0.22, -0.4) },
		mag = { Vector3.new(0.22, 0.4, 0.2), offset = Vector3.new(0, -0.4, 0.2) },
		sight = { Vector3.new(0.04, 0.1, 0.18), offset = Vector3.new(0, 0.27, 0) },
		color = Color3.fromRGB(40, 40, 45),
	},
	Sniper = {
		receiver = { Vector3.new(0.28, 0.46, 1.4) },
		barrel = { Vector3.new(0.08, 0.08, 0.8), offset = Vector3.new(0, 0.05, -1.0) },
		stock = { Vector3.new(0.22, 0.4, 0.55), offset = Vector3.new(0, -0.05, 1.0) },
		grip = { Vector3.new(0.25, 0.55, 0.25), offset = Vector3.new(0, -0.45, 0.4) },
		scope = { Vector3.new(0.15, 0.18, 0.5), offset = Vector3.new(0, 0.34, 0.05) },
		mag = { Vector3.new(0.2, 0.3, 0.15), offset = Vector3.new(0, -0.35, 0.2) },
		color = Color3.fromRGB(35, 40, 50),
	},
	MachineGun = {
		receiver = { Vector3.new(0.32, 0.48, 1.3) },
		barrel = { Vector3.new(0.14, 0.14, 0.65), offset = Vector3.new(0, 0.06, -0.95) },
		stock = { Vector3.new(0.25, 0.4, 0.55), offset = Vector3.new(0, -0.05, 0.9) },
		grip = { Vector3.new(0.28, 0.55, 0.28), offset = Vector3.new(0, -0.45, 0.35) },
		foregrip = { Vector3.new(0.14, 0.25, 0.25), offset = Vector3.new(0, -0.25, -0.45) },
		mag = { Vector3.new(0.4, 0.4, 0.3), offset = Vector3.new(0, -0.4, 0.1) },
		sight = { Vector3.new(0.04, 0.1, 0.18), offset = Vector3.new(0, 0.3, 0) },
		color = Color3.fromRGB(45, 45, 55),
	},
	Melee = {
		blade = { Vector3.new(0.05, 0.6, 0.05), offset = Vector3.new(0, 0.3, 0) },
		handle = { Vector3.new(0.1, 0.3, 0.1), offset = Vector3.new(0, -0.15, 0) },
		color = Color3.fromRGB(200, 200, 210),
	},
}

local function destroyViewmodel()
	if viewmodel then
		viewmodel:Destroy()
		viewmodel = nil
		gunPart = nil
	end
end

local function createViewmodel(weaponName)
	destroyViewmodel()

	local w = WeaponDatabase[weaponName]
	if not w then return end
	local visual = WEAPON_VISUAL[w.Category] or WEAPON_VISUAL.Rifle

	viewmodel = Instance.new("Model")
	viewmodel.Name = "Viewmodel"

	local skinColor = (currentSkin and currentSkin.Color) or visual.color
	local skinMaterial = (currentSkin and currentSkin.Material) or Enum.Material.SmoothPlastic

	local function makePart(name, sz, color, material)
		local p = Instance.new("Part")
		p.Name = name
		p.Size = sz
		p.Color = color
		p.Material = material or Enum.Material.SmoothPlastic
		p.Anchored = true
		p.CanCollide = false
		p.CastShadow = false
		p.TopSurface = Enum.SurfaceType.Smooth
		p.BottomSurface = Enum.SurfaceType.Smooth
		p.Parent = viewmodel
		return p
	end

	-- Main receiver (or gun body for melee)
	if visual.receiver then
		gunPart = makePart("Gun", visual.receiver[1], skinColor, skinMaterial)
	elseif visual.blade then
		-- Melee
		gunPart = makePart("Gun", visual.blade[1], Color3.fromRGB(220, 220, 240), Enum.Material.Metal)
	else
		gunPart = makePart("Gun", Vector3.new(0.25, 0.42, 1.1), skinColor, skinMaterial)
	end

	-- Optional parts (only created if defined in visual)
	if visual.barrel then
		makePart("Barrel_Visual", visual.barrel[1], Color3.fromRGB(20, 20, 25), Enum.Material.Metal):SetAttribute("Offset", visual.barrel.offset)
	end
	if visual.stock then
		makePart("Stock", visual.stock[1], Color3.fromRGB(60, 50, 40), Enum.Material.Wood):SetAttribute("Offset", visual.stock.offset)
	end
	if visual.grip then
		makePart("Grip", visual.grip[1], Color3.fromRGB(25, 25, 30), Enum.Material.SmoothPlastic):SetAttribute("Offset", visual.grip.offset)
	end
	if visual.foregrip then
		makePart("Foregrip", visual.foregrip[1], Color3.fromRGB(25, 25, 30), Enum.Material.SmoothPlastic):SetAttribute("Offset", visual.foregrip.offset)
	end
	if visual.mag then
		makePart("Magazine", visual.mag[1], Color3.fromRGB(20, 20, 25), Enum.Material.Metal):SetAttribute("Offset", visual.mag.offset)
	end
	if visual.sight then
		makePart("Sight", visual.sight[1], Color3.fromRGB(20, 20, 30), Enum.Material.SmoothPlastic):SetAttribute("Offset", visual.sight.offset)
	end
	if visual.scope then
		local scopeBody = makePart("Scope", visual.scope[1], Color3.fromRGB(20, 20, 30), Enum.Material.Metal)
		scopeBody:SetAttribute("Offset", visual.scope.offset)
		-- Scope lens (glow on front)
		local lens = makePart("ScopeLens", Vector3.new(0.12, 0.12, 0.02), Color3.fromRGB(100, 100, 130), Enum.Material.Glass)
		lens:SetAttribute("Offset", visual.scope.offset + Vector3.new(0, 0, -visual.scope[1].Z / 2))
	end
	if visual.handle then
		makePart("Handle", visual.handle[1], Color3.fromRGB(40, 30, 20), Enum.Material.Wood):SetAttribute("Offset", visual.handle.offset)
	end

	-- Barrel tip for muzzle flash
	local barrelTip = makePart("Barrel", Vector3.new(0.1, 0.1, 0.1), Color3.fromRGB(0, 0, 0))
	barrelTip.Transparency = 1
	if visual.receiver then
		barrelTip:SetAttribute("Offset", Vector3.new(0, 0, -visual.receiver[1].Z / 2 - 0.4))
	end

	-- Tier 3+ fire VFX attach
	if currentSkin and currentSkin.HasFireVFX then
		local fireAttach = Instance.new("Attachment")
		fireAttach.Name = "MuzzleFireAttach"
		fireAttach.Position = Vector3.new(0, 0, -gunPart.Size.Z / 2)
		fireAttach.Parent = gunPart
	end

	viewmodel.Parent = camera
end

local function spawnShell()
	if not gunPart or not gunPart.Parent then return end

	local shell = Instance.new("Part")
	shell.Name = "Shell"
	shell.Size = Vector3.new(0.06, 0.06, 0.18)
	shell.Color = Color3.fromRGB(220, 180, 80)
	shell.Material = Enum.Material.Metal
	shell.CanCollide = true
	shell.CastShadow = false
	shell.CFrame = gunPart.CFrame * CFrame.new(0.2, 0, 0)
	shell.AssemblyLinearVelocity = camera.CFrame.RightVector * 6 + Vector3.new(0, 2, 0)
	shell.AssemblyAngularVelocity = Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10))
	shell.Parent = Workspace
	Debris:AddItem(shell, 2)
end

local function updateViewmodel(dt)
	if not gunPart or not gunPart.Parent then return end

	local character = LocalPlayer.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	-- Walking bob (reduced in ADS)
	local moveSpeed = humanoid.MoveDirection.Magnitude * humanoid.WalkSpeed
	local bobScale = isADS and 0.3 or 1.0
	if moveSpeed > 0.5 then
		bobTime += dt * 6
		swayOffset = Vector3.new(
			math.sin(bobTime) * 0.03 * bobScale,
			math.abs(math.sin(bobTime * 2)) * 0.02 * bobScale,
			0
		)
	else
		bobTime = 0
		swayOffset = swayOffset:Lerp(Vector3.new(0, 0, 0), math.min(dt * 8, 1))
	end

	-- Mouse sway
	local mouseDelta = UserInputService:GetMouseDelta()
	local swayScale = isADS and 0.2 or 1.0
	swayOffset = swayOffset + Vector3.new(-mouseDelta.X * 0.0005 * swayScale, -mouseDelta.Y * 0.0005 * swayScale, 0)
	swayOffset = Vector3.new(
		math.clamp(swayOffset.X, -0.1, 0.1),
		math.clamp(swayOffset.Y, -0.1, 0.1),
		0
	)
	swayOffset = swayOffset:Lerp(Vector3.new(0, 0, 0), math.min(dt * 2, 1))

	-- Kick decay
	pendingKick = pendingKick:Lerp(Vector3.new(0, 0, 0), math.min(dt * 12, 1))

	-- Reload animation: rotate gun down 60deg + drop magazine slightly
	local reloadOffsetCFrame = CFrame.new(0, 0, 0)
	if isReloading then
		local elapsed = tick() - reloadAnimStart
		local cfg = WeaponDatabase[currentWeapon]
		local reloadDuration = (cfg and cfg.ReloadTime) or 2.5
		local progress = math.clamp(elapsed / reloadDuration, 0, 1)
		-- Down → up motion: goes down for first half, comes up second half
		local angle = math.sin(progress * math.pi) * math.rad(50)
		reloadOffsetCFrame = CFrame.Angles(-angle, 0, 0) * CFrame.new(0, -0.1 * math.sin(progress * math.pi), 0)
	end

	-- ADS position: center the gun on camera + closer to face
	local basePos
	if isADS then
		basePos = Vector3.new(0, -0.15, -0.8)
	else
		basePos = Vector3.new(0.5, -0.45, -1.3)
	end
	local finalPos = basePos + swayOffset + pendingKick
	gunPart.CFrame = camera.CFrame * CFrame.new(finalPos) * reloadOffsetCFrame

	-- Attach all sub-parts relative to gunPart via their Offset attribute
	local model = gunPart.Parent
	if model then
		for _, part in ipairs(model:GetChildren()) do
			if part:IsA("BasePart") and part ~= gunPart then
				local offset = part:GetAttribute("Offset")
				if offset then
					if part.Name == "Magazine" and isReloading then
						-- During reload, magazine drops slightly
						local dropOffset = Vector3.new(0, -0.3 * math.sin((tick() - reloadAnimStart) * 4), 0)
						part.CFrame = gunPart.CFrame * CFrame.new(offset + dropOffset)
					else
						part.CFrame = gunPart.CFrame * CFrame.new(offset)
					end
				end
			end
		end
	end
end

function ViewmodelController.SetWeapon(weaponName)
	if currentWeapon == weaponName then return end
	currentWeapon = weaponName
	createViewmodel(weaponName)
end

function ViewmodelController.ApplyKick(amount)
	pendingKick = pendingKick + Vector3.new(0, 0.015 * amount, 0.05 * amount)
	-- Spawn shell on shot
	if currentWeapon ~= "Knife" then
		spawnShell()
	end
end

function ViewmodelController.ApplySkin(skinData)
	currentSkin = skinData
	createViewmodel(currentWeapon)  -- rebuild with skin
end

function ViewmodelController.SetADS(state)
	isADS = state
end

function ViewmodelController.IsADS()
	return isADS
end

function ViewmodelController.SetReloading(state)
	if state and not isReloading then
		reloadAnimStart = tick()
	end
	isReloading = state
end

function ViewmodelController.GetBarrelPosition()
	if not viewmodel then return nil end
	local barrel = viewmodel:FindFirstChild("Barrel")
	return barrel and barrel.Position or nil
end

function ViewmodelController.Start()
	createViewmodel(currentWeapon)
	RunService.RenderStepped:Connect(updateViewmodel)

	Remotes.WeaponFired.OnClientEvent:Connect(function(shooter, from, to, weaponName)
		if shooter == LocalPlayer then
			ViewmodelController.ApplyKick(1)
			if weaponName and weaponName ~= currentWeapon then
				ViewmodelController.SetWeapon(weaponName)
			end
		end
	end)

	Remotes.BuyResult.OnClientEvent:Connect(function(success, message)
		if success and message and message:find("^Bought ") then
			local weaponName = message:gsub("^Bought ", "")
			if WeaponDatabase[weaponName] then
				ViewmodelController.SetWeapon(weaponName)
			end
		end
	end)

	-- Reload state from server
	Remotes.UpdateAmmo.OnClientEvent:Connect(function(magazine, reserve, reloading)
		ViewmodelController.SetReloading(reloading)
	end)

	-- Skin equip
	Remotes.SkinEquipped.OnClientEvent:Connect(function(userId, weaponName, skinId)
		if userId == LocalPlayer.UserId and weaponName == currentWeapon then
			local SkinDatabase = require(ReplicatedStorage.Shared:WaitForChild("SkinDatabase"))
			local skin = SkinDatabase.Get(skinId)
			if skin then
				ViewmodelController.ApplySkin(skin)
			end
		end
	end)

	LocalPlayer.CharacterAdded:Connect(function()
		task.wait(0.3)
		createViewmodel(currentWeapon)
	end)
end

return ViewmodelController
