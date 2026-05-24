-- MapTheme: per-map materials + buildings + decorative props + floor patches + atmosphere
-- Goal: each of 6 maps looks like a REAL location, not just a flat plane with a few props
-- Used by: MapBuilder.lua (in Roblox), mirrored in presentation/maps3d.html

local MapTheme = {}

MapTheme.Themes = {

	-- ============================================================
	-- ASCENT — Italian Renaissance, Venice
	-- ============================================================
	Ascent = {
		Materials = {
			Floor    = "Slate",
			Wall     = "Brick",
			Cover    = "WoodPlanks",
			Platform = "Marble",
		},
		AccentColor = Color3.fromRGB(100, 140, 80),
		LampColor = Color3.fromRGB(255, 220, 150),

		-- Perimeter buildings forming actual streets
		Buildings = {
			-- North row (defender side, 3-storey villas)
			{ pos = Vector3.new(-110, 0, 130), size = Vector3.new(50, 40, 35), color = Color3.fromRGB(220, 180, 130), roofColor = Color3.fromRGB(180, 80, 50), windows = 6, hasBalcony = true },
			{ pos = Vector3.new(-40, 0, 135), size = Vector3.new(40, 32, 25), color = Color3.fromRGB(230, 190, 140), roofColor = Color3.fromRGB(160, 70, 50), windows = 4 },
			{ pos = Vector3.new(40, 0, 135), size = Vector3.new(40, 36, 25), color = Color3.fromRGB(210, 170, 120), roofColor = Color3.fromRGB(180, 80, 50), windows = 5 },
			{ pos = Vector3.new(120, 0, 130), size = Vector3.new(55, 42, 35), color = Color3.fromRGB(230, 195, 145), roofColor = Color3.fromRGB(170, 75, 55), windows = 7, hasBalcony = true },
			-- South row (attacker side)
			{ pos = Vector3.new(-110, 0, -130), size = Vector3.new(50, 38, 35), color = Color3.fromRGB(215, 175, 125), roofColor = Color3.fromRGB(180, 85, 55), windows = 6 },
			{ pos = Vector3.new(-40, 0, -135), size = Vector3.new(45, 34, 25), color = Color3.fromRGB(225, 185, 135), roofColor = Color3.fromRGB(165, 75, 50), windows = 5 },
			{ pos = Vector3.new(40, 0, -135), size = Vector3.new(45, 36, 25), color = Color3.fromRGB(220, 180, 130), roofColor = Color3.fromRGB(180, 80, 50), windows = 5 },
			{ pos = Vector3.new(120, 0, -130), size = Vector3.new(50, 40, 35), color = Color3.fromRGB(225, 185, 135), roofColor = Color3.fromRGB(170, 75, 55), windows = 6, hasBalcony = true },
			-- East row
			{ pos = Vector3.new(140, 0, 30), size = Vector3.new(25, 32, 50), color = Color3.fromRGB(220, 180, 130), roofColor = Color3.fromRGB(175, 80, 55), windows = 6 },
			{ pos = Vector3.new(140, 0, -30), size = Vector3.new(25, 30, 50), color = Color3.fromRGB(225, 185, 135), roofColor = Color3.fromRGB(165, 75, 50), windows = 5 },
			-- West row
			{ pos = Vector3.new(-140, 0, 30), size = Vector3.new(25, 32, 50), color = Color3.fromRGB(220, 180, 130), roofColor = Color3.fromRGB(175, 80, 55), windows = 6 },
			{ pos = Vector3.new(-140, 0, -30), size = Vector3.new(25, 30, 50), color = Color3.fromRGB(225, 185, 135), roofColor = Color3.fromRGB(165, 75, 50), windows = 5 },
		},

		-- Floor patches (color variation breaking up monotone floor)
		FloorPatches = {
			{ pos = Vector3.new(0, 0, 0), size = Vector3.new(60, 0, 60), color = Color3.fromRGB(200, 170, 130), material = "Cobblestone" },   -- mid plaza
			{ pos = Vector3.new(-90, 0, 60), size = Vector3.new(30, 0, 30), color = Color3.fromRGB(180, 150, 100), material = "Cobblestone" }, -- A site plaza
			{ pos = Vector3.new(90, 0, 60), size = Vector3.new(30, 0, 30), color = Color3.fromRGB(180, 150, 100), material = "Cobblestone" },  -- B site plaza
			-- Walking paths
			{ pos = Vector3.new(0, 0, -60), size = Vector3.new(15, 0, 80), color = Color3.fromRGB(190, 165, 115), material = "Slate" },
			{ pos = Vector3.new(0, 0, 60), size = Vector3.new(15, 0, 80), color = Color3.fromRGB(190, 165, 115), material = "Slate" },
			-- Garden patches (green)
			{ pos = Vector3.new(-115, 0, 30), size = Vector3.new(15, 0, 25), color = Color3.fromRGB(80, 130, 60), material = "Grass" },
			{ pos = Vector3.new(115, 0, 30), size = Vector3.new(15, 0, 25), color = Color3.fromRGB(80, 130, 60), material = "Grass" },
			{ pos = Vector3.new(-115, 0, -30), size = Vector3.new(15, 0, 25), color = Color3.fromRGB(80, 130, 60), material = "Grass" },
			{ pos = Vector3.new(115, 0, -30), size = Vector3.new(15, 0, 25), color = Color3.fromRGB(80, 130, 60), material = "Grass" },
		},

		Props = {
			-- Central area
			{ type = "fountain", pos = Vector3.new(0, 0, -10), size = 8 },
			{ type = "fountain", pos = Vector3.new(0, 0, 50), size = 6 },
			-- Archways at site entrances
			{ type = "archway", pos = Vector3.new(-110, 0, -20), width = 14 },
			{ type = "archway", pos = Vector3.new(110, 0, -20), width = 14 },
			{ type = "archway", pos = Vector3.new(-90, 0, 30), width = 12 },
			{ type = "archway", pos = Vector3.new(90, 0, 30), width = 12 },
			-- Marble statues throughout
			{ type = "statue", pos = Vector3.new(-40, 0, -55), color = Color3.fromRGB(230, 220, 200) },
			{ type = "statue", pos = Vector3.new(40, 0, -55), color = Color3.fromRGB(230, 220, 200) },
			{ type = "statue", pos = Vector3.new(-80, 0, 110), color = Color3.fromRGB(220, 210, 190) },
			{ type = "statue", pos = Vector3.new(80, 0, 110), color = Color3.fromRGB(220, 210, 190) },
			-- Cypress trees lining the map
			{ type = "cypress", pos = Vector3.new(-140, 0, -100) },
			{ type = "cypress", pos = Vector3.new(140, 0, -100) },
			{ type = "cypress", pos = Vector3.new(-140, 0, -60) },
			{ type = "cypress", pos = Vector3.new(140, 0, -60) },
			{ type = "cypress", pos = Vector3.new(-140, 0, 0) },
			{ type = "cypress", pos = Vector3.new(140, 0, 0) },
			{ type = "cypress", pos = Vector3.new(-140, 0, 60) },
			{ type = "cypress", pos = Vector3.new(140, 0, 60) },
			{ type = "cypress", pos = Vector3.new(-140, 0, 100) },
			{ type = "cypress", pos = Vector3.new(140, 0, 100) },
			-- Hedges along paths
			{ type = "hedge", pos = Vector3.new(-25, 0, 25), size = Vector3.new(15, 3, 1.5) },
			{ type = "hedge", pos = Vector3.new(25, 0, 25), size = Vector3.new(15, 3, 1.5) },
			{ type = "hedge", pos = Vector3.new(-25, 0, -25), size = Vector3.new(15, 3, 1.5) },
			{ type = "hedge", pos = Vector3.new(25, 0, -25), size = Vector3.new(15, 3, 1.5) },
			{ type = "hedge", pos = Vector3.new(-115, 0, 30), size = Vector3.new(12, 2.5, 1) },
			{ type = "hedge", pos = Vector3.new(115, 0, 30), size = Vector3.new(12, 2.5, 1) },
			-- Wooden barrel stacks (Boathouse area)
			{ type = "barrel_stack", pos = Vector3.new(-100, 0, -90) },
			{ type = "barrel_stack", pos = Vector3.new(100, 0, -90) },
			{ type = "barrel_stack", pos = Vector3.new(75, 0, 95) },
			-- Wooden crate piles
			{ type = "crate_pile", pos = Vector3.new(-105, 0, 95) },
			{ type = "crate_pile", pos = Vector3.new(-65, 0, 105) },
			{ type = "crate_pile", pos = Vector3.new(65, 0, 105) },
			-- Wooden logs (Logs callout)
			{ type = "log_pile", pos = Vector3.new(95, 0, 100) },
			{ type = "log_pile", pos = Vector3.new(-95, 0, 100) },
			-- Hanging laundry lines (Italian street vibe)
			{ type = "hanging_laundry", from = Vector3.new(-130, 25, 90), to = Vector3.new(-50, 25, 90) },
			{ type = "hanging_laundry", from = Vector3.new(50, 25, 90), to = Vector3.new(130, 25, 90) },
			{ type = "hanging_laundry", from = Vector3.new(-130, 25, -90), to = Vector3.new(-50, 25, -90) },
			-- Planters with flowers
			{ type = "planter", pos = Vector3.new(-20, 0, -100), color = Color3.fromRGB(255, 100, 100) },
			{ type = "planter", pos = Vector3.new(20, 0, -100), color = Color3.fromRGB(255, 200, 100) },
			{ type = "planter", pos = Vector3.new(-20, 0, 100), color = Color3.fromRGB(220, 80, 200) },
			{ type = "planter", pos = Vector3.new(20, 0, 100), color = Color3.fromRGB(255, 150, 50) },
			-- Italian flag banners (red/white/green vertical stripes)
			{ type = "wall_banner", pos = Vector3.new(-100, 18, 110), face = "Z", colors = {Color3.fromRGB(0,140,69), Color3.fromRGB(255,255,255), Color3.fromRGB(206,17,38)} },
			{ type = "wall_banner", pos = Vector3.new(100, 18, 110), face = "Z", colors = {Color3.fromRGB(0,140,69), Color3.fromRGB(255,255,255), Color3.fromRGB(206,17,38)} },
			-- Pizza shop sign (Pizza callout)
			{ type = "shop_sign", pos = Vector3.new(35, 12, -30), text = "PIZZA", color = Color3.fromRGB(220, 60, 60) },
			-- Gelato sign
			{ type = "shop_sign", pos = Vector3.new(-35, 12, -30), text = "GELATO", color = Color3.fromRGB(120, 200, 220) },
			-- Wells
			{ type = "well", pos = Vector3.new(-60, 0, -10) },
			{ type = "well", pos = Vector3.new(60, 0, -10) },
			-- Street lamps (additional)
			{ type = "street_lamp", pos = Vector3.new(-30, 0, 0) },
			{ type = "street_lamp", pos = Vector3.new(30, 0, 0) },
			{ type = "street_lamp", pos = Vector3.new(-30, 0, -50) },
			{ type = "street_lamp", pos = Vector3.new(30, 0, -50) },
			{ type = "street_lamp", pos = Vector3.new(-30, 0, 50) },
			{ type = "street_lamp", pos = Vector3.new(30, 0, 50) },
			-- Benches
			{ type = "bench", pos = Vector3.new(-15, 0, -5) },
			{ type = "bench", pos = Vector3.new(15, 0, -5) },
			{ type = "bench", pos = Vector3.new(-15, 0, 65) },
			{ type = "bench", pos = Vector3.new(15, 0, 65) },
		},
		Particles = { type = "dust", color = Color3.fromRGB(255, 240, 200), rate = 3 },
	},

	-- ============================================================
	-- BIND — Rabat, Morocco, desert
	-- ============================================================
	Bind = {
		Materials = {
			Floor    = "Sand",
			Wall     = "Sandstone",
			Cover    = "Sandstone",
			Platform = "Sandstone",
		},
		AccentColor = Color3.fromRGB(80, 110, 160),
		LampColor = Color3.fromRGB(255, 180, 80),

		Buildings = {
			-- North row (defender side, Moroccan houses)
			{ pos = Vector3.new(-95, 0, 110), size = Vector3.new(40, 35, 30), color = Color3.fromRGB(235, 195, 145), roofColor = Color3.fromRGB(160, 100, 60), windows = 6, accentColor = Color3.fromRGB(80, 110, 160) },
			{ pos = Vector3.new(-35, 0, 115), size = Vector3.new(35, 28, 20), color = Color3.fromRGB(225, 180, 130), roofColor = Color3.fromRGB(150, 90, 55), windows = 4, accentColor = Color3.fromRGB(80, 110, 160) },
			{ pos = Vector3.new(35, 0, 115), size = Vector3.new(35, 32, 20), color = Color3.fromRGB(230, 185, 135), roofColor = Color3.fromRGB(160, 100, 60), windows = 5, accentColor = Color3.fromRGB(80, 110, 160) },
			{ pos = Vector3.new(95, 0, 110), size = Vector3.new(40, 38, 30), color = Color3.fromRGB(235, 195, 145), roofColor = Color3.fromRGB(150, 95, 60), windows = 6, accentColor = Color3.fromRGB(80, 110, 160) },
			-- South row
			{ pos = Vector3.new(-95, 0, -110), size = Vector3.new(40, 35, 30), color = Color3.fromRGB(225, 180, 130), roofColor = Color3.fromRGB(160, 100, 60), windows = 6, accentColor = Color3.fromRGB(80, 110, 160) },
			{ pos = Vector3.new(-35, 0, -115), size = Vector3.new(35, 28, 20), color = Color3.fromRGB(230, 185, 135), roofColor = Color3.fromRGB(150, 90, 55), windows = 4, accentColor = Color3.fromRGB(80, 110, 160) },
			{ pos = Vector3.new(35, 0, -115), size = Vector3.new(35, 32, 20), color = Color3.fromRGB(225, 180, 130), roofColor = Color3.fromRGB(160, 100, 60), windows = 5, accentColor = Color3.fromRGB(80, 110, 160) },
			{ pos = Vector3.new(95, 0, -110), size = Vector3.new(40, 38, 30), color = Color3.fromRGB(235, 195, 145), roofColor = Color3.fromRGB(150, 95, 60), windows = 6, accentColor = Color3.fromRGB(80, 110, 160) },
			-- East/west covered souk passages
			{ pos = Vector3.new(120, 0, 0), size = Vector3.new(20, 30, 60), color = Color3.fromRGB(230, 185, 135), roofColor = Color3.fromRGB(155, 95, 60), windows = 5, accentColor = Color3.fromRGB(80, 110, 160) },
			{ pos = Vector3.new(-120, 0, 0), size = Vector3.new(20, 30, 60), color = Color3.fromRGB(230, 185, 135), roofColor = Color3.fromRGB(155, 95, 60), windows = 5, accentColor = Color3.fromRGB(80, 110, 160) },
		},

		FloorPatches = {
			-- Mid courtyards (no mid passage, but A/B sides have plazas)
			{ pos = Vector3.new(-60, 0, 0), size = Vector3.new(40, 0, 40), color = Color3.fromRGB(210, 165, 115), material = "Sandstone" },
			{ pos = Vector3.new(60, 0, 0), size = Vector3.new(40, 0, 40), color = Color3.fromRGB(210, 165, 115), material = "Sandstone" },
			-- Site areas (tiled pattern)
			{ pos = Vector3.new(-80, 0, 50), size = Vector3.new(30, 0, 30), color = Color3.fromRGB(180, 140, 90), material = "Sandstone" },
			{ pos = Vector3.new(80, 0, 50), size = Vector3.new(30, 0, 30), color = Color3.fromRGB(180, 140, 90), material = "Sandstone" },
			-- Blue mosaic accent tiles
			{ pos = Vector3.new(-50, 0, 30), size = Vector3.new(8, 0, 8), color = Color3.fromRGB(80, 110, 160), material = "Marble" },
			{ pos = Vector3.new(50, 0, 30), size = Vector3.new(8, 0, 8), color = Color3.fromRGB(80, 110, 160), material = "Marble" },
		},

		Props = {
			-- Palm trees throughout (Morocco desert oasis)
			{ type = "palm", pos = Vector3.new(-30, 0, 90) },
			{ type = "palm", pos = Vector3.new(30, 0, 90) },
			{ type = "palm", pos = Vector3.new(-30, 0, -90) },
			{ type = "palm", pos = Vector3.new(30, 0, -90) },
			{ type = "palm", pos = Vector3.new(-90, 0, 90) },
			{ type = "palm", pos = Vector3.new(90, 0, 90) },
			{ type = "palm", pos = Vector3.new(-90, 0, -90) },
			{ type = "palm", pos = Vector3.new(90, 0, -90) },
			{ type = "palm", pos = Vector3.new(-105, 0, 30) },
			{ type = "palm", pos = Vector3.new(105, 0, 30) },
			{ type = "palm", pos = Vector3.new(-105, 0, -30) },
			{ type = "palm", pos = Vector3.new(105, 0, -30) },
			-- Moroccan archways everywhere
			{ type = "moroccan_arch", pos = Vector3.new(-50, 0, 0) },
			{ type = "moroccan_arch", pos = Vector3.new(50, 0, 0) },
			{ type = "moroccan_arch", pos = Vector3.new(-80, 0, 70) },
			{ type = "moroccan_arch", pos = Vector3.new(80, 0, 70) },
			{ type = "moroccan_arch", pos = Vector3.new(-50, 0, 90) },
			{ type = "moroccan_arch", pos = Vector3.new(50, 0, 90) },
			-- Hanging lanterns everywhere
			{ type = "lantern_hanging", pos = Vector3.new(75, 10, 30) },
			{ type = "lantern_hanging", pos = Vector3.new(-75, 10, 30) },
			{ type = "lantern_hanging", pos = Vector3.new(75, 10, -30) },
			{ type = "lantern_hanging", pos = Vector3.new(-75, 10, -30) },
			{ type = "lantern_hanging", pos = Vector3.new(50, 12, 70) },
			{ type = "lantern_hanging", pos = Vector3.new(-50, 12, 70) },
			{ type = "lantern_hanging", pos = Vector3.new(50, 12, -70) },
			{ type = "lantern_hanging", pos = Vector3.new(-50, 12, -70) },
			-- Mosaic panels (decorative walls)
			{ type = "mosaic_panel", pos = Vector3.new(-115, 10, 50), face = "X" },
			{ type = "mosaic_panel", pos = Vector3.new(115, 10, 50), face = "-X" },
			{ type = "mosaic_panel", pos = Vector3.new(-115, 10, -50), face = "X" },
			{ type = "mosaic_panel", pos = Vector3.new(115, 10, -50), face = "-X" },
			-- Market stalls (souk-style)
			{ type = "market_stall", pos = Vector3.new(-60, 0, 70), color = Color3.fromRGB(200, 60, 60) },
			{ type = "market_stall", pos = Vector3.new(60, 0, 70), color = Color3.fromRGB(60, 100, 180) },
			{ type = "market_stall", pos = Vector3.new(-60, 0, -70), color = Color3.fromRGB(200, 150, 50) },
			{ type = "market_stall", pos = Vector3.new(60, 0, -70), color = Color3.fromRGB(150, 80, 180) },
			{ type = "market_stall", pos = Vector3.new(-20, 0, -60), color = Color3.fromRGB(180, 80, 50) },
			{ type = "market_stall", pos = Vector3.new(20, 0, -60), color = Color3.fromRGB(60, 160, 100) },
			-- Stone wells
			{ type = "well", pos = Vector3.new(-90, 0, -60) },
			{ type = "well", pos = Vector3.new(90, 0, -60) },
			{ type = "well", pos = Vector3.new(0, 0, -50) },
			-- Hanging carpets (between buildings)
			{ type = "hanging_carpet", from = Vector3.new(-115, 22, 80), to = Vector3.new(-75, 22, 80), color = Color3.fromRGB(180, 60, 60) },
			{ type = "hanging_carpet", from = Vector3.new(75, 22, 80), to = Vector3.new(115, 22, 80), color = Color3.fromRGB(60, 100, 180) },
			{ type = "hanging_carpet", from = Vector3.new(-115, 22, -80), to = Vector3.new(-75, 22, -80), color = Color3.fromRGB(200, 150, 50) },
			-- Hookah platforms with cushions (B Hookah callout)
			{ type = "hookah_cushion", pos = Vector3.new(70, 12, 30) },
			{ type = "hookah_cushion", pos = Vector3.new(-70, 17, 70) },  -- A Heaven version
			-- Sand piles
			{ type = "sand_pile", pos = Vector3.new(-100, 0, 0) },
			{ type = "sand_pile", pos = Vector3.new(100, 0, 0) },
			-- Camel statue (signature)
			{ type = "camel_statue", pos = Vector3.new(0, 0, 70) },
			-- Date palm trees (smaller versions)
			{ type = "date_palm", pos = Vector3.new(-40, 0, 40) },
			{ type = "date_palm", pos = Vector3.new(40, 0, 40) },
			{ type = "date_palm", pos = Vector3.new(-40, 0, -40) },
			{ type = "date_palm", pos = Vector3.new(40, 0, -40) },
			-- Pottery jars
			{ type = "pottery_jar", pos = Vector3.new(-70, 0, 20) },
			{ type = "pottery_jar", pos = Vector3.new(70, 0, 20) },
			{ type = "pottery_jar", pos = Vector3.new(-70, 0, -20) },
			{ type = "pottery_jar", pos = Vector3.new(70, 0, -20) },
			{ type = "pottery_jar", pos = Vector3.new(0, 0, 80) },
			{ type = "pottery_jar", pos = Vector3.new(0, 0, -80) },
			-- Crates
			{ type = "crate_pile", pos = Vector3.new(-100, 0, 80) },
			{ type = "crate_pile", pos = Vector3.new(100, 0, 80) },
			-- Spice baskets
			{ type = "spice_basket", pos = Vector3.new(-55, 0, 75), color = Color3.fromRGB(220, 100, 30) },
			{ type = "spice_basket", pos = Vector3.new(55, 0, 75), color = Color3.fromRGB(220, 180, 50) },
			{ type = "spice_basket", pos = Vector3.new(-55, 0, -65), color = Color3.fromRGB(200, 50, 50) },
			{ type = "spice_basket", pos = Vector3.new(55, 0, -65), color = Color3.fromRGB(150, 200, 50) },
		},
		Particles = { type = "sand", color = Color3.fromRGB(255, 220, 180), rate = 5 },
	},

	-- ============================================================
	-- SPLIT — Tokyo, Japan, cyberpunk night
	-- ============================================================
	Split = {
		Materials = {
			Floor    = "Pavement",
			Wall     = "Metal",
			Cover    = "Metal",
			Platform = "DiamondPlate",
		},
		AccentColor = Color3.fromRGB(255, 100, 200),
		LampColor = Color3.fromRGB(80, 200, 255),

		Buildings = {
			-- TALL skyscrapers everywhere — Tokyo style
			{ pos = Vector3.new(-95, 0, 115), size = Vector3.new(40, 60, 30), color = Color3.fromRGB(50, 50, 65), roofColor = Color3.fromRGB(30, 30, 40), windows = 18, lit = true, neonColor = Color3.fromRGB(255, 100, 200) },
			{ pos = Vector3.new(-30, 0, 120), size = Vector3.new(30, 75, 20), color = Color3.fromRGB(60, 60, 75), roofColor = Color3.fromRGB(30, 30, 40), windows = 22, lit = true, neonColor = Color3.fromRGB(80, 200, 255) },
			{ pos = Vector3.new(30, 0, 120), size = Vector3.new(30, 70, 20), color = Color3.fromRGB(55, 55, 70), roofColor = Color3.fromRGB(30, 30, 40), windows = 20, lit = true, neonColor = Color3.fromRGB(255, 200, 80) },
			{ pos = Vector3.new(95, 0, 115), size = Vector3.new(40, 65, 30), color = Color3.fromRGB(45, 45, 60), roofColor = Color3.fromRGB(30, 30, 40), windows = 18, lit = true, neonColor = Color3.fromRGB(80, 200, 255) },
			{ pos = Vector3.new(-95, 0, -115), size = Vector3.new(40, 55, 30), color = Color3.fromRGB(50, 50, 65), roofColor = Color3.fromRGB(30, 30, 40), windows = 16, lit = true, neonColor = Color3.fromRGB(255, 100, 200) },
			{ pos = Vector3.new(-30, 0, -120), size = Vector3.new(30, 80, 20), color = Color3.fromRGB(60, 60, 75), roofColor = Color3.fromRGB(30, 30, 40), windows = 24, lit = true, neonColor = Color3.fromRGB(80, 200, 255) },
			{ pos = Vector3.new(30, 0, -120), size = Vector3.new(30, 70, 20), color = Color3.fromRGB(55, 55, 70), roofColor = Color3.fromRGB(30, 30, 40), windows = 20, lit = true, neonColor = Color3.fromRGB(255, 80, 80) },
			{ pos = Vector3.new(95, 0, -115), size = Vector3.new(40, 60, 30), color = Color3.fromRGB(45, 45, 60), roofColor = Color3.fromRGB(30, 30, 40), windows = 18, lit = true, neonColor = Color3.fromRGB(255, 200, 80) },
			-- East/west smaller buildings
			{ pos = Vector3.new(120, 0, 30), size = Vector3.new(20, 45, 50), color = Color3.fromRGB(50, 50, 65), roofColor = Color3.fromRGB(30, 30, 40), windows = 14, lit = true, neonColor = Color3.fromRGB(80, 200, 255) },
			{ pos = Vector3.new(120, 0, -30), size = Vector3.new(20, 45, 50), color = Color3.fromRGB(55, 55, 70), roofColor = Color3.fromRGB(30, 30, 40), windows = 14, lit = true, neonColor = Color3.fromRGB(255, 100, 200) },
			{ pos = Vector3.new(-120, 0, 30), size = Vector3.new(20, 45, 50), color = Color3.fromRGB(50, 50, 65), roofColor = Color3.fromRGB(30, 30, 40), windows = 14, lit = true, neonColor = Color3.fromRGB(255, 200, 80) },
			{ pos = Vector3.new(-120, 0, -30), size = Vector3.new(20, 45, 50), color = Color3.fromRGB(55, 55, 70), roofColor = Color3.fromRGB(30, 30, 40), windows = 14, lit = true, neonColor = Color3.fromRGB(255, 100, 200) },
		},

		FloorPatches = {
			-- Crosswalks (painted white stripes on asphalt)
			{ pos = Vector3.new(0, 0, -60), size = Vector3.new(20, 0, 8), color = Color3.fromRGB(220, 220, 220), material = "SmoothPlastic" },
			{ pos = Vector3.new(0, 0, 60), size = Vector3.new(20, 0, 8), color = Color3.fromRGB(220, 220, 220), material = "SmoothPlastic" },
			-- Yellow road lines (cubed asphalt)
			{ pos = Vector3.new(-60, 0, 0), size = Vector3.new(2, 0, 60), color = Color3.fromRGB(255, 220, 50), material = "SmoothPlastic" },
			{ pos = Vector3.new(60, 0, 0), size = Vector3.new(2, 0, 60), color = Color3.fromRGB(255, 220, 50), material = "SmoothPlastic" },
		},

		Props = {
			-- Vending machines clustered
			{ type = "vending", pos = Vector3.new(-40, 0, 30), color = Color3.fromRGB(255, 100, 200) },
			{ type = "vending", pos = Vector3.new(-44, 0, 30), color = Color3.fromRGB(80, 200, 255) },
			{ type = "vending", pos = Vector3.new(40, 0, 30), color = Color3.fromRGB(80, 200, 255) },
			{ type = "vending", pos = Vector3.new(44, 0, 30), color = Color3.fromRGB(255, 200, 80) },
			{ type = "vending", pos = Vector3.new(-40, 0, -30), color = Color3.fromRGB(50, 220, 100) },
			{ type = "vending", pos = Vector3.new(40, 0, -30), color = Color3.fromRGB(255, 80, 80) },
			-- Vertical neon signs
			{ type = "neon_sign", pos = Vector3.new(-115, 10, 50), color = Color3.fromRGB(255, 100, 200), text = "シ" },
			{ type = "neon_sign", pos = Vector3.new(115, 10, 50), color = Color3.fromRGB(80, 200, 255), text = "ク" },
			{ type = "neon_sign", pos = Vector3.new(-115, 10, -50), color = Color3.fromRGB(255, 200, 80), text = "東" },
			{ type = "neon_sign", pos = Vector3.new(115, 10, -50), color = Color3.fromRGB(255, 80, 80), text = "京" },
			{ type = "neon_sign", pos = Vector3.new(0, 12, -130), color = Color3.fromRGB(255, 200, 80), text = "東京" },
			{ type = "neon_sign", pos = Vector3.new(-60, 14, -120), color = Color3.fromRGB(80, 220, 80), text = "渋" },
			{ type = "neon_sign", pos = Vector3.new(60, 14, -120), color = Color3.fromRGB(220, 80, 220), text = "谷" },
			-- Ramen stands (multiple food carts)
			{ type = "ramen_stand", pos = Vector3.new(0, 0, 40) },
			{ type = "ramen_stand", pos = Vector3.new(-70, 0, 0) },
			{ type = "ramen_stand", pos = Vector3.new(70, 0, 0) },
			-- Power lines (cobwebs of Tokyo wires)
			{ type = "wire", from = Vector3.new(-115, 25, -40), to = Vector3.new(115, 25, -40) },
			{ type = "wire", from = Vector3.new(-115, 25, 40), to = Vector3.new(115, 25, 40) },
			{ type = "wire", from = Vector3.new(-115, 27, 0), to = Vector3.new(115, 27, 0) },
			{ type = "wire", from = Vector3.new(0, 25, -115), to = Vector3.new(0, 25, 115) },
			{ type = "wire", from = Vector3.new(-50, 25, -115), to = Vector3.new(-50, 25, 115) },
			{ type = "wire", from = Vector3.new(50, 25, -115), to = Vector3.new(50, 25, 115) },
			-- Bicycles parked
			{ type = "bicycle", pos = Vector3.new(-60, 0, 0) },
			{ type = "bicycle", pos = Vector3.new(60, 0, 0) },
			{ type = "bicycle", pos = Vector3.new(-50, 0, 70) },
			{ type = "bicycle", pos = Vector3.new(50, 0, 70) },
			{ type = "bicycle", pos = Vector3.new(-50, 0, -70) },
			{ type = "bicycle", pos = Vector3.new(50, 0, -70) },
			-- AC units (on platforms)
			{ type = "ac_unit", pos = Vector3.new(-80, 17, 60) },
			{ type = "ac_unit", pos = Vector3.new(80, 17, 60) },
			{ type = "ac_unit", pos = Vector3.new(-85, 17, 65) },
			{ type = "ac_unit", pos = Vector3.new(85, 17, 65) },
			-- Trash bins (Tokyo style)
			{ type = "trash_bin", pos = Vector3.new(-25, 0, 0) },
			{ type = "trash_bin", pos = Vector3.new(25, 0, 0) },
			{ type = "trash_bin", pos = Vector3.new(-70, 0, 30) },
			{ type = "trash_bin", pos = Vector3.new(70, 0, 30) },
			-- Phone booths
			{ type = "phone_booth", pos = Vector3.new(-90, 0, 0) },
			{ type = "phone_booth", pos = Vector3.new(90, 0, 0) },
			-- Traffic cones
			{ type = "traffic_cone", pos = Vector3.new(-10, 0, -25) },
			{ type = "traffic_cone", pos = Vector3.new(0, 0, -25) },
			{ type = "traffic_cone", pos = Vector3.new(10, 0, -25) },
			{ type = "traffic_cone", pos = Vector3.new(-10, 0, 25) },
			{ type = "traffic_cone", pos = Vector3.new(0, 0, 25) },
			{ type = "traffic_cone", pos = Vector3.new(10, 0, 25) },
			-- Horizontal billboards (lit advertising)
			{ type = "billboard", pos = Vector3.new(0, 30, -100), color = Color3.fromRGB(255, 100, 200), text = "TOKYO" },
			{ type = "billboard", pos = Vector3.new(0, 30, 100), color = Color3.fromRGB(80, 200, 255), text = "渋谷" },
			-- Motorbikes
			{ type = "motorbike", pos = Vector3.new(-30, 0, 50) },
			{ type = "motorbike", pos = Vector3.new(30, 0, 50) },
			-- Sake barrels
			{ type = "sake_barrel", pos = Vector3.new(-15, 0, 45) },
			{ type = "sake_barrel", pos = Vector3.new(15, 0, 45) },
			-- Air conditioner pipes on ground (industrial)
			{ type = "industrial_pipe", from = Vector3.new(-100, 1, 0), to = Vector3.new(-50, 1, 0) },
			{ type = "industrial_pipe", from = Vector3.new(50, 1, 0), to = Vector3.new(100, 1, 0) },
		},
		Particles = { type = "neon_glow", color = Color3.fromRGB(255, 100, 200), rate = 8 },
	},

	-- ============================================================
	-- HAVEN — Bhutan, Buddhist monastery
	-- ============================================================
	Haven = {
		Materials = {
			Floor    = "Slate",
			Wall     = "Brick",
			Cover    = "Wood",
			Platform = "Brick",
		},
		AccentColor = Color3.fromRGB(255, 220, 100),
		LampColor = Color3.fromRGB(255, 200, 100),

		Buildings = {
			-- Monastery main buildings (red walls + golden trim)
			{ pos = Vector3.new(-130, 0, 140), size = Vector3.new(45, 40, 35), color = Color3.fromRGB(180, 90, 60), roofColor = Color3.fromRGB(220, 180, 60), windows = 8, accentColor = Color3.fromRGB(255, 220, 100), isMonastery = true },
			{ pos = Vector3.new(0, 0, 145), size = Vector3.new(50, 45, 30), color = Color3.fromRGB(190, 100, 70), roofColor = Color3.fromRGB(220, 180, 60), windows = 10, accentColor = Color3.fromRGB(255, 220, 100), isMonastery = true },
			{ pos = Vector3.new(130, 0, 140), size = Vector3.new(45, 42, 35), color = Color3.fromRGB(180, 90, 60), roofColor = Color3.fromRGB(220, 180, 60), windows = 8, accentColor = Color3.fromRGB(255, 220, 100), isMonastery = true },
			-- South side
			{ pos = Vector3.new(-130, 0, -140), size = Vector3.new(45, 38, 35), color = Color3.fromRGB(180, 90, 60), roofColor = Color3.fromRGB(220, 180, 60), windows = 8, accentColor = Color3.fromRGB(255, 220, 100), isMonastery = true },
			{ pos = Vector3.new(0, 0, -145), size = Vector3.new(50, 40, 30), color = Color3.fromRGB(190, 100, 70), roofColor = Color3.fromRGB(220, 180, 60), windows = 10, accentColor = Color3.fromRGB(255, 220, 100), isMonastery = true },
			{ pos = Vector3.new(130, 0, -140), size = Vector3.new(45, 40, 35), color = Color3.fromRGB(180, 90, 60), roofColor = Color3.fromRGB(220, 180, 60), windows = 8, accentColor = Color3.fromRGB(255, 220, 100), isMonastery = true },
			-- East/west wings
			{ pos = Vector3.new(155, 0, 0), size = Vector3.new(30, 35, 70), color = Color3.fromRGB(180, 90, 60), roofColor = Color3.fromRGB(220, 180, 60), windows = 10, accentColor = Color3.fromRGB(255, 220, 100), isMonastery = true },
			{ pos = Vector3.new(-155, 0, 0), size = Vector3.new(30, 35, 70), color = Color3.fromRGB(180, 90, 60), roofColor = Color3.fromRGB(220, 180, 60), windows = 10, accentColor = Color3.fromRGB(255, 220, 100), isMonastery = true },
		},

		FloorPatches = {
			-- Stone paths
			{ pos = Vector3.new(0, 0, 0), size = Vector3.new(20, 0, 200), color = Color3.fromRGB(180, 170, 150), material = "Slate" },
			{ pos = Vector3.new(0, 0, 0), size = Vector3.new(200, 0, 20), color = Color3.fromRGB(180, 170, 150), material = "Slate" },
			-- Golden mandala at center
			{ pos = Vector3.new(0, 0, 0), size = Vector3.new(15, 0, 15), color = Color3.fromRGB(220, 180, 80), material = "Slate" },
			-- Stone plazas at sites
			{ pos = Vector3.new(-100, 0, 70), size = Vector3.new(40, 0, 40), color = Color3.fromRGB(200, 190, 170), material = "Slate" },
			{ pos = Vector3.new(0, 0, 70), size = Vector3.new(40, 0, 40), color = Color3.fromRGB(200, 190, 170), material = "Slate" },
			{ pos = Vector3.new(100, 0, 70), size = Vector3.new(40, 0, 40), color = Color3.fromRGB(200, 190, 170), material = "Slate" },
		},

		Props = {
			-- Multiple stupas
			{ type = "stupa", pos = Vector3.new(100, 0, 130) },
			{ type = "stupa", pos = Vector3.new(-100, 0, 130), size = 0.7 },
			{ type = "stupa", pos = Vector3.new(0, 0, 130), size = 0.85 },
			-- Prayer flag lines (lots)
			{ type = "prayer_flags", from = Vector3.new(-150, 22, -80), to = Vector3.new(150, 22, -80) },
			{ type = "prayer_flags", from = Vector3.new(-150, 20, -40), to = Vector3.new(150, 20, -40) },
			{ type = "prayer_flags", from = Vector3.new(-150, 20, 40), to = Vector3.new(150, 20, 40) },
			{ type = "prayer_flags", from = Vector3.new(-150, 22, 80), to = Vector3.new(150, 22, 80) },
			{ type = "prayer_flags", from = Vector3.new(-80, 18, -150), to = Vector3.new(-80, 18, 150) },
			{ type = "prayer_flags", from = Vector3.new(80, 18, -150), to = Vector3.new(80, 18, 150) },
			-- Bronze bells throughout
			{ type = "bell", pos = Vector3.new(-60, 0, 30) },
			{ type = "bell", pos = Vector3.new(60, 0, 30) },
			{ type = "bell", pos = Vector3.new(-60, 0, -30) },
			{ type = "bell", pos = Vector3.new(60, 0, -30) },
			{ type = "bell", pos = Vector3.new(0, 0, -100) },
			{ type = "bell", pos = Vector3.new(0, 0, 100) },
			-- Trees throughout
			{ type = "tree", pos = Vector3.new(-140, 0, 100), color = Color3.fromRGB(255, 150, 200) },
			{ type = "tree", pos = Vector3.new(140, 0, 100), color = Color3.fromRGB(255, 150, 200) },
			{ type = "tree", pos = Vector3.new(-140, 0, -100), color = Color3.fromRGB(255, 150, 200) },
			{ type = "tree", pos = Vector3.new(140, 0, -100), color = Color3.fromRGB(255, 150, 200) },
			{ type = "tree", pos = Vector3.new(-140, 0, 30), color = Color3.fromRGB(255, 180, 220) },
			{ type = "tree", pos = Vector3.new(140, 0, 30), color = Color3.fromRGB(255, 180, 220) },
			-- Prayer wheels lining paths
			{ type = "prayer_wheel", pos = Vector3.new(-30, 0, -10) },
			{ type = "prayer_wheel", pos = Vector3.new(-30, 0, 10) },
			{ type = "prayer_wheel", pos = Vector3.new(30, 0, -10) },
			{ type = "prayer_wheel", pos = Vector3.new(30, 0, 10) },
			{ type = "prayer_wheel", pos = Vector3.new(-30, 0, -30) },
			{ type = "prayer_wheel", pos = Vector3.new(30, 0, -30) },
			{ type = "prayer_wheel", pos = Vector3.new(-30, 0, 30) },
			{ type = "prayer_wheel", pos = Vector3.new(30, 0, 30) },
			-- Braziers everywhere (warm light)
			{ type = "brazier", pos = Vector3.new(-100, 0, -30) },
			{ type = "brazier", pos = Vector3.new(100, 0, -30) },
			{ type = "brazier", pos = Vector3.new(-100, 0, 30) },
			{ type = "brazier", pos = Vector3.new(100, 0, 30) },
			{ type = "brazier", pos = Vector3.new(0, 0, 20) },
			{ type = "brazier", pos = Vector3.new(0, 0, -20) },
			-- Buddha statues
			{ type = "buddha", pos = Vector3.new(-50, 0, -100), small = true },
			{ type = "buddha", pos = Vector3.new(50, 0, -100), small = true },
			-- Stone steps
			{ type = "stone_steps", pos = Vector3.new(-100, 0, 30) },
			{ type = "stone_steps", pos = Vector3.new(0, 0, 30) },
			{ type = "stone_steps", pos = Vector3.new(100, 0, 30) },
			-- Rocks (Zen garden)
			{ type = "zen_rock", pos = Vector3.new(-50, 0, 80) },
			{ type = "zen_rock", pos = Vector3.new(50, 0, 80) },
			{ type = "zen_rock", pos = Vector3.new(-25, 0, 100) },
			{ type = "zen_rock", pos = Vector3.new(25, 0, 100) },
			{ type = "zen_rock", pos = Vector3.new(0, 0, 100) },
			-- Incense holders
			{ type = "incense_holder", pos = Vector3.new(-30, 0, -50) },
			{ type = "incense_holder", pos = Vector3.new(30, 0, -50) },
			{ type = "incense_holder", pos = Vector3.new(0, 0, -80) },
		},
		Particles = { type = "incense", color = Color3.fromRGB(255, 250, 240), rate = 4 },
	},

	-- ============================================================
	-- FRACTURE — Desert research facility, post-explosion
	-- ============================================================
	Fracture = {
		Materials = {
			Floor    = "Asphalt",
			Wall     = "CorrodedMetal",
			Cover    = "CorrodedMetal",
			Platform = "DiamondPlate",
		},
		AccentColor = Color3.fromRGB(255, 200, 80),
		LampColor = Color3.fromRGB(255, 100, 50),

		Buildings = {
			-- Industrial research buildings (concrete bunkers with antennas)
			{ pos = Vector3.new(-110, 0, 130), size = Vector3.new(45, 25, 30), color = Color3.fromRGB(140, 120, 90), roofColor = Color3.fromRGB(100, 90, 70), windows = 4, isIndustrial = true },
			{ pos = Vector3.new(0, 0, 135), size = Vector3.new(60, 30, 25), color = Color3.fromRGB(150, 130, 100), roofColor = Color3.fromRGB(110, 100, 80), windows = 6, isIndustrial = true },
			{ pos = Vector3.new(110, 0, 130), size = Vector3.new(45, 28, 30), color = Color3.fromRGB(140, 120, 90), roofColor = Color3.fromRGB(100, 90, 70), windows = 4, isIndustrial = true },
			-- South (other attacker side)
			{ pos = Vector3.new(-110, 0, -130), size = Vector3.new(45, 25, 30), color = Color3.fromRGB(150, 130, 100), roofColor = Color3.fromRGB(110, 100, 80), windows = 5, isIndustrial = true },
			{ pos = Vector3.new(0, 0, -135), size = Vector3.new(60, 32, 25), color = Color3.fromRGB(140, 120, 90), roofColor = Color3.fromRGB(100, 90, 70), windows = 6, isIndustrial = true },
			{ pos = Vector3.new(110, 0, -130), size = Vector3.new(45, 25, 30), color = Color3.fromRGB(150, 130, 100), roofColor = Color3.fromRGB(110, 100, 80), windows = 5, isIndustrial = true },
			-- East/west large bunkers
			{ pos = Vector3.new(140, 0, 0), size = Vector3.new(20, 22, 60), color = Color3.fromRGB(130, 110, 85), roofColor = Color3.fromRGB(95, 85, 65), windows = 5, isIndustrial = true },
			{ pos = Vector3.new(-140, 0, 0), size = Vector3.new(20, 22, 60), color = Color3.fromRGB(130, 110, 85), roofColor = Color3.fromRGB(95, 85, 65), windows = 5, isIndustrial = true },
		},

		FloorPatches = {
			-- Cracked asphalt patches
			{ pos = Vector3.new(0, 0, 0), size = Vector3.new(80, 0, 80), color = Color3.fromRGB(80, 70, 60), material = "Asphalt" },
			-- Sand patches (desert)
			{ pos = Vector3.new(-100, 0, 60), size = Vector3.new(40, 0, 40), color = Color3.fromRGB(220, 180, 120), material = "Sand" },
			{ pos = Vector3.new(100, 0, 60), size = Vector3.new(40, 0, 40), color = Color3.fromRGB(220, 180, 120), material = "Sand" },
			{ pos = Vector3.new(-100, 0, -60), size = Vector3.new(40, 0, 40), color = Color3.fromRGB(220, 180, 120), material = "Sand" },
			{ pos = Vector3.new(100, 0, -60), size = Vector3.new(40, 0, 40), color = Color3.fromRGB(220, 180, 120), material = "Sand" },
			-- Yellow hazard markings
			{ pos = Vector3.new(0, 0, -20), size = Vector3.new(20, 0, 4), color = Color3.fromRGB(220, 180, 50), material = "SmoothPlastic" },
			{ pos = Vector3.new(0, 0, 20), size = Vector3.new(20, 0, 4), color = Color3.fromRGB(220, 180, 50), material = "SmoothPlastic" },
			-- Oil stains
			{ pos = Vector3.new(-50, 0, -90), size = Vector3.new(8, 0, 8), color = Color3.fromRGB(30, 25, 20), material = "Slate" },
			{ pos = Vector3.new(50, 0, 90), size = Vector3.new(8, 0, 8), color = Color3.fromRGB(30, 25, 20), material = "Slate" },
		},

		Props = {
			-- Wrecked vehicles
			{ type = "wrecked_truck", pos = Vector3.new(-60, 0, -90), rot = 45 },
			{ type = "wrecked_truck", pos = Vector3.new(60, 0, 90), rot = 220 },
			{ type = "wrecked_truck", pos = Vector3.new(-90, 0, 90), rot = 135 },
			{ type = "wrecked_truck", pos = Vector3.new(90, 0, -90), rot = 60 },
			{ type = "wrecked_car", pos = Vector3.new(0, 0, -70), rot = 90 },
			{ type = "wrecked_car", pos = Vector3.new(0, 0, 70), rot = 270 },
			{ type = "wrecked_car", pos = Vector3.new(-40, 0, -30), rot = 30 },
			{ type = "wrecked_car", pos = Vector3.new(40, 0, 30), rot = 150 },
			-- Shipping containers
			{ type = "container", pos = Vector3.new(-70, 0, 60), color = Color3.fromRGB(160, 80, 40) },
			{ type = "container", pos = Vector3.new(70, 0, -60), color = Color3.fromRGB(60, 80, 100) },
			{ type = "container", pos = Vector3.new(70, 0, 60), color = Color3.fromRGB(80, 140, 60) },
			{ type = "container", pos = Vector3.new(-70, 0, -60), color = Color3.fromRGB(140, 80, 40) },
			{ type = "container", pos = Vector3.new(-90, 0, 30), color = Color3.fromRGB(60, 60, 80) },
			{ type = "container", pos = Vector3.new(90, 0, -30), color = Color3.fromRGB(180, 100, 50) },
			-- Power generators
			{ type = "generator", pos = Vector3.new(0, 0, 30) },
			{ type = "generator", pos = Vector3.new(0, 0, -30) },
			{ type = "generator", pos = Vector3.new(-40, 0, 0) },
			{ type = "generator", pos = Vector3.new(40, 0, 0) },
			-- Antennas
			{ type = "antenna", pos = Vector3.new(-130, 0, -130) },
			{ type = "antenna", pos = Vector3.new(130, 0, 130) },
			{ type = "antenna", pos = Vector3.new(-130, 0, 130) },
			{ type = "antenna", pos = Vector3.new(130, 0, -130) },
			-- Warning signs
			{ type = "warning_sign", pos = Vector3.new(-30, 0, 0) },
			{ type = "warning_sign", pos = Vector3.new(30, 0, 0) },
			{ type = "warning_sign", pos = Vector3.new(-90, 0, 0) },
			{ type = "warning_sign", pos = Vector3.new(90, 0, 0) },
			-- Rebar piles
			{ type = "rebar_pile", pos = Vector3.new(-100, 0, 100) },
			{ type = "rebar_pile", pos = Vector3.new(100, 0, -100) },
			{ type = "rebar_pile", pos = Vector3.new(-50, 0, 100) },
			{ type = "rebar_pile", pos = Vector3.new(50, 0, -100) },
			-- Sandbag walls
			{ type = "sandbag_wall", pos = Vector3.new(-20, 0, -50), length = 12 },
			{ type = "sandbag_wall", pos = Vector3.new(20, 0, 50), length = 12 },
			{ type = "sandbag_wall", pos = Vector3.new(-80, 0, 0), length = 16 },
			{ type = "sandbag_wall", pos = Vector3.new(80, 0, 0), length = 16 },
			-- Fuel barrels
			{ type = "fuel_barrel", pos = Vector3.new(-95, 0, 45) },
			{ type = "fuel_barrel", pos = Vector3.new(-90, 0, 45) },
			{ type = "fuel_barrel", pos = Vector3.new(-85, 0, 45) },
			{ type = "fuel_barrel", pos = Vector3.new(95, 0, -45) },
			{ type = "fuel_barrel", pos = Vector3.new(90, 0, -45) },
			{ type = "fuel_barrel", pos = Vector3.new(85, 0, -45) },
			-- Floodlights (high lamps on poles)
			{ type = "floodlight", pos = Vector3.new(-60, 0, 0) },
			{ type = "floodlight", pos = Vector3.new(60, 0, 0) },
			{ type = "floodlight", pos = Vector3.new(0, 0, -60) },
			{ type = "floodlight", pos = Vector3.new(0, 0, 60) },
			-- Satellite dishes
			{ type = "satellite_dish", pos = Vector3.new(-120, 0, 60) },
			{ type = "satellite_dish", pos = Vector3.new(120, 0, -60) },
			-- Wire fences
			{ type = "wire_fence", from = Vector3.new(-140, 0, -50), to = Vector3.new(-140, 0, 50) },
			{ type = "wire_fence", from = Vector3.new(140, 0, -50), to = Vector3.new(140, 0, 50) },
			-- Solar panels
			{ type = "solar_panel", pos = Vector3.new(-100, 0, -110) },
			{ type = "solar_panel", pos = Vector3.new(-60, 0, -110) },
			{ type = "solar_panel", pos = Vector3.new(60, 0, 110) },
			{ type = "solar_panel", pos = Vector3.new(100, 0, 110) },
			-- Crates (military)
			{ type = "crate_pile", pos = Vector3.new(-40, 0, 80) },
			{ type = "crate_pile", pos = Vector3.new(40, 0, -80) },
			{ type = "crate_pile", pos = Vector3.new(-70, 0, 30) },
			{ type = "crate_pile", pos = Vector3.new(70, 0, -30) },
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
		AccentColor = Color3.fromRGB(80, 160, 100),
		LampColor = Color3.fromRGB(255, 220, 150),

		Buildings = {
			-- Temple structures (white marble + golden trim, vine-overgrown)
			{ pos = Vector3.new(-130, 0, 140), size = Vector3.new(45, 40, 35), color = Color3.fromRGB(220, 210, 190), roofColor = Color3.fromRGB(180, 140, 80), windows = 6, accentColor = Color3.fromRGB(255, 200, 80), isTemple = true },
			{ pos = Vector3.new(0, 0, 145), size = Vector3.new(60, 45, 30), color = Color3.fromRGB(225, 215, 195), roofColor = Color3.fromRGB(190, 150, 90), windows = 8, accentColor = Color3.fromRGB(255, 200, 80), isTemple = true },
			{ pos = Vector3.new(130, 0, 140), size = Vector3.new(45, 42, 35), color = Color3.fromRGB(220, 210, 190), roofColor = Color3.fromRGB(180, 140, 80), windows = 6, accentColor = Color3.fromRGB(255, 200, 80), isTemple = true },
			-- South
			{ pos = Vector3.new(-130, 0, -140), size = Vector3.new(45, 38, 35), color = Color3.fromRGB(220, 210, 190), roofColor = Color3.fromRGB(180, 140, 80), windows = 6, accentColor = Color3.fromRGB(255, 200, 80), isTemple = true },
			{ pos = Vector3.new(0, 0, -145), size = Vector3.new(60, 42, 30), color = Color3.fromRGB(225, 215, 195), roofColor = Color3.fromRGB(190, 150, 90), windows = 8, accentColor = Color3.fromRGB(255, 200, 80), isTemple = true },
			{ pos = Vector3.new(130, 0, -140), size = Vector3.new(45, 40, 35), color = Color3.fromRGB(220, 210, 190), roofColor = Color3.fromRGB(180, 140, 80), windows = 6, accentColor = Color3.fromRGB(255, 200, 80), isTemple = true },
			-- East/west smaller temples
			{ pos = Vector3.new(155, 0, 0), size = Vector3.new(30, 32, 60), color = Color3.fromRGB(215, 205, 185), roofColor = Color3.fromRGB(180, 140, 80), windows = 8, accentColor = Color3.fromRGB(255, 200, 80), isTemple = true },
			{ pos = Vector3.new(-155, 0, 0), size = Vector3.new(30, 32, 60), color = Color3.fromRGB(215, 205, 185), roofColor = Color3.fromRGB(180, 140, 80), windows = 8, accentColor = Color3.fromRGB(255, 200, 80), isTemple = true },
		},

		FloorPatches = {
			-- Marble paths
			{ pos = Vector3.new(0, 0, 0), size = Vector3.new(200, 0, 16), color = Color3.fromRGB(245, 240, 230), material = "Marble" },
			{ pos = Vector3.new(0, 0, 0), size = Vector3.new(16, 0, 200), color = Color3.fromRGB(245, 240, 230), material = "Marble" },
			-- Central lotus mandala
			{ pos = Vector3.new(0, 0, 0), size = Vector3.new(20, 0, 20), color = Color3.fromRGB(180, 140, 80), material = "Granite" },
			-- Green moss patches (overgrowth)
			{ pos = Vector3.new(-120, 0, 60), size = Vector3.new(30, 0, 30), color = Color3.fromRGB(80, 130, 70), material = "Grass" },
			{ pos = Vector3.new(120, 0, 60), size = Vector3.new(30, 0, 30), color = Color3.fromRGB(80, 130, 70), material = "Grass" },
			{ pos = Vector3.new(-120, 0, -60), size = Vector3.new(30, 0, 30), color = Color3.fromRGB(80, 130, 70), material = "Grass" },
			{ pos = Vector3.new(120, 0, -60), size = Vector3.new(30, 0, 30), color = Color3.fromRGB(80, 130, 70), material = "Grass" },
		},

		Props = {
			-- Central lotus pond
			{ type = "lotus_pond", pos = Vector3.new(0, 0, 0), size = 12 },
			{ type = "lotus_pond", pos = Vector3.new(-70, 0, 90), size = 8 },
			{ type = "lotus_pond", pos = Vector3.new(70, 0, 90), size = 8 },
			-- Buddha statues
			{ type = "buddha", pos = Vector3.new(0, 0, -120) },
			{ type = "buddha", pos = Vector3.new(-100, 0, -60), small = true },
			{ type = "buddha", pos = Vector3.new(100, 0, -60), small = true },
			-- Pillars (lots, lining everything)
			{ type = "pillar", pos = Vector3.new(-90, 0, 90) },
			{ type = "pillar", pos = Vector3.new(-60, 0, 90) },
			{ type = "pillar", pos = Vector3.new(60, 0, 90) },
			{ type = "pillar", pos = Vector3.new(90, 0, 90) },
			{ type = "pillar", pos = Vector3.new(-90, 0, -90) },
			{ type = "pillar", pos = Vector3.new(-60, 0, -90) },
			{ type = "pillar", pos = Vector3.new(60, 0, -90) },
			{ type = "pillar", pos = Vector3.new(90, 0, -90) },
			{ type = "pillar", pos = Vector3.new(-90, 0, 30) },
			{ type = "pillar", pos = Vector3.new(-90, 0, -30) },
			{ type = "pillar", pos = Vector3.new(90, 0, 30) },
			{ type = "pillar", pos = Vector3.new(90, 0, -30) },
			-- Elephant statues
			{ type = "elephant_statue", pos = Vector3.new(-30, 0, -110) },
			{ type = "elephant_statue", pos = Vector3.new(30, 0, -110) },
			{ type = "elephant_statue", pos = Vector3.new(-30, 0, 110) },
			{ type = "elephant_statue", pos = Vector3.new(30, 0, 110) },
			-- Banyan trees (large signature trees)
			{ type = "banyan", pos = Vector3.new(-130, 0, 100) },
			{ type = "banyan", pos = Vector3.new(130, 0, 100) },
			{ type = "banyan", pos = Vector3.new(-130, 0, -100) },
			{ type = "banyan", pos = Vector3.new(130, 0, -100) },
			-- Stone steps to platforms
			{ type = "stone_steps", pos = Vector3.new(-50, 0, 60) },
			{ type = "stone_steps", pos = Vector3.new(50, 0, 60) },
			{ type = "stone_steps", pos = Vector3.new(-50, 0, -60) },
			{ type = "stone_steps", pos = Vector3.new(50, 0, -60) },
			-- Vines on walls
			{ type = "ivy", pos = Vector3.new(-155, 12, 80), face = "X" },
			{ type = "ivy", pos = Vector3.new(155, 12, 80), face = "-X" },
			{ type = "ivy", pos = Vector3.new(-155, 12, -80), face = "X" },
			{ type = "ivy", pos = Vector3.new(155, 12, -80), face = "-X" },
			{ type = "ivy", pos = Vector3.new(-80, 12, 155), face = "Z" },
			{ type = "ivy", pos = Vector3.new(80, 12, 155), face = "Z" },
			-- Cobra statues
			{ type = "cobra_statue", pos = Vector3.new(-50, 0, 0) },
			{ type = "cobra_statue", pos = Vector3.new(50, 0, 0) },
			-- Sandalwood incense holders
			{ type = "incense_holder", pos = Vector3.new(-30, 0, -50) },
			{ type = "incense_holder", pos = Vector3.new(30, 0, -50) },
			{ type = "incense_holder", pos = Vector3.new(-30, 0, 50) },
			{ type = "incense_holder", pos = Vector3.new(30, 0, 50) },
			-- Stone benches
			{ type = "stone_bench", pos = Vector3.new(-15, 0, 25) },
			{ type = "stone_bench", pos = Vector3.new(15, 0, 25) },
			{ type = "stone_bench", pos = Vector3.new(-15, 0, -25) },
			{ type = "stone_bench", pos = Vector3.new(15, 0, -25) },
			-- Bell hanging stations
			{ type = "bell", pos = Vector3.new(-90, 0, 90) },
			{ type = "bell", pos = Vector3.new(90, 0, 90) },
			-- Mandala carvings on floor (decorative discs)
			{ type = "mandala", pos = Vector3.new(-100, 0, -90) },
			{ type = "mandala", pos = Vector3.new(100, 0, -90) },
			{ type = "mandala", pos = Vector3.new(-100, 0, 90) },
			{ type = "mandala", pos = Vector3.new(100, 0, 90) },
			-- Lotus flowers floating (decorative)
			{ type = "lotus_flower", pos = Vector3.new(-40, 0, 40) },
			{ type = "lotus_flower", pos = Vector3.new(40, 0, 40) },
			{ type = "lotus_flower", pos = Vector3.new(-40, 0, -40) },
			{ type = "lotus_flower", pos = Vector3.new(40, 0, -40) },
			-- Stupa
			{ type = "stupa", pos = Vector3.new(0, 0, 100), size = 0.8 },
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
