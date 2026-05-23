-- MapVoteController: UI dla głosowania na następną mapę

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
local MapData = require(ReplicatedStorage.Shared:WaitForChild("MapData"))

local MapVoteController = {}

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local gui
local mapCards = {}  -- [mapName] = { card, voteCount }
local timerLabel
local myVote

local function buildGui()
	gui = Instance.new("ScreenGui")
	gui.Name = "MapVote"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Enabled = false
	gui.Parent = PlayerGui

	local backdrop = Instance.new("Frame")
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
	backdrop.BackgroundTransparency = 0.1
	backdrop.BorderSizePixel = 0
	backdrop.Parent = gui

	local title = Instance.new("TextLabel")
	title.AnchorPoint = Vector2.new(0.5, 0)
	title.Position = UDim2.new(0.5, 0, 0, 60)
	title.Size = UDim2.fromOffset(800, 60)
	title.BackgroundTransparency = 1
	title.Text = "VOTE FOR NEXT MAP"
	title.TextColor3 = Color3.fromRGB(255, 100, 80)
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 36
	title.Parent = backdrop

	timerLabel = Instance.new("TextLabel")
	timerLabel.AnchorPoint = Vector2.new(0.5, 0)
	timerLabel.Position = UDim2.new(0.5, 0, 0, 130)
	timerLabel.Size = UDim2.fromOffset(300, 30)
	timerLabel.BackgroundTransparency = 1
	timerLabel.Text = "20"
	timerLabel.TextColor3 = Color3.fromRGB(255, 200, 80)
	timerLabel.Font = Enum.Font.GothamBold
	timerLabel.TextSize = 22
	timerLabel.Parent = backdrop

	-- Card container
	local container = Instance.new("Frame")
	container.AnchorPoint = Vector2.new(0.5, 0.5)
	container.Position = UDim2.fromScale(0.5, 0.55)
	container.Size = UDim2.fromOffset(1100, 380)
	container.BackgroundTransparency = 1
	container.Parent = backdrop

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 24)
	layout.Parent = container

	return container
end

local function createMapCard(parent, mapName)
	local mapInfo = MapData.GetByName(mapName)
	local color = (mapInfo and mapInfo.ColorPalette and mapInfo.ColorPalette.Primary) or Color3.fromRGB(80, 80, 100)

	local card = Instance.new("TextButton")
	card.Name = "Card_" .. mapName
	card.Size = UDim2.fromOffset(320, 360)
	card.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
	card.BorderSizePixel = 0
	card.AutoButtonColor = false
	card.Text = ""
	card.Parent = parent

	local cCorner = Instance.new("UICorner")
	cCorner.CornerRadius = UDim.new(0, 12)
	cCorner.Parent = card

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 3
	stroke.Color = color
	stroke.Transparency = 0.5
	stroke.Parent = card

	-- Color top bar
	local accent = Instance.new("Frame")
	accent.Size = UDim2.new(1, 0, 0, 8)
	accent.BackgroundColor3 = color
	accent.BorderSizePixel = 0
	accent.Parent = card

	-- Map name
	local name = Instance.new("TextLabel")
	name.Position = UDim2.fromOffset(0, 20)
	name.Size = UDim2.new(1, 0, 0, 40)
	name.BackgroundTransparency = 1
	name.Text = mapName:upper()
	name.TextColor3 = Color3.fromRGB(255, 255, 255)
	name.Font = Enum.Font.GothamBlack
	name.TextSize = 32
	name.Parent = card

	-- Theme
	local theme = Instance.new("TextLabel")
	theme.Position = UDim2.fromOffset(0, 60)
	theme.Size = UDim2.new(1, 0, 0, 24)
	theme.BackgroundTransparency = 1
	theme.Text = mapInfo and mapInfo.Theme or ""
	theme.TextColor3 = color
	theme.Font = Enum.Font.GothamBold
	theme.TextSize = 13
	theme.TextWrapped = true
	theme.Parent = card

	-- Vote count
	local voteCount = Instance.new("TextLabel")
	voteCount.Name = "VoteCount"
	voteCount.AnchorPoint = Vector2.new(0.5, 0.5)
	voteCount.Position = UDim2.fromScale(0.5, 0.6)
	voteCount.Size = UDim2.fromOffset(200, 80)
	voteCount.BackgroundTransparency = 1
	voteCount.Text = "0"
	voteCount.TextColor3 = Color3.fromRGB(255, 220, 80)
	voteCount.Font = Enum.Font.GothamBlack
	voteCount.TextSize = 64
	voteCount.Parent = card

	-- Vote button
	local btnLbl = Instance.new("TextLabel")
	btnLbl.AnchorPoint = Vector2.new(0.5, 1)
	btnLbl.Position = UDim2.new(0.5, 0, 1, -20)
	btnLbl.Size = UDim2.fromOffset(200, 30)
	btnLbl.BackgroundTransparency = 1
	btnLbl.Text = "CLICK TO VOTE"
	btnLbl.TextColor3 = Color3.fromRGB(180, 180, 200)
	btnLbl.Font = Enum.Font.GothamBold
	btnLbl.TextSize = 14
	btnLbl.Parent = card

	card.MouseEnter:Connect(function()
		card.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
		stroke.Transparency = 0
	end)
	card.MouseLeave:Connect(function()
		if myVote ~= mapName then
			card.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
			stroke.Transparency = 0.5
		end
	end)
	card.Activated:Connect(function()
		myVote = mapName
		Remotes.MapVoteCast:FireServer(mapName)
		-- Visual: mark this card
		for _, otherCard in pairs(mapCards) do
			if otherCard.card then
				otherCard.card.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
				local s = otherCard.card:FindFirstChildOfClass("UIStroke")
				if s then s.Transparency = 0.5 end
			end
		end
		card.BackgroundColor3 = Color3.fromRGB(60, 80, 100)
		stroke.Transparency = 0
		btnLbl.Text = "✓ VOTED"
		btnLbl.TextColor3 = Color3.fromRGB(80, 220, 120)
	end)

	return card
end

local function refresh(mapOptions, tallies)
	if not gui then return end
	local container = gui.Frame:FindFirstChildOfClass("Frame")
	-- Find the actual layout container
	for _, c in ipairs(gui:GetDescendants()) do
		if c:IsA("Frame") and c:FindFirstChildOfClass("UIListLayout") then
			container = c
			break
		end
	end
	if not container then return end

	-- Clear old cards
	for _, child in ipairs(container:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end
	mapCards = {}

	for _, mapName in ipairs(mapOptions) do
		local card = createMapCard(container, mapName)
		mapCards[mapName] = { card = card }
	end

	-- Update vote counts
	for mapName, count in pairs(tallies or {}) do
		if mapCards[mapName] then
			local vc = mapCards[mapName].card:FindFirstChild("VoteCount")
			if vc then vc.Text = tostring(count) end
		end
	end
end

function MapVoteController.Start()
	buildGui()

	Remotes.MapVoteStart.OnClientEvent:Connect(function(mapOptions, duration)
		gui.Enabled = true
		myVote = nil
		refresh(mapOptions, {})
	end)

	Remotes.MapVoteUpdate.OnClientEvent:Connect(function(mapOptions, tallies, remaining)
		if not mapCards or not next(mapCards) then
			refresh(mapOptions, tallies)
		else
			for mapName, count in pairs(tallies or {}) do
				if mapCards[mapName] then
					local vc = mapCards[mapName].card:FindFirstChild("VoteCount")
					if vc then vc.Text = tostring(count) end
				end
			end
		end
		if timerLabel then timerLabel.Text = string.format("%d", math.max(0, math.floor(remaining))) end
		if remaining and remaining <= 0 then
			task.delay(2, function() gui.Enabled = false end)
		end
	end)
end

return MapVoteController
