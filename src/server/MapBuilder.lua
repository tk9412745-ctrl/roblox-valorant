local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MapData = require(ReplicatedStorage.Shared.MapData)

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

	-- Floating animation (simple)
	local startY = pos.Y
	task.spawn(function()
		local startTime = tick()
		while orb.Parent do
			local elapsed = tick() - startTime
			orb.Position = Vector3.new(pos.X, startY + math.sin(elapsed * 2) * 0.5, pos.Z)
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

	-- Per-map skybox config (custom per map theme)
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

	-- ============================================================
	-- POST-PROCESSING EFFECTS
	-- ============================================================
	-- Bloom — soft glow on bright parts (neon spike, ult orbs)
	local bloom = Instance.new("BloomEffect")
	bloom.Intensity = 0.4
	bloom.Size = 24
	bloom.Threshold = 1.0
	bloom.Parent = Lighting

	-- Color correction — slight saturation + warmth
	local colorCorr = Instance.new("ColorCorrectionEffect")
	colorCorr.Brightness = 0.0
	colorCorr.Contrast = 0.1
	colorCorr.Saturation = 0.15
	if mapInfo.DisplayName == "Bind" then
		colorCorr.TintColor = Color3.fromRGB(255, 240, 220)  -- warm desert
		colorCorr.Saturation = 0.2
	elseif mapInfo.DisplayName == "Split" then
		colorCorr.TintColor = Color3.fromRGB(220, 220, 255)  -- cool cyberpunk
		colorCorr.Saturation = 0.25
	else  -- Ascent default
		colorCorr.TintColor = Color3.fromRGB(255, 250, 240)
	end
	colorCorr.Parent = Lighting

	-- Sun rays
	local sunRays = Instance.new("SunRaysEffect")
	sunRays.Intensity = 0.15
	sunRays.Spread = 0.8
	sunRays.Parent = Lighting

	-- Depth of field (subtle distance blur)
	local dof = Instance.new("DepthOfFieldEffect")
	dof.FarIntensity = 0.05
	dof.FocusDistance = 50
	dof.InFocusRadius = 30
	dof.NearIntensity = 0
	dof.Parent = Lighting

	-- ============================================================
	-- ATMOSPHERE (volumetric haze) — per-map config
	-- ============================================================
	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Density = sky.AtmosphereDensity or 0.3
	atmosphere.Offset = 0.2
	atmosphere.Color = sky.AtmosphereColor or mapInfo.ColorPalette.Primary
	atmosphere.Decay = Color3.fromRGB(106, 106, 106)
	atmosphere.Glare = 0.3
	atmosphere.Haze = sky.HazeBoost and 2.5 or 1.2
	atmosphere.Parent = Lighting

	-- ============================================================
	-- SKYBOX (per-map config)
	-- ============================================================
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

function MapBuilder.Build(mapName)
	mapName = mapName or "Ascent"
	local mapInfo = MapData.GetByName(mapName)
	if not mapInfo then
		warn("[MapBuilder] Unknown map: " .. mapName)
		return nil
	end

	clearMap()
	buildLights(mapInfo)

	-- Set MapName attribute so clients can detect current map
	mapFolder:SetAttribute("MapName", mapName)

	local result = {
		mapName = mapName,
		plantAreas = {},
		spawnAttackers = mapInfo.SpawnAttackers,
		spawnDefenders = mapInfo.SpawnDefenders,
	}

	-- Floor (full map dimensions)
	local floorSize = Vector3.new(mapInfo.Dimensions.X, 1, mapInfo.Dimensions.Z)
	makePart({
		Name = "Floor",
		Size = floorSize,
		Position = Vector3.new(0, 0, 0),
		Color = mapInfo.ColorPalette.Primary,
		Material = Enum.Material.Concrete,
	})

	-- Boundary walls (prevent falling off)
	local halfX = mapInfo.Dimensions.X / 2
	local halfZ = mapInfo.Dimensions.Z / 2
	makePart({
		Name = "WallN", Size = Vector3.new(mapInfo.Dimensions.X, 20, 2),
		Position = Vector3.new(0, 10, halfZ),
		Color = mapInfo.ColorPalette.Secondary, Material = Enum.Material.Brick,
	})
	makePart({
		Name = "WallS", Size = Vector3.new(mapInfo.Dimensions.X, 20, 2),
		Position = Vector3.new(0, 10, -halfZ),
		Color = mapInfo.ColorPalette.Secondary, Material = Enum.Material.Brick,
	})
	makePart({
		Name = "WallE", Size = Vector3.new(2, 20, mapInfo.Dimensions.Z),
		Position = Vector3.new(halfX, 10, 0),
		Color = mapInfo.ColorPalette.Secondary, Material = Enum.Material.Brick,
	})
	makePart({
		Name = "WallW", Size = Vector3.new(2, 20, mapInfo.Dimensions.Z),
		Position = Vector3.new(-halfX, 10, 0),
		Color = mapInfo.ColorPalette.Secondary, Material = Enum.Material.Brick,
	})

	-- Cover blocks
	for _, c in ipairs(mapInfo.CoverBlocks or {}) do
		local part = makePart({
			Name = c.name or "Cover",
			Size = c.size,
			Position = c.pos,
			Color = mapInfo.ColorPalette.Secondary,
			Material = Enum.Material.WoodPlanks,
		})
		-- Mark thin parts as penetrable for wallbang
		if math.min(c.size.X, c.size.Z) <= 4 then
			part:SetAttribute("Penetrable", true)
		end
	end

	-- Elevated platforms (Heavens, Towers)
	for _, plat in ipairs(mapInfo.Platforms or {}) do
		makePart({
			Name = plat.name or "Platform",
			Size = plat.size,
			Position = plat.pos,
			Color = mapInfo.ColorPalette.Primary,
			Material = Enum.Material.Brick,
		})
		-- Add ramps up to platforms (simplified)
		local rampLen = 10
		local rampPos = plat.pos - Vector3.new(plat.size.X / 2 + rampLen / 2, plat.size.Y / 2 + plat.pos.Y / 2, 0)
		makePart({
			Name = (plat.name or "Platform") .. "Ramp",
			Size = Vector3.new(rampLen, 0.5, math.min(plat.size.Z, 8)),
			CFrame = CFrame.new(rampPos) * CFrame.Angles(0, 0, math.rad(20)),
			Color = mapInfo.ColorPalette.Primary,
			Material = Enum.Material.Brick,
		})
	end

	-- Ropes / ascenders (for Split) — Truss Parts (Roblox built-in ladders)
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

	-- Teleporters (for Bind)
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

			-- Visual: ring around pad
			pad.Touched:Connect(function(hit)
				local model = hit:FindFirstAncestorWhichIsA("Model")
				if not model then return end
				local hum = model:FindFirstChildOfClass("Humanoid")
				if not hum then return end
				local hrp = model:FindFirstChild("HumanoidRootPart")
				if not hrp then return end
				-- Prevent infinite loop: cooldown per character
				if hrp:GetAttribute("TeleportCooldown") then return end
				hrp:SetAttribute("TeleportCooldown", true)
				hrp.CFrame = CFrame.new(tp.To)
				if tp.AudioCue then
					-- Audio cue: spawn sound at both ends
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

		-- Visual site marker (large translucent label)
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

	-- Ambient props (lamp posts, barrels, signs, banners)
	buildAmbientProps(mapInfo)

	return result
end

function buildAmbientProps(mapInfo)
	-- Lamp posts along walkways
	local lampPositions = {
		Vector3.new(0, 8, -80), Vector3.new(0, 8, 80),
		Vector3.new(-60, 8, -40), Vector3.new(60, 8, -40),
		Vector3.new(-60, 8, 40), Vector3.new(60, 8, 40),
	}
	for _, pos in ipairs(lampPositions) do
		-- Post
		local post = Instance.new("Part")
		post.Name = "LampPost"
		post.Size = Vector3.new(0.4, 8, 0.4)
		post.Position = pos - Vector3.new(0, 4, 0)
		post.Anchored = true
		post.Color = Color3.fromRGB(40, 40, 50)
		post.Material = Enum.Material.Metal
		post.Parent = mapFolder

		-- Lamp head (glowing)
		local lamp = Instance.new("Part")
		lamp.Name = "Lamp"
		lamp.Shape = Enum.PartType.Ball
		lamp.Size = Vector3.new(1, 1, 1)
		lamp.Position = pos
		lamp.Anchored = true
		lamp.CanCollide = false
		lamp.Color = Color3.fromRGB(255, 220, 150)
		lamp.Material = Enum.Material.Neon
		lamp.Parent = mapFolder

		local light = Instance.new("PointLight")
		light.Color = Color3.fromRGB(255, 220, 180)
		light.Range = 18
		light.Brightness = 1.5
		light.Parent = lamp
	end

	-- Barrels scattered around (random positions within map bounds)
	math.randomseed(mapInfo.DisplayName:byte(1) or 1)
	for i = 1, 8 do
		local x = math.random(-mapInfo.Dimensions.X / 2 + 20, mapInfo.Dimensions.X / 2 - 20)
		local z = math.random(-mapInfo.Dimensions.Z / 2 + 20, mapInfo.Dimensions.Z / 2 - 20)
		local barrel = Instance.new("Part")
		barrel.Name = "Barrel"
		barrel.Shape = Enum.PartType.Cylinder
		barrel.Size = Vector3.new(3, 2, 2)
		barrel.CFrame = CFrame.new(x, 1.5, z) * CFrame.Angles(0, 0, math.rad(90))
		barrel.Anchored = true
		barrel.Color = Color3.fromRGB(140, 80, 40)
		barrel.Material = Enum.Material.Metal
		barrel.Parent = mapFolder
	end

	-- Team banners near spawns
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
	if mapInfo.SpawnAttackers then
		makeBanner(mapInfo.SpawnAttackers + Vector3.new(8, 4, 0), Color3.fromRGB(180, 30, 30), "ATTACKERS")
	end
	if mapInfo.SpawnDefenders then
		makeBanner(mapInfo.SpawnDefenders + Vector3.new(-8, 4, 0), Color3.fromRGB(30, 60, 180), "DEFENDERS")
	end
end

function MapBuilder.GetMapInfo()
	return MapData.Ascent  -- default
end

return MapBuilder
