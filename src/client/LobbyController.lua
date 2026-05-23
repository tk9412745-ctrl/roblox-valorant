-- LobbyController: welcome screen + lobby waiting state + pre-match team display

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local LobbyController = {}

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local welcomeGui
local lobbyGui

-- ============================================================
-- WELCOME SCREEN (5s on join)
-- ============================================================
local function buildWelcomeGui()
	welcomeGui = Instance.new("ScreenGui")
	welcomeGui.Name = "WelcomeScreen"
	welcomeGui.ResetOnSpawn = false
	welcomeGui.IgnoreGuiInset = true
	welcomeGui.Parent = PlayerGui

	local backdrop = Instance.new("Frame")
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	backdrop.BorderSizePixel = 0
	backdrop.Parent = welcomeGui

	local logo = Instance.new("TextLabel")
	logo.AnchorPoint = Vector2.new(0.5, 0.5)
	logo.Position = UDim2.fromScale(0.5, 0.4)
	logo.Size = UDim2.fromOffset(800, 120)
	logo.BackgroundTransparency = 1
	logo.Text = "VALORANT-LIKE"
	logo.TextColor3 = Color3.fromRGB(255, 70, 80)
	logo.TextStrokeTransparency = 0.7
	logo.Font = Enum.Font.GothamBlack
	logo.TextSize = 80
	logo.TextTransparency = 1
	logo.Parent = backdrop

	local subtitle = Instance.new("TextLabel")
	subtitle.AnchorPoint = Vector2.new(0.5, 0.5)
	subtitle.Position = UDim2.fromScale(0.5, 0.5)
	subtitle.Size = UDim2.fromOffset(600, 40)
	subtitle.BackgroundTransparency = 1
	subtitle.Text = "TACTICAL FPS"
	subtitle.TextColor3 = Color3.fromRGB(180, 180, 200)
	subtitle.Font = Enum.Font.GothamBold
	subtitle.TextSize = 24
	subtitle.TextTransparency = 1
	subtitle.Parent = backdrop

	local welcomeText = Instance.new("TextLabel")
	welcomeText.AnchorPoint = Vector2.new(0.5, 0.5)
	welcomeText.Position = UDim2.fromScale(0.5, 0.6)
	welcomeText.Size = UDim2.fromOffset(600, 30)
	welcomeText.BackgroundTransparency = 1
	welcomeText.Text = "Welcome, " .. LocalPlayer.Name
	welcomeText.TextColor3 = Color3.fromRGB(255, 220, 80)
	welcomeText.Font = Enum.Font.Gotham
	welcomeText.TextSize = 20
	welcomeText.TextTransparency = 1
	welcomeText.Parent = backdrop

	-- Fade in
	task.spawn(function()
		TweenService:Create(logo, TweenInfo.new(0.8), { TextTransparency = 0 }):Play()
		task.wait(0.3)
		TweenService:Create(subtitle, TweenInfo.new(0.6), { TextTransparency = 0 }):Play()
		task.wait(0.2)
		TweenService:Create(welcomeText, TweenInfo.new(0.6), { TextTransparency = 0 }):Play()

		task.wait(3.5)

		-- Fade out
		TweenService:Create(backdrop, TweenInfo.new(0.8), { BackgroundTransparency = 1 }):Play()
		TweenService:Create(logo, TweenInfo.new(0.6), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
		TweenService:Create(subtitle, TweenInfo.new(0.6), { TextTransparency = 1 }):Play()
		TweenService:Create(welcomeText, TweenInfo.new(0.6), { TextTransparency = 1 }):Play()
		task.wait(0.8)
		welcomeGui:Destroy()
	end)
end

-- ============================================================
-- LOBBY WAITING STATE
-- ============================================================
local lobbyOpen = false
local function buildLobbyGui()
	lobbyGui = Instance.new("ScreenGui")
	lobbyGui.Name = "Lobby"
	lobbyGui.ResetOnSpawn = false
	lobbyGui.IgnoreGuiInset = true
	lobbyGui.Enabled = false
	lobbyGui.Parent = PlayerGui

	local backdrop = Instance.new("Frame")
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
	backdrop.BackgroundTransparency = 0.1
	backdrop.BorderSizePixel = 0
	backdrop.Parent = lobbyGui

	local title = Instance.new("TextLabel")
	title.AnchorPoint = Vector2.new(0.5, 0)
	title.Position = UDim2.new(0.5, 0, 0, 80)
	title.Size = UDim2.fromOffset(800, 60)
	title.BackgroundTransparency = 1
	title.Text = "WAITING FOR PLAYERS"
	title.TextColor3 = Color3.fromRGB(255, 100, 80)
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 36
	title.Parent = backdrop

	local subtitle = Instance.new("TextLabel")
	subtitle.AnchorPoint = Vector2.new(0.5, 0)
	subtitle.Position = UDim2.new(0.5, 0, 0, 150)
	subtitle.Size = UDim2.fromOffset(800, 30)
	subtitle.Name = "Subtitle"
	subtitle.BackgroundTransparency = 1
	subtitle.Text = "Match begins when enough players join..."
	subtitle.TextColor3 = Color3.fromRGB(180, 180, 200)
	subtitle.Font = Enum.Font.Gotham
	subtitle.TextSize = 18
	subtitle.Parent = backdrop

	-- Team panels
	local function makeTeamPanel(name, color, side)
		local panel = Instance.new("Frame")
		panel.Name = name .. "Panel"
		panel.AnchorPoint = Vector2.new(side == "left" and 0 or 1, 0.5)
		panel.Position = UDim2.new(side == "left" and 0.1 or 0.9, 0, 0.5, 0)
		panel.Size = UDim2.fromOffset(350, 420)
		panel.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
		panel.BackgroundTransparency = 0.2
		panel.BorderSizePixel = 0
		panel.Parent = backdrop
		local pCorner = Instance.new("UICorner")
		pCorner.CornerRadius = UDim.new(0, 12)
		pCorner.Parent = panel
		local pStroke = Instance.new("UIStroke")
		pStroke.Thickness = 2
		pStroke.Color = color
		pStroke.Transparency = 0.4
		pStroke.Parent = panel

		local teamTitle = Instance.new("TextLabel")
		teamTitle.Size = UDim2.new(1, 0, 0, 50)
		teamTitle.BackgroundTransparency = 1
		teamTitle.Text = name:upper()
		teamTitle.TextColor3 = color
		teamTitle.Font = Enum.Font.GothamBlack
		teamTitle.TextSize = 24
		teamTitle.Parent = panel

		local list = Instance.new("ScrollingFrame")
		list.Name = "PlayerList"
		list.Position = UDim2.fromOffset(15, 60)
		list.Size = UDim2.new(1, -30, 1, -75)
		list.BackgroundTransparency = 1
		list.BorderSizePixel = 0
		list.CanvasSize = UDim2.fromScale(0, 0)
		list.AutomaticCanvasSize = Enum.AutomaticSize.Y
		list.ScrollBarThickness = 4
		list.Parent = panel
		local layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, 6)
		layout.Parent = list

		return panel, list
	end

	makeTeamPanel("Attackers", Color3.fromRGB(255, 80, 80), "left")
	makeTeamPanel("Defenders", Color3.fromRGB(80, 120, 255), "right")

	-- Player count
	local playerCount = Instance.new("TextLabel")
	playerCount.Name = "PlayerCount"
	playerCount.AnchorPoint = Vector2.new(0.5, 1)
	playerCount.Position = UDim2.new(0.5, 0, 1, -60)
	playerCount.Size = UDim2.fromOffset(400, 30)
	playerCount.BackgroundTransparency = 1
	playerCount.Text = "Players: 0/10"
	playerCount.TextColor3 = Color3.fromRGB(255, 220, 80)
	playerCount.Font = Enum.Font.GothamBold
	playerCount.TextSize = 18
	playerCount.Parent = backdrop
end

local function refreshLobbyPlayers()
	if not lobbyGui then return end
	local atkPanel = lobbyGui:FindFirstChild("AttackersPanel", true)
	local defPanel = lobbyGui:FindFirstChild("DefendersPanel", true)
	if not atkPanel or not defPanel then return end

	local atkList = atkPanel:FindFirstChild("PlayerList")
	local defList = defPanel:FindFirstChild("PlayerList")

	-- Clear
	for _, list in ipairs({ atkList, defList }) do
		for _, child in ipairs(list:GetChildren()) do
			if child:IsA("TextLabel") then child:Destroy() end
		end
	end

	local atkCount, defCount = 0, 0
	for _, p in ipairs(Players:GetPlayers()) do
		local team = p.Team and p.Team.Name or nil
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, 0, 0, 32)
		lbl.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
		lbl.BackgroundTransparency = 0.3
		lbl.BorderSizePixel = 0
		lbl.Text = "  " .. p.Name .. (p == LocalPlayer and " (YOU)" or "")
		lbl.TextColor3 = Color3.fromRGB(240, 240, 240)
		lbl.Font = Enum.Font.GothamBold
		lbl.TextSize = 14
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		local lCorner = Instance.new("UICorner")
		lCorner.CornerRadius = UDim.new(0, 4)
		lCorner.Parent = lbl

		if team == "Attackers" then
			lbl.Parent = atkList
			atkCount += 1
		elseif team == "Defenders" then
			lbl.Parent = defList
			defCount += 1
		end
	end

	local pc = lobbyGui:FindFirstChild("PlayerCount", true)
	if pc then
		pc.Text = string.format("Attackers: %d | Defenders: %d | Total: %d/10", atkCount, defCount, atkCount + defCount)
	end
end

function LobbyController.ShowLobby(state)
	lobbyOpen = state
	if lobbyGui then lobbyGui.Enabled = state end
	if state then refreshLobbyPlayers() end
end

function LobbyController.Start()
	buildWelcomeGui()
	buildLobbyGui()

	-- Show lobby until match starts (RoundPhaseChanged != PreMatch)
	Remotes.LobbyState.OnClientEvent:Connect(function(state, statusText)
		LobbyController.ShowLobby(state == "Waiting")
		if statusText and lobbyGui then
			local subtitle = lobbyGui:FindFirstChild("Subtitle", true)
			if subtitle then subtitle.Text = statusText end
		end
		if state == "Waiting" then refreshLobbyPlayers() end
	end)

	-- Refresh on player join/leave
	Players.PlayerAdded:Connect(function()
		task.wait(1)
		if lobbyOpen then refreshLobbyPlayers() end
	end)
	Players.PlayerRemoving:Connect(function()
		if lobbyOpen then refreshLobbyPlayers() end
	end)

	-- Hide lobby when buy phase starts (match has begun)
	Remotes.RoundPhaseChanged.OnClientEvent:Connect(function(phase)
		if phase == "BuyPhase" then
			LobbyController.ShowLobby(false)
		end
	end)
end

return LobbyController
