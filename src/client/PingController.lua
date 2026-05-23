-- PingController: Z/T/G/H hotkeys → ping na crosshair → wszyscy teammates widzą

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local PingController = {}

local LocalPlayer = Players.LocalPlayer
local PING_BINDINGS = {
	[Enum.KeyCode.Z] = "Default",
	[Enum.KeyCode.T] = "Danger",
	[Enum.KeyCode.G] = "Push",
	[Enum.KeyCode.H] = "Backup",
}

local PING_COLORS = {
	Default = Color3.fromRGB(255, 220, 80),
	Danger = Color3.fromRGB(255, 60, 60),
	Push = Color3.fromRGB(80, 220, 120),
	Backup = Color3.fromRGB(80, 120, 255),
}

local PING_LABELS = {
	Default = "WATCHING",
	Danger = "DANGER",
	Push = "GO HERE",
	Backup = "NEED BACKUP",
}

local function getCrosshairWorldHit()
	local camera = workspace.CurrentCamera
	local origin = camera.CFrame.Position
	local direction = camera.CFrame.LookVector * 500
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = { LocalPlayer.Character }
	params.FilterType = Enum.RaycastFilterType.Exclude
	local result = workspace:Raycast(origin, direction, params)
	if result then return result.Position end
	return origin + direction
end

local function spawnPingMarker(playerName, position, pingType)
	local color = PING_COLORS[pingType] or PING_COLORS.Default
	local labelText = PING_LABELS[pingType] or "PING"

	local anchor = Instance.new("Part")
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.Transparency = 1
	anchor.Size = Vector3.new(0.1, 0.1, 0.1)
	anchor.Position = position + Vector3.new(0, 0.5, 0)
	anchor.Parent = Workspace

	-- Visual marker (diamond pulsing)
	local marker = Instance.new("Part")
	marker.Shape = Enum.PartType.Ball
	marker.Size = Vector3.new(1, 1, 1)
	marker.Position = position + Vector3.new(0, 1, 0)
	marker.Anchored = true
	marker.CanCollide = false
	marker.Color = color
	marker.Material = Enum.Material.Neon
	marker.Transparency = 0.2
	marker.Parent = anchor

	-- Floating BillboardGui above
	local bg = Instance.new("BillboardGui")
	bg.AlwaysOnTop = true
	bg.Size = UDim2.fromOffset(220, 60)
	bg.StudsOffset = Vector3.new(0, 3, 0)
	bg.Parent = anchor

	local container = Instance.new("Frame")
	container.Size = UDim2.fromScale(1, 1)
	container.BackgroundTransparency = 1
	container.Parent = bg

	local labelLbl = Instance.new("TextLabel")
	labelLbl.Size = UDim2.new(1, 0, 0, 28)
	labelLbl.BackgroundTransparency = 1
	labelLbl.Text = labelText
	labelLbl.TextColor3 = color
	labelLbl.TextStrokeTransparency = 0
	labelLbl.Font = Enum.Font.GothamBlack
	labelLbl.TextSize = 20
	labelLbl.Parent = container

	local fromLbl = Instance.new("TextLabel")
	fromLbl.Position = UDim2.fromOffset(0, 30)
	fromLbl.Size = UDim2.new(1, 0, 0, 22)
	fromLbl.BackgroundTransparency = 1
	fromLbl.Text = "from " .. playerName
	fromLbl.TextColor3 = Color3.fromRGB(220, 220, 240)
	fromLbl.TextStrokeTransparency = 0.5
	fromLbl.Font = Enum.Font.Gotham
	fromLbl.TextSize = 14
	fromLbl.Parent = container

	-- Pulse animation
	task.spawn(function()
		local startTime = tick()
		while marker.Parent do
			local t = tick() - startTime
			marker.Size = Vector3.new(1, 1, 1) * (1 + math.sin(t * 4) * 0.2)
			task.wait(0.05)
		end
	end)

	-- Fade out after 5s
	task.delay(5, function()
		if not anchor.Parent then return end
		TweenService:Create(marker, TweenInfo.new(0.5), { Transparency = 1 }):Play()
		TweenService:Create(labelLbl, TweenInfo.new(0.5), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
		TweenService:Create(fromLbl, TweenInfo.new(0.5), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
		task.wait(0.5)
		anchor:Destroy()
	end)

	Debris:AddItem(anchor, 6)
end

function PingController.Start()
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		local pingType = PING_BINDINGS[input.KeyCode]
		if pingType then
			local position = getCrosshairWorldHit()
			Remotes.SendPing:FireServer(position, pingType)
		end
	end)

	Remotes.PingReceived.OnClientEvent:Connect(function(playerName, position, pingType)
		spawnPingMarker(playerName, position, pingType)
	end)
end

return PingController
