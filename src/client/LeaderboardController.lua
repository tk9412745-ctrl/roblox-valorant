-- LeaderboardController: top 100 players UI (L key toggle)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local LeaderboardController = {}

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local gui
local list
local menuOpen = false

local function buildGui()
	gui = Instance.new("ScreenGui")
	gui.Name = "Leaderboard"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Enabled = false
	gui.Parent = PlayerGui

	local backdrop = Instance.new("Frame")
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	backdrop.BackgroundTransparency = 0.4
	backdrop.BorderSizePixel = 0
	backdrop.Parent = gui

	local panel = Instance.new("Frame")
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.Size = UDim2.fromOffset(700, 700)
	panel.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
	panel.BorderSizePixel = 0
	panel.Parent = backdrop
	local pCorner = Instance.new("UICorner")
	pCorner.CornerRadius = UDim.new(0, 12)
	pCorner.Parent = panel

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 60)
	title.BackgroundTransparency = 1
	title.Text = "🏆 GLOBAL LEADERBOARD"
	title.TextColor3 = Color3.fromRGB(255, 215, 0)
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 26
	title.Parent = panel

	local closeBtn = Instance.new("TextButton")
	closeBtn.AnchorPoint = Vector2.new(1, 0)
	closeBtn.Position = UDim2.new(1, -16, 0, 16)
	closeBtn.Size = UDim2.fromOffset(100, 32)
	closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	closeBtn.Text = "CLOSE (L)"
	closeBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 12
	closeBtn.Parent = panel
	local cbCorner = Instance.new("UICorner")
	cbCorner.CornerRadius = UDim.new(0, 6)
	cbCorner.Parent = closeBtn
	closeBtn.Activated:Connect(function()
		gui.Enabled = false
		menuOpen = false
	end)

	-- Header row
	local header = Instance.new("Frame")
	header.Position = UDim2.fromOffset(20, 70)
	header.Size = UDim2.new(1, -40, 0, 32)
	header.BackgroundTransparency = 1
	header.Parent = panel
	local function addColLabel(text, x, width)
		local lbl = Instance.new("TextLabel")
		lbl.Position = UDim2.fromOffset(x, 0)
		lbl.Size = UDim2.fromOffset(width, 32)
		lbl.BackgroundTransparency = 1
		lbl.Text = text
		lbl.TextColor3 = Color3.fromRGB(180, 180, 200)
		lbl.Font = Enum.Font.GothamBold
		lbl.TextSize = 12
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = header
	end
	addColLabel("#", 0, 60)
	addColLabel("PLAYER", 60, 280)
	addColLabel("RANK", 340, 160)
	addColLabel("MMR", 500, 100)

	list = Instance.new("ScrollingFrame")
	list.Position = UDim2.fromOffset(20, 110)
	list.Size = UDim2.new(1, -40, 1, -130)
	list.BackgroundTransparency = 1
	list.BorderSizePixel = 0
	list.CanvasSize = UDim2.fromScale(0, 0)
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.ScrollBarThickness = 6
	list.Parent = panel
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 4)
	layout.Parent = list
end

local function refresh(entries)
	if not list then return end
	for _, child in ipairs(list:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	for i, entry in ipairs(entries) do
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, -10, 0, 32)
		row.BackgroundColor3 = (i % 2 == 0) and Color3.fromRGB(30, 30, 45) or Color3.fromRGB(20, 20, 35)
		row.BackgroundTransparency = 0.3
		row.BorderSizePixel = 0
		row.Parent = list
		local rCorner = Instance.new("UICorner")
		rCorner.CornerRadius = UDim.new(0, 4)
		rCorner.Parent = row

		local function addCol(text, x, width, color, font)
			local lbl = Instance.new("TextLabel")
			lbl.Position = UDim2.fromOffset(x, 0)
			lbl.Size = UDim2.fromOffset(width, 32)
			lbl.BackgroundTransparency = 1
			lbl.Text = text
			lbl.TextColor3 = color or Color3.fromRGB(220, 220, 240)
			lbl.Font = font or Enum.Font.GothamBold
			lbl.TextSize = 13
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.Parent = row
		end

		-- Rank-color medal for top 3
		local rankColor
		if i == 1 then rankColor = Color3.fromRGB(255, 215, 0)
		elseif i == 2 then rankColor = Color3.fromRGB(200, 200, 220)
		elseif i == 3 then rankColor = Color3.fromRGB(180, 110, 60)
		end

		addCol(tostring(i), 0, 60, rankColor or Color3.fromRGB(255, 255, 255), Enum.Font.GothamBlack)
		addCol(entry.name or "?", 60, 280, Color3.fromRGB(255, 255, 255))
		addCol(entry.rank or "?", 340, 160, Color3.fromRGB(180, 220, 255))
		addCol(tostring(entry.mmr or 0), 500, 100, Color3.fromRGB(255, 220, 80))
	end
end

function LeaderboardController.Start()
	buildGui()

	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.L then
			menuOpen = not menuOpen
			gui.Enabled = menuOpen
			if menuOpen then
				Remotes.RequestLeaderboard:FireServer()
			end
		end
	end)

	Remotes.UpdateLeaderboard.OnClientEvent:Connect(function(entries)
		refresh(entries or {})
	end)
end

return LeaderboardController
