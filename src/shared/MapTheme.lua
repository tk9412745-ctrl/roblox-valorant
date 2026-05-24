-- MapTheme: per-map materials + decorative props + particle effects
-- Goal: each of 6 maps has distinct visual identity, not just different floor color
-- Used by: MapBuilder.lua (in Roblox), mirrored in presentation/maps3d.html

local MapTheme = {}

-- Roblox Material enum aliases (use strings, MapBuilder converts to Enum.Material[name])
-- Available materials: Plastic, Wood, Slate, Concrete, CorrodedMetal, DiamondPlate,
-- Foil, Grass, Ice, Marble, Granite, Brick, Pebble, Sand, Fabric, SmoothPlastic,
-- Metal, WoodPlanks, Cobblestone, Air, Water, Rock, Glacier, Snow, Sandstone,
-- Mud, Basalt, Ground, CrackedLava, Neon, Glass, Asphalt, LeafyGrass, Salt,
-- Limestone, Pavement

MapTheme.Themes = {

	-- ============================================================
	-- ASCENT — Italian Renaissance, Venice
	-- ============================================================
	Ascent = {
		Materials = {
			Floor    = "Slate",       -- cobblestone-like
			Wall     = "Brick",       -- terracotta brick
			Cover    = "WoodPlanks",  -- wooden crates
			Platform = "Marble",      -- marble heaven floor
		},
		AccentColor = Color3.fromRGB(100, 140, 80),  -- green ivy
		LampColor = Color3.fromRGB(255, 220, 150),   -- warm yellow lanterns
		Props = {
			-- Central courtyard fountain (Venetian style)
			{ type = "fountain", pos = Vector3.new(0, 0, -10), size = 8 },
			-- Stone arches at site entrances
			{ type = "archway", pos = Vector3.new(-110, 0, -20), rot = 0, width = 14 },
			{ type = "archway", pos = Vector3.new(110, 0, -20), rot = 0, width = 14 },
			-- Marble statues
			{ type = "statue", pos = Vector3.new(-40, 0, -55), color = Color3.fromRGB(230, 220, 200) },
			{ type = "statue", pos = Vector3.new(40, 0, -55), color = Color3.fromRGB(230, 220, 200) },
			-- Hanging ivy on side walls
			{ type = "ivy", pos = Vector3.new(-148, 8, 60), face = "X" },
			{ type = "ivy", pos = Vector3.new(148, 8, 60), face = "-X" },
			-- Wooden barrel cluster
			{ type = "barrel_stack", pos = Vector3.new(-100, 0, -90) },
			{ type = "barrel_stack", pos = Vector3.new(100, 0, -90) },
			-- Cypress trees (Tuscan classic)
			{ type = "cypress", pos = Vector3.new(-140, 0, -120) },
			{ type = "cypress", pos = Vector3.new(140, 0, -120) },
			{ type = "cypress", pos = Vector3.new(-140, 0, 120) },
			{ type = "cypress", pos = Vector3.new(140, 0, 120) },
		},
		Particles = { type = "dust", color = Color3.fromRGB(255, 240, 200), rate = 3 },
	},

	-- ============================================================
	-- BIND — Rabat, Morocco, desert
	-- ============================================================
	Bind = {
		Materials = {
			Floor    = "Sand",        -- sand floor
			Wall     = "Sandstone",   -- sandstone walls
			Cover    = "Sandstone",   -- sandstone covers
			Platform = "Sandstone",   -- hookah & heaven
		},
		AccentColor = Color3.fromRGB(80, 110, 160),  -- blue mosaic
		LampColor = Color3.fromRGB(255, 180, 80),    -- warm Moroccan lantern
		Props = {
			-- Palm trees
			{ type = "palm", pos = Vector3.new(-30, 0, 90) },
			{ type = "palm", pos = Vector3.new(30, 0, 90) },
			{ type = "palm", pos = Vector3.new(-30, 0, -90) },
			{ type = "palm", pos = Vector3.new(30, 0, -90) },
			-- Moroccan archways (blue tile)
			{ type = "moroccan_arch", pos = Vector3.new(-50, 0, 0) },
			{ type = "moroccan_arch", pos = Vector3.new(50, 0, 0) },
			-- Hookah lanterns
			{ type = "lantern_hanging", pos = Vector3.new(75, 10, 30) },
			{ type = "lantern_hanging", pos = Vector3.new(-75, 10, 30) },
			-- Mosaic tile decorations
			{ type = "mosaic_panel", pos = Vector3.new(-120, 10, 50), face = "X" },
			{ type = "mosaic_panel", pos = Vector3.new(120, 10, 50), face = "-X" },
			-- Market stalls
			{ type = "market_stall", pos = Vector3.new(-60, 0, 70), color = Color3.fromRGB(200, 60, 60) },
			{ type = "market_stall", pos = Vector3.new(60, 0, 70), color = Color3.fromRGB(60, 100, 180) },
			-- Stone wells
			{ type = "well", pos = Vector3.new(-90, 0, -60) },
		},
		Particles = { type = "sand", color = Color3.fromRGB(255, 220, 180), rate = 5 },
	},

	-- ============================================================
	-- SPLIT — Tokyo, Japan, cyberpunk night
	-- ============================================================
	Split = {
		Materials = {
			Floor    = "Pavement",       -- asphalt city
			Wall     = "Metal",          -- metal panels
			Cover    = "Metal",          -- metal covers
			Platform = "DiamondPlate",   -- towers/rafters industrial
		},
		AccentColor = Color3.fromRGB(255, 100, 200),  -- neon pink
		LampColor = Color3.fromRGB(80, 200, 255),     -- neon blue street
		Props = {
			-- Vending machines (Tokyo street staple)
			{ type = "vending", pos = Vector3.new(-40, 0, 30), color = Color3.fromRGB(255, 100, 200) },
			{ type = "vending", pos = Vector3.new(40, 0, 30), color = Color3.fromRGB(80, 200, 255) },
			{ type = "vending", pos = Vector3.new(-40, 0, -30), color = Color3.fromRGB(50, 220, 100) },
			-- Vertical neon signs (Japanese characters)
			{ type = "neon_sign", pos = Vector3.new(-115, 10, 0), color = Color3.fromRGB(255, 100, 200), text = "シ" },
			{ type = "neon_sign", pos = Vector3.new(115, 10, 0), color = Color3.fromRGB(80, 200, 255), text = "ク" },
			{ type = "neon_sign", pos = Vector3.new(0, 12, -130), color = Color3.fromRGB(255, 200, 80), text = "東京" },
			-- Ramen stand
			{ type = "ramen_stand", pos = Vector3.new(0, 0, 40) },
			-- Power lines stretching across map
			{ type = "wire", from = Vector3.new(-115, 22, -40), to = Vector3.new(115, 22, -40) },
			{ type = "wire", from = Vector3.new(-115, 22, 40), to = Vector3.new(115, 22, 40) },
			-- Bicycle parked
			{ type = "bicycle", pos = Vector3.new(-60, 0, 0) },
			{ type = "bicycle", pos = Vector3.new(60, 0, 0) },
			-- Rooftop AC units (on tower platforms)
			{ type = "ac_unit", pos = Vector3.new(-80, 17, 60) },
			{ type = "ac_unit", pos = Vector3.new(80, 17, 60) },
		},
		Particles = { type = "neon_glow", color = Color3.fromRGB(255, 100, 200), rate = 8 },
	},

	-- ============================================================
	-- HAVEN — Bhutan, Buddhist monastery
	-- ============================================================
	Haven = {
		Materials = {
			Floor    = "Slate",
			Wall     = "Brick",         -- red monastery brick
			Cover    = "Wood",          -- carved wood
			Platform = "Brick",
		},
		AccentColor = Color3.fromRGB(255, 220, 100),  -- saffron gold
		LampColor = Color3.fromRGB(255, 200, 100),    -- candle warm
		Props = {
			-- Buddhist stupa (white tower) at site C
			{ type = "stupa", pos = Vector3.new(100, 0, 130) },
			-- Prayer flags across map (5 colored lines)
			{ type = "prayer_flags", from = Vector3.new(-130, 18, -60), to = Vector3.new(130, 18, -60) },
			{ type = "prayer_flags", from = Vector3.new(-130, 16, 60), to = Vector3.new(130, 16, 60) },
			-- Bronze bells
			{ type = "bell", pos = Vector3.new(-60, 0, 30) },
			{ type = "bell", pos = Vector3.new(60, 0, 30) },
			-- Rhododendron / cherry trees
			{ type = "tree", pos = Vector3.new(-140, 0, 140), color = Color3.fromRGB(255, 150, 200) },
			{ type = "tree", pos = Vector3.new(140, 0, 140), color = Color3.fromRGB(255, 150, 200) },
			-- Prayer wheels
			{ type = "prayer_wheel", pos = Vector3.new(-30, 0, -10) },
			{ type = "prayer_wheel", pos = Vector3.new(30, 0, -10) },
			-- Monk braziers (incense)
			{ type = "brazier", pos = Vector3.new(-100, 0, -30) },
			{ type = "brazier", pos = Vector3.new(100, 0, -30) },
		},
		Particles = { type = "incense", color = Color3.fromRGB(255, 250, 240), rate = 4 },
	},

	-- ============================================================
	-- FRACTURE — Desert research facility, post-explosion
	-- ============================================================
	Fracture = {
		Materials = {
			Floor    = "Asphalt",          -- cracked road
			Wall     = "CorrodedMetal",    -- rusty walls
			Cover    = "CorrodedMetal",
			Platform = "DiamondPlate",
		},
		AccentColor = Color3.fromRGB(255, 200, 80),   -- warning yellow
		LampColor = Color3.fromRGB(255, 100, 50),     -- emergency orange
		Props = {
			-- Wrecked vehicles (research convoy crashed)
			{ type = "wrecked_truck", pos = Vector3.new(-60, 0, -90), rot = 45 },
			{ type = "wrecked_truck", pos = Vector3.new(60, 0, 90), rot = 220 },
			{ type = "wrecked_car", pos = Vector3.new(0, 0, -70), rot = 90 },
			-- Shipping containers (research crates)
			{ type = "container", pos = Vector3.new(-70, 0, 60), color = Color3.fromRGB(160, 80, 40) },
			{ type = "container", pos = Vector3.new(70, 0, -60), color = Color3.fromRGB(60, 80, 100) },
			{ type = "container", pos = Vector3.new(70, 0, 60), color = Color3.fromRGB(80, 140, 60) },
			-- Power generators
			{ type = "generator", pos = Vector3.new(0, 0, 30) },
			{ type = "generator", pos = Vector3.new(0, 0, -30) },
			-- Antenna towers
			{ type = "antenna", pos = Vector3.new(-130, 0, -130) },
			{ type = "antenna", pos = Vector3.new(130, 0, 130) },
			-- Warning signs
			{ type = "warning_sign", pos = Vector3.new(-30, 0, 0) },
			{ type = "warning_sign", pos = Vector3.new(30, 0, 0) },
			-- Rebar/debris piles
			{ type = "rebar_pile", pos = Vector3.new(-100, 0, 100) },
			{ type = "rebar_pile", pos = Vector3.new(100, 0, -100) },
		},
		Particles = { type = "smoke", color = Color3.fromRGB(180, 120, 80), rate = 10 },
	},

	-- ============================================================
	-- LOTUS — Indian temple, ancient stone + nature
	-- ============================================================
	Lotus = {
		Materials = {
			Floor    = "Marble",
			Wall     = "Marble",
			Cover    = "Marble",
			Platform = "Granite",
		},
		AccentColor = Color3.fromRGB(80, 160, 100),  -- jungle green
		LampColor = Color3.fromRGB(255, 220, 150),   -- gold lamp
		Props = {
			-- Central lotus pond
			{ type = "lotus_pond", pos = Vector3.new(0, 0, 0), size = 12 },
			-- Buddha statue (north entrance)
			{ type = "buddha", pos = Vector3.new(0, 0, -120) },
			-- Rotating doors (the actual map mechanic — large stone wheels)
			{ type = "rotating_door", pos = Vector3.new(-50, 0, 30) },
			{ type = "rotating_door", pos = Vector3.new(50, 0, 30) },
			-- Temple pillars (carved stone)
			{ type = "pillar", pos = Vector3.new(-90, 0, 90) },
			{ type = "pillar", pos = Vector3.new(90, 0, 90) },
			{ type = "pillar", pos = Vector3.new(-90, 0, -90) },
			{ type = "pillar", pos = Vector3.new(90, 0, -90) },
			-- Vines on side walls (overgrown ruins)
			{ type = "ivy", pos = Vector3.new(-155, 10, 0), face = "X" },
			{ type = "ivy", pos = Vector3.new(155, 10, 0), face = "-X" },
			-- Stone elephant statues at entries
			{ type = "elephant_statue", pos = Vector3.new(-30, 0, -110) },
			{ type = "elephant_statue", pos = Vector3.new(30, 0, -110) },
			-- Banyan trees
			{ type = "banyan", pos = Vector3.new(-130, 0, 130) },
			{ type = "banyan", pos = Vector3.new(130, 0, 130) },
		},
		Particles = { type = "pollen", color = Color3.fromRGB(255, 220, 150), rate = 6 },
	},
}

function MapTheme.GetTheme(mapName)
	return MapTheme.Themes[mapName] or MapTheme.Themes.Ascent
end

function MapTheme.GetMaterial(mapName, slot)
	local theme = MapTheme.GetTheme(mapName)
	local matName = theme.Materials[slot] or "Concrete"
	return Enum.Material[matName] or Enum.Material.Concrete
end

return MapTheme
