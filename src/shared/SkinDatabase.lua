-- SkinDatabase: definicje skinów dla broni
-- Każdy skin ma: id, weapon, tier, displayName, color, material, optional mesh asset
-- Tier 1-5 (Standard, Refined, Elite, Legendary, Mythic) wzorowane na Valorant

local SkinDatabase = {}

SkinDatabase.Skins = {
	-- ============================================================
	-- Tier 1 — Standard (texture/color variant only)
	-- ============================================================
	default_vandal = {
		Id = "default_vandal",
		Weapon = "Vandal",
		Tier = 1,
		DisplayName = "Standard Vandal",
		Color = Color3.fromRGB(80, 80, 80),
		Material = Enum.Material.Metal,
		IsDefault = true,
	},
	steel_vandal = {
		Id = "steel_vandal",
		Weapon = "Vandal",
		Tier = 1,
		DisplayName = "Steel Vandal",
		Color = Color3.fromRGB(140, 140, 160),
		Material = Enum.Material.Metal,
	},
	rust_vandal = {
		Id = "rust_vandal",
		Weapon = "Vandal",
		Tier = 1,
		DisplayName = "Rust Vandal",
		Color = Color3.fromRGB(180, 100, 50),
		Material = Enum.Material.CorrodedMetal,
	},
	default_phantom = {
		Id = "default_phantom",
		Weapon = "Phantom",
		Tier = 1,
		DisplayName = "Standard Phantom",
		Color = Color3.fromRGB(70, 70, 70),
		Material = Enum.Material.Metal,
		IsDefault = true,
	},
	default_ghost = {
		Id = "default_ghost",
		Weapon = "Ghost",
		Tier = 1,
		DisplayName = "Standard Ghost",
		Color = Color3.fromRGB(60, 60, 60),
		Material = Enum.Material.Metal,
		IsDefault = true,
	},
	default_sheriff = {
		Id = "default_sheriff",
		Weapon = "Sheriff",
		Tier = 1,
		DisplayName = "Standard Sheriff",
		Color = Color3.fromRGB(50, 30, 20),
		Material = Enum.Material.Wood,
		IsDefault = true,
	},
	default_operator = {
		Id = "default_operator",
		Weapon = "Operator",
		Tier = 1,
		DisplayName = "Standard Operator",
		Color = Color3.fromRGB(40, 50, 60),
		Material = Enum.Material.Metal,
		IsDefault = true,
	},

	-- ============================================================
	-- Tier 2 — Refined (custom mesh + equip animation + 1 chroma)
	-- ============================================================
	neon_vandal = {
		Id = "neon_vandal",
		Weapon = "Vandal",
		Tier = 2,
		DisplayName = "Neon Vandal",
		Color = Color3.fromRGB(0, 255, 200),
		Material = Enum.Material.Neon,
		HasEquipAnim = true,
		Chromas = { Color3.fromRGB(255, 100, 200) },
	},
	gold_phantom = {
		Id = "gold_phantom",
		Weapon = "Phantom",
		Tier = 2,
		DisplayName = "Gold Phantom",
		Color = Color3.fromRGB(255, 215, 0),
		Material = Enum.Material.Metal,
		HasEquipAnim = true,
	},

	-- ============================================================
	-- Tier 3 — Elite (custom reload anim + fire VFX + kill banner + 3 chromas)
	-- ============================================================
	prime_vandal = {
		Id = "prime_vandal",
		Weapon = "Vandal",
		Tier = 3,
		DisplayName = "Prime Vandal",
		Color = Color3.fromRGB(200, 220, 240),
		Material = Enum.Material.SmoothPlastic,
		HasEquipAnim = true,
		HasReloadAnim = true,
		HasFireVFX = true,
		HasKillBanner = true,
		Chromas = {
			Color3.fromRGB(255, 100, 100),
			Color3.fromRGB(100, 255, 100),
			Color3.fromRGB(100, 100, 255),
		},
	},
	reaver_phantom = {
		Id = "reaver_phantom",
		Weapon = "Phantom",
		Tier = 3,
		DisplayName = "Reaver Phantom",
		Color = Color3.fromRGB(150, 80, 220),
		Material = Enum.Material.Neon,
		HasEquipAnim = true,
		HasReloadAnim = true,
		HasFireVFX = true,
		HasKillBanner = true,
	},

	-- ============================================================
	-- Tier 4 — Legendary (finisher animation + variant kill counter)
	-- ============================================================
	champions_vandal = {
		Id = "champions_vandal",
		Weapon = "Vandal",
		Tier = 4,
		DisplayName = "Champions Vandal",
		Color = Color3.fromRGB(255, 215, 0),
		Material = Enum.Material.ForceField,
		HasEquipAnim = true,
		HasReloadAnim = true,
		HasFireVFX = true,
		HasKillBanner = true,
		HasFinisher = true,
		HasKillCounter = true,
		LimitedTime = true,
	},

	-- ============================================================
	-- Tier 5 — Mythic (evolving form + custom death effect)
	-- ============================================================
	elder_flame_vandal = {
		Id = "elder_flame_vandal",
		Weapon = "Vandal",
		Tier = 5,
		DisplayName = "Elder Flame Vandal",
		Color = Color3.fromRGB(255, 60, 0),
		Material = Enum.Material.Neon,
		HasEquipAnim = true,
		HasReloadAnim = true,
		HasFireVFX = true,
		HasKillBanner = true,
		HasFinisher = true,
		HasKillCounter = true,
		HasEvolvingForm = true,
		HasCustomDeathEffect = true,
		BundleOnly = true,
	},

	-- ============================================================
	-- EXTENDED CATALOG (Sprint 68)
	-- ============================================================

	-- Vandal extras
	forest_vandal = { Id = "forest_vandal", Weapon = "Vandal", Tier = 1, DisplayName = "Forest Vandal", Color = Color3.fromRGB(50, 80, 40), Material = Enum.Material.SmoothPlastic },
	arctic_vandal = { Id = "arctic_vandal", Weapon = "Vandal", Tier = 1, DisplayName = "Arctic Vandal", Color = Color3.fromRGB(220, 230, 245), Material = Enum.Material.Ice },
	sovereign_vandal = { Id = "sovereign_vandal", Weapon = "Vandal", Tier = 2, DisplayName = "Sovereign Vandal", Color = Color3.fromRGB(180, 160, 240), Material = Enum.Material.Marble, HasEquipAnim = true },
	oni_vandal = { Id = "oni_vandal", Weapon = "Vandal", Tier = 3, DisplayName = "Oni Vandal", Color = Color3.fromRGB(220, 50, 50), Material = Enum.Material.Neon, HasEquipAnim = true, HasReloadAnim = true, HasFireVFX = true, HasKillBanner = true },

	-- Phantom extras
	gunslinger_phantom = { Id = "gunslinger_phantom", Weapon = "Phantom", Tier = 1, DisplayName = "Gunslinger", Color = Color3.fromRGB(180, 120, 50), Material = Enum.Material.Wood },
	infinity_phantom = { Id = "infinity_phantom", Weapon = "Phantom", Tier = 2, DisplayName = "Infinity", Color = Color3.fromRGB(80, 60, 240), Material = Enum.Material.Neon, HasEquipAnim = true },
	ion_phantom = { Id = "ion_phantom", Weapon = "Phantom", Tier = 3, DisplayName = "Ion", Color = Color3.fromRGB(255, 255, 255), Material = Enum.Material.Neon, HasEquipAnim = true, HasReloadAnim = true, HasFireVFX = true, HasKillBanner = true },

	-- Ghost extras
	prime_ghost = { Id = "prime_ghost", Weapon = "Ghost", Tier = 3, DisplayName = "Prime Ghost", Color = Color3.fromRGB(220, 220, 230), Material = Enum.Material.SmoothPlastic, HasEquipAnim = true, HasReloadAnim = true, HasFireVFX = true, HasKillBanner = true },
	reaver_ghost = { Id = "reaver_ghost", Weapon = "Ghost", Tier = 3, DisplayName = "Reaver Ghost", Color = Color3.fromRGB(150, 80, 220), Material = Enum.Material.Neon, HasEquipAnim = true, HasReloadAnim = true, HasFireVFX = true, HasKillBanner = true },
	champions_ghost = { Id = "champions_ghost", Weapon = "Ghost", Tier = 4, DisplayName = "Champions Ghost", Color = Color3.fromRGB(255, 215, 0), Material = Enum.Material.ForceField, HasEquipAnim = true, HasReloadAnim = true, HasFireVFX = true, HasKillBanner = true, HasFinisher = true, HasKillCounter = true, LimitedTime = true },

	-- Sheriff extras
	prime_sheriff = { Id = "prime_sheriff", Weapon = "Sheriff", Tier = 3, DisplayName = "Prime Sheriff", Color = Color3.fromRGB(200, 220, 240), Material = Enum.Material.Metal, HasEquipAnim = true, HasReloadAnim = true, HasFireVFX = true, HasKillBanner = true },
	magepunk_sheriff = { Id = "magepunk_sheriff", Weapon = "Sheriff", Tier = 3, DisplayName = "Magepunk Sheriff", Color = Color3.fromRGB(180, 90, 220), Material = Enum.Material.Metal, HasEquipAnim = true, HasReloadAnim = true, HasFireVFX = true, HasKillBanner = true },

	-- Operator extras
	prime_operator = { Id = "prime_operator", Weapon = "Operator", Tier = 3, DisplayName = "Prime Operator", Color = Color3.fromRGB(200, 220, 240), Material = Enum.Material.SmoothPlastic, HasEquipAnim = true, HasReloadAnim = true, HasFireVFX = true, HasKillBanner = true },
	reaver_operator = { Id = "reaver_operator", Weapon = "Operator", Tier = 3, DisplayName = "Reaver Operator", Color = Color3.fromRGB(150, 80, 220), Material = Enum.Material.Neon, HasEquipAnim = true, HasReloadAnim = true, HasFireVFX = true, HasKillBanner = true },
	cyber_operator = { Id = "cyber_operator", Weapon = "Operator", Tier = 5, DisplayName = "Cyber Operator", Color = Color3.fromRGB(80, 200, 255), Material = Enum.Material.Neon, HasEquipAnim = true, HasReloadAnim = true, HasFireVFX = true, HasKillBanner = true, HasFinisher = true, HasKillCounter = true, HasEvolvingForm = true, HasCustomDeathEffect = true, BundleOnly = true },

	-- Default + variants for other weapons
	default_classic = { Id = "default_classic", Weapon = "Classic", Tier = 1, DisplayName = "Standard Classic", Color = Color3.fromRGB(60, 60, 70), Material = Enum.Material.Metal, IsDefault = true },
	gold_classic = { Id = "gold_classic", Weapon = "Classic", Tier = 2, DisplayName = "Gold Classic", Color = Color3.fromRGB(255, 215, 0), Material = Enum.Material.Metal, HasEquipAnim = true },

	default_shorty = { Id = "default_shorty", Weapon = "Shorty", Tier = 1, DisplayName = "Standard Shorty", Color = Color3.fromRGB(60, 40, 30), Material = Enum.Material.Wood, IsDefault = true },
	rusty_shorty = { Id = "rusty_shorty", Weapon = "Shorty", Tier = 1, DisplayName = "Rusty Shorty", Color = Color3.fromRGB(180, 90, 50), Material = Enum.Material.CorrodedMetal },

	default_frenzy = { Id = "default_frenzy", Weapon = "Frenzy", Tier = 1, DisplayName = "Standard Frenzy", Color = Color3.fromRGB(50, 50, 60), Material = Enum.Material.Metal, IsDefault = true },
	neon_frenzy = { Id = "neon_frenzy", Weapon = "Frenzy", Tier = 2, DisplayName = "Neon Frenzy", Color = Color3.fromRGB(255, 100, 200), Material = Enum.Material.Neon, HasEquipAnim = true },

	default_stinger = { Id = "default_stinger", Weapon = "Stinger", Tier = 1, DisplayName = "Standard Stinger", Color = Color3.fromRGB(50, 50, 60), Material = Enum.Material.Metal, IsDefault = true },
	default_spectre = { Id = "default_spectre", Weapon = "Spectre", Tier = 1, DisplayName = "Standard Spectre", Color = Color3.fromRGB(50, 50, 60), Material = Enum.Material.Metal, IsDefault = true },
	default_bucky = { Id = "default_bucky", Weapon = "Bucky", Tier = 1, DisplayName = "Standard Bucky", Color = Color3.fromRGB(60, 40, 30), Material = Enum.Material.Wood, IsDefault = true },
	default_judge = { Id = "default_judge", Weapon = "Judge", Tier = 1, DisplayName = "Standard Judge", Color = Color3.fromRGB(50, 50, 60), Material = Enum.Material.Metal, IsDefault = true },
	default_bulldog = { Id = "default_bulldog", Weapon = "Bulldog", Tier = 1, DisplayName = "Standard Bulldog", Color = Color3.fromRGB(40, 40, 45), Material = Enum.Material.Metal, IsDefault = true },
	default_guardian = { Id = "default_guardian", Weapon = "Guardian", Tier = 1, DisplayName = "Standard Guardian", Color = Color3.fromRGB(40, 40, 45), Material = Enum.Material.Metal, IsDefault = true },
	default_marshal = { Id = "default_marshal", Weapon = "Marshal", Tier = 1, DisplayName = "Standard Marshal", Color = Color3.fromRGB(35, 40, 50), Material = Enum.Material.Metal, IsDefault = true },
	default_outlaw = { Id = "default_outlaw", Weapon = "Outlaw", Tier = 1, DisplayName = "Standard Outlaw", Color = Color3.fromRGB(120, 80, 50), Material = Enum.Material.Wood, IsDefault = true },
	default_ares = { Id = "default_ares", Weapon = "Ares", Tier = 1, DisplayName = "Standard Ares", Color = Color3.fromRGB(45, 45, 55), Material = Enum.Material.Metal, IsDefault = true },
	default_odin = { Id = "default_odin", Weapon = "Odin", Tier = 1, DisplayName = "Standard Odin", Color = Color3.fromRGB(45, 45, 55), Material = Enum.Material.Metal, IsDefault = true },
	default_knife = { Id = "default_knife", Weapon = "Knife", Tier = 1, DisplayName = "Tactical Knife", Color = Color3.fromRGB(200, 200, 210), Material = Enum.Material.Metal, IsDefault = true },

	-- Knife premium skins
	karambit_knife = { Id = "karambit_knife", Weapon = "Knife", Tier = 4, DisplayName = "Karambit", Color = Color3.fromRGB(220, 220, 240), Material = Enum.Material.Metal, HasEquipAnim = true, HasFireVFX = true, HasFinisher = true, LimitedTime = true },
	butterfly_knife = { Id = "butterfly_knife", Weapon = "Knife", Tier = 4, DisplayName = "Butterfly Knife", Color = Color3.fromRGB(200, 180, 240), Material = Enum.Material.Metal, HasEquipAnim = true, HasFireVFX = true, HasFinisher = true, LimitedTime = true },
	dragon_dagger = { Id = "dragon_dagger", Weapon = "Knife", Tier = 5, DisplayName = "Dragon Dagger", Color = Color3.fromRGB(255, 80, 30), Material = Enum.Material.Neon, HasEquipAnim = true, HasFireVFX = true, HasFinisher = true, HasEvolvingForm = true, BundleOnly = true },
}

function SkinDatabase.Get(skinId)
	return SkinDatabase.Skins[skinId]
end

function SkinDatabase.GetForWeapon(weaponName)
	local result = {}
	for _, skin in pairs(SkinDatabase.Skins) do
		if skin.Weapon == weaponName then
			table.insert(result, skin)
		end
	end
	return result
end

function SkinDatabase.GetDefaultForWeapon(weaponName)
	for _, skin in pairs(SkinDatabase.Skins) do
		if skin.Weapon == weaponName and skin.IsDefault then
			return skin
		end
	end
	return nil
end

function SkinDatabase.GetByTier(tier)
	local result = {}
	for _, skin in pairs(SkinDatabase.Skins) do
		if skin.Tier == tier then
			table.insert(result, skin)
		end
	end
	return result
end

return SkinDatabase
