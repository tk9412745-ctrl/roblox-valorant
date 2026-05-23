-- MapData: 3 mapy z Valoranta dostosowane pod Roblox (uproszczone geometrie)
-- 1 stud Roblox ≈ 1/3 metra Valorant (1m = 3 studs)
-- Każda mapa: spawny + bombsites + callouts + cover geometry

local MapData = {}

-- ============================================================
-- MAP 1: ASCENT (priority: build first)
-- ============================================================

MapData.Ascent = {
	DisplayName = "Ascent",
	Theme = "Italian Renaissance / floating Venice",
	SkyboxConfig = {
		ClockTime = 14,
		Brightness = 2.5,
		FogColor = Color3.fromRGB(220, 200, 170),
		FogStart = 200, FogEnd = 600,
		Ambient = Color3.fromRGB(100, 100, 110),
		OutdoorAmbient = Color3.fromRGB(180, 160, 130),
		SunAngularSize = 14,
		StarCount = 0,
		AtmosphereDensity = 0.25,
		AtmosphereColor = Color3.fromRGB(220, 200, 170),
	},
	ColorPalette = {
		Primary = Color3.fromRGB(220, 200, 170),  -- beige stone
		Secondary = Color3.fromRGB(180, 100, 70),  -- terracotta
		Accent = Color3.fromRGB(100, 140, 80),     -- green vines
	},
	Dimensions = { X = 300, Z = 300 },  -- studs
	Difficulty = "Easy",
	HasMid = true,
	BombSites = 2,
	SpawnAttackers = Vector3.new(0, 3, -120),
	SpawnDefenders = Vector3.new(0, 3, 120),
	Sites = {
		A = {
			PlantArea = Vector3.new(-90, 1, 60),
			Radius = 12,
			Callouts = { "A Main", "A Lobby", "A Site", "A Heaven", "Generator", "Hell", "Tree", "Garden", "Window", "Catwalk" },
			HasHeaven = true,
			HeavenHeight = 15,
		},
		B = {
			PlantArea = Vector3.new(90, 1, 60),
			Radius = 12,
			Callouts = { "B Main", "B Lobby", "B Site", "Boathouse", "Logs", "Market", "Stairs", "Triple Box" },
			HasHeaven = false,
		},
	},
	MidCallouts = { "Mid Top", "Mid Bottom", "Courtyard", "Pizza", "Catwalk", "Tiles", "Screens" },
	UltOrbs = {
		Vector3.new(-60, 3, 0),  -- Mid-A side
		Vector3.new(60, 3, 0),   -- Mid-B side
	},
	-- Geometry: cover blocks dla MVP build
	CoverBlocks = {
		-- A Main → A Site path
		{ pos = Vector3.new(-80, 4, -30), size = Vector3.new(2, 8, 12), name = "A Main Wall" },
		{ pos = Vector3.new(-100, 3, 30), size = Vector3.new(8, 6, 8), name = "A Generator" },
		{ pos = Vector3.new(-90, 4, 90), size = Vector3.new(12, 8, 2), name = "A Heaven Wall" },
		-- B Main → B Site path
		{ pos = Vector3.new(80, 4, -30), size = Vector3.new(2, 8, 12), name = "B Main Wall" },
		{ pos = Vector3.new(95, 3, 50), size = Vector3.new(6, 6, 4), name = "Triple Box" },
		{ pos = Vector3.new(80, 4, 90), size = Vector3.new(8, 8, 4), name = "Boathouse" },
		-- Mid Courtyard
		{ pos = Vector3.new(0, 4, 0), size = Vector3.new(4, 8, 4), name = "Mid Pillar" },
		{ pos = Vector3.new(-30, 4, 30), size = Vector3.new(8, 8, 2), name = "Catwalk Wall" },
		{ pos = Vector3.new(30, 4, -30), size = Vector3.new(8, 8, 2), name = "Pizza Wall" },
		-- Defender side cover
		{ pos = Vector3.new(-40, 4, 70), size = Vector3.new(2, 8, 20), name = "A CT" },
		{ pos = Vector3.new(40, 4, 70), size = Vector3.new(2, 8, 20), name = "B CT" },
	},
	-- Heaven platform A
	Platforms = {
		{ pos = Vector3.new(-90, 16, 80), size = Vector3.new(30, 1, 20), name = "A Heaven" },
	},
}

-- ============================================================
-- MAP 2: BIND (priority: build second)
-- ============================================================

MapData.Bind = {
	DisplayName = "Bind",
	Theme = "Rabat, Morocco / desert Mediterranean",
	SkyboxConfig = {
		ClockTime = 11,
		Brightness = 3.0,
		FogColor = Color3.fromRGB(255, 220, 180),
		FogStart = 250, FogEnd = 700,
		Ambient = Color3.fromRGB(140, 110, 80),
		OutdoorAmbient = Color3.fromRGB(220, 180, 130),
		SunAngularSize = 18,
		StarCount = 0,
		AtmosphereDensity = 0.4,
		AtmosphereColor = Color3.fromRGB(255, 220, 180),
		HazeBoost = true,
	},
	ColorPalette = {
		Primary = Color3.fromRGB(230, 180, 120),   -- sandstone
		Secondary = Color3.fromRGB(200, 110, 70),  -- dusty orange
		Accent = Color3.fromRGB(80, 110, 160),     -- blue tile mosaics
	},
	Dimensions = { X = 250, Z = 250 },
	Difficulty = "Easy-Medium",
	HasMid = false,  -- BIND'S SIGNATURE: no mid, only teleporters
	BombSites = 2,
	SpawnAttackers = Vector3.new(0, 3, -100),
	SpawnDefenders = Vector3.new(0, 3, 100),
	Sites = {
		A = {
			PlantArea = Vector3.new(-80, 1, 50),
			Radius = 12,
			Callouts = { "A Lobby", "A Short", "A Bath", "A Showers", "A Site", "A Heaven", "A Lamps", "Back Elbow", "A Default" },
			HasHeaven = true,
			HeavenHeight = 15,
		},
		B = {
			PlantArea = Vector3.new(80, 1, 50),
			Radius = 12,
			Callouts = { "B Long", "B Garden", "B Hookah", "B Window", "B Site", "B Elbow", "B Backsite", "B Hall", "B Default" },
			HasHeaven = false,
			HasHookah = true,
			HookahHeight = 10,
		},
	},
	UltOrbs = {
		Vector3.new(-50, 3, -30),
		Vector3.new(50, 3, -30),
	},
	-- Bind's teleporters (one-way)
	Teleporters = {
		{
			Name = "TP_A_to_B",
			From = Vector3.new(-50, 3, -20),  -- A Short
			To = Vector3.new(70, 11, 30),     -- B Hookah window
			AudioCue = true,  -- loud sound when used
			OneWay = true,
		},
		{
			Name = "TP_B_to_A",
			From = Vector3.new(60, 3, -50),   -- B Long
			To = Vector3.new(-75, 3, 25),     -- A Showers
			AudioCue = true,
			OneWay = true,
		},
	},
	CoverBlocks = {
		-- A side
		{ pos = Vector3.new(-60, 4, -30), size = Vector3.new(2, 8, 10), name = "A Short Wall" },
		{ pos = Vector3.new(-85, 3, 30), size = Vector3.new(6, 6, 6), name = "A Bath Cover" },
		{ pos = Vector3.new(-80, 4, 80), size = Vector3.new(10, 8, 2), name = "A Heaven Wall" },
		-- B side
		{ pos = Vector3.new(60, 4, -50), size = Vector3.new(2, 8, 30), name = "B Long Corridor" },
		{ pos = Vector3.new(85, 3, 30), size = Vector3.new(6, 6, 6), name = "B Pillar" },
		{ pos = Vector3.new(75, 6, 30), size = Vector3.new(4, 4, 4), name = "Under Hookah" },
	},
	Platforms = {
		{ pos = Vector3.new(-80, 16, 70), size = Vector3.new(20, 1, 15), name = "A Heaven" },
		{ pos = Vector3.new(70, 11, 30), size = Vector3.new(10, 1, 15), name = "B Hookah" },
	},
}

-- ============================================================
-- MAP 3: SPLIT (priority: build third — most complex)
-- ============================================================

MapData.Split = {
	DisplayName = "Split",
	Theme = "Tokyo, Japan / neon-lit cyberpunk",
	SkyboxConfig = {
		ClockTime = 21,  -- night
		Brightness = 1.5,
		FogColor = Color3.fromRGB(40, 50, 90),
		FogStart = 100, FogEnd = 400,
		Ambient = Color3.fromRGB(40, 30, 60),
		OutdoorAmbient = Color3.fromRGB(80, 60, 120),
		SunAngularSize = 0,
		MoonAngularSize = 16,
		StarCount = 5000,
		AtmosphereDensity = 0.5,
		AtmosphereColor = Color3.fromRGB(80, 60, 120),
	},
	ColorPalette = {
		Primary = Color3.fromRGB(60, 60, 80),     -- dark steel
		Secondary = Color3.fromRGB(255, 100, 200), -- neon pink
		Accent = Color3.fromRGB(80, 200, 255),    -- neon blue
	},
	Dimensions = { X = 250, Z = 280 },
	Difficulty = "Medium-Hard",
	HasMid = true,
	BombSites = 2,
	SpawnAttackers = Vector3.new(0, 3, -120),
	SpawnDefenders = Vector3.new(0, 3, 120),
	Sites = {
		A = {
			PlantArea = Vector3.new(-80, 1, 70),
			Radius = 12,
			Callouts = { "A Main", "A Ramps", "A Sewer", "A Tower", "A Heaven", "A Rafters", "A Screens", "A Site", "A Elbow", "Under Heaven" },
			HasHeaven = true,
			HeavenHeight = 15,
			HasRafters = true,
		},
		B = {
			PlantArea = Vector3.new(80, 1, 70),
			Radius = 12,
			Callouts = { "B Garage", "B Main", "B Link", "B Alley", "B Tower", "B Heaven", "B Rafters", "B Site", "Double Box", "Back Pillar" },
			HasHeaven = true,
			HeavenHeight = 15,
			HasRafters = true,
		},
	},
	MidCallouts = { "Mid Top", "Mid Bottom", "Mid Mail", "Mail Room", "Mid Vents", "Mid Cubby", "Ramen" },
	UltOrbs = {
		Vector3.new(-40, 3, 0),
		Vector3.new(40, 3, 0),
	},
	-- Split's ropes (vertical ascenders) — replace with Truss Parts in Roblox MVP
	Ropes = {
		{ Name = "Mid_Vent_Rope", from = Vector3.new(-20, 3, 0), to = Vector3.new(-20, 15, 0) },
		{ Name = "B_Tower_Rope", from = Vector3.new(70, 3, 60), to = Vector3.new(70, 15, 60) },
		{ Name = "A_Sewer_Rope", from = Vector3.new(-70, 3, -30), to = Vector3.new(-70, 12, -30) },
	},
	CoverBlocks = {
		-- A side
		{ pos = Vector3.new(-80, 4, -40), size = Vector3.new(2, 8, 6), name = "A Main Corridor" },
		{ pos = Vector3.new(-80, 3, 50), size = Vector3.new(4, 6, 4), name = "A Site Box" },
		-- B side
		{ pos = Vector3.new(80, 4, -40), size = Vector3.new(2, 8, 6), name = "B Garage" },
		{ pos = Vector3.new(80, 3, 60), size = Vector3.new(4, 6, 4), name = "Double Box" },
		-- Mid (tight corridors)
		{ pos = Vector3.new(-15, 4, 0), size = Vector3.new(2, 8, 10), name = "Mid Vent Wall" },
		{ pos = Vector3.new(15, 4, 0), size = Vector3.new(2, 8, 10), name = "Mid Mail Wall" },
		{ pos = Vector3.new(0, 4, 10), size = Vector3.new(8, 8, 2), name = "Mid Top" },
	},
	Platforms = {
		{ pos = Vector3.new(-80, 16, 60), size = Vector3.new(15, 1, 12), name = "A Tower" },
		{ pos = Vector3.new(-90, 16, 80), size = Vector3.new(8, 1, 8), name = "A Rafters" },
		{ pos = Vector3.new(80, 16, 60), size = Vector3.new(15, 1, 12), name = "B Tower" },
		{ pos = Vector3.new(90, 16, 80), size = Vector3.new(8, 1, 8), name = "B Rafters" },
		{ pos = Vector3.new(0, 8, 20), size = Vector3.new(12, 1, 8), name = "Mid Top" },
	},
}

-- ============================================================
-- HELPERS
-- ============================================================

-- ============================================================
-- MAP 4: HAVEN (3 bombsites — popularna)
-- ============================================================

MapData.Haven = {
	DisplayName = "Haven",
	Theme = "Bhutan, Buddhist monastery",
	SkyboxConfig = {
		ClockTime = 8,  -- morning
		Brightness = 2.8,
		FogColor = Color3.fromRGB(200, 220, 240),
		FogStart = 220, FogEnd = 650,
		Ambient = Color3.fromRGB(120, 130, 140),
		OutdoorAmbient = Color3.fromRGB(180, 200, 220),
		SunAngularSize = 12,
		StarCount = 0,
		AtmosphereDensity = 0.35,
		AtmosphereColor = Color3.fromRGB(200, 220, 240),
	},
	ColorPalette = {
		Primary = Color3.fromRGB(220, 200, 170),
		Secondary = Color3.fromRGB(180, 90, 60),
		Accent = Color3.fromRGB(255, 220, 100),
	},
	Dimensions = { X = 320, Z = 320 },
	Difficulty = "Medium",
	HasMid = true,
	BombSites = 3,
	SpawnAttackers = Vector3.new(0, 3, -130),
	SpawnDefenders = Vector3.new(0, 3, 130),
	Sites = {
		A = {
			PlantArea = Vector3.new(-100, 1, 70),
			Radius = 12,
			Callouts = { "A Main", "A Lobby", "A Site", "A Sewer", "Heaven", "A Long", "A Short" },
			HasHeaven = true,
			HeavenHeight = 15,
		},
		B = {
			PlantArea = Vector3.new(0, 1, 70),
			Radius = 12,
			Callouts = { "B Main", "B Site", "Mid Window", "Mid Courtyard", "B Default", "Garage" },
			HasHeaven = false,
		},
		C = {
			PlantArea = Vector3.new(100, 1, 70),
			Radius = 12,
			Callouts = { "C Main", "C Lobby", "C Site", "C Cubby", "C Long", "C Garage" },
			HasHeaven = false,
		},
	},
	MidCallouts = { "Mid", "Mid Courtyard", "Mid Window", "Mid Doors" },
	UltOrbs = {
		Vector3.new(-50, 3, 0),
		Vector3.new(50, 3, 0),
	},
	CoverBlocks = {
		-- A Site
		{ pos = Vector3.new(-95, 4, 50), size = Vector3.new(6, 8, 4), name = "A Box" },
		{ pos = Vector3.new(-110, 4, 80), size = Vector3.new(2, 8, 12), name = "A Wall" },
		{ pos = Vector3.new(-85, 4, 90), size = Vector3.new(8, 8, 2), name = "A Heaven Wall" },
		-- B Site (mid)
		{ pos = Vector3.new(0, 4, 50), size = Vector3.new(2, 8, 10), name = "B Front" },
		{ pos = Vector3.new(-12, 4, 80), size = Vector3.new(4, 8, 4), name = "B Default" },
		{ pos = Vector3.new(12, 4, 80), size = Vector3.new(4, 8, 4), name = "B Back" },
		-- C Site
		{ pos = Vector3.new(95, 4, 50), size = Vector3.new(6, 8, 4), name = "C Box" },
		{ pos = Vector3.new(110, 4, 80), size = Vector3.new(2, 8, 12), name = "C Wall" },
		{ pos = Vector3.new(85, 4, 90), size = Vector3.new(8, 8, 2), name = "C Cubby" },
		-- Mid corridor
		{ pos = Vector3.new(-30, 4, 0), size = Vector3.new(2, 8, 14), name = "Mid Wall L" },
		{ pos = Vector3.new(30, 4, 0), size = Vector3.new(2, 8, 14), name = "Mid Wall R" },
		-- Attacker side
		{ pos = Vector3.new(-60, 4, -50), size = Vector3.new(2, 8, 16), name = "A Lobby" },
		{ pos = Vector3.new(60, 4, -50), size = Vector3.new(2, 8, 16), name = "C Lobby" },
	},
	Platforms = {
		{ pos = Vector3.new(-95, 16, 90), size = Vector3.new(20, 1, 16), name = "A Heaven" },
	},
}

-- ============================================================
-- MAP 5: FRACTURE (H-shape, 2 sites, 4 ult orbs)
-- ============================================================

MapData.Fracture = {
	DisplayName = "Fracture",
	Theme = "Desert research facility, post-explosion",
	SkyboxConfig = {
		ClockTime = 17,
		Brightness = 2.0,
		FogColor = Color3.fromRGB(220, 160, 100),
		FogStart = 200, FogEnd = 550,
		Ambient = Color3.fromRGB(120, 90, 60),
		OutdoorAmbient = Color3.fromRGB(220, 170, 100),
		SunAngularSize = 16,
		AtmosphereDensity = 0.4,
		AtmosphereColor = Color3.fromRGB(220, 160, 100),
	},
	ColorPalette = {
		Primary = Color3.fromRGB(200, 160, 110),
		Secondary = Color3.fromRGB(140, 100, 70),
		Accent = Color3.fromRGB(255, 200, 80),
	},
	Dimensions = { X = 300, Z = 300 },
	Difficulty = "Hard",
	HasMid = false,  -- H-shape — attackers spawn on north AND south
	BombSites = 2,
	SpawnAttackers = Vector3.new(0, 3, -130),  -- simplified (real Fracture has dual spawn)
	SpawnDefenders = Vector3.new(0, 3, 0),     -- center
	Sites = {
		A = {
			PlantArea = Vector3.new(-90, 1, 0),
			Radius = 12,
			Callouts = { "A Main", "A Tower", "A Drop", "A Halls", "A Site", "A Hookah" },
			HasHeaven = true,
			HeavenHeight = 15,
		},
		B = {
			PlantArea = Vector3.new(90, 1, 0),
			Radius = 12,
			Callouts = { "B Main", "B Tower", "B Generator", "B Drop", "B Tree" },
			HasHeaven = false,
		},
	},
	UltOrbs = {  -- 4 orbs (Fracture special)
		Vector3.new(-40, 3, -60),
		Vector3.new(40, 3, -60),
		Vector3.new(-40, 3, 60),
		Vector3.new(40, 3, 60),
	},
	CoverBlocks = {
		-- A side
		{ pos = Vector3.new(-80, 4, -30), size = Vector3.new(2, 8, 10), name = "A Tower" },
		{ pos = Vector3.new(-95, 3, 0), size = Vector3.new(6, 6, 4), name = "A Box" },
		{ pos = Vector3.new(-80, 4, 30), size = Vector3.new(2, 8, 10), name = "A Drop" },
		-- B side
		{ pos = Vector3.new(80, 4, -30), size = Vector3.new(2, 8, 10), name = "B Tower" },
		{ pos = Vector3.new(95, 3, 0), size = Vector3.new(6, 6, 4), name = "B Generator" },
		{ pos = Vector3.new(80, 4, 30), size = Vector3.new(2, 8, 10), name = "B Drop" },
		-- Center (defender spawn area)
		{ pos = Vector3.new(0, 4, 0), size = Vector3.new(8, 8, 8), name = "Center Bunker" },
		{ pos = Vector3.new(-30, 4, 30), size = Vector3.new(4, 6, 4), name = "Mid L" },
		{ pos = Vector3.new(30, 4, -30), size = Vector3.new(4, 6, 4), name = "Mid R" },
	},
	Platforms = {
		{ pos = Vector3.new(-95, 16, 0), size = Vector3.new(20, 1, 20), name = "A Heaven" },
	},
}

-- ============================================================
-- MAP 6: LOTUS (3 sites, rotating doors)
-- ============================================================

MapData.Lotus = {
	DisplayName = "Lotus",
	Theme = "Indian temple, ancient stone + nature",
	SkyboxConfig = {
		ClockTime = 6,  -- dawn
		Brightness = 2.2,
		FogColor = Color3.fromRGB(255, 200, 180),
		FogStart = 220, FogEnd = 600,
		Ambient = Color3.fromRGB(140, 110, 90),
		OutdoorAmbient = Color3.fromRGB(255, 200, 170),
		SunAngularSize = 14,
		AtmosphereDensity = 0.3,
		AtmosphereColor = Color3.fromRGB(255, 200, 180),
	},
	ColorPalette = {
		Primary = Color3.fromRGB(200, 170, 130),
		Secondary = Color3.fromRGB(140, 100, 70),
		Accent = Color3.fromRGB(80, 160, 100),
	},
	Dimensions = { X = 320, Z = 320 },
	Difficulty = "Medium-Hard",
	HasMid = true,
	BombSites = 3,
	SpawnAttackers = Vector3.new(0, 3, -130),
	SpawnDefenders = Vector3.new(0, 3, 130),
	Sites = {
		A = {
			PlantArea = Vector3.new(-100, 1, 60),
			Radius = 12,
			Callouts = { "A Main", "A Tree", "A Site", "A Top", "A Rubble", "A Door" },
			HasHeaven = false,
		},
		B = {
			PlantArea = Vector3.new(0, 1, 80),
			Radius = 12,
			Callouts = { "B Main", "B Site", "B Default", "B Window", "B Backsite" },
			HasHeaven = false,
		},
		C = {
			PlantArea = Vector3.new(100, 1, 60),
			Radius = 12,
			Callouts = { "C Main", "C Mound", "C Site", "C Hall", "C Lobby" },
			HasHeaven = false,
		},
	},
	MidCallouts = { "Mid", "Mid Top", "Mid Bottom" },
	UltOrbs = {
		Vector3.new(-50, 3, 0),
		Vector3.new(50, 3, 0),
	},
	CoverBlocks = {
		-- A Site
		{ pos = Vector3.new(-95, 4, 40), size = Vector3.new(6, 8, 4), name = "A Mound" },
		{ pos = Vector3.new(-105, 4, 70), size = Vector3.new(2, 8, 12), name = "A Wall" },
		-- B Site (mid)
		{ pos = Vector3.new(0, 4, 50), size = Vector3.new(8, 8, 2), name = "B Front" },
		{ pos = Vector3.new(-10, 4, 90), size = Vector3.new(4, 8, 4), name = "B Default" },
		{ pos = Vector3.new(10, 4, 90), size = Vector3.new(4, 8, 4), name = "B Back" },
		-- C Site
		{ pos = Vector3.new(95, 4, 40), size = Vector3.new(6, 8, 4), name = "C Mound" },
		{ pos = Vector3.new(105, 4, 70), size = Vector3.new(2, 8, 12), name = "C Wall" },
		-- Mid corridor
		{ pos = Vector3.new(-25, 4, 0), size = Vector3.new(2, 8, 12), name = "Mid Wall L" },
		{ pos = Vector3.new(25, 4, 0), size = Vector3.new(2, 8, 12), name = "Mid Wall R" },
	},
	Platforms = {},
}

function MapData.GetByName(name)
	return MapData[name]
end

function MapData.GetAllMaps()
	return { "Ascent", "Bind", "Split", "Haven", "Fracture", "Lotus" }
end

function MapData.GetEasiestMap()
	return MapData.Ascent
end

return MapData
