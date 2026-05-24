local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MapData = require(ReplicatedStorage.Shared.MapData)
local MapTheme = require(ReplicatedStorage.Shared.MapTheme)

local MapBuilder = {}

local mapFolder  -- holds current map's geometry (cleared on rebuild)

local function makePart(props, parent)
	local p = Instance.new("Part")
	for k, v in pairs(props) do
		if k ~= "Parent" then
			p[k] = v
		end
	end
	p.Anchored = true
	p.Parent = parent or mapFolder or Workspace
	return p
end

local function clearMap()
	if mapFolder then mapFolder:Destroy() end
	mapFolder = Instance.new("Folder")
	mapFolder.Name = "ActiveMap"
	mapFolder.Parent = Workspace
end

local function buildSpawnPad(name, pos, color)
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = name
	spawn.Size = Vector3.new(8, 1, 8)
	spawn.Position = pos
	spawn.Anchored = true
	spawn.CanCollide = true
	spawn.Color = color
	spawn.Material = Enum.Material.Neon
	spawn.Neutral = true  -- accept any team
	spawn.Enabled = true
	spawn.Parent = mapFolder
	return spawn
end

local function buildPlantArea(name, pos, size, color)
	local part = Instance.new("Part")
	part.Name = "PlantArea_" .. name
	part.Size = Vector3.new(size, 0.2, size)
	part.Position = pos - Vector3.new(0, 0.4, 0)
	part.Anchored = true
	part.CanCollide = false
	part.Color = color or Color3.fromRGB(255, 200, 100)
	part.Material = Enum.Material.Neon
	part.Transparency = 0.7
	part:SetAttribute("PlantArea", name)
	part.Parent = mapFolder

	-- Outline ring
	local outline = Instance.new("Part")
	outline.Name = "PlantOutline_" .. name
	outline.Size = Vector3.new(size + 2, 0.1, size + 2)
	outline.Position = pos - Vector3.new(0, 0.5, 0)
	outline.Anchored = true
	outline.CanCollide = false
	outline.Color = Color3.fromRGB(255, 80, 30)
	outline.Material = Enum.Material.Neon
	outline.Transparency = 0.5
	outline.Parent = mapFolder

	return part
end

local function buildUltOrb(pos)
	local orb = Instance.new("Part")
	orb.Name = "UltOrb"
	orb.Shape = Enum.PartType.Ball
	orb.Size = Vector3.new(2, 2, 2)
	orb.Position = pos
	orb.Anchored = true
	orb.CanCollide = false
	orb.Material = Enum.Material.Neon
	orb.Color = Color3.fromRGB(180, 100, 255)
	orb.Transparency = 0.2
	orb:SetAttribute("UltOrb", true)
	orb.Parent = mapFolder

	-- Glow light
	local pl = Instance.new("PointLight")
	pl.Color = Color3.fromRGB(180, 100, 255)
	pl.Range = 14
	pl.Brightness = 2
	pl.Parent = orb

	-- Floating animation
	local startY = pos.Y
	task.spawn(function()
		local startTime = tick()
		while orb.Parent do
			local elapsed = tick() - startTime
			orb.Position = Vector3.new(pos.X, startY + math.sin(elapsed * 2) * 0.5, pos.Z)
			orb.CFrame = orb.CFrame * CFrame.Angles(0, math.rad(2), 0)
			task.wait(0.05)
		end
	end)
	return orb
end

local function clearLightingEffects()
	for _, child in ipairs(Lighting:GetChildren()) do
		if child:IsA("PostEffect") or child:IsA("Atmosphere") or child:IsA("Sky") then
			child:Destroy()
		end
	end
end

local function buildLights(mapInfo)
	clearLightingEffects()

	local sky = mapInfo and mapInfo.SkyboxConfig or {}

	Lighting.Ambient = sky.Ambient or Color3.fromRGB(80, 80, 90)
	Lighting.OutdoorAmbient = sky.OutdoorAmbient or Color3.fromRGB(140, 140, 150)
	Lighting.Brightness = sky.Brightness or 2.5
	Lighting.ClockTime = sky.ClockTime or 14
	Lighting.FogEnd = sky.FogEnd or 600
	Lighting.FogStart = sky.FogStart or 200
	Lighting.GlobalShadows = true
	Lighting.ShadowSoftness = 0.3
	Lighting.GeographicLatitude = 30
	Lighting.ExposureCompensation = 0.1
	Lighting.FogColor = sky.FogColor or (mapInfo.ColorPalette and mapInfo.ColorPalette.Primary) or Color3.fromRGB(180, 180, 180)

	local bloom = Instance.new("BloomEffect")
	bloom.Intensity = 0.4
	bloom.Size = 24
	bloom.Threshold = 1.0
	bloom.Parent = Lighting

	local colorCorr = Instance.new("ColorCorrectionEffect")
	colorCorr.Brightness = 0.0
	colorCorr.Contrast = 0.1
	colorCorr.Saturation = 0.15
	if mapInfo.DisplayName == "Bind" then
		colorCorr.TintColor = Color3.fromRGB(255, 240, 220)
		colorCorr.Saturation = 0.2
	elseif mapInfo.DisplayName == "Split" then
		colorCorr.TintColor = Color3.fromRGB(220, 220, 255)
		colorCorr.Saturation = 0.25
	elseif mapInfo.DisplayName == "Fracture" then
		colorCorr.TintColor = Color3.fromRGB(255, 230, 200)
		colorCorr.Saturation = 0.1
	elseif mapInfo.DisplayName == "Lotus" then
		colorCorr.TintColor = Color3.fromRGB(255, 240, 220)
		colorCorr.Saturation = 0.2
	else
		colorCorr.TintColor = Color3.fromRGB(255, 250, 240)
	end
	colorCorr.Parent = Lighting

	local sunRays = Instance.new("SunRaysEffect")
	sunRays.Intensity = 0.15
	sunRays.Spread = 0.8
	sunRays.Parent = Lighting

	local dof = Instance.new("DepthOfFieldEffect")
	dof.FarIntensity = 0.05
	dof.FocusDistance = 50
	dof.InFocusRadius = 30
	dof.NearIntensity = 0
	dof.Parent = Lighting

	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Density = sky.AtmosphereDensity or 0.3
	atmosphere.Offset = 0.2
	atmosphere.Color = sky.AtmosphereColor or mapInfo.ColorPalette.Primary
	atmosphere.Decay = Color3.fromRGB(106, 106, 106)
	atmosphere.Glare = 0.3
	atmosphere.Haze = sky.HazeBoost and 2.5 or 1.2
	atmosphere.Parent = Lighting

	local skyInstance = Instance.new("Sky")
	skyInstance.SkyboxBk = "rbxasset://textures/sky/sky512_bk.tex"
	skyInstance.SkyboxDn = "rbxasset://textures/sky/sky512_dn.tex"
	skyInstance.SkyboxFt = "rbxasset://textures/sky/sky512_ft.tex"
	skyInstance.SkyboxLf = "rbxasset://textures/sky/sky512_lf.tex"
	skyInstance.SkyboxRt = "rbxasset://textures/sky/sky512_rt.tex"
	skyInstance.SkyboxUp = "rbxasset://textures/sky/sky512_up.tex"
	skyInstance.CelestialBodiesShown = true
	skyInstance.SunAngularSize = sky.SunAngularSize or 11
	skyInstance.MoonAngularSize = sky.MoonAngularSize or 11
	skyInstance.StarCount = sky.StarCount or 3000
	skyInstance.Parent = Lighting
end

-- ============================================================
-- PROP BUILDERS — each function builds one decorative prop type
-- ============================================================
local PropBuilders = {}

function PropBuilders.fountain(p)
	-- Tiered stone fountain with water
	local base = makePart({
		Name = "Fountain_Base",
		Size = Vector3.new(p.size, 1, p.size),
		Position = p.pos + Vector3.new(0, 0.5, 0),
		Color = Color3.fromRGB(200, 190, 170),
		Material = Enum.Material.Marble,
	})
	local rim = makePart({
		Name = "Fountain_Rim",
		Size = Vector3.new(p.size + 2, 0.5, p.size + 2),
		Position = p.pos + Vector3.new(0, 1.2, 0),
		Color = Color3.fromRGB(180, 170, 150),
		Material = Enum.Material.Marble,
	})
	local water = makePart({
		Name = "Fountain_Water",
		Size = Vector3.new(p.size - 1, 0.4, p.size - 1),
		Position = p.pos + Vector3.new(0, 1.4, 0),
		Color = Color3.fromRGB(80, 140, 200),
		Material = Enum.Material.Glass,
		Transparency = 0.4,
	})
	local center = makePart({
		Name = "Fountain_Center",
		Size = Vector3.new(1.5, 4, 1.5),
		Position = p.pos + Vector3.new(0, 4, 0),
		Color = Color3.fromRGB(200, 190, 170),
		Material = Enum.Material.Marble,
	})
	-- Water spray particle
	local spray = Instance.new("ParticleEmitter")
	spray.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	spray.Color = ColorSequence.new(Color3.fromRGB(180, 220, 255))
	spray.Lifetime = NumberRange.new(0.8, 1.4)
	spray.Rate = 30
	spray.Speed = NumberRange.new(8, 12)
	spray.Acceleration = Vector3.new(0, -25, 0)
	spray.SpreadAngle = Vector2.new(20, 20)
	spray.Size = NumberSequence.new(0.4, 0.1)
	spray.Transparency = NumberSequence.new(0.3, 1)
	spray.Parent = center
end

function PropBuilders.archway(p)
	-- Stone arch (two pillars + top)
	local w = p.width or 14
	local h = 10
	makePart({ Name="ArchPillarL", Size=Vector3.new(2, h, 2), Position=p.pos+Vector3.new(-w/2, h/2, 0), Color=Color3.fromRGB(220, 200, 170), Material=Enum.Material.Slate })
	makePart({ Name="ArchPillarR", Size=Vector3.new(2, h, 2), Position=p.pos+Vector3.new(w/2, h/2, 0), Color=Color3.fromRGB(220, 200, 170), Material=Enum.Material.Slate })
	makePart({ Name="ArchTop", Size=Vector3.new(w + 2, 2, 3), Position=p.pos+Vector3.new(0, h + 1, 0), Color=Color3.fromRGB(180, 100, 70), Material=Enum.Material.Brick })
end

function PropBuilders.statue(p)
	-- Marble statue (pedestal + body)
	makePart({ Name="StatuePedestal", Size=Vector3.new(3, 2, 3), Position=p.pos+Vector3.new(0, 1, 0), Color=Color3.fromRGB(180, 170, 150), Material=Enum.Material.Marble })
	makePart({ Name="StatueBody", Size=Vector3.new(2, 6, 2), Position=p.pos+Vector3.new(0, 5, 0), Color=p.color or Color3.fromRGB(220, 210, 190), Material=Enum.Material.Marble })
	makePart({ Name="StatueHead", Shape=Enum.PartType.Ball, Size=Vector3.new(1.4, 1.4, 1.4), Position=p.pos+Vector3.new(0, 8.7, 0), Color=p.color or Color3.fromRGB(220, 210, 190), Material=Enum.Material.Marble })
end

function PropBuilders.ivy(p)
	-- Hanging ivy panel
	local panel = makePart({
		Name="Ivy",
		Size=(p.face == "X" or p.face == "-X") and Vector3.new(0.4, 12, 20) or Vector3.new(20, 12, 0.4),
		Position=p.pos,
		Color=Color3.fromRGB(60, 100, 50),
		Material=Enum.Material.Grass,
	})
end

function PropBuilders.barrel_stack(p)
	-- 3 barrels stacked pyramid
	for i, offset in ipairs({{x=-1.5, y=0}, {x=1.5, y=0}, {x=0, y=2}}) do
		local b = Instance.new("Part")
		b.Name = "Barrel"
		b.Shape = Enum.PartType.Cylinder
		b.Size = Vector3.new(2.5, 2, 2)
		b.CFrame = CFrame.new(p.pos + Vector3.new(offset.x, 1 + offset.y, 0)) * CFrame.Angles(0, 0, math.rad(90))
		b.Anchored = true
		b.Color = Color3.fromRGB(140, 80, 40)
		b.Material = Enum.Material.Wood
		b.Parent = mapFolder
	end
end

function PropBuilders.cypress(p)
	-- Tall thin Tuscan cypress
	makePart({ Name="CypressTrunk", Size=Vector3.new(1, 16, 1), Position=p.pos+Vector3.new(0, 8, 0), Color=Color3.fromRGB(90, 70, 50), Material=Enum.Material.Wood })
	for i = 0, 4 do
		local foliage = Instance.new("Part")
		foliage.Name = "CypressFoliage"
		foliage.Shape = Enum.PartType.Ball
		local sz = 4 - i * 0.5
		foliage.Size = Vector3.new(sz, sz, sz)
		foliage.Position = p.pos + Vector3.new(0, 6 + i * 3, 0)
		foliage.Anchored = true
		foliage.Color = Color3.fromRGB(50, 80, 50)
		foliage.Material = Enum.Material.LeafyGrass
		foliage.Parent = mapFolder
	end
end

function PropBuilders.palm(p)
	-- Palm tree (curved trunk + fronds)
	makePart({ Name="PalmTrunk", Size=Vector3.new(1.5, 18, 1.5), Position=p.pos+Vector3.new(0, 9, 0), Color=Color3.fromRGB(110, 80, 50), Material=Enum.Material.Wood })
	-- Fronds (5 angled boards)
	for i = 0, 4 do
		local angle = i * 72
		local frond = Instance.new("Part")
		frond.Name = "PalmFrond"
		frond.Size = Vector3.new(8, 0.3, 2.5)
		local rad = math.rad(angle)
		frond.CFrame = CFrame.new(p.pos + Vector3.new(math.cos(rad) * 3, 18, math.sin(rad) * 3))
			* CFrame.Angles(0, rad, math.rad(-25))
		frond.Anchored = true
		frond.Color = Color3.fromRGB(60, 130, 50)
		frond.Material = Enum.Material.LeafyGrass
		frond.Parent = mapFolder
	end
end

function PropBuilders.moroccan_arch(p)
	-- Horseshoe arch with blue tile
	local w = 10
	local h = 12
	makePart({ Name="MoroccoArchL", Size=Vector3.new(1.5, h, 1.5), Position=p.pos+Vector3.new(-w/2, h/2, 0), Color=Color3.fromRGB(230, 180, 120), Material=Enum.Material.Sandstone })
	makePart({ Name="MoroccoArchR", Size=Vector3.new(1.5, h, 1.5), Position=p.pos+Vector3.new(w/2, h/2, 0), Color=Color3.fromRGB(230, 180, 120), Material=Enum.Material.Sandstone })
	makePart({ Name="MoroccoArchTop", Size=Vector3.new(w + 2, 2, 1.5), Position=p.pos+Vector3.new(0, h + 1, 0), Color=Color3.fromRGB(80, 110, 160), Material=Enum.Material.Marble })
	-- Tile accent panel
	makePart({ Name="MoroccoTile", Size=Vector3.new(w - 2, 1.5, 0.3), Position=p.pos+Vector3.new(0, h + 3, 0), Color=Color3.fromRGB(80, 110, 160), Material=Enum.Material.Marble })
end

function PropBuilders.lantern_hanging(p)
	-- Hanging Moroccan/Asian lantern
	makePart({ Name="LanternChain", Size=Vector3.new(0.2, 4, 0.2), Position=p.pos+Vector3.new(0, 2, 0), Color=Color3.fromRGB(60, 50, 40), Material=Enum.Material.Metal })
	local body = makePart({ Name="LanternBody", Size=Vector3.new(2, 3, 2), Position=p.pos-Vector3.new(0, 1.5, 0), Color=Color3.fromRGB(255, 180, 80), Material=Enum.Material.Neon, Transparency=0.2 })
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 180, 80)
	light.Range = 14
	light.Brightness = 2
	light.Parent = body
end

function PropBuilders.mosaic_panel(p)
	local size = (p.face == "X" or p.face == "-X") and Vector3.new(0.4, 8, 12) or Vector3.new(12, 8, 0.4)
	makePart({ Name="MosaicPanel", Size=size, Position=p.pos, Color=Color3.fromRGB(80, 110, 160), Material=Enum.Material.Marble })
end

function PropBuilders.market_stall(p)
	-- Stall with red/blue fabric awning
	makePart({ Name="StallCounter", Size=Vector3.new(6, 3, 3), Position=p.pos+Vector3.new(0, 1.5, 0), Color=Color3.fromRGB(110, 70, 40), Material=Enum.Material.Wood })
	makePart({ Name="StallPoleL", Size=Vector3.new(0.3, 5, 0.3), Position=p.pos+Vector3.new(-2.7, 5.5, 1.3), Color=Color3.fromRGB(80, 60, 40), Material=Enum.Material.Wood })
	makePart({ Name="StallPoleR", Size=Vector3.new(0.3, 5, 0.3), Position=p.pos+Vector3.new(2.7, 5.5, 1.3), Color=Color3.fromRGB(80, 60, 40), Material=Enum.Material.Wood })
	makePart({ Name="StallAwning", Size=Vector3.new(7, 0.2, 4), Position=p.pos+Vector3.new(0, 8, 1.5), Color=p.color or Color3.fromRGB(200, 60, 60), Material=Enum.Material.Fabric })
end

function PropBuilders.well(p)
	-- Stone well
	local well = Instance.new("Part")
	well.Name = "Well"
	well.Shape = Enum.PartType.Cylinder
	well.Size = Vector3.new(5, 6, 6)
	well.CFrame = CFrame.new(p.pos + Vector3.new(0, 2.5, 0)) * CFrame.Angles(0, 0, math.rad(90))
	well.Anchored = true
	well.Color = Color3.fromRGB(160, 140, 110)
	well.Material = Enum.Material.Slate
	well.Parent = mapFolder
	-- Roof
	makePart({ Name="WellRoofL", Size=Vector3.new(0.3, 6, 0.3), Position=p.pos+Vector3.new(-2, 8, 0), Color=Color3.fromRGB(80, 60, 40), Material=Enum.Material.Wood })
	makePart({ Name="WellRoofR", Size=Vector3.new(0.3, 6, 0.3), Position=p.pos+Vector3.new(2, 8, 0), Color=Color3.fromRGB(80, 60, 40), Material=Enum.Material.Wood })
	makePart({ Name="WellRoofTop", Size=Vector3.new(5, 0.4, 4), Position=p.pos+Vector3.new(0, 11, 0), Color=Color3.fromRGB(140, 80, 50), Material=Enum.Material.Wood })
end

function PropBuilders.vending(p)
	-- Cyberpunk vending machine
	local body = makePart({ Name="VendingBody", Size=Vector3.new(3, 7, 2), Position=p.pos+Vector3.new(0, 3.5, 0), Color=Color3.fromRGB(40, 40, 50), Material=Enum.Material.Metal })
	local screen = makePart({ Name="VendingScreen", Size=Vector3.new(2.6, 5, 0.2), Position=p.pos+Vector3.new(0, 4, 1.05), Color=p.color or Color3.fromRGB(255, 100, 200), Material=Enum.Material.Neon, Transparency=0.1 })
	local light = Instance.new("PointLight")
	light.Color = p.color or Color3.fromRGB(255, 100, 200)
	light.Range = 12
	light.Brightness = 1.8
	light.Parent = screen
end

function PropBuilders.neon_sign(p)
	-- Vertical neon sign (Japanese characters)
	local pole = makePart({ Name="NeonPole", Size=Vector3.new(0.3, 15, 0.3), Position=p.pos+Vector3.new(0, 7.5, 0), Color=Color3.fromRGB(30, 30, 35), Material=Enum.Material.Metal })
	local sign = makePart({ Name="NeonSign", Size=Vector3.new(0.5, 8, 3), Position=p.pos+Vector3.new(0, 11, 0), Color=p.color or Color3.fromRGB(255, 100, 200), Material=Enum.Material.Neon, Transparency=0.05 })
	-- Character via SurfaceGui
	local sg = Instance.new("SurfaceGui")
	sg.Face = Enum.NormalId.Front
	sg.CanvasSize = Vector2.new(120, 320)
	sg.Parent = sign
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.fromScale(1, 1)
	lbl.BackgroundTransparency = 1
	lbl.Text = p.text or ""
	lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	lbl.Font = Enum.Font.GothamBlack
	lbl.TextScaled = true
	lbl.Parent = sg
	local light = Instance.new("PointLight")
	light.Color = p.color or Color3.fromRGB(255, 100, 200)
	light.Range = 20
	light.Brightness = 2.5
	light.Parent = sign
end

function PropBuilders.ramen_stand(p)
	-- Wooden ramen stand with red lantern
	makePart({ Name="RamenCounter", Size=Vector3.new(8, 3, 3), Position=p.pos+Vector3.new(0, 1.5, 0), Color=Color3.fromRGB(130, 80, 50), Material=Enum.Material.Wood })
	makePart({ Name="RamenRoofL", Size=Vector3.new(0.3, 5, 0.3), Position=p.pos+Vector3.new(-3.7, 5.5, 0), Color=Color3.fromRGB(60, 40, 30), Material=Enum.Material.Wood })
	makePart({ Name="RamenRoofR", Size=Vector3.new(0.3, 5, 0.3), Position=p.pos+Vector3.new(3.7, 5.5, 0), Color=Color3.fromRGB(60, 40, 30), Material=Enum.Material.Wood })
	makePart({ Name="RamenRoof", Size=Vector3.new(9, 0.4, 4), Position=p.pos+Vector3.new(0, 8, 0), Color=Color3.fromRGB(180, 60, 60), Material=Enum.Material.Fabric })
	-- Red lantern
	local lantern = makePart({ Name="RamenLantern", Shape=Enum.PartType.Ball, Size=Vector3.new(1.5, 2, 1.5), Position=p.pos+Vector3.new(0, 6, 0), Color=Color3.fromRGB(220, 60, 60), Material=Enum.Material.Neon, Transparency=0.1 })
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 100, 80)
	light.Range = 10
	light.Brightness = 1.5
	light.Parent = lantern
end

function PropBuilders.wire(p)
	-- Power wire (cylinder between two points)
	local midpoint = (p.from + p.to) / 2
	local length = (p.to - p.from).Magnitude
	local wire = Instance.new("Part")
	wire.Name = "Wire"
	wire.Size = Vector3.new(0.2, length, 0.2)
	wire.CFrame = CFrame.new(midpoint, p.to) * CFrame.Angles(math.rad(90), 0, 0)
	wire.Anchored = true
	wire.Color = Color3.fromRGB(20, 20, 25)
	wire.Material = Enum.Material.Metal
	wire.Parent = mapFolder
end

function PropBuilders.bicycle(p)
	-- Simple bike (2 wheels + frame)
	local wheelL = Instance.new("Part")
	wheelL.Name = "BikeWheel"
	wheelL.Shape = Enum.PartType.Cylinder
	wheelL.Size = Vector3.new(0.4, 2.5, 2.5)
	wheelL.CFrame = CFrame.new(p.pos + Vector3.new(-1.5, 1.2, 0))
	wheelL.Anchored = true
	wheelL.Color = Color3.fromRGB(30, 30, 30)
	wheelL.Material = Enum.Material.Plastic
	wheelL.Parent = mapFolder

	local wheelR = wheelL:Clone()
	wheelR.CFrame = CFrame.new(p.pos + Vector3.new(1.5, 1.2, 0))
	wheelR.Parent = mapFolder

	makePart({ Name="BikeFrame", Size=Vector3.new(3.5, 0.3, 0.4), Position=p.pos+Vector3.new(0, 2, 0), Color=Color3.fromRGB(180, 60, 60), Material=Enum.Material.Metal })
	makePart({ Name="BikeSeat", Size=Vector3.new(0.7, 0.3, 1), Position=p.pos+Vector3.new(0.5, 2.5, 0), Color=Color3.fromRGB(30, 30, 30), Material=Enum.Material.SmoothPlastic })
end

function PropBuilders.ac_unit(p)
	makePart({ Name="ACUnit", Size=Vector3.new(3, 2.5, 2), Position=p.pos+Vector3.new(0, 1.25, 0), Color=Color3.fromRGB(160, 160, 170), Material=Enum.Material.Metal })
end

function PropBuilders.stupa(p)
	-- Buddhist stupa: square base, dome, spire
	makePart({ Name="StupaBase", Size=Vector3.new(8, 3, 8), Position=p.pos+Vector3.new(0, 1.5, 0), Color=Color3.fromRGB(250, 245, 240), Material=Enum.Material.Marble })
	makePart({ Name="StupaTier", Size=Vector3.new(6, 2, 6), Position=p.pos+Vector3.new(0, 4, 0), Color=Color3.fromRGB(250, 245, 240), Material=Enum.Material.Marble })
	local dome = makePart({ Name="StupaDome", Shape=Enum.PartType.Ball, Size=Vector3.new(6, 6, 6), Position=p.pos+Vector3.new(0, 7, 0), Color=Color3.fromRGB(250, 245, 240), Material=Enum.Material.Marble })
	makePart({ Name="StupaSpire", Size=Vector3.new(0.6, 6, 0.6), Position=p.pos+Vector3.new(0, 12, 0), Color=Color3.fromRGB(255, 200, 80), Material=Enum.Material.Neon })
end

function PropBuilders.prayer_flags(p)
	-- 5 colored flags along a line
	local colors = {
		Color3.fromRGB(60, 100, 200), Color3.fromRGB(255, 255, 255),
		Color3.fromRGB(220, 60, 60), Color3.fromRGB(60, 180, 80),
		Color3.fromRGB(255, 200, 80),
	}
	-- Wire
	PropBuilders.wire({from=p.from, to=p.to})
	-- Flags
	local segments = 10
	for i = 0, segments do
		local t = i / segments
		local pos = p.from:Lerp(p.to, t)
		local flag = makePart({
			Name="PrayerFlag",
			Size=Vector3.new(0.1, 2, 2.5),
			Position=pos - Vector3.new(0, 1.5, 0),
			Color=colors[(i % 5) + 1],
			Material=Enum.Material.Fabric,
		})
	end
end

function PropBuilders.bell(p)
	-- Bronze bell on stand
	makePart({ Name="BellPostL", Size=Vector3.new(0.4, 6, 0.4), Position=p.pos+Vector3.new(-1.5, 3, 0), Color=Color3.fromRGB(60, 40, 20), Material=Enum.Material.Wood })
	makePart({ Name="BellPostR", Size=Vector3.new(0.4, 6, 0.4), Position=p.pos+Vector3.new(1.5, 3, 0), Color=Color3.fromRGB(60, 40, 20), Material=Enum.Material.Wood })
	makePart({ Name="BellBeam", Size=Vector3.new(4, 0.5, 0.5), Position=p.pos+Vector3.new(0, 6.5, 0), Color=Color3.fromRGB(60, 40, 20), Material=Enum.Material.Wood })
	local bell = Instance.new("Part")
	bell.Name = "Bell"
	bell.Shape = Enum.PartType.Cylinder
	bell.Size = Vector3.new(2, 2, 2)
	bell.CFrame = CFrame.new(p.pos + Vector3.new(0, 5, 0)) * CFrame.Angles(0, 0, math.rad(90))
	bell.Anchored = true
	bell.Color = Color3.fromRGB(180, 120, 50)
	bell.Material = Enum.Material.Metal
	bell.Parent = mapFolder
end

function PropBuilders.tree(p)
	-- Generic colorful tree (cherry/rhododendron)
	makePart({ Name="TreeTrunk", Size=Vector3.new(1.5, 8, 1.5), Position=p.pos+Vector3.new(0, 4, 0), Color=Color3.fromRGB(80, 60, 40), Material=Enum.Material.Wood })
	for i = 0, 5 do
		local rad = math.rad(i * 60)
		local foliage = Instance.new("Part")
		foliage.Name = "TreeFoliage"
		foliage.Shape = Enum.PartType.Ball
		foliage.Size = Vector3.new(5, 5, 5)
		foliage.Position = p.pos + Vector3.new(math.cos(rad) * 2, 9 + math.sin(rad) * 1.5, math.sin(rad) * 2)
		foliage.Anchored = true
		foliage.Color = p.color or Color3.fromRGB(255, 150, 200)
		foliage.Material = Enum.Material.LeafyGrass
		foliage.Parent = mapFolder
	end
end

function PropBuilders.prayer_wheel(p)
	-- Cylindrical prayer wheel
	local wheel = Instance.new("Part")
	wheel.Name = "PrayerWheel"
	wheel.Shape = Enum.PartType.Cylinder
	wheel.Size = Vector3.new(3, 2, 2)
	wheel.CFrame = CFrame.new(p.pos + Vector3.new(0, 2.5, 0))
	wheel.Anchored = true
	wheel.Color = Color3.fromRGB(220, 160, 80)
	wheel.Material = Enum.Material.Metal
	wheel.Parent = mapFolder
	-- Animate rotation
	task.spawn(function()
		while wheel.Parent do
			wheel.CFrame = wheel.CFrame * CFrame.Angles(math.rad(2), 0, 0)
			task.wait(0.05)
		end
	end)
end

function PropBuilders.brazier(p)
	-- Bronze brazier with fire
	local bowl = Instance.new("Part")
	bowl.Name = "Brazier"
	bowl.Shape = Enum.PartType.Cylinder
	bowl.Size = Vector3.new(0.5, 3, 3)
	bowl.CFrame = CFrame.new(p.pos + Vector3.new(0, 2.5, 0)) * CFrame.Angles(0, 0, math.rad(90))
	bowl.Anchored = true
	bowl.Color = Color3.fromRGB(140, 80, 30)
	bowl.Material = Enum.Material.Metal
	bowl.Parent = mapFolder
	-- Fire light
	local fire = Instance.new("PointLight")
	fire.Color = Color3.fromRGB(255, 140, 60)
	fire.Range = 12
	fire.Brightness = 2.5
	fire.Parent = bowl
	-- Fire particle
	local flame = Instance.new("Fire")
	flame.Heat = 8
	flame.Size = 3
	flame.Color = Color3.fromRGB(255, 140, 60)
	flame.SecondaryColor = Color3.fromRGB(255, 80, 20)
	flame.Parent = bowl
end

function PropBuilders.wrecked_truck(p)
	local rot = math.rad(p.rot or 0)
	-- Body
	local body = makePart({ Name="TruckBody", Size=Vector3.new(8, 4, 4), CFrame=CFrame.new(p.pos+Vector3.new(0, 2, 0)) * CFrame.Angles(0, rot, math.rad(15)), Color=Color3.fromRGB(120, 90, 50), Material=Enum.Material.CorrodedMetal })
	-- Cab
	local cab = makePart({ Name="TruckCab", Size=Vector3.new(3, 3.5, 4), CFrame=CFrame.new(p.pos + (CFrame.Angles(0, rot, 0) * Vector3.new(2.5, 4, 0))) * CFrame.Angles(0, rot, math.rad(10)), Color=Color3.fromRGB(100, 70, 40), Material=Enum.Material.CorrodedMetal })
	-- Wheels (4 wheels)
	for _, offset in ipairs({{x=-3, z=2}, {x=3, z=2}, {x=-3, z=-2}, {x=3, z=-2}}) do
		local pos = p.pos + (CFrame.Angles(0, rot, 0) * Vector3.new(offset.x, 0, offset.z))
		local w = Instance.new("Part")
		w.Name = "TruckWheel"
		w.Shape = Enum.PartType.Cylinder
		w.Size = Vector3.new(0.8, 2, 2)
		w.CFrame = CFrame.new(pos + Vector3.new(0, 1, 0)) * CFrame.Angles(0, rot, 0)
		w.Anchored = true
		w.Color = Color3.fromRGB(30, 30, 30)
		w.Material = Enum.Material.Plastic
		w.Parent = mapFolder
	end
end

function PropBuilders.wrecked_car(p)
	local rot = math.rad(p.rot or 0)
	makePart({ Name="CarBody", Size=Vector3.new(5, 2, 3), CFrame=CFrame.new(p.pos+Vector3.new(0, 1.2, 0)) * CFrame.Angles(0, rot, math.rad(-8)), Color=Color3.fromRGB(160, 50, 40), Material=Enum.Material.CorrodedMetal })
	makePart({ Name="CarCab", Size=Vector3.new(3.5, 1.5, 2.8), CFrame=CFrame.new(p.pos+Vector3.new(0, 2.8, 0)) * CFrame.Angles(0, rot, math.rad(-8)), Color=Color3.fromRGB(140, 40, 30), Material=Enum.Material.CorrodedMetal })
end

function PropBuilders.container(p)
	-- Shipping container
	makePart({ Name="Container", Size=Vector3.new(12, 6, 5), Position=p.pos+Vector3.new(0, 3, 0), Color=p.color or Color3.fromRGB(160, 80, 40), Material=Enum.Material.CorrodedMetal })
end

function PropBuilders.generator(p)
	-- Yellow industrial generator
	makePart({ Name="Generator", Size=Vector3.new(4, 3, 3), Position=p.pos+Vector3.new(0, 1.5, 0), Color=Color3.fromRGB(220, 180, 40), Material=Enum.Material.Metal })
	makePart({ Name="GeneratorPipe", Size=Vector3.new(0.6, 4, 0.6), Position=p.pos+Vector3.new(1.5, 5, 0), Color=Color3.fromRGB(60, 60, 70), Material=Enum.Material.Metal })
	-- Smoke from pipe
	local pipe = mapFolder:FindFirstChild("GeneratorPipe")
	if pipe then
		local smoke = Instance.new("Smoke")
		smoke.Color = Color3.fromRGB(80, 80, 80)
		smoke.Size = 1.5
		smoke.RiseVelocity = 4
		smoke.Opacity = 0.4
		smoke.Parent = pipe
	end
end

function PropBuilders.antenna(p)
	-- Tall antenna tower
	makePart({ Name="AntennaBase", Size=Vector3.new(4, 1, 4), Position=p.pos+Vector3.new(0, 0.5, 0), Color=Color3.fromRGB(80, 80, 90), Material=Enum.Material.Metal })
	local truss = Instance.new("TrussPart")
	truss.Name = "AntennaTruss"
	truss.Size = Vector3.new(2, 25, 2)
	truss.CFrame = CFrame.new(p.pos + Vector3.new(0, 13, 0))
	truss.Anchored = true
	truss.Color = Color3.fromRGB(80, 80, 90)
	truss.Material = Enum.Material.Metal
	truss.Parent = mapFolder
	-- Red blinking light at top
	local top = makePart({ Name="AntennaLight", Shape=Enum.PartType.Ball, Size=Vector3.new(1, 1, 1), Position=p.pos+Vector3.new(0, 27, 0), Color=Color3.fromRGB(255, 60, 60), Material=Enum.Material.Neon })
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 60, 60)
	light.Range = 20
	light.Brightness = 2
	light.Parent = top
	-- Blink
	task.spawn(function()
		while top.Parent do
			top.Transparency = 0
			light.Enabled = true
			task.wait(1)
			top.Transparency = 0.7
			light.Enabled = false
			task.wait(1)
		end
	end)
end

function PropBuilders.warning_sign(p)
	makePart({ Name="WarnPost", Size=Vector3.new(0.3, 5, 0.3), Position=p.pos+Vector3.new(0, 2.5, 0), Color=Color3.fromRGB(60, 60, 70), Material=Enum.Material.Metal })
	local sign = makePart({ Name="WarnSign", Size=Vector3.new(2.5, 2.5, 0.2), Position=p.pos+Vector3.new(0, 4.5, 0), Color=Color3.fromRGB(255, 200, 40), Material=Enum.Material.Metal })
	-- Black triangle in middle
	makePart({ Name="WarnTriangle", Size=Vector3.new(1.8, 1.8, 0.3), Position=p.pos+Vector3.new(0, 4.5, 0.1), Color=Color3.fromRGB(20, 20, 20), Material=Enum.Material.SmoothPlastic })
end

function PropBuilders.rebar_pile(p)
	-- Pile of broken rebar
	for i = 1, 5 do
		local rad = math.rad(i * 72)
		local bar = Instance.new("Part")
		bar.Name = "Rebar"
		bar.Size = Vector3.new(0.3, 0.3, 6)
		bar.CFrame = CFrame.new(p.pos + Vector3.new(math.cos(rad), 0.5 + i * 0.1, math.sin(rad))) * CFrame.Angles(math.rad(5), rad, math.rad(15))
		bar.Anchored = true
		bar.Color = Color3.fromRGB(100, 50, 30)
		bar.Material = Enum.Material.CorrodedMetal
		bar.Parent = mapFolder
	end
end

function PropBuilders.lotus_pond(p)
	-- Octagonal pond with lotus flowers
	makePart({ Name="PondRim", Size=Vector3.new(p.size + 2, 0.5, p.size + 2), Position=p.pos+Vector3.new(0, 0.5, 0), Color=Color3.fromRGB(180, 170, 150), Material=Enum.Material.Marble })
	local water = makePart({ Name="PondWater", Size=Vector3.new(p.size, 0.4, p.size), Position=p.pos+Vector3.new(0, 0.7, 0), Color=Color3.fromRGB(80, 140, 120), Material=Enum.Material.Glass, Transparency=0.35 })
	-- Lotus flowers
	for i = 1, 4 do
		local rad = math.rad(i * 90 + 45)
		local r = p.size / 3
		local flower = Instance.new("Part")
		flower.Name = "LotusFlower"
		flower.Shape = Enum.PartType.Ball
		flower.Size = Vector3.new(1.2, 0.5, 1.2)
		flower.Position = p.pos + Vector3.new(math.cos(rad) * r, 1, math.sin(rad) * r)
		flower.Anchored = true
		flower.Color = Color3.fromRGB(255, 180, 220)
		flower.Material = Enum.Material.Neon
		flower.Parent = mapFolder
	end
end

function PropBuilders.buddha(p)
	-- Seated Buddha statue
	makePart({ Name="BuddhaPedestal", Size=Vector3.new(6, 2, 6), Position=p.pos+Vector3.new(0, 1, 0), Color=Color3.fromRGB(220, 200, 170), Material=Enum.Material.Granite })
	makePart({ Name="BuddhaBody", Size=Vector3.new(4, 5, 3), Position=p.pos+Vector3.new(0, 4.5, 0), Color=Color3.fromRGB(220, 180, 60), Material=Enum.Material.Metal })
	makePart({ Name="BuddhaHead", Shape=Enum.PartType.Ball, Size=Vector3.new(2.5, 2.5, 2.5), Position=p.pos+Vector3.new(0, 8.5, 0), Color=Color3.fromRGB(220, 180, 60), Material=Enum.Material.Metal })
end

function PropBuilders.rotating_door(p)
	-- Large rotating stone door
	local door = makePart({ Name="RotatingDoor", Size=Vector3.new(12, 8, 0.8), Position=p.pos+Vector3.new(0, 4, 0), Color=Color3.fromRGB(140, 120, 100), Material=Enum.Material.Slate })
	door:SetAttribute("IsRotatingDoor", true)
	-- Animate rotation slowly when triggered (here: continuous slow rotation for visual)
	task.spawn(function()
		while door.Parent do
			door.CFrame = door.CFrame * CFrame.Angles(0, math.rad(0.5), 0)
			task.wait(0.05)
		end
	end)
end

function PropBuilders.pillar(p)
	-- Carved temple pillar
	makePart({ Name="PillarBase", Size=Vector3.new(3, 1, 3), Position=p.pos+Vector3.new(0, 0.5, 0), Color=Color3.fromRGB(200, 180, 150), Material=Enum.Material.Granite })
	makePart({ Name="PillarShaft", Size=Vector3.new(2, 12, 2), Position=p.pos+Vector3.new(0, 7, 0), Color=Color3.fromRGB(220, 200, 170), Material=Enum.Material.Marble })
	makePart({ Name="PillarCap", Size=Vector3.new(3, 1, 3), Position=p.pos+Vector3.new(0, 13.5, 0), Color=Color3.fromRGB(200, 180, 150), Material=Enum.Material.Granite })
end

function PropBuilders.elephant_statue(p)
	-- Stone elephant guardian
	makePart({ Name="ElephantBody", Size=Vector3.new(4, 3, 2.5), Position=p.pos+Vector3.new(0, 3, 0), Color=Color3.fromRGB(180, 170, 150), Material=Enum.Material.Granite })
	makePart({ Name="ElephantHead", Size=Vector3.new(2.5, 2, 2), Position=p.pos+Vector3.new(0, 4.5, 1.5), Color=Color3.fromRGB(180, 170, 150), Material=Enum.Material.Granite })
	-- 4 legs
	for _, ox in ipairs({-1.3, 1.3}) do
		for _, oz in ipairs({-0.9, 0.9}) do
			makePart({ Name="ElephantLeg", Size=Vector3.new(0.7, 3, 0.7), Position=p.pos+Vector3.new(ox, 1.5, oz), Color=Color3.fromRGB(180, 170, 150), Material=Enum.Material.Granite })
		end
	end
	-- Trunk
	makePart({ Name="ElephantTrunk", Size=Vector3.new(0.5, 2.5, 0.5), Position=p.pos+Vector3.new(0, 3, 2.5), Color=Color3.fromRGB(180, 170, 150), Material=Enum.Material.Granite })
end

function PropBuilders.banyan(p)
	-- Large banyan tree (multiple trunks)
	for _, ox in ipairs({-1.5, 0, 1.5}) do
		makePart({ Name="BanyanTrunk", Size=Vector3.new(1.2, 12, 1.2), Position=p.pos+Vector3.new(ox, 6, 0), Color=Color3.fromRGB(110, 80, 50), Material=Enum.Material.Wood })
	end
	for i = 0, 7 do
		local rad = math.rad(i * 45)
		local foliage = Instance.new("Part")
		foliage.Name = "BanyanFoliage"
		foliage.Shape = Enum.PartType.Ball
		foliage.Size = Vector3.new(6, 5, 6)
		foliage.Position = p.pos + Vector3.new(math.cos(rad) * 4, 13, math.sin(rad) * 4)
		foliage.Anchored = true
		foliage.Color = Color3.fromRGB(60, 130, 50)
		foliage.Material = Enum.Material.LeafyGrass
		foliage.Parent = mapFolder
	end
end

-- ============================================================
-- NEW DENSIFICATION PROPS (matches presentation/maps3d.html)
-- ============================================================

function PropBuilders.crate_pile(p)
	local offsets = { {-1.5, 1, 0}, {1.5, 1, 0}, {-0.5, 1, 1.5}, {0.5, 3, 0}, {0, 3, 1.5} }
	for _, o in ipairs(offsets) do
		makePart({ Name="Crate", Size=Vector3.new(2.5, 2, 2.5), Position=p.pos+Vector3.new(o[1], o[2], o[3]), Color=Color3.fromRGB(160, 110, 80), Material=Enum.Material.WoodPlanks })
	end
end

function PropBuilders.log_pile(p)
	for i = 0, 3 do
		local log = Instance.new("Part")
		log.Name = "Log"
		log.Shape = Enum.PartType.Cylinder
		log.Size = Vector3.new(6, 1.6, 1.6)
		log.CFrame = CFrame.new(p.pos + Vector3.new(0, 0.8 + (i % 2) * 1.6, math.floor(i / 2) * 1.6))
		log.Anchored = true
		log.Color = Color3.fromRGB(110, 72, 40)
		log.Material = Enum.Material.Wood
		log.Parent = mapFolder
	end
end

function PropBuilders.hanging_laundry(p)
	PropBuilders.wire(p)
	local laundry = { Color3.fromRGB(255, 100, 200), Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 200, 80), Color3.fromRGB(80, 200, 255), Color3.fromRGB(180, 100, 255) }
	local fromV, toV = p.from, p.to
	for i = 1, 5 do
		local t = i / 6
		local pos = fromV:Lerp(toV, t)
		makePart({ Name="Laundry", Size=Vector3.new(0.1, 4, 3), Position=pos - Vector3.new(0, 2, 0), Color=laundry[i], Material=Enum.Material.Fabric })
	end
end

function PropBuilders.planter(p)
	makePart({ Name="PlanterBox", Size=Vector3.new(3, 1.5, 3), Position=p.pos+Vector3.new(0, 0.75, 0), Color=Color3.fromRGB(130, 100, 70), Material=Enum.Material.Wood })
	local foliage = Instance.new("Part")
	foliage.Name = "PlanterFoliage"
	foliage.Shape = Enum.PartType.Ball
	foliage.Size = Vector3.new(2.4, 1.6, 2.4)
	foliage.Position = p.pos + Vector3.new(0, 1.8, 0)
	foliage.Anchored = true
	foliage.Color = Color3.fromRGB(80, 140, 60)
	foliage.Material = Enum.Material.LeafyGrass
	foliage.Parent = mapFolder
	for i = 0, 4 do
		local angle = math.rad(i * 72)
		makePart({ Name="Flower", Shape=Enum.PartType.Ball, Size=Vector3.new(1, 1, 1), Position=p.pos+Vector3.new(math.cos(angle) * 0.9, 2, math.sin(angle) * 0.9), Color=p.color or Color3.fromRGB(255, 100, 100), Material=Enum.Material.Neon })
	end
end

function PropBuilders.wall_banner(p)
	local colors = p.colors or { Color3.fromRGB(0,140,69), Color3.fromRGB(255,255,255), Color3.fromRGB(206,17,38) }
	for i = 1, 3 do
		makePart({ Name="BannerStripe", Size=Vector3.new(2, 8, 0.3), Position=p.pos+Vector3.new(-2 + (i - 1) * 2, 0, 0), Color=colors[i], Material=Enum.Material.Fabric })
	end
end

function PropBuilders.shop_sign(p)
	local sign = makePart({ Name="ShopSign", Size=Vector3.new(8, 2.5, 0.4), Position=p.pos, Color=p.color or Color3.fromRGB(220, 60, 60), Material=Enum.Material.Neon, Transparency=0.05 })
	local sg = Instance.new("SurfaceGui")
	sg.Face = Enum.NormalId.Back
	sg.CanvasSize = Vector2.new(400, 100)
	sg.Parent = sign
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.fromScale(1, 1)
	lbl.BackgroundTransparency = 1
	lbl.Text = p.text or "SHOP"
	lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	lbl.Font = Enum.Font.GothamBlack
	lbl.TextScaled = true
	lbl.Parent = sg
	local light = Instance.new("PointLight")
	light.Color = p.color or Color3.fromRGB(220, 60, 60)
	light.Range = 14
	light.Brightness = 1.2
	light.Parent = sign
end

function PropBuilders.street_lamp(p)
	makePart({ Name="StreetLampPost", Size=Vector3.new(0.4, 12, 0.4), Position=p.pos+Vector3.new(0, 6, 0), Color=Color3.fromRGB(40, 40, 50), Material=Enum.Material.Metal })
	makePart({ Name="StreetLampArm", Size=Vector3.new(2, 0.3, 0.3), Position=p.pos+Vector3.new(1, 11.5, 0), Color=Color3.fromRGB(40, 40, 50), Material=Enum.Material.Metal })
	local lamp = makePart({ Name="StreetLampBulb", Shape=Enum.PartType.Ball, Size=Vector3.new(1.4, 1.4, 1.4), Position=p.pos+Vector3.new(2, 11, 0), Color=Color3.fromRGB(255, 220, 150), Material=Enum.Material.Neon })
	local pl = Instance.new("PointLight")
	pl.Color = Color3.fromRGB(255, 220, 150)
	pl.Range = 16
	pl.Brightness = 1.5
	pl.Parent = lamp
end

function PropBuilders.bench(p)
	makePart({ Name="BenchSeat", Size=Vector3.new(5, 0.4, 1.5), Position=p.pos+Vector3.new(0, 1.5, 0), Color=Color3.fromRGB(100, 60, 30), Material=Enum.Material.Wood })
	makePart({ Name="BenchBack", Size=Vector3.new(5, 2, 0.4), Position=p.pos+Vector3.new(0, 2.5, -0.5), Color=Color3.fromRGB(100, 60, 30), Material=Enum.Material.Wood })
	makePart({ Name="BenchLegL", Size=Vector3.new(0.4, 1.5, 1.5), Position=p.pos+Vector3.new(-2, 0.75, 0), Color=Color3.fromRGB(40, 30, 20), Material=Enum.Material.Wood })
	makePart({ Name="BenchLegR", Size=Vector3.new(0.4, 1.5, 1.5), Position=p.pos+Vector3.new(2, 0.75, 0), Color=Color3.fromRGB(40, 30, 20), Material=Enum.Material.Wood })
end

function PropBuilders.hedge(p)
	local sz = p.size
	makePart({ Name="Hedge", Size=sz, Position=p.pos+Vector3.new(0, sz.Y / 2, 0), Color=Color3.fromRGB(80, 140, 60), Material=Enum.Material.LeafyGrass })
	makePart({ Name="HedgeTop", Size=Vector3.new(sz.X, 0.5, sz.Z), Position=p.pos+Vector3.new(0, sz.Y + 0.25, 0), Color=Color3.fromRGB(110, 160, 80), Material=Enum.Material.LeafyGrass })
end

function PropBuilders.hanging_carpet(p)
	PropBuilders.wire(p)
	local mid = (p.from + p.to) / 2
	local length = math.abs(p.to.X - p.from.X) - 4
	makePart({ Name="HangingCarpet", Size=Vector3.new(length, 6, 0.2), Position=mid - Vector3.new(0, 4, 0), Color=p.color or Color3.fromRGB(180, 60, 60), Material=Enum.Material.Fabric })
	for i = 1, 3 do
		makePart({ Name="CarpetStripe", Size=Vector3.new(length - 0.5, 0.3, 0.25), Position=mid - Vector3.new(0, 2 + i * 1.3, 0), Color=Color3.fromRGB(40, 20, 20), Material=Enum.Material.Fabric })
	end
end

function PropBuilders.hookah_cushion(p)
	local colors = { Color3.fromRGB(180, 60, 60), Color3.fromRGB(200, 160, 50), Color3.fromRGB(80, 140, 60), Color3.fromRGB(60, 100, 180) }
	for i = 1, 4 do
		local angle = math.rad((i - 1) * 90)
		makePart({ Name="Cushion", Size=Vector3.new(2, 0.6, 2), Position=p.pos+Vector3.new(math.cos(angle) * 1.5, 0.5, math.sin(angle) * 1.5), Color=colors[i], Material=Enum.Material.Fabric })
	end
	local base = Instance.new("Part")
	base.Name = "HookahBase"
	base.Shape = Enum.PartType.Cylinder
	base.Size = Vector3.new(1, 1.2, 1.6)
	base.CFrame = CFrame.new(p.pos + Vector3.new(0, 0.5, 0)) * CFrame.Angles(0, 0, math.rad(90))
	base.Anchored = true
	base.Color = Color3.fromRGB(100, 100, 100)
	base.Material = Enum.Material.Metal
	base.Parent = mapFolder
	makePart({ Name="HookahStem", Size=Vector3.new(0.3, 2.5, 0.3), Position=p.pos+Vector3.new(0, 2, 0), Color=Color3.fromRGB(192, 160, 80), Material=Enum.Material.Metal })
end

function PropBuilders.sand_pile(p)
	local s = Instance.new("Part")
	s.Name = "SandPile"
	s.Shape = Enum.PartType.Ball
	s.Size = Vector3.new(6, 3, 6)
	s.Position = p.pos + Vector3.new(0, 1.5, 0)
	s.Anchored = true
	s.Color = Color3.fromRGB(230, 200, 150)
	s.Material = Enum.Material.Sand
	s.Parent = mapFolder
end

function PropBuilders.camel_statue(p)
	makePart({ Name="CamelBody", Size=Vector3.new(4, 3, 1.8), Position=p.pos+Vector3.new(0, 3.5, 0), Color=Color3.fromRGB(180, 148, 110), Material=Enum.Material.Slate })
	local hump = Instance.new("Part")
	hump.Name = "CamelHump"
	hump.Shape = Enum.PartType.Ball
	hump.Size = Vector3.new(3, 3, 3)
	hump.Position = p.pos + Vector3.new(0, 5.3, 0)
	hump.Anchored = true
	hump.Color = Color3.fromRGB(180, 148, 110)
	hump.Material = Enum.Material.Slate
	hump.Parent = mapFolder
	makePart({ Name="CamelNeck", Size=Vector3.new(0.8, 3.5, 0.8), CFrame=CFrame.new(p.pos+Vector3.new(1.5, 5, 0)) * CFrame.Angles(0, 0, math.rad(-17)), Color=Color3.fromRGB(180, 148, 110), Material=Enum.Material.Slate })
	makePart({ Name="CamelHead", Size=Vector3.new(1.5, 1, 0.8), Position=p.pos+Vector3.new(2.5, 6.5, 0), Color=Color3.fromRGB(180, 148, 110), Material=Enum.Material.Slate })
	for _, leg in ipairs({{-1.3, -0.7}, {1.3, -0.7}, {-1.3, 0.7}, {1.3, 0.7}}) do
		makePart({ Name="CamelLeg", Size=Vector3.new(0.5, 2, 0.5), Position=p.pos+Vector3.new(leg[1], 1, leg[2]), Color=Color3.fromRGB(160, 130, 95), Material=Enum.Material.Slate })
	end
end

function PropBuilders.date_palm(p)
	makePart({ Name="DatePalmTrunk", Size=Vector3.new(1.2, 10, 1.2), Position=p.pos+Vector3.new(0, 5, 0), Color=Color3.fromRGB(100, 70, 40), Material=Enum.Material.Wood })
	for i = 0, 5 do
		local angle = math.rad(i * 60)
		local frond = Instance.new("Part")
		frond.Name = "DatePalmFrond"
		frond.Size = Vector3.new(5, 0.2, 1.5)
		frond.CFrame = CFrame.new(p.pos + Vector3.new(math.cos(angle) * 2, 10, math.sin(angle) * 2)) * CFrame.Angles(0, angle, math.rad(-17))
		frond.Anchored = true
		frond.Color = Color3.fromRGB(80, 130, 50)
		frond.Material = Enum.Material.LeafyGrass
		frond.Parent = mapFolder
	end
end

function PropBuilders.pottery_jar(p)
	local body = Instance.new("Part")
	body.Name = "PotteryJar"
	body.Shape = Enum.PartType.Ball
	body.Size = Vector3.new(2.4, 3.6, 2.4)
	body.Position = p.pos + Vector3.new(0, 1.5, 0)
	body.Anchored = true
	body.Color = Color3.fromRGB(165, 90, 50)
	body.Material = Enum.Material.Slate
	body.Parent = mapFolder
	makePart({ Name="PotteryNeck", Size=Vector3.new(0.8, 1, 0.8), Position=p.pos+Vector3.new(0, 3, 0), Color=Color3.fromRGB(165, 90, 50), Material=Enum.Material.Slate })
end

function PropBuilders.spice_basket(p)
	local basket = Instance.new("Part")
	basket.Name = "SpiceBasket"
	basket.Shape = Enum.PartType.Cylinder
	basket.Size = Vector3.new(1.5, 2, 2)
	basket.CFrame = CFrame.new(p.pos + Vector3.new(0, 0.75, 0)) * CFrame.Angles(0, 0, math.rad(90))
	basket.Anchored = true
	basket.Color = Color3.fromRGB(110, 70, 40)
	basket.Material = Enum.Material.Wood
	basket.Parent = mapFolder
	local mound = Instance.new("Part")
	mound.Name = "SpiceMound"
	mound.Shape = Enum.PartType.Ball
	mound.Size = Vector3.new(1.8, 0.8, 1.8)
	mound.Position = p.pos + Vector3.new(0, 1.8, 0)
	mound.Anchored = true
	mound.Color = p.color or Color3.fromRGB(220, 100, 30)
	mound.Material = Enum.Material.Sand
	mound.Parent = mapFolder
end

function PropBuilders.trash_bin(p)
	local bin = Instance.new("Part")
	bin.Name = "TrashBin"
	bin.Shape = Enum.PartType.Cylinder
	bin.Size = Vector3.new(2.5, 1.8, 1.8)
	bin.CFrame = CFrame.new(p.pos + Vector3.new(0, 1.25, 0)) * CFrame.Angles(0, 0, math.rad(90))
	bin.Anchored = true
	bin.Color = Color3.fromRGB(40, 40, 40)
	bin.Material = Enum.Material.Metal
	bin.Parent = mapFolder
end

function PropBuilders.phone_booth(p)
	makePart({ Name="PhoneBoothBody", Size=Vector3.new(2, 7, 2), Position=p.pos+Vector3.new(0, 3.5, 0), Color=Color3.fromRGB(50, 160, 80), Material=Enum.Material.Metal })
	makePart({ Name="PhoneBoothGlass", Size=Vector3.new(1.8, 5, 0.1), Position=p.pos+Vector3.new(0, 4, 1.05), Color=Color3.fromRGB(200, 225, 225), Material=Enum.Material.Glass, Transparency=0.6 })
	local sign = makePart({ Name="PhoneBoothSign", Size=Vector3.new(2.2, 0.8, 2.2), Position=p.pos+Vector3.new(0, 7.5, 0), Color=Color3.fromRGB(255, 80, 80), Material=Enum.Material.Neon })
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 80, 80)
	light.Range = 10
	light.Brightness = 1.5
	light.Parent = sign
end

function PropBuilders.traffic_cone(p)
	local cone = Instance.new("Part")
	cone.Name = "TrafficCone"
	cone.Shape = Enum.PartType.Cylinder
	cone.Size = Vector3.new(1.5, 1.6, 1.6)
	cone.CFrame = CFrame.new(p.pos + Vector3.new(0, 0.75, 0)) * CFrame.Angles(0, 0, math.rad(90))
	cone.Anchored = true
	cone.Color = Color3.fromRGB(255, 100, 40)
	cone.Material = Enum.Material.Neon
	cone.Transparency = 0.05
	cone.Parent = mapFolder
end

function PropBuilders.billboard(p)
	makePart({ Name="BillboardPoleL", Size=Vector3.new(0.5, 30, 0.5), Position=p.pos+Vector3.new(-8, -p.pos.Y + 15, 0), Color=Color3.fromRGB(50, 50, 60), Material=Enum.Material.Metal })
	makePart({ Name="BillboardPoleR", Size=Vector3.new(0.5, 30, 0.5), Position=p.pos+Vector3.new(8, -p.pos.Y + 15, 0), Color=Color3.fromRGB(50, 50, 60), Material=Enum.Material.Metal })
	local board = makePart({ Name="BillboardBoard", Size=Vector3.new(20, 8, 0.5), Position=p.pos, Color=p.color or Color3.fromRGB(255, 100, 200), Material=Enum.Material.Neon, Transparency=0.05 })
	local sg = Instance.new("SurfaceGui")
	sg.Face = Enum.NormalId.Front
	sg.CanvasSize = Vector2.new(800, 320)
	sg.Parent = board
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.fromScale(1, 1)
	lbl.BackgroundTransparency = 1
	lbl.Text = p.text or "AD"
	lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	lbl.Font = Enum.Font.GothamBlack
	lbl.TextScaled = true
	lbl.Parent = sg
	local light = Instance.new("PointLight")
	light.Color = p.color or Color3.fromRGB(255, 100, 200)
	light.Range = 30
	light.Brightness = 2.5
	light.Parent = board
end

function PropBuilders.motorbike(p)
	local wl = Instance.new("Part")
	wl.Shape = Enum.PartType.Cylinder
	wl.Size = Vector3.new(0.4, 2, 2)
	wl.CFrame = CFrame.new(p.pos + Vector3.new(-1.2, 1, 0))
	wl.Anchored = true
	wl.Color = Color3.fromRGB(30, 30, 30)
	wl.Material = Enum.Material.Plastic
	wl.Name = "BikeWheel"
	wl.Parent = mapFolder
	local wr = wl:Clone()
	wr.CFrame = CFrame.new(p.pos + Vector3.new(1.2, 1, 0))
	wr.Parent = mapFolder
	makePart({ Name="BikeBody", Size=Vector3.new(3, 0.8, 0.7), Position=p.pos+Vector3.new(0, 1.6, 0), Color=Color3.fromRGB(40, 40, 40), Material=Enum.Material.Metal })
	makePart({ Name="BikeSeat", Size=Vector3.new(1.5, 0.3, 0.8), Position=p.pos+Vector3.new(0.5, 2.1, 0), Color=Color3.fromRGB(20, 20, 20), Material=Enum.Material.SmoothPlastic })
end

function PropBuilders.sake_barrel(p)
	local barrel = Instance.new("Part")
	barrel.Name = "SakeBarrel"
	barrel.Shape = Enum.PartType.Cylinder
	barrel.Size = Vector3.new(1.8, 1.8, 1.8)
	barrel.CFrame = CFrame.new(p.pos + Vector3.new(0, 0.9, 0)) * CFrame.Angles(0, 0, math.rad(90))
	barrel.Anchored = true
	barrel.Color = Color3.fromRGB(230, 220, 200)
	barrel.Material = Enum.Material.Wood
	barrel.Parent = mapFolder
	makePart({ Name="SakeLabel", Size=Vector3.new(0.05, 0.8, 1.6), Position=p.pos+Vector3.new(0, 1.2, 0.9), Color=Color3.fromRGB(200, 50, 50), Material=Enum.Material.SmoothPlastic })
end

function PropBuilders.industrial_pipe(p)
	local length = (p.to - p.from).Magnitude
	local mid = (p.from + p.to) / 2
	local pipe = Instance.new("Part")
	pipe.Name = "IndustrialPipe"
	pipe.Shape = Enum.PartType.Cylinder
	pipe.Size = Vector3.new(length, 0.8, 0.8)
	pipe.CFrame = CFrame.new(mid, p.to) * CFrame.Angles(0, math.rad(90), 0)
	pipe.Anchored = true
	pipe.Color = Color3.fromRGB(100, 100, 100)
	pipe.Material = Enum.Material.Metal
	pipe.Parent = mapFolder
end

function PropBuilders.stone_steps(p)
	for i = 0, 3 do
		makePart({ Name="StoneStep", Size=Vector3.new(6 - i * 0.5, 0.4, 1.5), Position=p.pos+Vector3.new(0, 0.2 + i * 0.4, -i * 1.5), Color=Color3.fromRGB(180, 170, 150), Material=Enum.Material.Slate })
	end
end

function PropBuilders.zen_rock(p)
	local rock = Instance.new("Part")
	rock.Name = "ZenRock"
	rock.Shape = Enum.PartType.Ball
	rock.Size = Vector3.new(3, 2.1, 3.6)
	rock.Position = p.pos + Vector3.new(0, 1, 0)
	rock.Anchored = true
	rock.Color = Color3.fromRGB(100, 100, 90)
	rock.Material = Enum.Material.Slate
	rock.Parent = mapFolder
end

function PropBuilders.incense_holder(p)
	makePart({ Name="IncenseBase", Size=Vector3.new(1, 0.8, 1), Position=p.pos+Vector3.new(0, 0.4, 0), Color=Color3.fromRGB(180, 110, 30), Material=Enum.Material.Metal })
	for i = 0, 4 do
		makePart({ Name="IncenseStick", Size=Vector3.new(0.1, 2, 0.1), Position=p.pos+Vector3.new((i - 2) * 0.2, 1.8, 0), Color=Color3.fromRGB(140, 80, 40), Material=Enum.Material.Wood })
		local tip = makePart({ Name="IncenseTip", Shape=Enum.PartType.Ball, Size=Vector3.new(0.2, 0.2, 0.2), Position=p.pos+Vector3.new((i - 2) * 0.2, 2.8, 0), Color=Color3.fromRGB(255, 100, 50), Material=Enum.Material.Neon })
		-- Add subtle smoke effect
		local smoke = Instance.new("Smoke")
		smoke.Color = Color3.fromRGB(220, 220, 220)
		smoke.Size = 0.3
		smoke.RiseVelocity = 1.5
		smoke.Opacity = 0.2
		smoke.Parent = tip
	end
end

function PropBuilders.sandbag_wall(p)
	local length = p.length or 12
	local bagsPerRow = math.floor(length / 1.5)
	for r = 0, 2 do
		for b = 0, bagsPerRow - 1 do
			makePart({ Name="Sandbag", Size=Vector3.new(1.4, 0.7, 1.5), Position=p.pos+Vector3.new(-length/2 + b * 1.5 + (r % 2) * 0.75, 0.35 + r * 0.7, 0), Color=Color3.fromRGB(160, 140, 100), Material=Enum.Material.Fabric })
		end
	end
end

function PropBuilders.fuel_barrel(p)
	local barrel = Instance.new("Part")
	barrel.Name = "FuelBarrel"
	barrel.Shape = Enum.PartType.Cylinder
	barrel.Size = Vector3.new(2.5, 1.6, 1.6)
	barrel.CFrame = CFrame.new(p.pos + Vector3.new(0, 1.25, 0)) * CFrame.Angles(0, 0, math.rad(90))
	barrel.Anchored = true
	barrel.Color = Color3.fromRGB(200, 60, 30)
	barrel.Material = Enum.Material.CorrodedMetal
	barrel.Parent = mapFolder
end

function PropBuilders.floodlight(p)
	makePart({ Name="FloodPole", Size=Vector3.new(0.4, 20, 0.4), Position=p.pos+Vector3.new(0, 10, 0), Color=Color3.fromRGB(50, 50, 60), Material=Enum.Material.Metal })
	makePart({ Name="FloodHead", Size=Vector3.new(2, 1.5, 1.5), Position=p.pos+Vector3.new(0, 19, 0), Color=Color3.fromRGB(20, 20, 20), Material=Enum.Material.Metal })
	local bulb = makePart({ Name="FloodBulb", Size=Vector3.new(1.6, 1.1, 0.3), Position=p.pos+Vector3.new(0, 19, 0.85), Color=Color3.fromRGB(255, 255, 230), Material=Enum.Material.Neon })
	local sl = Instance.new("SpotLight")
	sl.Color = Color3.fromRGB(255, 255, 230)
	sl.Range = 50
	sl.Brightness = 4
	sl.Angle = 60
	sl.Face = Enum.NormalId.Front
	sl.Parent = bulb
end

function PropBuilders.satellite_dish(p)
	makePart({ Name="DishPole", Size=Vector3.new(0.5, 8, 0.5), Position=p.pos+Vector3.new(0, 4, 0), Color=Color3.fromRGB(74, 74, 80), Material=Enum.Material.Metal })
	local dish = Instance.new("Part")
	dish.Name = "SatelliteDish"
	dish.Shape = Enum.PartType.Ball
	dish.Size = Vector3.new(6, 1.8, 6)
	dish.CFrame = CFrame.new(p.pos + Vector3.new(0, 9, 0)) * CFrame.Angles(math.rad(-45), 0, 0)
	dish.Anchored = true
	dish.Color = Color3.fromRGB(200, 200, 200)
	dish.Material = Enum.Material.Metal
	dish.Parent = mapFolder
	makePart({ Name="DishReceiver", Size=Vector3.new(0.4, 0.4, 1.5), Position=p.pos+Vector3.new(0, 10.5, -1), Color=Color3.fromRGB(40, 40, 40), Material=Enum.Material.Metal })
end

function PropBuilders.wire_fence(p)
	local from, to = p.from, p.to
	local length = (to - from).Magnitude
	local posts = math.ceil(length / 5)
	for i = 0, posts do
		local t = i / posts
		local pos = from:Lerp(to, t)
		makePart({ Name="FencePost", Size=Vector3.new(0.3, 8, 0.3), Position=Vector3.new(pos.X, 4, pos.Z), Color=Color3.fromRGB(50, 50, 60), Material=Enum.Material.Metal })
	end
	-- Truss wire top
	local truss = Instance.new("TrussPart")
	truss.Name = "FenceTruss"
	truss.Size = Vector3.new(2, length, 2)
	truss.CFrame = CFrame.new((from + to) / 2 + Vector3.new(0, 4, 0), to + Vector3.new(0, 4, 0))
	truss.Anchored = true
	truss.Color = Color3.fromRGB(110, 110, 110)
	truss.Material = Enum.Material.Metal
	truss.Parent = mapFolder
end

function PropBuilders.solar_panel(p)
	makePart({ Name="SolarPost", Size=Vector3.new(0.3, 3, 0.3), Position=p.pos+Vector3.new(0, 1.5, 0), Color=Color3.fromRGB(50, 50, 60), Material=Enum.Material.Metal })
	makePart({ Name="SolarPanel", Size=Vector3.new(5, 0.2, 3.5), CFrame=CFrame.new(p.pos + Vector3.new(0, 3.5, 0)) * CFrame.Angles(math.rad(-23), 0, 0), Color=Color3.fromRGB(30, 40, 100), Material=Enum.Material.SmoothPlastic })
end

function PropBuilders.cobra_statue(p)
	for i = 0, 2 do
		local coil = Instance.new("Part")
		coil.Name = "CobraCoil"
		coil.Shape = Enum.PartType.Cylinder
		coil.Size = Vector3.new(0.6, (2.4 - i * 0.4), (2.4 - i * 0.4))
		coil.CFrame = CFrame.new(p.pos + Vector3.new(0, 0.3 + i * 0.6, 0)) * CFrame.Angles(0, 0, math.rad(90))
		coil.Anchored = true
		coil.Color = Color3.fromRGB(200, 180, 150)
		coil.Material = Enum.Material.Slate
		coil.Parent = mapFolder
	end
	makePart({ Name="CobraHood", Size=Vector3.new(1.5, 2, 0.5), Position=p.pos+Vector3.new(0, 3, 0), Color=Color3.fromRGB(200, 180, 150), Material=Enum.Material.Slate })
	makePart({ Name="CobraEyeL", Shape=Enum.PartType.Ball, Size=Vector3.new(0.3, 0.3, 0.3), Position=p.pos+Vector3.new(-0.3, 3.4, 0.3), Color=Color3.fromRGB(255, 50, 50), Material=Enum.Material.Neon })
	makePart({ Name="CobraEyeR", Shape=Enum.PartType.Ball, Size=Vector3.new(0.3, 0.3, 0.3), Position=p.pos+Vector3.new(0.3, 3.4, 0.3), Color=Color3.fromRGB(255, 50, 50), Material=Enum.Material.Neon })
end

function PropBuilders.stone_bench(p)
	makePart({ Name="StoneBenchSeat", Size=Vector3.new(4, 0.6, 1.4), Position=p.pos+Vector3.new(0, 1.5, 0), Color=Color3.fromRGB(200, 180, 150), Material=Enum.Material.Marble })
	makePart({ Name="StoneBenchLegL", Size=Vector3.new(0.6, 1.5, 1.4), Position=p.pos+Vector3.new(-1.7, 0.75, 0), Color=Color3.fromRGB(180, 160, 130), Material=Enum.Material.Marble })
	makePart({ Name="StoneBenchLegR", Size=Vector3.new(0.6, 1.5, 1.4), Position=p.pos+Vector3.new(1.7, 0.75, 0), Color=Color3.fromRGB(180, 160, 130), Material=Enum.Material.Marble })
end

function PropBuilders.mandala(p)
	for i = 0, 2 do
		local disc = Instance.new("Part")
		disc.Name = "Mandala"
		disc.Shape = Enum.PartType.Cylinder
		disc.Size = Vector3.new(0.15, (6 - i * 1.4), (6 - i * 1.4))
		disc.CFrame = CFrame.new(p.pos + Vector3.new(0, 0.05 + i * 0.05, 0)) * CFrame.Angles(0, 0, math.rad(90))
		disc.Anchored = true
		disc.Color = ({ Color3.fromRGB(180, 140, 90), Color3.fromRGB(200, 160, 100), Color3.fromRGB(220, 180, 120) })[i + 1]
		disc.Material = Enum.Material.Marble
		disc.Parent = mapFolder
	end
end

function PropBuilders.lotus_flower(p)
	for i = 0, 7 do
		local angle = math.rad(i * 45)
		makePart({ Name="LotusPetal", Size=Vector3.new(0.4, 0.2, 1.2), CFrame=CFrame.new(p.pos + Vector3.new(math.cos(angle) * 0.5, 0.5, math.sin(angle) * 0.5)) * CFrame.Angles(0, angle, math.rad(23)), Color=Color3.fromRGB(255, 180, 220), Material=Enum.Material.Neon })
	end
	makePart({ Name="LotusCenter", Shape=Enum.PartType.Ball, Size=Vector3.new(0.8, 0.8, 0.8), Position=p.pos+Vector3.new(0, 0.7, 0), Color=Color3.fromRGB(255, 224, 100), Material=Enum.Material.Neon })
end

-- ============================================================
-- BUILDING BUILDER (perimeter structures)
-- ============================================================
local function buildBuildingFromTheme(b)
	local body = makePart({ Name="BuildingBody", Size=b.size, Position=b.pos + Vector3.new(0, b.size.Y / 2, 0), Color=b.color, Material=Enum.Material.Brick })
	-- Roof (slightly larger)
	makePart({ Name="BuildingRoof", Size=Vector3.new(b.size.X + 3, 2, b.size.Z + 3), Position=b.pos + Vector3.new(0, b.size.Y + 1, 0), Color=b.roofColor or Color3.fromRGB(120, 70, 50), Material=Enum.Material.Slate })
	makePart({ Name="BuildingRoofCap", Size=Vector3.new(b.size.X - 2, 2, b.size.Z - 2), Position=b.pos + Vector3.new(0, b.size.Y + 3, 0), Color=b.roofColor or Color3.fromRGB(120, 70, 50), Material=Enum.Material.Slate })
	-- Windows (grid pattern, 2-3 storeys)
	local nWin = b.windows or 4
	local winRows = math.max(2, math.floor(b.size.Y / 8))
	local winCols = math.min(nWin, math.floor(b.size.X / 5))
	local winColor = b.lit and (b.neonColor or Color3.fromRGB(255, 224, 100)) or Color3.fromRGB(40, 40, 56)
	local winMat = b.lit and Enum.Material.Neon or Enum.Material.Glass
	for r = 0, winRows - 1 do
		for c = 0, winCols - 1 do
			local sx = (c + 0.5) / winCols
			local sy = (r + 0.5) / winRows
			-- Skip some windows for lit (looks more random)
			if b.lit and math.random() < 0.25 then continue end
			-- Front
			makePart({ Name="Window", Size=Vector3.new(2, 2, 0.3), Position=b.pos + Vector3.new(-b.size.X/2 + sx * b.size.X, sy * b.size.Y, b.size.Z/2 + 0.1), Color=winColor, Material=winMat, Transparency=b.lit and 0 or 0.4 })
			-- Back
			makePart({ Name="Window", Size=Vector3.new(2, 2, 0.3), Position=b.pos + Vector3.new(-b.size.X/2 + sx * b.size.X, sy * b.size.Y, -b.size.Z/2 - 0.1), Color=winColor, Material=winMat, Transparency=b.lit and 0 or 0.4 })
		end
	end
	-- Side windows
	local sideCols = math.floor(b.size.Z / 6)
	for r = 0, winRows - 1 do
		for c = 0, sideCols - 1 do
			local sx = (c + 0.5) / sideCols
			local sy = (r + 0.5) / winRows
			if b.lit and math.random() < 0.3 then continue end
			makePart({ Name="WindowL", Size=Vector3.new(0.3, 2, 2), Position=b.pos + Vector3.new(-b.size.X/2 - 0.1, sy * b.size.Y, -b.size.Z/2 + sx * b.size.Z), Color=winColor, Material=winMat, Transparency=b.lit and 0 or 0.4 })
			makePart({ Name="WindowR", Size=Vector3.new(0.3, 2, 2), Position=b.pos + Vector3.new(b.size.X/2 + 0.1, sy * b.size.Y, -b.size.Z/2 + sx * b.size.Z), Color=winColor, Material=winMat, Transparency=b.lit and 0 or 0.4 })
		end
	end
	-- Door + frame
	makePart({ Name="BuildingDoor", Size=Vector3.new(3, 5, 0.4), Position=b.pos + Vector3.new(0, 2.5, b.size.Z/2 + 0.2), Color=Color3.fromRGB(60, 40, 24), Material=Enum.Material.Wood })
	makePart({ Name="BuildingDoorFrame", Size=Vector3.new(4, 6, 0.6), Position=b.pos + Vector3.new(0, 3, b.size.Z/2 + 0.05), Color=b.accentColor or Color3.fromRGB(140, 100, 50), Material=Enum.Material.Wood })
	-- Balcony (Ascent villas)
	if b.hasBalcony then
		makePart({ Name="Balcony", Size=Vector3.new(b.size.X + 4, 0.6, 4), Position=b.pos + Vector3.new(0, b.size.Y * 0.5, b.size.Z/2 + 2), Color=Color3.fromRGB(128, 106, 80), Material=Enum.Material.Wood })
		-- Rails
		for bx = 0, 4 do
			makePart({ Name="BalconyRail", Size=Vector3.new(0.2, 2, 0.2), Position=b.pos + Vector3.new(-b.size.X/2 + (bx / 4) * b.size.X, b.size.Y * 0.5 + 1, b.size.Z/2 + 3.8), Color=Color3.fromRGB(80, 64, 48), Material=Enum.Material.Wood })
		end
		makePart({ Name="BalconyRailTop", Size=Vector3.new(b.size.X + 4, 0.2, 0.2), Position=b.pos + Vector3.new(0, b.size.Y * 0.5 + 2, b.size.Z/2 + 3.8), Color=Color3.fromRGB(80, 64, 48), Material=Enum.Material.Wood })
	end
	-- Monastery/temple golden trim
	if b.isMonastery or b.isTemple then
		makePart({ Name="GoldTrim", Size=Vector3.new(b.size.X + 4, 0.4, b.size.Z + 4), Position=b.pos + Vector3.new(0, b.size.Y - 0.5, 0), Color=b.accentColor or Color3.fromRGB(255, 200, 80), Material=Enum.Material.Metal })
	end
	-- Industrial vents
	if b.isIndustrial then
		for v = 0, 2 do
			makePart({ Name="RoofVent", Size=Vector3.new(2, 1.5, 2), Position=b.pos + Vector3.new(-b.size.X/3 + v * (b.size.X/3), b.size.Y + 2, 0), Color=Color3.fromRGB(80, 70, 64), Material=Enum.Material.Metal })
		end
	end
	-- Light glow (if lit)
	if b.lit then
		local pl = Instance.new("PointLight")
		pl.Color = b.neonColor or Color3.fromRGB(255, 224, 100)
		pl.Range = 30
		pl.Brightness = 0.6
		pl.Parent = body
	end
end

-- ============================================================
-- FLOOR PATCH BUILDER
-- ============================================================
local function buildFloorPatch(fp)
	local mat = Enum.Material[fp.material or "Concrete"] or Enum.Material.Concrete
	makePart({
		Name = "FloorPatch",
		Size = Vector3.new(fp.size.X, 0.3, fp.size.Z),
		Position = fp.pos + Vector3.new(0, 0.16, 0),
		Color = fp.color,
		Material = mat,
		CanCollide = false,
	})
end

-- ============================================================
-- ATMOSPHERE PARTICLES
-- ============================================================
local function buildAtmosphereParticles(theme, mapInfo)
	if not theme.Particles then return end
	-- Create invisible emitter parts at corners
	local cfg = theme.Particles
	local positions = {
		Vector3.new(-mapInfo.Dimensions.X / 4, 30, -mapInfo.Dimensions.Z / 4),
		Vector3.new(mapInfo.Dimensions.X / 4, 30, mapInfo.Dimensions.Z / 4),
		Vector3.new(0, 30, 0),
	}
	for _, pos in ipairs(positions) do
		local emitter = makePart({
			Name = "AtmoEmitter",
			Size = Vector3.new(1, 1, 1),
			Position = pos,
			Transparency = 1,
			CanCollide = false,
		})
		local pe = Instance.new("ParticleEmitter")
		pe.Texture = "rbxasset://textures/particles/smoke_main.dds"
		pe.Color = ColorSequence.new(cfg.color)
		pe.Lifetime = NumberRange.new(4, 8)
		pe.Rate = cfg.rate or 4
		pe.Speed = NumberRange.new(0.5, 2)
		pe.Acceleration = Vector3.new(0, -0.3, 0)
		pe.Size = NumberSequence.new(0.5, 3)
		pe.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.3, 0.7),
			NumberSequenceKeypoint.new(1, 1),
		})
		pe.SpreadAngle = Vector2.new(180, 180)
		pe.Parent = emitter
	end
end

-- ============================================================
-- THEME-AWARE LAMP POSTS (replaces old generic lamps)
-- ============================================================
local function buildLamps(mapInfo, theme)
	local lampColor = theme.LampColor or Color3.fromRGB(255, 220, 150)
	local lampPositions = {
		Vector3.new(0, 8, -80), Vector3.new(0, 8, 80),
		Vector3.new(-60, 8, -40), Vector3.new(60, 8, -40),
		Vector3.new(-60, 8, 40), Vector3.new(60, 8, 40),
	}
	for _, pos in ipairs(lampPositions) do
		local post = Instance.new("Part")
		post.Name = "LampPost"
		post.Size = Vector3.new(0.4, 8, 0.4)
		post.Position = pos - Vector3.new(0, 4, 0)
		post.Anchored = true
		post.Color = Color3.fromRGB(40, 40, 50)
		post.Material = Enum.Material.Metal
		post.Parent = mapFolder

		local lamp = Instance.new("Part")
		lamp.Name = "Lamp"
		lamp.Shape = Enum.PartType.Ball
		lamp.Size = Vector3.new(1, 1, 1)
		lamp.Position = pos
		lamp.Anchored = true
		lamp.CanCollide = false
		lamp.Color = lampColor
		lamp.Material = Enum.Material.Neon
		lamp.Parent = mapFolder

		local light = Instance.new("PointLight")
		light.Color = lampColor
		light.Range = 18
		light.Brightness = 1.5
		light.Parent = lamp
	end
end

-- ============================================================
-- BANNERS (themed team markers near spawns)
-- ============================================================
local function makeBanner(pos, color, text)
	local banner = Instance.new("Part")
	banner.Name = "Banner"
	banner.Size = Vector3.new(0.2, 6, 4)
	banner.Position = pos
	banner.Anchored = true
	banner.Color = color
	banner.Material = Enum.Material.Fabric
	banner.Parent = mapFolder

	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Face = Enum.NormalId.Right
	surfaceGui.CanvasSize = Vector2.new(400, 600)
	surfaceGui.Parent = banner
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.fromScale(1, 1)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	lbl.Font = Enum.Font.GothamBlack
	lbl.TextSize = 80
	lbl.TextRotation = -90
	lbl.Parent = surfaceGui
end

-- ============================================================
-- MAIN BUILD
-- ============================================================
function MapBuilder.Build(mapName)
	mapName = mapName or "Ascent"
	local mapInfo = MapData.GetByName(mapName)
	if not mapInfo then
		warn("[MapBuilder] Unknown map: " .. mapName)
		return nil
	end

	local theme = MapTheme.GetTheme(mapName)

	clearMap()
	buildLights(mapInfo)
	mapFolder:SetAttribute("MapName", mapName)

	local result = {
		mapName = mapName,
		plantAreas = {},
		spawnAttackers = mapInfo.SpawnAttackers,
		spawnDefenders = mapInfo.SpawnDefenders,
	}

	-- Floor with theme material
	local floorSize = Vector3.new(mapInfo.Dimensions.X, 1, mapInfo.Dimensions.Z)
	makePart({
		Name = "Floor",
		Size = floorSize,
		Position = Vector3.new(0, 0, 0),
		Color = mapInfo.ColorPalette.Primary,
		Material = MapTheme.GetMaterial(mapName, "Floor"),
	})

	-- Boundary walls with theme material
	local halfX = mapInfo.Dimensions.X / 2
	local halfZ = mapInfo.Dimensions.Z / 2
	local wallMat = MapTheme.GetMaterial(mapName, "Wall")
	makePart({ Name="WallN", Size=Vector3.new(mapInfo.Dimensions.X, 20, 2), Position=Vector3.new(0, 10, halfZ), Color=mapInfo.ColorPalette.Secondary, Material=wallMat })
	makePart({ Name="WallS", Size=Vector3.new(mapInfo.Dimensions.X, 20, 2), Position=Vector3.new(0, 10, -halfZ), Color=mapInfo.ColorPalette.Secondary, Material=wallMat })
	makePart({ Name="WallE", Size=Vector3.new(2, 20, mapInfo.Dimensions.Z), Position=Vector3.new(halfX, 10, 0), Color=mapInfo.ColorPalette.Secondary, Material=wallMat })
	makePart({ Name="WallW", Size=Vector3.new(2, 20, mapInfo.Dimensions.Z), Position=Vector3.new(-halfX, 10, 0), Color=mapInfo.ColorPalette.Secondary, Material=wallMat })

	-- Cover blocks with theme material
	local coverMat = MapTheme.GetMaterial(mapName, "Cover")
	for _, c in ipairs(mapInfo.CoverBlocks or {}) do
		local part = makePart({
			Name = c.name or "Cover",
			Size = c.size,
			Position = c.pos,
			Color = mapInfo.ColorPalette.Secondary,
			Material = coverMat,
		})
		if math.min(c.size.X, c.size.Z) <= 4 then
			part:SetAttribute("Penetrable", true)
		end
	end

	-- Platforms with theme material
	local platMat = MapTheme.GetMaterial(mapName, "Platform")
	for _, plat in ipairs(mapInfo.Platforms or {}) do
		makePart({
			Name = plat.name or "Platform",
			Size = plat.size,
			Position = plat.pos,
			Color = mapInfo.ColorPalette.Primary,
			Material = platMat,
		})
		-- Ramp up
		local rampLen = 10
		local rampPos = plat.pos - Vector3.new(plat.size.X / 2 + rampLen / 2, plat.size.Y / 2 + plat.pos.Y / 2, 0)
		makePart({
			Name = (plat.name or "Platform") .. "Ramp",
			Size = Vector3.new(rampLen, 0.5, math.min(plat.size.Z, 8)),
			CFrame = CFrame.new(rampPos) * CFrame.Angles(0, 0, math.rad(20)),
			Color = mapInfo.ColorPalette.Primary,
			Material = platMat,
		})
	end

	-- Ropes (Split)
	if mapInfo.Ropes then
		for _, rope in ipairs(mapInfo.Ropes) do
			local fromPos = rope.from
			local toPos = rope.to
			local length = (toPos - fromPos).Magnitude
			local truss = Instance.new("TrussPart")
			truss.Name = "Rope_" .. (rope.Name or "Ascender")
			truss.Size = Vector3.new(2, length, 2)
			truss.CFrame = CFrame.new((fromPos + toPos) / 2)
			truss.Anchored = true
			truss.Color = Color3.fromRGB(180, 150, 100)
			truss.Material = Enum.Material.Wood
			truss.Style = Enum.Style.AlternatingSupports
			truss.Parent = mapFolder
		end
	end

	-- Teleporters (Bind)
	if mapInfo.Teleporters then
		for _, tp in ipairs(mapInfo.Teleporters) do
			local pad = makePart({
				Name = "Teleporter_" .. tp.Name,
				Size = Vector3.new(6, 1, 6),
				Position = tp.From,
				Color = Color3.fromRGB(180, 100, 255),
				Material = Enum.Material.Neon,
				Transparency = 0.4,
			})
			pad:SetAttribute("TeleportTo", tp.To)
			pad:SetAttribute("OneWay", tp.OneWay or true)
			pad.Touched:Connect(function(hit)
				local model = hit:FindFirstAncestorWhichIsA("Model")
				if not model then return end
				local hum = model:FindFirstChildOfClass("Humanoid")
				if not hum then return end
				local hrp = model:FindFirstChild("HumanoidRootPart")
				if not hrp then return end
				if hrp:GetAttribute("TeleportCooldown") then return end
				hrp:SetAttribute("TeleportCooldown", true)
				hrp.CFrame = CFrame.new(tp.To)
				if tp.AudioCue then
					local sound = Instance.new("Sound")
					sound.SoundId = "rbxasset://sounds/electronicpingshort.wav"
					sound.Volume = 1
					sound.Parent = pad
					sound:Play()
				end
				task.delay(2, function()
					hrp:SetAttribute("TeleportCooldown", nil)
				end)
			end)
		end
	end

	-- Spawn pads
	buildSpawnPad("AttackerSpawn", mapInfo.SpawnAttackers, Color3.fromRGB(255, 80, 80))
	buildSpawnPad("DefenderSpawn", mapInfo.SpawnDefenders, Color3.fromRGB(80, 120, 255))

	-- Bombsites + plant areas
	for siteName, site in pairs(mapInfo.Sites or {}) do
		local plantPart = buildPlantArea(siteName, site.PlantArea, site.Radius * 2)
		table.insert(result.plantAreas, plantPart)

		local sign = Instance.new("Part")
		sign.Name = "Site_" .. siteName
		sign.Size = Vector3.new(3, 3, 0.2)
		sign.Position = site.PlantArea + Vector3.new(0, 8, 0)
		sign.Anchored = true
		sign.CanCollide = false
		sign.Material = Enum.Material.Neon
		sign.Color = Color3.fromRGB(255, 100, 80)
		sign.Transparency = 0.2
		sign.Parent = mapFolder

		local bg = Instance.new("BillboardGui")
		bg.Size = UDim2.fromOffset(120, 80)
		bg.AlwaysOnTop = true
		bg.Parent = sign
		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.Text = "Site " .. siteName
		label.TextColor3 = Color3.fromRGB(255, 200, 100)
		label.Font = Enum.Font.GothamBlack
		label.TextSize = 40
		label.TextStrokeTransparency = 0
		label.Parent = bg
	end

	-- Ult orbs
	for _, orbPos in ipairs(mapInfo.UltOrbs or {}) do
		buildUltOrb(orbPos)
	end

	-- FLOOR PATCHES (theme color variation)
	if theme.FloorPatches then
		for _, fp in ipairs(theme.FloorPatches) do
			buildFloorPatch(fp)
		end
	end

	-- BUILDINGS (perimeter structures forming streets/courtyards)
	if theme.Buildings then
		for _, b in ipairs(theme.Buildings) do
			buildBuildingFromTheme(b)
		end
	end

	-- THEME-SPECIFIC PROPS
	if theme.Props then
		for _, prop in ipairs(theme.Props) do
			local builder = PropBuilders[prop.type]
			if builder then
				local ok, err = pcall(builder, prop)
				if not ok then
					warn("[MapBuilder] Prop " .. prop.type .. " failed: " .. tostring(err))
				end
			end
		end
	end

	-- Theme lamps + banners + particles
	buildLamps(mapInfo, theme)
	if mapInfo.SpawnAttackers then
		makeBanner(mapInfo.SpawnAttackers + Vector3.new(8, 4, 0), Color3.fromRGB(180, 30, 30), "ATTACKERS")
	end
	if mapInfo.SpawnDefenders then
		makeBanner(mapInfo.SpawnDefenders + Vector3.new(-8, 4, 0), Color3.fromRGB(30, 60, 180), "DEFENDERS")
	end
	buildAtmosphereParticles(theme, mapInfo)

	return result
end

function MapBuilder.GetMapInfo()
	return MapData.Ascent
end

return MapBuilder
