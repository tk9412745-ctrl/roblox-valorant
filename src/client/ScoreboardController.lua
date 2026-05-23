-- ScoreboardController: TAB key (hold) → fullscreen scoreboard z K/D/A/ACS/HS%/ADR

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local ScoreboardController = {}

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local gui
local atkPanel, defPanel
local stats = {}  -- snapshot from server

local function buildGui()
	gui = Instance.new("ScreenGui")
	gui.Name = "Scoreboard"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Enabled = false
	gui.Parent = PlayerGui

	-- Backdrop
	local backdrop = Instance.new("Frame")
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	backdrop.BackgroundTransparency = 0.4
	backdrop.BorderSizePixel = 0
	backdrop.Parent = gui

	-- Container
	local container = Instance.new("Frame")
	container.AnchorPoint = Vector2.new(0.5, 0.5)
	container.Position = UDim2.fromScale(0.5, 0.5)
	container.Size = UDim2.fromOffset(1000, 600)
	container.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
	container.BackgroundTransparency = 0.1
	container.BorderSizePixel = 0
	container.Parent = backdrop
	local cCorner = Instance.new("UICorner")
	cCorner.CornerRadius = UDim.new(0, 12)
	cCorner.Parent = container

	-- Header
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 60)
	header.BackgroundTransparency = 1
	header.Parent = container
	local title = Instance.new("TextLabel")
	title.Size = UDim2.fromScale(1, 1)
	title.BackgroundTransparency = 1
	title.Text = "SCOREBOARD"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 28
	title.Parent = header

	-- Attackers panel
	atkPanel = Instance.new("Frame")
	atkPanel.Name = "AttackersPanel"
	atkPanel.Position = UDim2.fromOffset(20, 80)
	atkPanel.Size = UDim2.new(0.5, -30, 1, -100)
	atkPanel.BackgroundColor3 = Color3.fromRGB(40, 20, 25)
	atkPanel.BackgroundTransparency = 0.3
	atkPanel.BorderSizePixel = 0
	atkPanel.Parent = container
	local apCorner = Instance.new("UICorner")
	apCorner.CornerRadius = UDim.new(0, 8)
	apCorner.Parent = atkPanel

	local atkTitle = Instance.new("TextLabel")
	atkTitle.Size = UDim2.new(1, 0, 0, 30)
	atkTitle.BackgroundTransparency = 1
	atkTitle.Text = "ATTACKERS"
	atkTitle.TextColor3 = Color3.fromRGB(255, 80, 80)
	atkTitle.Font = Enum.Font.GothamBold
	atkTitle.TextSize = 18
	atkTitle.Parent = atkPanel

	-- Defenders panel
	defPanel = Instance.new("Frame")
	defPanel.Name = "DefendersPanel"
	defPanel.Position = UDim2.new(0.5, 10, 0, 80)
	defPanel.Size = UDim2.new(0.5, -30, 1, -100)
	defPanel.BackgroundColor3 = Color3.fromRGB(20, 25, 40)
	defPanel.BackgroundTransparency = 0.3
	defPanel.BorderSizePixel = 0
	defPanel.Parent = container
	local dpCorner = Instance.new("UICorner")
	dpCorner.CornerRadius = UDim.new(0, 8)
	dpCorner.Parent = defPanel

	local defTitle = Instance.new("TextLabel")
	defTitle.Size = UDim2.new(1, 0, 0, 30)
	defTitle.BackgroundTransparency = 1
	defTitle.Text = "DEFENDERS"
	defTitle.TextColor3 = Color3.fromRGB(80, 120, 255)
	defTitle.Font = Enum.Font.GothamBold
	defTitle.TextSize = 18
	defTitle.Parent = defPanel

	-- Headers row for each panel
	local function addHeaderRow(panel)
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, -20, 0, 26)
		row.Position = UDim2.fromOffset(10, 36)
		row.BackgroundTransparency = 1
		row.Parent = panel
		local function addCol(text, x, width, color)
			local lbl = Instance.new("TextLabel")
			lbl.Position = UDim2.fromOffset(x, 0)
			lbl.Size = UDim2.fromOffset(width, 26)
			lbl.BackgroundTransparency = 1
			lbl.Text = text
			lbl.TextColor3 = color or Color3.fromRGB(180, 180, 200)
			lbl.Font = Enum.Font.GothamBold
			lbl.TextSize = 12
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.Parent = row
		end
		addCol("PLAYER", 0, 130)
		addCol("AGENT", 130, 70)
		addCol("ACS", 200, 50)
		addCol("K", 250, 30)
		addCol("D", 280, 30)
		addCol("A", 310, 30)
		addCol("HS%", 340, 50)
		addCol("ADR", 390, 50)
	end
	addHeaderRow(atkPanel)
	addHeaderRow(defPanel)
end

local function clearPlayerRows(panel)
	for _, child in ipairs(panel:GetChildren()) do
		if child:IsA("Frame") and child.Name:find("^Row_") then
			child:Destroy()
		end
	end
end

local function addPlayerRow(panel, entry, index)
	local row = Instance.new("Frame")
	row.Name = "Row_" .. entry.name
	row.Size = UDim2.new(1, -20, 0, 36)
	row.Position = UDim2.fromOffset(10, 70 + (index - 1) * 40)
	row.BackgroundColor3 = (index % 2 == 0) and Color3.fromRGB(30, 30, 45) or Color3.fromRGB(20, 20, 35)
	row.BackgroundTransparency = 0.3
	row.BorderSizePixel = 0
	row.Parent = panel
	local rCorner = Instance.new("UICorner")
	rCorner.CornerRadius = UDim.new(0, 4)
	rCorner.Parent = row

	local function addCol(text, x, width, color, font, size)
		local lbl = Instance.new("TextLabel")
		lbl.Position = UDim2.fromOffset(x, 0)
		lbl.Size = UDim2.fromOffset(width, 36)
		lbl.BackgroundTransparency = 1
		lbl.Text = text
		lbl.TextColor3 = color or Color3.fromRGB(220, 220, 240)
		lbl.Font = font or Enum.Font.Gotham
		lbl.TextSize = size or 14
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = row
	end

	-- Player name with MVP medal prefix
	local nameText = entry.name
	if (entry.mvps or 0) > 0 then
		nameText = "★" .. (entry.mvps > 1 and entry.mvps or "") .. " " .. nameText
	end
	addCol(nameText, 0, 130, Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold, 14)
	addCol(entry.agent or "—", 130, 70)
	addCol(tostring(entry.acs), 200, 50, Color3.fromRGB(255, 220, 80), Enum.Font.GothamBold)
	addCol(tostring(entry.kills), 250, 30, Color3.fromRGB(80, 220, 120), Enum.Font.GothamBold)
	addCol(tostring(entry.deaths), 280, 30, Color3.fromRGB(220, 80, 80))
	addCol(tostring(entry.assists), 310, 30)
	addCol(entry.hsPct .. "%", 340, 50)
	addCol(tostring(entry.adr), 390, 50)
end

local function refresh()
	if not gui or not gui.Enabled then return end
	clearPlayerRows(atkPanel)
	clearPlayerRows(defPanel)

	local atkIdx = 0
	local defIdx = 0
	-- Sort by ACS desc
	table.sort(stats, function(a, b) return a.acs > b.acs end)
	for _, entry in ipairs(stats) do
		if entry.team == "Attackers" then
			atkIdx += 1
			addPlayerRow(atkPanel, entry, atkIdx)
		elseif entry.team == "Defenders" then
			defIdx += 1
			addPlayerRow(defPanel, entry, defIdx)
		end
	end
end

function ScoreboardController.Start()
	buildGui()

	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.Tab then
			gui.Enabled = true
			refresh()
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.Tab then
			gui.Enabled = false
		end
	end)

	Remotes.UpdateMatchStats.OnClientEvent:Connect(function(snapshot)
		stats = snapshot or {}
		if gui.Enabled then refresh() end
	end)
end

return ScoreboardController
