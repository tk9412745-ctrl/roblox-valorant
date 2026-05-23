-- CompendiumController: F1 key opens browseable database (agents/maps/weapons)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local AgentDatabase = require(ReplicatedStorage.Shared:WaitForChild("AgentDatabase"))
local MapData = require(ReplicatedStorage.Shared:WaitForChild("MapData"))
local WeaponDatabase = require(ReplicatedStorage.Shared:WaitForChild("WeaponDatabase"))

local CompendiumController = {}

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local gui
local menuOpen = false
local currentTab = "Agents"
local contentArea
local IMPLEMENTED_AGENTS = { Jett = true, Sage = true, Phoenix = true, Cypher = true, Reyna = true, KAYO = true, Sova = true, Brimstone = true, Viper = true, Astra = true, Omen = true, Killjoy = true }

local function buildGui()
	gui = Instance.new("ScreenGui")
	gui.Name = "Compendium"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Enabled = false
	gui.Parent = PlayerGui

	local backdrop = Instance.new("Frame")
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
	backdrop.BackgroundTransparency = 0.05
	backdrop.BorderSizePixel = 0
	backdrop.Parent = gui

	local title = Instance.new("TextLabel")
	title.AnchorPoint = Vector2.new(0.5, 0)
	title.Position = UDim2.new(0.5, 0, 0, 40)
	title.Size = UDim2.fromOffset(600, 50)
	title.BackgroundTransparency = 1
	title.Text = "📖 COMPENDIUM"
	title.TextColor3 = Color3.fromRGB(220, 220, 240)
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 28
	title.Parent = backdrop

	local closeBtn = Instance.new("TextButton")
	closeBtn.AnchorPoint = Vector2.new(1, 0)
	closeBtn.Position = UDim2.new(1, -30, 0, 40)
	closeBtn.Size = UDim2.fromOffset(120, 40)
	closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	closeBtn.Text = "CLOSE (F1)"
	closeBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 13
	closeBtn.Parent = backdrop
	local cbCorner = Instance.new("UICorner")
	cbCorner.CornerRadius = UDim.new(0, 6)
	cbCorner.Parent = closeBtn
	closeBtn.Activated:Connect(function()
		menuOpen = false
		gui.Enabled = false
	end)

	-- Tab buttons
	local tabContainer = Instance.new("Frame")
	tabContainer.AnchorPoint = Vector2.new(0.5, 0)
	tabContainer.Position = UDim2.new(0.5, 0, 0, 110)
	tabContainer.Size = UDim2.fromOffset(600, 50)
	tabContainer.BackgroundTransparency = 1
	tabContainer.Parent = backdrop

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	tabLayout.Padding = UDim.new(0, 12)
	tabLayout.Parent = tabContainer

	for _, tabName in ipairs({ "Agents", "Maps", "Weapons" }) do
		local btn = Instance.new("TextButton")
		btn.Name = "Tab_" .. tabName
		btn.Size = UDim2.fromOffset(160, 44)
		btn.BackgroundColor3 = currentTab == tabName and Color3.fromRGB(255, 100, 80) or Color3.fromRGB(40, 40, 55)
		btn.BorderSizePixel = 0
		btn.Text = tabName:upper()
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.Font = Enum.Font.GothamBlack
		btn.TextSize = 14
		btn.AutoButtonColor = false
		btn.Parent = tabContainer
		local bCorner = Instance.new("UICorner")
		bCorner.CornerRadius = UDim.new(0, 6)
		bCorner.Parent = btn
		btn.Activated:Connect(function()
			currentTab = tabName
			-- Re-color tabs
			for _, c in ipairs(tabContainer:GetChildren()) do
				if c:IsA("TextButton") then
					c.BackgroundColor3 = c.Name == "Tab_" .. currentTab
						and Color3.fromRGB(255, 100, 80) or Color3.fromRGB(40, 40, 55)
				end
			end
			CompendiumController.RefreshContent()
		end)
	end

	-- Content area
	contentArea = Instance.new("ScrollingFrame")
	contentArea.Name = "Content"
	contentArea.AnchorPoint = Vector2.new(0.5, 0)
	contentArea.Position = UDim2.new(0.5, 0, 0, 180)
	contentArea.Size = UDim2.fromOffset(1100, 540)
	contentArea.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
	contentArea.BackgroundTransparency = 0.3
	contentArea.BorderSizePixel = 0
	contentArea.CanvasSize = UDim2.fromScale(0, 0)
	contentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
	contentArea.ScrollBarThickness = 6
	contentArea.Parent = backdrop
	local caCorner = Instance.new("UICorner")
	caCorner.CornerRadius = UDim.new(0, 8)
	caCorner.Parent = contentArea
end

local function buildAgentCard(agent, name, parent)
	local card = Instance.new("Frame")
	card.Size = UDim2.fromOffset(340, 180)
	card.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
	card.BorderSizePixel = 0
	card.Parent = parent
	local cCorner = Instance.new("UICorner")
	cCorner.CornerRadius = UDim.new(0, 8)
	cCorner.Parent = card

	local accent = Color3.fromRGB(180, 180, 200)
	if agent.Role == "Duelist" then accent = Color3.fromRGB(255, 120, 60)
	elseif agent.Role == "Initiator" then accent = Color3.fromRGB(60, 180, 255)
	elseif agent.Role == "Sentinel" then accent = Color3.fromRGB(255, 100, 200)
	elseif agent.Role == "Controller" then accent = Color3.fromRGB(150, 80, 220) end

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2
	stroke.Color = accent
	stroke.Transparency = 0.5
	stroke.Parent = card

	-- Name + role + implemented status
	local nameLbl = Instance.new("TextLabel")
	nameLbl.Position = UDim2.fromOffset(15, 10)
	nameLbl.Size = UDim2.fromOffset(200, 30)
	nameLbl.BackgroundTransparency = 1
	nameLbl.Text = name:upper()
	nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLbl.Font = Enum.Font.GothamBlack
	nameLbl.TextSize = 20
	nameLbl.TextXAlignment = Enum.TextXAlignment.Left
	nameLbl.Parent = card

	local roleLbl = Instance.new("TextLabel")
	roleLbl.Position = UDim2.fromOffset(15, 38)
	roleLbl.Size = UDim2.fromOffset(140, 20)
	roleLbl.BackgroundTransparency = 1
	roleLbl.Text = agent.Role
	roleLbl.TextColor3 = accent
	roleLbl.Font = Enum.Font.GothamBold
	roleLbl.TextSize = 14
	roleLbl.TextXAlignment = Enum.TextXAlignment.Left
	roleLbl.Parent = card

	local statusLbl = Instance.new("TextLabel")
	statusLbl.AnchorPoint = Vector2.new(1, 0)
	statusLbl.Position = UDim2.new(1, -10, 0, 14)
	statusLbl.Size = UDim2.fromOffset(110, 20)
	statusLbl.BackgroundTransparency = 1
	statusLbl.Text = IMPLEMENTED_AGENTS[name] and "✓ PLAYABLE" or "DATA ONLY"
	statusLbl.TextColor3 = IMPLEMENTED_AGENTS[name] and Color3.fromRGB(80, 220, 120) or Color3.fromRGB(120, 120, 130)
	statusLbl.Font = Enum.Font.GothamBold
	statusLbl.TextSize = 11
	statusLbl.TextXAlignment = Enum.TextXAlignment.Right
	statusLbl.Parent = card

	-- Country + real name
	if agent.Country then
		local country = Instance.new("TextLabel")
		country.Position = UDim2.fromOffset(15, 62)
		country.Size = UDim2.fromOffset(300, 18)
		country.BackgroundTransparency = 1
		country.Text = agent.Country .. (agent.RealName and ("  •  " .. agent.RealName) or "")
		country.TextColor3 = Color3.fromRGB(180, 180, 200)
		country.Font = Enum.Font.Gotham
		country.TextSize = 11
		country.TextXAlignment = Enum.TextXAlignment.Left
		country.Parent = card
	end

	-- Abilities preview (4 small chips)
	if agent.Abilities then
		local abLayout = Instance.new("Frame")
		abLayout.Position = UDim2.fromOffset(15, 90)
		abLayout.Size = UDim2.fromOffset(310, 80)
		abLayout.BackgroundTransparency = 1
		abLayout.Parent = card

		local i = 0
		for _, key in ipairs({ "C", "Q", "E", "X" }) do
			local ab = agent.Abilities[key]
			if ab then
				local chip = Instance.new("Frame")
				chip.Position = UDim2.fromOffset((i % 2) * 155, math.floor(i / 2) * 38)
				chip.Size = UDim2.fromOffset(150, 34)
				chip.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
				chip.BackgroundTransparency = 0.3
				chip.BorderSizePixel = 0
				chip.Parent = abLayout
				local chCorner = Instance.new("UICorner")
				chCorner.CornerRadius = UDim.new(0, 4)
				chCorner.Parent = chip
				local lbl = Instance.new("TextLabel")
				lbl.Size = UDim2.fromScale(1, 1)
				lbl.BackgroundTransparency = 1
				lbl.Text = " [" .. key .. "] " .. (ab.Name or "?")
				lbl.TextColor3 = key == "X" and Color3.fromRGB(255, 220, 80) or accent
				lbl.Font = Enum.Font.GothamBold
				lbl.TextSize = 11
				lbl.TextXAlignment = Enum.TextXAlignment.Left
				lbl.Parent = chip
				i += 1
			end
		end
	end
end

local function buildMapCard(map, name, parent)
	local card = Instance.new("Frame")
	card.Size = UDim2.fromOffset(340, 140)
	card.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
	card.BorderSizePixel = 0
	card.Parent = parent
	local cCorner = Instance.new("UICorner")
	cCorner.CornerRadius = UDim.new(0, 8)
	cCorner.Parent = card

	local accent = (map.ColorPalette and map.ColorPalette.Primary) or Color3.fromRGB(180, 180, 200)
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2
	stroke.Color = accent
	stroke.Transparency = 0.5
	stroke.Parent = card

	-- Color accent bar
	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(1, 0, 0, 8)
	bar.BackgroundColor3 = accent
	bar.BorderSizePixel = 0
	bar.Parent = card

	local nameLbl = Instance.new("TextLabel")
	nameLbl.Position = UDim2.fromOffset(15, 16)
	nameLbl.Size = UDim2.fromOffset(310, 30)
	nameLbl.BackgroundTransparency = 1
	nameLbl.Text = name:upper()
	nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLbl.Font = Enum.Font.GothamBlack
	nameLbl.TextSize = 22
	nameLbl.TextXAlignment = Enum.TextXAlignment.Left
	nameLbl.Parent = card

	local themeLbl = Instance.new("TextLabel")
	themeLbl.Position = UDim2.fromOffset(15, 46)
	themeLbl.Size = UDim2.fromOffset(310, 20)
	themeLbl.BackgroundTransparency = 1
	themeLbl.Text = map.Theme or ""
	themeLbl.TextColor3 = accent
	themeLbl.Font = Enum.Font.GothamBold
	themeLbl.TextSize = 12
	themeLbl.TextWrapped = true
	themeLbl.TextXAlignment = Enum.TextXAlignment.Left
	themeLbl.Parent = card

	local stats = Instance.new("TextLabel")
	stats.Position = UDim2.fromOffset(15, 80)
	stats.Size = UDim2.fromOffset(310, 50)
	stats.BackgroundTransparency = 1
	stats.Text = string.format(
		"Sites: %d  •  %dx%d studs  •  %s",
		map.BombSites or 2,
		map.Dimensions.X, map.Dimensions.Z,
		map.Difficulty or "?"
	)
	stats.TextColor3 = Color3.fromRGB(180, 180, 200)
	stats.Font = Enum.Font.Gotham
	stats.TextSize = 11
	stats.TextWrapped = true
	stats.TextXAlignment = Enum.TextXAlignment.Left
	stats.Parent = card
end

local function buildWeaponCard(weapon, name, parent)
	local card = Instance.new("Frame")
	card.Size = UDim2.fromOffset(220, 140)
	card.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
	card.BorderSizePixel = 0
	card.Parent = parent
	local cCorner = Instance.new("UICorner")
	cCorner.CornerRadius = UDim.new(0, 8)
	cCorner.Parent = card

	local nameLbl = Instance.new("TextLabel")
	nameLbl.Position = UDim2.fromOffset(10, 8)
	nameLbl.Size = UDim2.fromOffset(200, 24)
	nameLbl.BackgroundTransparency = 1
	nameLbl.Text = weapon.DisplayName or name
	nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLbl.Font = Enum.Font.GothamBlack
	nameLbl.TextSize = 16
	nameLbl.TextXAlignment = Enum.TextXAlignment.Left
	nameLbl.Parent = card

	local catLbl = Instance.new("TextLabel")
	catLbl.Position = UDim2.fromOffset(10, 30)
	catLbl.Size = UDim2.fromOffset(120, 18)
	catLbl.BackgroundTransparency = 1
	catLbl.Text = weapon.Category or "?"
	catLbl.TextColor3 = Color3.fromRGB(255, 200, 80)
	catLbl.Font = Enum.Font.GothamBold
	catLbl.TextSize = 11
	catLbl.TextXAlignment = Enum.TextXAlignment.Left
	catLbl.Parent = card

	local priceLbl = Instance.new("TextLabel")
	priceLbl.AnchorPoint = Vector2.new(1, 0)
	priceLbl.Position = UDim2.new(1, -10, 0, 30)
	priceLbl.Size = UDim2.fromOffset(80, 18)
	priceLbl.BackgroundTransparency = 1
	priceLbl.Text = (weapon.Price or 0) .. " cr"
	priceLbl.TextColor3 = Color3.fromRGB(255, 220, 80)
	priceLbl.Font = Enum.Font.GothamBold
	priceLbl.TextSize = 11
	priceLbl.TextXAlignment = Enum.TextXAlignment.Right
	priceLbl.Parent = card

	-- Damage
	if weapon.Damage and weapon.Damage[1] then
		local d = weapon.Damage[1]
		local dmgLbl = Instance.new("TextLabel")
		dmgLbl.Position = UDim2.fromOffset(10, 60)
		dmgLbl.Size = UDim2.fromOffset(200, 18)
		dmgLbl.BackgroundTransparency = 1
		dmgLbl.RichText = true
		dmgLbl.Text = string.format("DMG: <font color=\"#ff8888\">H%d</font> B%d L%d", d.Head or 0, d.Body or 0, d.Leg or 0)
		dmgLbl.TextColor3 = Color3.fromRGB(220, 220, 240)
		dmgLbl.Font = Enum.Font.GothamBold
		dmgLbl.TextSize = 12
		dmgLbl.TextXAlignment = Enum.TextXAlignment.Left
		dmgLbl.Parent = card
	end

	if weapon.FireRate then
		local rpmLbl = Instance.new("TextLabel")
		rpmLbl.Position = UDim2.fromOffset(10, 80)
		rpmLbl.Size = UDim2.fromOffset(200, 18)
		rpmLbl.BackgroundTransparency = 1
		rpmLbl.Text = string.format("RPS: %.2f  •  Mag: %d/%d", weapon.FireRate, weapon.MagazineSize or 0, weapon.ReserveAmmo or 0)
		rpmLbl.TextColor3 = Color3.fromRGB(180, 180, 200)
		rpmLbl.Font = Enum.Font.Gotham
		rpmLbl.TextSize = 11
		rpmLbl.TextXAlignment = Enum.TextXAlignment.Left
		rpmLbl.Parent = card
	end

	if weapon.WallPen then
		local wpLbl = Instance.new("TextLabel")
		wpLbl.Position = UDim2.fromOffset(10, 100)
		wpLbl.Size = UDim2.fromOffset(200, 18)
		wpLbl.BackgroundTransparency = 1
		wpLbl.Text = "Wall Pen: " .. weapon.WallPen
		wpLbl.TextColor3 = Color3.fromRGB(180, 180, 200)
		wpLbl.Font = Enum.Font.Gotham
		wpLbl.TextSize = 11
		wpLbl.TextXAlignment = Enum.TextXAlignment.Left
		wpLbl.Parent = card
	end
end

function CompendiumController.RefreshContent()
	if not contentArea then return end
	for _, child in ipairs(contentArea:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	-- Layout
	local existing = contentArea:FindFirstChildOfClass("UIGridLayout")
	if existing then existing:Destroy() end
	local existingPad = contentArea:FindFirstChildOfClass("UIPadding")
	if existingPad then existingPad:Destroy() end
	local layout = Instance.new("UIGridLayout")
	layout.CellPadding = UDim2.fromOffset(10, 10)
	layout.Parent = contentArea
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 10)
	pad.PaddingLeft = UDim.new(0, 10)
	pad.Parent = contentArea

	if currentTab == "Agents" then
		layout.CellSize = UDim2.fromOffset(340, 180)
		for _, name in ipairs(AgentDatabase.GetAllNames()) do
			local agent = AgentDatabase[name]
			buildAgentCard(agent, name, contentArea)
		end
	elseif currentTab == "Maps" then
		layout.CellSize = UDim2.fromOffset(340, 140)
		for _, name in ipairs(MapData.GetAllMaps()) do
			local map = MapData[name]
			if map then buildMapCard(map, name, contentArea) end
		end
	elseif currentTab == "Weapons" then
		layout.CellSize = UDim2.fromOffset(220, 140)
		for _, category in ipairs({ "Sidearm", "SMG", "Shotgun", "Rifle", "Sniper", "MachineGun", "Melee" }) do
			for _, name in ipairs(WeaponDatabase.Categories[category] or {}) do
				local w = WeaponDatabase[name]
				if w then buildWeaponCard(w, name, contentArea) end
			end
		end
	end
end

function CompendiumController.Start()
	buildGui()
	CompendiumController.RefreshContent()

	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.F1 then
			menuOpen = not menuOpen
			gui.Enabled = menuOpen
			if menuOpen then CompendiumController.RefreshContent() end
		end
	end)
end

return CompendiumController
