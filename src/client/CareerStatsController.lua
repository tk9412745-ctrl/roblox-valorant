-- CareerStatsController: K key → career stats screen z all-time data

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local CareerStatsController = {}

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local gui
local menuOpen = false
local inventory = {}
local winStreakHud  -- HUD element (always visible)

local function buildGui()
	gui = Instance.new("ScreenGui")
	gui.Name = "CareerStats"
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

	-- Title
	local title = Instance.new("TextLabel")
	title.AnchorPoint = Vector2.new(0.5, 0)
	title.Position = UDim2.new(0.5, 0, 0, 40)
	title.Size = UDim2.fromOffset(700, 60)
	title.BackgroundTransparency = 1
	title.Text = "📊 CAREER STATS — " .. LocalPlayer.Name
	title.TextColor3 = Color3.fromRGB(80, 200, 255)
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 28
	title.Parent = backdrop

	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.AnchorPoint = Vector2.new(1, 0)
	closeBtn.Position = UDim2.new(1, -30, 0, 40)
	closeBtn.Size = UDim2.fromOffset(120, 40)
	closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	closeBtn.Text = "CLOSE (K)"
	closeBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 14
	closeBtn.Parent = backdrop
	local cbCorner = Instance.new("UICorner")
	cbCorner.CornerRadius = UDim.new(0, 6)
	cbCorner.Parent = closeBtn
	closeBtn.Activated:Connect(function()
		menuOpen = false
		gui.Enabled = false
	end)

	-- Stats grid (2x4)
	local statsGrid = Instance.new("Frame")
	statsGrid.Name = "StatsGrid"
	statsGrid.AnchorPoint = Vector2.new(0.5, 0)
	statsGrid.Position = UDim2.new(0.5, 0, 0, 130)
	statsGrid.Size = UDim2.fromOffset(900, 500)
	statsGrid.BackgroundTransparency = 1
	statsGrid.Parent = backdrop

	local layout = Instance.new("UIGridLayout")
	layout.CellSize = UDim2.fromOffset(210, 110)
	layout.CellPadding = UDim2.fromOffset(12, 12)
	layout.Parent = statsGrid
end

local function addStatCard(label, value, color)
	if not gui then return end
	local grid = gui:FindFirstChild("StatsGrid", true)
	if not grid then return end

	local card = Instance.new("Frame")
	card.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
	card.BackgroundTransparency = 0.2
	card.BorderSizePixel = 0
	card.Parent = grid
	local cCorner = Instance.new("UICorner")
	cCorner.CornerRadius = UDim.new(0, 8)
	cCorner.Parent = card

	local lbl = Instance.new("TextLabel")
	lbl.AnchorPoint = Vector2.new(0.5, 0)
	lbl.Position = UDim2.new(0.5, 0, 0, 12)
	lbl.Size = UDim2.new(1, 0, 0, 24)
	lbl.BackgroundTransparency = 1
	lbl.Text = label
	lbl.TextColor3 = Color3.fromRGB(180, 180, 200)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 12
	lbl.Parent = card

	local val = Instance.new("TextLabel")
	val.AnchorPoint = Vector2.new(0.5, 0)
	val.Position = UDim2.new(0.5, 0, 0, 40)
	val.Size = UDim2.new(1, 0, 0, 60)
	val.BackgroundTransparency = 1
	val.Text = tostring(value)
	val.TextColor3 = color or Color3.fromRGB(255, 220, 80)
	val.Font = Enum.Font.GothamBlack
	val.TextSize = 40
	val.Parent = card
end

local function refresh()
	if not gui then return end
	local grid = gui:FindFirstChild("StatsGrid", true)
	if not grid then return end

	-- Clear
	for _, child in ipairs(grid:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	local stats = inventory.stats or {}
	local matches = stats.MatchesPlayed or 0
	local wins = stats.MatchesWon or 0
	local kills = stats.Kills or 0
	local deaths = stats.Deaths or 0
	local hs = stats.HeadshotKills or 0
	local kd = deaths > 0 and (kills / deaths) or kills
	local winrate = matches > 0 and (wins / matches * 100) or 0
	local hsPct = kills > 0 and (hs / kills * 100) or 0
	local mmr = inventory.mmr or 800

	addStatCard("MMR", mmr, Color3.fromRGB(255, 200, 80))
	addStatCard("MATCHES PLAYED", matches, Color3.fromRGB(220, 220, 240))
	addStatCard("MATCHES WON", wins, Color3.fromRGB(80, 220, 120))
	addStatCard("WIN RATE", string.format("%.1f%%", winrate), Color3.fromRGB(80, 200, 255))
	addStatCard("TOTAL KILLS", kills, Color3.fromRGB(220, 80, 80))
	addStatCard("TOTAL DEATHS", deaths, Color3.fromRGB(180, 180, 200))
	addStatCard("K/D RATIO", string.format("%.2f", kd), Color3.fromRGB(255, 220, 80))
	addStatCard("HEADSHOT %", string.format("%.0f%%", hsPct), Color3.fromRGB(255, 100, 80))
	addStatCard("PLANTS", stats.Plants or 0, Color3.fromRGB(255, 150, 50))
	addStatCard("DEFUSES", stats.Defuses or 0, Color3.fromRGB(80, 180, 255))
	addStatCard("WIN STREAK", stats.WinStreak or 0, Color3.fromRGB(255, 215, 0))
	addStatCard("BEST STREAK", stats.BestWinStreak or 0, Color3.fromRGB(255, 100, 200))
end

-- HUD win streak indicator (small badge)
local function buildWinStreakHud()
	winStreakHud = Instance.new("ScreenGui")
	winStreakHud.Name = "WinStreakHUD"
	winStreakHud.ResetOnSpawn = false
	winStreakHud.IgnoreGuiInset = true
	winStreakHud.Parent = PlayerGui

	local badge = Instance.new("Frame")
	badge.Name = "Badge"
	badge.AnchorPoint = Vector2.new(0, 0)
	badge.Position = UDim2.fromOffset(190, 20)
	badge.Size = UDim2.fromOffset(140, 28)
	badge.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	badge.BackgroundTransparency = 0.3
	badge.BorderSizePixel = 0
	badge.Visible = false
	badge.Parent = winStreakHud
	local bCorner = Instance.new("UICorner")
	bCorner.CornerRadius = UDim.new(0, 4)
	bCorner.Parent = badge

	local lbl = Instance.new("TextLabel")
	lbl.Name = "Label"
	lbl.Size = UDim2.fromScale(1, 1)
	lbl.BackgroundTransparency = 1
	lbl.Text = "🔥 0W"
	lbl.TextColor3 = Color3.fromRGB(255, 200, 80)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 14
	lbl.Parent = badge
end

local function updateWinStreakHud()
	if not winStreakHud then return end
	local badge = winStreakHud:FindFirstChild("Badge")
	if not badge then return end
	local streak = (inventory.stats and inventory.stats.WinStreak) or 0
	if streak >= 2 then
		badge.Visible = true
		local lbl = badge:FindFirstChild("Label")
		if lbl then lbl.Text = "🔥 " .. streak .. "W" end
	else
		badge.Visible = false
	end
end

function CareerStatsController.Start()
	buildGui()
	buildWinStreakHud()

	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.K then
			menuOpen = not menuOpen
			gui.Enabled = menuOpen
			if menuOpen then
				Remotes.RequestInventory:FireServer()
				refresh()
			end
		end
	end)

	Remotes.UpdateInventory.OnClientEvent:Connect(function(data)
		if data then
			inventory = data
			updateWinStreakHud()
			if menuOpen then refresh() end
		end
	end)
end

return CareerStatsController
