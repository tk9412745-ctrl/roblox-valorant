-- WeaponDatabase: Pełne stats wszystkich 19 broni z Valoranta (post-2024 patches, weryfikowane cross-source)
-- Distances: w studs Roblox (1 metr Valorant ≈ 3 studs)
-- DPS: damage per second, FireRate w shots/sec, ReloadTime w sekundach
-- WallPen tier: "Low" (×0.5 dmg through wall), "Medium" (×0.65), "High" (×0.8)

local WeaponDatabase = {}

local METER_TO_STUDS = 3
local function m(meters) return meters * METER_TO_STUDS end

-- ============================================================
-- SIDEARMS
-- ============================================================

WeaponDatabase.Classic = {
	DisplayName = "Classic",
	Category = "Sidearm",
	Price = 0,
	WallPen = "Low",
	FireRate = 6.75,
	MagazineSize = 12,
	ReserveAmmo = 36,
	ReloadTime = 1.75,
	EquipTime = 0.75,
	WalkSpeedStuds = 13.6,
	WalkSpeedPct = 85,
	FirstBulletAccuracy = 0.4,
	FireMode = "SemiAuto",
	Damage = {
		{ MaxRange = m(30), Head = 78, Body = 26, Leg = 22 },
		{ MaxRange = m(50), Head = 66, Body = 22, Leg = 19 },
	},
	AltFire = {
		Type = "Burst",
		Pellets = 3,
		FireRate = 2.22,
		FirstBurstSpread = 1.9,
		SecondBurstSpread = 2.5,
		IgnoresMovementSpread = true,
	},
	Recoil = { Vertical = 1.0, Horizontal = 0.3, Pattern = "Light" },
	Notes = "Starter pistol, given free every round. Alt-fire: 3-pellet shotgun burst.",
}

WeaponDatabase.Shorty = {
	DisplayName = "Shorty",
	Category = "Sidearm",
	Price = 300,
	WallPen = "Low",
	FireRate = 3.3,
	MagazineSize = 2,
	ReserveAmmo = 6,
	ReloadTime = 1.75,
	EquipTime = 0.75,
	WalkSpeedStuds = 12.8,
	WalkSpeedPct = 80,
	FirstBulletAccuracy = 4.0,
	FireMode = "SemiAutoShotgun",
	PelletCount = 15,
	Damage = {
		{ MaxRange = m(7), Head = 24, Body = 11, Leg = 10 },
		{ MaxRange = m(15), Head = 16, Body = 6, Leg = 6 },
		{ MaxRange = m(50), Head = 6, Body = 3, Leg = 2 },
	},
	Recoil = { Vertical = 2.5, Horizontal = 0.5, Pattern = "Heavy" },
	Notes = "Per-pellet damage. 15 pellets × 11 body = 165 dmg point-blank. Patch 12.09 nerfed moving/jumping spread.",
}

WeaponDatabase.Frenzy = {
	DisplayName = "Frenzy",
	Category = "Sidearm",
	Price = 450,
	WallPen = "Low",
	FireRate = 10,
	MagazineSize = 13,
	ReserveAmmo = 39,
	ReloadTime = 1.5,
	EquipTime = 1.0,
	WalkSpeedStuds = 13.6,
	WalkSpeedPct = 85,
	FirstBulletAccuracy = 0.65,
	FireMode = "FullAuto",
	Damage = {
		{ MaxRange = m(20), Head = 78, Body = 26, Leg = 22 },
		{ MaxRange = m(50), Head = 63, Body = 21, Leg = 17 },
	},
	Recoil = { Vertical = 1.5, Horizontal = 0.4, Pattern = "Medium" },
	Notes = "Only full-auto pistol. ~3 HS-tap kills, 7-8 body shots.",
}

WeaponDatabase.Ghost = {
	DisplayName = "Ghost",
	Category = "Sidearm",
	Price = 500,
	WallPen = "Medium",
	FireRate = 6.75,
	MagazineSize = 15,
	ReserveAmmo = 45,
	ReloadTime = 1.5,
	EquipTime = 0.75,
	WalkSpeedStuds = 13.6,
	WalkSpeedPct = 85,
	FirstBulletAccuracy = 0.3,
	FireMode = "SemiAuto",
	Silenced = true,
	Damage = {
		{ MaxRange = m(30), Head = 105, Body = 30, Leg = 26 },
		{ MaxRange = m(50), Head = 87, Body = 25, Leg = 21 },
	},
	Recoil = { Vertical = 0.8, Horizontal = 0.2, Pattern = "Light" },
	Notes = "Silenced (no audible direction at 40m+). 2-tap HS unarmored. Pistol-round meta.",
}

WeaponDatabase.Sheriff = {
	DisplayName = "Sheriff",
	Category = "Sidearm",
	Price = 800,
	WallPen = "High",
	FireRate = 4,
	MagazineSize = 6,
	ReserveAmmo = 24,
	ReloadTime = 2.25,
	EquipTime = 1.0,
	WalkSpeedStuds = 12.8,
	WalkSpeedPct = 80,
	FirstBulletAccuracy = 0.25,
	FireMode = "SemiAuto",
	Damage = {
		{ MaxRange = m(30), Head = 159, Body = 55, Leg = 47 },
		{ MaxRange = m(50), Head = 145, Body = 50, Leg = 42 },
	},
	WallbangBody = 125,
	Recoil = { Vertical = 3.5, Horizontal = 0.8, Pattern = "Heavy" },
	Notes = "ONE-SHOT HEADSHOT at any range, through any armor. Hardest pistol to control.",
}

-- ============================================================
-- SMGs
-- ============================================================

WeaponDatabase.Stinger = {
	DisplayName = "Stinger",
	Category = "SMG",
	Price = 1100,
	WallPen = "Low",
	FireRate = 16,
	FireRateADS = 8.47,
	MagazineSize = 20,
	ReserveAmmo = 60,
	ReloadTime = 2.25,
	EquipTime = 0.75,
	WalkSpeedStuds = 13.6,
	WalkSpeedPct = 85,
	FirstBulletAccuracy = 0.65,
	FireMode = "FullAuto",
	ADSMode = "FourRoundBurst",
	Damage = {
		{ MaxRange = m(9), Head = 67, Body = 27, Leg = 23 },
		{ MaxRange = m(15), Head = 52, Body = 21, Leg = 18 },
		{ MaxRange = m(50), Head = 42, Body = 17, Leg = 14 },
	},
	Recoil = { Vertical = 2.0, Horizontal = 1.5, Pattern = "Heavy" },
	Notes = "Fastest RPM in game. Melts close range, ineffective past 15m. ADS = 4-round tight burst.",
}

WeaponDatabase.Spectre = {
	DisplayName = "Spectre",
	Category = "SMG",
	Price = 1600,
	WallPen = "Medium",
	FireRate = 13.33,
	FireRateADS = 12,
	MagazineSize = 30,
	ReserveAmmo = 90,
	ReloadTime = 2.25,
	EquipTime = 0.75,
	WalkSpeedStuds = 13.6,
	WalkSpeedPct = 85,
	FirstBulletAccuracy = 0.4,
	FireMode = "FullAuto",
	Silenced = true,
	Damage = {
		{ MaxRange = m(15), Head = 78, Body = 26, Leg = 22 },
		{ MaxRange = m(30), Head = 66, Body = 22, Leg = 19 },
		{ MaxRange = m(50), Head = 60, Body = 20, Leg = 17 },
	},
	Recoil = { Vertical = 1.5, Horizontal = 0.8, Pattern = "Medium" },
	Notes = "Eco-round meta. Silenced (no tracers, quiet). The 'second rifle'.",
}

-- ============================================================
-- SHOTGUNS
-- ============================================================

WeaponDatabase.Bucky = {
	DisplayName = "Bucky",
	Category = "Shotgun",
	Price = 850,
	WallPen = "Low",
	FireRate = 1.1,
	MagazineSize = 5,
	ReserveAmmo = 10,
	ReloadTime = 2.5,
	ReloadPerShell = 0.5,
	CanCancelReload = true,
	EquipTime = 1.0,
	WalkSpeedStuds = 12.1,
	WalkSpeedPct = 75,
	FirstBulletAccuracy = 3.0,
	FireMode = "SemiAutoShotgun",
	PelletCount = 15,
	Damage = {
		{ MaxRange = m(8), Head = 40, Body = 20, Leg = 17 },
		{ MaxRange = m(12), Head = 26, Body = 13, Leg = 11 },
		{ MaxRange = m(50), Head = 18, Body = 9, Leg = 7 },
	},
	AltFire = {
		Type = "Airburst",
		Pellets = 5,
		DetonateRange = m(8),
		Notes = "Single projectile that detonates at ~8m into tight cone for mid-range",
	},
	Recoil = { Vertical = 3.0, Horizontal = 0.5, Pattern = "Heavy" },
	Notes = "Patch 12.09: body dmg 20→17. Primary blast + airburst alt-fire.",
}

WeaponDatabase.Judge = {
	DisplayName = "Judge",
	Category = "Shotgun",
	Price = 1850,
	WallPen = "Medium",
	FireRate = 3.5,
	MagazineSize = 5,
	ReserveAmmo = 10,
	ReloadTime = 2.2,
	EquipTime = 1.0,
	WalkSpeedStuds = 12.1,
	WalkSpeedPct = 75,
	FirstBulletAccuracy = 2.5,
	FireMode = "FullAutoShotgun",
	PelletCount = 12,
	Damage = {
		{ MaxRange = m(10), Head = 34, Body = 17, Leg = 14 },
		{ MaxRange = m(15), Head = 20, Body = 10, Leg = 9 },
		{ MaxRange = m(50), Head = 14, Body = 7, Leg = 6 },
	},
	Recoil = { Vertical = 2.5, Horizontal = 0.4, Pattern = "Heavy" },
	Notes = "Auto-shotgun. Melts 2-3 enemies in close fight. 15% crouched accuracy boost.",
}

-- ============================================================
-- RIFLES
-- ============================================================

WeaponDatabase.Bulldog = {
	DisplayName = "Bulldog",
	Category = "Rifle",
	Price = 2050,
	WallPen = "Medium",
	FireRate = 9.15,
	FireRateADS = 6.32,
	MagazineSize = 24,
	ReserveAmmo = 72,
	ReloadTime = 2.5,
	EquipTime = 1.0,
	WalkSpeedStuds = 12.8,
	WalkSpeedPct = 80,
	FirstBulletAccuracy = 0.3,
	FireMode = "FullAuto",
	ADSMode = "ThreeRoundBurst",
	Damage = {
		{ MaxRange = m(50), Head = 115, Body = 35, Leg = 30 },
	},
	Recoil = { Vertical = 2.0, Horizontal = 0.8, Pattern = "Medium" },
	Notes = "Cheapest rifle. No falloff. ADS = accurate 3-burst for mid-range.",
}

WeaponDatabase.Guardian = {
	DisplayName = "Guardian",
	Category = "Rifle",
	Price = 2250,
	WallPen = "High",
	FireRate = 5.25,
	FireRateADS = 4.275,
	MagazineSize = 12,
	ReserveAmmo = 36,
	ReloadTime = 2.5,
	EquipTime = 1.0,
	WalkSpeedStuds = 12.8,
	WalkSpeedPct = 80,
	FirstBulletAccuracy = 0.1,
	FirstBulletAccuracyADS = 0.0,
	FireMode = "SemiAuto",
	HasADS = true,
	ADSZoom = 1.5,
	Damage = {
		{ MaxRange = m(50), Head = 195, Body = 65, Leg = 49 },
	},
	Recoil = { Vertical = 3.0, Horizontal = 1.0, Pattern = "Per-shot reset" },
	Notes = "ONE-SHOT HEADSHOT at any range through heavy armor. 2-tap body. Excellent wallbang.",
}

WeaponDatabase.Phantom = {
	DisplayName = "Phantom",
	Category = "Rifle",
	Price = 2900,
	WallPen = "Medium",
	FireRate = 11,
	FireRateADS = 9.9,
	MagazineSize = 30,
	ReserveAmmo = 90,
	ReloadTime = 2.5,
	EquipTime = 1.0,
	WalkSpeedStuds = 12.8,
	WalkSpeedPct = 80,
	FirstBulletAccuracy = 0.2,
	FireMode = "FullAuto",
	Silenced = true,
	Damage = {
		{ MaxRange = m(15), Head = 156, Body = 39, Leg = 33 },
		{ MaxRange = m(30), Head = 140, Body = 35, Leg = 30 },
		{ MaxRange = m(50), Head = 124, Body = 31, Leg = 26 },
	},
	Recoil = { Vertical = 2.5, Horizontal = 0.6, Pattern = "Smooth-T" },
	Notes = "ONE-SHOT HS only <15m unarmored / <30m light armor. Silenced, smoother spray.",
}

WeaponDatabase.Vandal = {
	DisplayName = "Vandal",
	Category = "Rifle",
	Price = 2900,
	WallPen = "Medium",
	FireRate = 9.75,
	FireRateADS = 8.32,
	MagazineSize = 25,
	ReserveAmmo = 75,
	ReloadTime = 2.5,
	EquipTime = 1.0,
	WalkSpeedStuds = 12.8,
	WalkSpeedPct = 80,
	FirstBulletAccuracy = 0.25,
	FireMode = "FullAuto",
	Damage = {
		{ MaxRange = m(50), Head = 160, Body = 40, Leg = 34 },
	},
	Recoil = { Vertical = 3.0, Horizontal = 1.2, Pattern = "T-shape" },
	Notes = "ONE-SHOT HEADSHOT at ANY range through ANY armor. T-shape spray.",
}

-- ============================================================
-- SNIPER RIFLES
-- ============================================================

WeaponDatabase.Marshal = {
	DisplayName = "Marshal",
	Category = "Sniper",
	Price = 950,
	WallPen = "Medium",
	FireRate = 1.5,
	MagazineSize = 5,
	ReserveAmmo = 15,
	ReloadTime = 2.5,
	EquipTime = 1.25,
	WalkSpeedStuds = 14.4,
	WalkSpeedPct = 90,
	WalkSpeedScopedPct = 81,
	FirstBulletAccuracy = 0.0,  -- scoped
	FireMode = "BoltAction",
	HasScope = true,
	ScopeZoom = 2.5,
	Damage = {
		{ MaxRange = m(50), Head = 202, Body = 101, Leg = 86 },
	},
	Recoil = { Vertical = 4.0, Horizontal = 0.0, Pattern = "Bolt-reset" },
	Notes = "1-shot HS any range (kills through heavy). 1-shot body unarmored. Mobile eco sniper.",
}

WeaponDatabase.Outlaw = {
	DisplayName = "Outlaw",
	Category = "Sniper",
	Price = 2400,
	WallPen = "High",
	FireRate = 2.75,
	MagazineSize = 2,
	ReserveAmmo = 10,
	ReloadTime = 3.8,
	ReloadSingleBullet = 2.3,
	EquipTime = 1.25,
	WalkSpeedStuds = 12.8,
	WalkSpeedPct = 80,
	FirstBulletAccuracy = 0.0,  -- scoped
	FireMode = "SemiAuto",
	HasScope = true,
	ScopeZoom = { 2.5, 5.0 },
	Damage = {
		{ MaxRange = m(50), Head = 238, Body = 140, Leg = 119 },
	},
	WallbangBody = 125,
	Recoil = { Vertical = 5.0, Horizontal = 0.5, Pattern = "Per-shot" },
	Notes = "Two-shot break-action. 1-shot body on light armor. Wallbang 125 body. Bridges Marshal+Op.",
}

WeaponDatabase.Operator = {
	DisplayName = "Operator",
	Category = "Sniper",
	Price = 4700,
	WallPen = "High",
	FireRate = 0.6,
	FireRateScoped = 0.75,
	MagazineSize = 5,
	ReserveAmmo = 10,
	ReloadTime = 3.7,
	EquipTime = 1.5,
	WalkSpeedStuds = 12.2,
	WalkSpeedPct = 76,
	WalkSpeedScopedPct = 51,
	FirstBulletAccuracy = 5.0,
	FirstBulletAccuracyADS = 0.0,
	FireMode = "BoltAction",
	HasScope = true,
	ScopeZoom = { 2.5, 5.0 },
	Damage = {
		{ MaxRange = m(50), Head = 255, Body = 150, Leg = 120 },
	},
	Recoil = { Vertical = 6.0, Horizontal = 0.0, Pattern = "Bolt-reset" },
	Notes = "1-SHOT KILL anywhere (head/body/leg) at any range through any armor. Severe scope movement penalty.",
}

-- ============================================================
-- MACHINE GUNS
-- ============================================================

WeaponDatabase.Ares = {
	DisplayName = "Ares",
	Category = "MachineGun",
	Price = 1550,
	WallPen = "High",
	FireRate = 13,
	MagazineSize = 50,
	ReserveAmmo = 100,
	ReloadTime = 3.25,
	EquipTime = 1.25,
	WalkSpeedStuds = 12.2,
	WalkSpeedPct = 76,
	FirstBulletAccuracy = 1.0,
	FireMode = "FullAuto",
	HasADS = true,
	ADSZoom = 1.25,
	Damage = {
		{ MaxRange = m(30), Head = 72, Body = 30, Leg = 26 },
		{ MaxRange = m(50), Head = 67, Body = 27, Leg = 23 },
	},
	Recoil = { Vertical = 2.0, Horizontal = 1.0, Pattern = "Forgiving" },
	Notes = "Spammy wallbang weapon. ADS reduces spread. Patch removed spin-up.",
}

WeaponDatabase.Odin = {
	DisplayName = "Odin",
	Category = "MachineGun",
	Price = 3200,
	WallPen = "High",
	FireRate = 12,
	FireRateAfterSpinup = 15.6,
	SpinupTime = 0.6,
	FireRateADS = 15.6,
	MagazineSize = 100,
	ReserveAmmo = 200,
	ReloadTime = 5.0,
	EquipTime = 1.25,
	WalkSpeedStuds = 12.2,
	WalkSpeedPct = 76,
	FirstBulletAccuracy = 0.8,
	FireMode = "FullAuto",
	HasADS = true,
	ADSZoom = 1.5,
	Damage = {
		{ MaxRange = m(30), Head = 95, Body = 38, Leg = 32 },
		{ MaxRange = m(50), Head = 77, Body = 31, Leg = 26 },
	},
	Recoil = { Vertical = 2.5, Horizontal = 1.2, Pattern = "Sustained" },
	Notes = "Premier suppression/wallbang. 100-round mag. ADS bypasses spin-up. Slow reload only weakness.",
}

-- ============================================================
-- MELEE
-- ============================================================

WeaponDatabase.Knife = {
	DisplayName = "Tactical Knife",
	Category = "Melee",
	Price = 0,
	WallPen = nil,
	FireRate = 2,
	MagazineSize = math.huge,
	ReserveAmmo = math.huge,
	ReloadTime = 0,
	EquipTime = 0,
	WalkSpeedStuds = 16.0,  -- 100% base, fastest weapon held
	WalkSpeedPct = 100,
	FireMode = "Melee",
	Damage = {
		Primary = { Front = 50, Back = 100 },
		Heavy = { Front = 75, Back = 150 },
	},
	Notes = "Backstab = instant kill (≥150). ONLY weapon at 100% movement speed.",
}

-- ============================================================
-- ARMOR
-- ============================================================

WeaponDatabase.Armor = {
	LightShield = {
		DisplayName = "Light Shields",
		Cost = 400,
		MaxHp = 25,
		HpDamageMultiplier = 0.33,
		ArmorDamageMultiplier = 0.66,
		HeadshotBypassesArmor = false,
	},
	HeavyShield = {
		DisplayName = "Heavy Shields",
		Cost = 1000,
		MaxHp = 50,
		HpDamageMultiplier = 0.33,
		ArmorDamageMultiplier = 0.66,
		HeadshotBypassesArmor = false,  -- (faktycznie tylko zmniejsza, niektóre bronie i tak 1-shot HS)
	},
	Regen = false,  -- Valorant: brak regenu armoru w runde
}

-- ============================================================
-- WALL PENETRATION MULTIPLIERS
-- ============================================================

WeaponDatabase.WallPenetration = {
	Low = 0.5,
	Medium = 0.65,
	High = 0.8,
}

-- ============================================================
-- CATEGORIES (for buy menu UI)
-- ============================================================

WeaponDatabase.Categories = {
	Sidearm = { "Classic", "Shorty", "Frenzy", "Ghost", "Sheriff" },
	SMG = { "Stinger", "Spectre" },
	Shotgun = { "Bucky", "Judge" },
	Rifle = { "Bulldog", "Guardian", "Phantom", "Vandal" },
	Sniper = { "Marshal", "Outlaw", "Operator" },
	MachineGun = { "Ares", "Odin" },
	Melee = { "Knife" },
}

-- ============================================================
-- HELPER FUNCTIONS
-- ============================================================

function WeaponDatabase.GetDamageAtRange(weaponName, distance, bodyPart)
	local w = WeaponDatabase[weaponName]
	if not w or not w.Damage or not w.Damage[1] then return 0 end

	-- Knife jest specjalny
	if w.Category == "Melee" then
		return w.Damage.Primary[bodyPart] or w.Damage.Primary.Front
	end

	for _, tier in ipairs(w.Damage) do
		if distance <= tier.MaxRange then
			return tier[bodyPart] or tier.Body
		end
	end
	-- Poza max range — użyj ostatniej warstwy
	local last = w.Damage[#w.Damage]
	return last[bodyPart] or last.Body
end

function WeaponDatabase.GetWallPenMultiplier(weaponName)
	local w = WeaponDatabase[weaponName]
	if not w or not w.WallPen then return 0 end
	return WeaponDatabase.WallPenetration[w.WallPen] or 0
end

return WeaponDatabase
