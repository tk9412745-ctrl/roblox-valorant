local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local WeaponDatabase = require(ReplicatedStorage.Shared.WeaponDatabase)
local SpreadCalculator = require(ReplicatedStorage.Shared.SpreadCalculator)
local WallPenetration = require(ReplicatedStorage.Shared.WallPenetration)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local CombatService = {}

local lastFireTime = {}
local ammoState = {}
local reloadTokens = {}
local equippedWeapon = {}  -- [player] = "Vandal" | "Phantom" | ... (currently equipped)
local weaponSlots = {}     -- [player] = { primary, secondary, melee }
local activeSlot = {}      -- [player] = "primary" | "secondary" | "melee"
local armorState = {}      -- [player] = {type="LightShield", hp=25, max=25} or nil
local equipUntil = {}      -- [player] = tick() when equip animation completes
local firingError = {}     -- [player] = accumulated spread (degrees)
local shotCount = {}       -- [player] = consecutive shots without break
local isADS = {}           -- [player] = true if scoped/ADS
local movementMode = {}    -- [player] = "Run" | "Walk" | "Crouch"

local LEG_PARTS = {
	LeftFoot = true, RightFoot = true,
	LeftLowerLeg = true, RightLowerLeg = true,
	LeftUpperLeg = true, RightUpperLeg = true,
}

local function getEquippedWeapon(player)
	return equippedWeapon[player] or "Vandal"
end

local function getAmmoState(player)
	if not ammoState[player] then
		local weapon = getEquippedWeapon(player)
		local cfg = WeaponDatabase[weapon]
		ammoState[player] = {
			magazine = cfg.MagazineSize,
			reserve = cfg.ReserveAmmo,
			isReloading = false,
		}
	end
	return ammoState[player]
end

local function sendAmmoUpdate(player)
	local state = getAmmoState(player)
	Remotes.UpdateAmmo:FireClient(player, state.magazine, state.reserve, state.isReloading)
end

local function getBodyPartCategory(part)
	if part.Name == "Head" then
		return "Head"
	elseif LEG_PARTS[part.Name] then
		return "Leg"
	end
	return "Body"
end

local killCallbacks = {}
local lastHitCategory = {}  -- [victim] = "Head" / "Body" / "Leg" (for headshot detection in killfeed)

function CombatService.OnPlayerKilled(callback)
	table.insert(killCallbacks, callback)
end

local function fireKillCallbacks(killer, victim)
	for _, cb in ipairs(killCallbacks) do
		task.spawn(cb, killer, victim)
	end
	-- Killfeed broadcast
	if killer and victim then
		local killerName = killer.Name
		local victimName = victim.Name
		local killerTeam = killer.Team and killer.Team.Name or nil
		local victimTeam = victim.Team and victim.Team.Name or nil
		local weaponName = equippedWeapon[killer] or "?"
		local isHeadshot = lastHitCategory[victim] == "Head"
		Remotes.KillFeed:FireAllClients(killerName, weaponName, victimName, killerTeam, victimTeam, isHeadshot)
		lastHitCategory[victim] = nil
	end
end

local function applyDamageWithArmor(targetCharacter, rawDamage, isHeadshot, attacker)
	local humanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
	if not humanoid then return 0 end

	-- Sprint 88: Spawn invulnerability blocks all damage
	if targetCharacter:GetAttribute("SpawnInvuln") then
		return 0
	end

	local targetPlayer = Players:GetPlayerFromCharacter(targetCharacter)
	local armor = targetPlayer and armorState[targetPlayer]

	local function maybeKill()
		if humanoid.Health <= 0 and targetPlayer then
			fireKillCallbacks(attacker, targetPlayer)
		end
	end

	-- Brak armoru — pełny damage na HP
	if not armor or armor.hp <= 0 then
		humanoid:TakeDamage(rawDamage)
		maybeKill()
		return rawDamage
	end

	-- Headshot bypassuje armor reduction (Valorant: headshot dmg pełne na HP)
	-- ale armor wciąż absorbuje część (uproszczone: -10 armor za HS)
	if isHeadshot then
		humanoid:TakeDamage(rawDamage)
		armor.hp = math.max(0, armor.hp - 10)
		maybeKill()
		return rawDamage
	end

	local cfg = WeaponDatabase.Armor.LightShield  -- użyj 33/66 (same for Light/Heavy)
	local hpLoss = math.floor(rawDamage * cfg.HpDamageMultiplier)
	local armorLoss = math.floor(rawDamage * cfg.ArmorDamageMultiplier)

	if armorLoss > armor.hp then
		local overflow = armorLoss - armor.hp
		humanoid:TakeDamage(hpLoss + overflow)
		armor.hp = 0
	else
		humanoid:TakeDamage(hpLoss)
		armor.hp -= armorLoss
	end
	maybeKill()
	return hpLoss
end

local function handleFire(player, origin, direction)
	if typeof(origin) ~= "Vector3" or typeof(direction) ~= "Vector3" then return end

	local character = player.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end

	local weaponName = getEquippedWeapon(player)
	local cfg = WeaponDatabase[weaponName]
	if not cfg then return end

	local state = getAmmoState(player)

	local now = tick()
	local minInterval = 1 / cfg.FireRate
	if lastFireTime[player] and (now - lastFireTime[player]) < minInterval * 0.9 then
		return
	end

	-- Sprint 89: Reload cancel — fire during reload cancels it (loses progress)
	if state.isReloading and state.magazine > 0 then
		state.isReloading = false
		reloadTokens[player] = (reloadTokens[player] or 0) + 1  -- invalidate pending reload
		sendAmmoUpdate(player)
	end

	if state.isReloading or state.magazine <= 0 then return end

	-- Equip delay (can't shoot during weapon swap)
	if equipUntil[player] and tick() < equipUntil[player] then return end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	if (origin - hrp.Position).Magnitude > 10 then return end
	if math.abs(direction.Magnitude - 1) > 0.05 then return end

	-- Decay firing error if previous shot was too long ago
	local timeSinceLast = now - (lastFireTime[player] or 0)
	if timeSinceLast > 0.5 then
		firingError[player] = 0
		shotCount[player] = 0
	end

	lastFireTime[player] = now
	state.magazine -= 1
	shotCount[player] = (shotCount[player] or 0) + 1

	-- Apply spread to direction (includes movement mode)
	local moveErr = SpreadCalculator.GetMovementError(player, movementMode[player])
	local totalSpread = SpreadCalculator.GetTotalSpread(weaponName, firingError[player] or 0, moveErr, isADS[player])
	local spreadDir = SpreadCalculator.ApplySpread(direction, totalSpread)

	-- Accumulate firing error for next shot (caps via SpreadCalculator)
	firingError[player] = math.min(
		(firingError[player] or 0) + SpreadCalculator.GetFiringErrorPerShot(weaponName),
		SpreadCalculator.MaxFiringError
	)

	-- Max range w studs: ostatnia tier MaxRange w damage table
	local maxRange = 150
	if cfg.Damage and cfg.Damage[#cfg.Damage] and cfg.Damage[#cfg.Damage].MaxRange then
		maxRange = cfg.Damage[#cfg.Damage].MaxRange
	end

	-- Penetrating raycast (server-side, with wallbang)
	local hits = WallPenetration.PenetratingRaycast(weaponName, origin, spreadDir, maxRange, { character })

	local hitPosition = origin + spreadDir * maxRange
	if #hits > 0 then
		hitPosition = hits[#hits].result.Position
	end

	-- Apply damage to FIRST humanoid hit (penetration multiplier applied)
	local humanoidHit, humanoidChar = WallPenetration.GetFirstHumanoidHit(hits)
	if humanoidHit and humanoidChar then
		local hitHumanoid = humanoidChar:FindFirstChildOfClass("Humanoid")
		if hitHumanoid and hitHumanoid.Health > 0 then
			local category = getBodyPartCategory(humanoidHit.result.Instance)
			local distance = (humanoidHit.result.Position - origin).Magnitude
			local rawDamage = WeaponDatabase.GetDamageAtRange(weaponName, distance, category)
			local damage = rawDamage * humanoidHit.damageMultiplier
			local isHeadshot = category == "Head"
			local victimPlayer = Players:GetPlayerFromCharacter(humanoidChar)
			if victimPlayer then
				lastHitCategory[victimPlayer] = category
				-- Notify victim of damage source
				Remotes.TookDamage:FireClient(victimPlayer, origin, damage)
			end
			applyDamageWithArmor(humanoidChar, damage, isHeadshot, player)
			Remotes.HitMarker:FireClient(player, category, damage, hitHumanoid.Health <= 0)
		end
	end

	Remotes.WeaponFired:FireAllClients(player, origin, hitPosition, weaponName)
	sendAmmoUpdate(player)
end

local function handleReload(player)
	local state = getAmmoState(player)
	local weaponName = getEquippedWeapon(player)
	local cfg = WeaponDatabase[weaponName]

	if state.isReloading then return end
	if state.magazine >= cfg.MagazineSize then return end
	if state.reserve <= 0 then return end

	state.isReloading = true
	local token = (reloadTokens[player] or 0) + 1
	reloadTokens[player] = token
	sendAmmoUpdate(player)

	task.delay(cfg.ReloadTime, function()
		if reloadTokens[player] ~= token then return end
		if not ammoState[player] then return end
		local needed = cfg.MagazineSize - state.magazine
		local taken = math.min(needed, state.reserve)
		state.magazine += taken
		state.reserve -= taken
		state.isReloading = false
		sendAmmoUpdate(player)
	end)
end

function CombatService.Start()
	Remotes.FireWeapon.OnServerEvent:Connect(handleFire)
	Remotes.Reload.OnServerEvent:Connect(handleReload)
	Remotes.SetMovementMode.OnServerEvent:Connect(function(player, mode)
		CombatService.SetMovementMode(player, mode)
	end)
	Remotes.SetADS.OnServerEvent:Connect(function(player, state)
		CombatService.SetADS(player, state)
	end)
	Remotes.SwitchSlot.OnServerEvent:Connect(function(player, slotName)
		CombatService.SwitchSlot(player, slotName)
	end)

	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function()
			ammoState[player] = nil
			lastFireTime[player] = nil
			reloadTokens[player] = (reloadTokens[player] or 0) + 1
			task.wait(0.5)
			sendAmmoUpdate(player)
		end)
	end)

	Players.PlayerRemoving:Connect(function(player)
		lastFireTime[player] = nil
		ammoState[player] = nil
		reloadTokens[player] = nil
		equippedWeapon[player] = nil
		armorState[player] = nil
		firingError[player] = nil
		shotCount[player] = nil
		isADS[player] = nil
	end)

	-- Decay firing error over time
	task.spawn(function()
		while true do
			task.wait(0.1)
			for player, err in pairs(firingError) do
				if err > 0 then
					firingError[player] = math.max(0, err - SpreadCalculator.FiringErrorDecayPerSec * 0.1)
				end
			end
		end
	end)
end

function CombatService.SetADS(player, adsState)
	isADS[player] = adsState and true or false
end

function CombatService.SetMovementMode(player, mode)
	if mode == "Run" or mode == "Walk" or mode == "Crouch" then
		movementMode[player] = mode
	end
end

function CombatService.GetMovementMode(player)
	return movementMode[player] or "Run"
end

local function getSlotForWeapon(weaponName)
	local w = WeaponDatabase[weaponName]
	if not w then return nil end
	local cat = w.Category
	if cat == "Sidearm" then return "secondary" end
	if cat == "Melee" then return "melee" end
	return "primary"
end

function CombatService.SetWeapon(player, weaponName)
	if not WeaponDatabase[weaponName] then return false end
	weaponSlots[player] = weaponSlots[player] or { primary = nil, secondary = "Classic", melee = "Knife" }
	local slot = getSlotForWeapon(weaponName)
	if slot then weaponSlots[player][slot] = weaponName end
	equippedWeapon[player] = weaponName
	activeSlot[player] = slot
	ammoState[player] = nil
	-- Apply equip delay
	local cfg = WeaponDatabase[weaponName]
	if cfg and cfg.EquipTime then
		equipUntil[player] = tick() + cfg.EquipTime
	end
	sendAmmoUpdate(player)
	return true
end

function CombatService.SwitchSlot(player, slotName)
	if slotName ~= "primary" and slotName ~= "secondary" and slotName ~= "melee" then return false end
	weaponSlots[player] = weaponSlots[player] or { primary = nil, secondary = "Classic", melee = "Knife" }
	local weaponInSlot = weaponSlots[player][slotName]
	if not weaponInSlot then return false end
	equippedWeapon[player] = weaponInSlot
	activeSlot[player] = slotName
	ammoState[player] = nil
	-- Apply equip delay
	local cfg = WeaponDatabase[weaponInSlot]
	if cfg and cfg.EquipTime then
		equipUntil[player] = tick() + cfg.EquipTime
	end
	sendAmmoUpdate(player)
	Remotes.PickupWeapon:FireClient(player, weaponInSlot)
	return true
end

function CombatService.GetSlots(player)
	return weaponSlots[player] or { primary = nil, secondary = "Classic", melee = "Knife" }
end

function CombatService.GrantArmor(player, armorType)
	if armorType == nil then
		armorState[player] = nil
		return true
	end
	local cfg = WeaponDatabase.Armor[armorType]
	if not cfg then return false end
	armorState[player] = {
		type = armorType,
		hp = cfg.MaxHp,
		max = cfg.MaxHp,
	}
	return true
end

function CombatService.GetArmor(player)
	return armorState[player]
end

return CombatService
