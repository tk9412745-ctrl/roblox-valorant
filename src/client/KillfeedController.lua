-- KillfeedController: top-right kill notifications (killer → weapon → victim)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local KillfeedController = {}

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local gui
local container
local MAX_ENTRIES = 6
local ENTRY_LIFETIME = 6

local function buildGui()
	gui = Instance.new("ScreenGui")
	gui.Name = "Killfeed"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = PlayerGui

	container = Instance.new("Frame")
	container.Name = "Container"
	container.Size = UDim2.fromOffset(380, 300)
	container.Position = UDim2.new(1, -400, 0, 130)
	container.BackgroundTransparency = 1
	container.Parent = gui

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 4)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	layout.VerticalAlignment = Enum.VerticalAlignment.Top
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = container
end

local entryCounter = 0
local function addEntry(killerName, weaponName, victimName, killerTeam, victimTeam, isHeadshot)
	if not container then return end
	entryCounter += 1
	local sortOrder = entryCounter

	-- Remove oldest if too many
	local kids = container:GetChildren()
	local entries = {}
	for _, k in ipairs(kids) do
		if k:IsA("Frame") then table.insert(entries, k) end
	end
	if #entries >= MAX_ENTRIES then
		entries[1]:Destroy()
	end

	local entry = Instance.new("Frame")
	entry.Name = "Entry"
	entry.LayoutOrder = -sortOrder
	entry.Size = UDim2.fromOffset(380, 32)
	entry.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	entry.BackgroundTransparency = 0.5
	entry.BorderSizePixel = 0
	entry.Parent = container

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = entry

	-- Killer side accent (team color)
	local killerColor = killerTeam == "Attackers" and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(80, 120, 255)
	local victimColor = victimTeam == "Attackers" and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(80, 120, 255)

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 6)
	layout.Parent = entry
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 10)
	pad.PaddingRight = UDim.new(0, 10)
	pad.Parent = entry

	local function addText(text, color, size, layoutOrder)
		local lbl = Instance.new("TextLabel")
		lbl.LayoutOrder = layoutOrder
		lbl.AutomaticSize = Enum.AutomaticSize.X
		lbl.Size = UDim2.fromOffset(0, 32)
		lbl.BackgroundTransparency = 1
		lbl.Text = text
		lbl.TextColor3 = color
		lbl.Font = Enum.Font.GothamBold
		lbl.TextSize = size or 16
		lbl.Parent = entry
		return lbl
	end

	addText(killerName or "?", killerColor, 16, 1)
	addText(" ▸ ", Color3.fromRGB(200, 200, 200), 16, 2)
	if isHeadshot then
		addText("🎯", Color3.fromRGB(255, 200, 80), 18, 3)
	else
		addText("[" .. (weaponName or "?") .. "]", Color3.fromRGB(200, 200, 200), 14, 3)
	end
	addText(" ▸ ", Color3.fromRGB(200, 200, 200), 16, 4)
	addText(victimName or "?", victimColor, 16, 5)

	-- Fade out + destroy after lifetime
	task.delay(ENTRY_LIFETIME, function()
		if not entry.Parent then return end
		local tween = TweenService:Create(entry, TweenInfo.new(0.5), {
			BackgroundTransparency = 1,
		})
		tween:Play()
		for _, child in ipairs(entry:GetChildren()) do
			if child:IsA("TextLabel") then
				TweenService:Create(child, TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
			end
		end
		tween.Completed:Wait()
		entry:Destroy()
	end)
end

function KillfeedController.Start()
	buildGui()

	Remotes.WeaponFired.OnClientEvent  -- already listened by VFXController, just hook killfeed via separate event

	-- We hook a dedicated KillFeed remote if available
	local killFeed = ReplicatedStorage:WaitForChild("Remotes"):FindFirstChild("KillFeed")
	if killFeed then
		killFeed.OnClientEvent:Connect(function(killerName, weaponName, victimName, killerTeam, victimTeam, isHeadshot)
			addEntry(killerName, weaponName, victimName, killerTeam, victimTeam, isHeadshot)
		end)
	end
end

return KillfeedController
