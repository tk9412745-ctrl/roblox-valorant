-- SpikeUrgencyController: red pulsing screen edge gdy spike timer < 10s

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local SpikeUrgencyController = {}

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local gui
local edge  -- frame z red border
local spikeActive = false
local timeRemaining = 0

local function buildGui()
	gui = Instance.new("ScreenGui")
	gui.Name = "SpikeUrgency"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = PlayerGui

	-- 4 red edge frames (top/bottom/left/right)
	for _, side in ipairs({
		{ pos = UDim2.new(0, 0, 0, 0),       size = UDim2.new(1, 0, 0, 60), anchor = Vector2.new(0, 0) },     -- top
		{ pos = UDim2.new(0, 0, 1, 0),       size = UDim2.new(1, 0, 0, 60), anchor = Vector2.new(0, 1) },     -- bottom
		{ pos = UDim2.new(0, 0, 0, 0),       size = UDim2.new(0, 60, 1, 0), anchor = Vector2.new(0, 0) },     -- left
		{ pos = UDim2.new(1, 0, 0, 0),       size = UDim2.new(0, 60, 1, 0), anchor = Vector2.new(1, 0) },     -- right
	}) do
		local frame = Instance.new("Frame")
		frame.AnchorPoint = side.anchor
		frame.Position = side.pos
		frame.Size = side.size
		frame.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.Parent = gui
		local gradient = Instance.new("UIGradient")
		-- Edge fades from opaque (at edge) to transparent (toward center)
		gradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1),
		})
		if side.anchor.Y == 1 then
			gradient.Rotation = 90  -- bottom fades upward
		elseif side.anchor.Y == 0 and side.size.Y.Scale > 0 then
			gradient.Rotation = -90
		elseif side.anchor.X == 1 then
			gradient.Rotation = 180
		else
			gradient.Rotation = 0
		end
		gradient.Parent = frame
	end
end

local function setUrgency(intensity)
	if not gui then return end
	for _, child in ipairs(gui:GetChildren()) do
		if child:IsA("Frame") then
			child.BackgroundTransparency = 1 - intensity
		end
	end
end

function SpikeUrgencyController.Start()
	buildGui()

	Remotes.SpikeStateChanged.OnClientEvent:Connect(function(newState)
		if newState == "Planted" then
			spikeActive = true
			timeRemaining = 45  -- spike timer
		else
			spikeActive = false
			timeRemaining = 0
			setUrgency(0)
		end
	end)

	-- Tick urgency based on round timer (during Spike phase, round timer becomes spike timer)
	Remotes.UpdateRoundTimer.OnClientEvent:Connect(function(phase, remaining)
		if spikeActive and remaining and remaining > 0 then
			timeRemaining = remaining
		end
	end)

	-- Pulse animation
	RunService.RenderStepped:Connect(function(dt)
		if not spikeActive then return end
		if timeRemaining > 10 then
			setUrgency(0)
			return
		end
		-- Pulse intensity based on time remaining (closer to 0 = more intense)
		local urgencyBase = 1 - (timeRemaining / 10)  -- 0 to 1
		local pulse = math.abs(math.sin(tick() * (3 + urgencyBase * 6)))  -- faster pulse near end
		local intensity = urgencyBase * 0.4 + pulse * 0.3 * urgencyBase
		setUrgency(math.min(intensity, 0.8))
	end)
end

return SpikeUrgencyController
