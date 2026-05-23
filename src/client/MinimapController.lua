-- MinimapController: top-right radar pokazujący mapę top-down + teammates + spike
-- Valorant-style: teammates always visible, enemies hidden (chyba że spotted)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
local MapData = require(ReplicatedStorage.Shared:WaitForChild("MapData"))

local MinimapController = {}

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local MINIMAP_SIZE = 220     -- pixels
local MAP_RANGE = 200        -- studs visible across minimap diameter
local UPDATE_RATE = 0.1      -- seconds

local gui
local minimapFrame
local mapImage
local playerIndicator
local teammateDots = {}      -- [player] = Frame
local spikeIndicator
local currentMapName = "Ascent"
local mapCoverFrames = {}    -- rendered cover blocks as static map background

local function buildGui()
	gui = Instance.new("ScreenGui")
	gui.Name = "Minimap"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = PlayerGui

	minimapFrame = Instance.new("Frame")
	minimapFrame.Name = "MinimapFrame"
	minimapFrame.AnchorPoint = Vector2.new(1, 0)
	minimapFrame.Position = UDim2.new(1, -20, 0, 20)
	minimapFrame.Size = UDim2.fromOffset(MINIMAP_SIZE, MINIMAP_SIZE)
	minimapFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
	minimapFrame.BackgroundTransparency = 0.2
	minimapFrame.BorderSizePixel = 0
	minimapFrame.ClipsDescendants = true
	minimapFrame.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = minimapFrame

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2
	stroke.Color = Color3.fromRGB(80, 80, 100)
	stroke.Transparency = 0.3
	stroke.Parent = minimapFrame

	-- Map render layer (cover blocks drawn here)
	mapImage = Instance.new("Frame")
	mapImage.Name = "MapImage"
	mapImage.Size = UDim2.fromScale(1, 1)
	mapImage.Position = UDim2.fromScale(0.5, 0.5)
	mapImage.AnchorPoint = Vector2.new(0.5, 0.5)
	mapImage.BackgroundTransparency = 1
	mapImage.Parent = minimapFrame

	-- Local player indicator (center, with direction triangle)
	playerIndicator = Instance.new("Frame")
	playerIndicator.Name = "Player"
	playerIndicator.AnchorPoint = Vector2.new(0.5, 0.5)
	playerIndicator.Position = UDim2.fromScale(0.5, 0.5)
	playerIndicator.Size = UDim2.fromOffset(14, 14)
	playerIndicator.BackgroundColor3 = Color3.fromRGB(80, 220, 120)
	playerIndicator.BorderSizePixel = 0
	playerIndicator.ZIndex = 10
	playerIndicator.Parent = minimapFrame
	local pCorner = Instance.new("UICorner")
	pCorner.CornerRadius = UDim.new(1, 0)
	pCorner.Parent = playerIndicator

	-- Direction arrow (triangle pointing forward)
	local arrow = Instance.new("Frame")
	arrow.Name = "Arrow"
	arrow.AnchorPoint = Vector2.new(0.5, 1)
	arrow.Position = UDim2.new(0.5, 0, 0, 0)
	arrow.Size = UDim2.fromOffset(4, 10)
	arrow.BackgroundColor3 = Color3.fromRGB(80, 220, 120)
	arrow.BorderSizePixel = 0
	arrow.ZIndex = 11
	arrow.Parent = playerIndicator

	-- Spike indicator (hidden until needed)
	spikeIndicator = Instance.new("ImageLabel")
	spikeIndicator.Name = "Spike"
	spikeIndicator.AnchorPoint = Vector2.new(0.5, 0.5)
	spikeIndicator.Size = UDim2.fromOffset(16, 16)
	spikeIndicator.Position = UDim2.fromScale(0.5, 0.5)
	spikeIndicator.BackgroundColor3 = Color3.fromRGB(255, 80, 30)
	spikeIndicator.BackgroundTransparency = 0
	spikeIndicator.ImageTransparency = 1
	spikeIndicator.BorderSizePixel = 0
	spikeIndicator.Visible = false
	spikeIndicator.ZIndex = 9
	spikeIndicator.Parent = minimapFrame
	local sCorner = Instance.new("UICorner")
	sCorner.CornerRadius = UDim.new(0.2, 0)
	sCorner.Parent = spikeIndicator
end

local function clearMapRender()
	for _, f in ipairs(mapCoverFrames) do
		if f.Parent then f:Destroy() end
	end
	mapCoverFrames = {}
end

local function renderMapToMinimap(mapName)
	local mapInfo = MapData.GetByName(mapName)
	if not mapInfo or not mapImage then return end

	clearMapRender()

	-- Floor background
	local floor = Instance.new("Frame")
	floor.AnchorPoint = Vector2.new(0.5, 0.5)
	floor.Position = UDim2.fromScale(0.5, 0.5)
	floor.Size = UDim2.fromScale(0.95, 0.95)
	floor.BackgroundColor3 = mapInfo.ColorPalette and mapInfo.ColorPalette.Primary or Color3.fromRGB(120, 120, 130)
	floor.BackgroundTransparency = 0.6
	floor.BorderSizePixel = 0
	floor.Parent = mapImage
	table.insert(mapCoverFrames, floor)

	-- Cover blocks
	local scale = MINIMAP_SIZE / mapInfo.Dimensions.X  -- approximate pixel-per-stud
	for _, c in ipairs(mapInfo.CoverBlocks or {}) do
		local coverFrame = Instance.new("Frame")
		coverFrame.AnchorPoint = Vector2.new(0.5, 0.5)
		coverFrame.Position = UDim2.new(0.5, c.pos.X * scale, 0.5, -c.pos.Z * scale)  -- Z inverted for screen
		coverFrame.Size = UDim2.fromOffset(c.size.X * scale, c.size.Z * scale)
		coverFrame.BackgroundColor3 = mapInfo.ColorPalette.Secondary or Color3.fromRGB(140, 100, 70)
		coverFrame.BackgroundTransparency = 0.3
		coverFrame.BorderSizePixel = 0
		coverFrame.Parent = mapImage
		table.insert(mapCoverFrames, coverFrame)
	end

	-- Sites (A/B labels)
	for siteName, site in pairs(mapInfo.Sites or {}) do
		local siteFrame = Instance.new("Frame")
		siteFrame.AnchorPoint = Vector2.new(0.5, 0.5)
		siteFrame.Position = UDim2.new(0.5, site.PlantArea.X * scale, 0.5, -site.PlantArea.Z * scale)
		siteFrame.Size = UDim2.fromOffset(site.Radius * 2 * scale, site.Radius * 2 * scale)
		siteFrame.BackgroundColor3 = Color3.fromRGB(255, 100, 80)
		siteFrame.BackgroundTransparency = 0.6
		siteFrame.BorderSizePixel = 0
		local sCorner = Instance.new("UICorner")
		sCorner.CornerRadius = UDim.new(1, 0)
		sCorner.Parent = siteFrame

		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.Text = siteName
		label.TextColor3 = Color3.fromRGB(255, 220, 200)
		label.Font = Enum.Font.GothamBlack
		label.TextSize = 14
		label.Parent = siteFrame

		siteFrame.Parent = mapImage
		table.insert(mapCoverFrames, siteFrame)
	end
end

local function getOrCreateTeammateDot(player)
	if teammateDots[player] and teammateDots[player].Parent then return teammateDots[player] end
	local dot = Instance.new("Frame")
	dot.Name = "TM_" .. player.Name
	dot.AnchorPoint = Vector2.new(0.5, 0.5)
	dot.Size = UDim2.fromOffset(10, 10)
	dot.BorderSizePixel = 0
	dot.BackgroundColor3 = Color3.fromRGB(80, 220, 120)
	dot.ZIndex = 8
	dot.Parent = minimapFrame
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(1, 0)
	c.Parent = dot
	teammateDots[player] = dot
	return dot
end

local function removeTeammateDot(player)
	if teammateDots[player] then
		teammateDots[player]:Destroy()
		teammateDots[player] = nil
	end
end

local function updateMinimap()
	local character = LocalPlayer.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	-- Center mapImage to local player position
	local mapInfo = MapData.GetByName(currentMapName)
	if not mapInfo then return end
	local scale = MINIMAP_SIZE / mapInfo.Dimensions.X
	local centerX = -hrp.Position.X * scale
	local centerY = hrp.Position.Z * scale
	mapImage.Position = UDim2.new(0.5, centerX, 0.5, centerY)

	-- Rotate map to match player orientation
	local lookVec = hrp.CFrame.LookVector
	local yaw = math.atan2(lookVec.X, lookVec.Z)
	mapImage.Rotation = math.deg(yaw)

	-- Update teammates (only same team)
	local seen = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Team == LocalPlayer.Team then
			local pchar = player.Character
			if pchar then
				local phrp = pchar:FindFirstChild("HumanoidRootPart")
				if phrp then
					local dot = getOrCreateTeammateDot(player)
					-- Position in mapImage local space
					local px = phrp.Position.X * scale
					local py = -phrp.Position.Z * scale
					dot.Position = UDim2.new(0.5, px + centerX, 0.5, py + centerY)
					dot.BackgroundColor3 = (pchar:FindFirstChildOfClass("Humanoid") and pchar:FindFirstChildOfClass("Humanoid").Health > 0)
						and Color3.fromRGB(80, 220, 120) or Color3.fromRGB(80, 80, 90)
					seen[player] = true
				end
			end
		end
	end
	-- Remove stale dots
	for player, _ in pairs(teammateDots) do
		if not seen[player] then removeTeammateDot(player) end
	end

	-- Spike indicator
	local spike = Workspace:FindFirstChild("Spike")
	if spike then
		spikeIndicator.Visible = true
		local sx = spike.Position.X * scale
		local sy = -spike.Position.Z * scale
		spikeIndicator.Position = UDim2.new(0.5, sx + centerX, 0.5, sy + centerY)
		-- Pulse if planted
		local t = tick() * 4
		spikeIndicator.BackgroundColor3 = Color3.fromRGB(255, 80 + math.abs(math.sin(t)) * 60, 30)
	else
		spikeIndicator.Visible = false
	end
end

function MinimapController.SetMap(mapName)
	currentMapName = mapName
	renderMapToMinimap(mapName)
end

function MinimapController.Start()
	buildGui()
	renderMapToMinimap(currentMapName)

	task.spawn(function()
		while true do
			updateMinimap()
			task.wait(UPDATE_RATE)
		end
	end)

	-- Listen for map changes (could be fired by server on rotation — for now check workspace)
	-- Workspace.ActiveMap folder gets created on each new map; we could read attribute
	task.spawn(function()
		while true do
			task.wait(2)
			local activeMap = Workspace:FindFirstChild("ActiveMap")
			if activeMap then
				local attrMap = activeMap:GetAttribute("MapName")
				if attrMap and attrMap ~= currentMapName then
					MinimapController.SetMap(attrMap)
				end
			end
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		removeTeammateDot(player)
	end)
end

return MinimapController
