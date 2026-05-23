-- LowHPController: red vignette pulsing przy HP < 30, faster pulse closer to 0

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LowHPController = {}

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local gui
local vignettes = {}  -- 4 edge frames

local function buildGui()
	gui = Instance.new("ScreenGui")
	gui.Name = "LowHPVignette"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = PlayerGui

	-- 4 edge frames with gradient (similar to SpikeUrgency but red)
	for _, side in ipairs({
		{ pos = UDim2.new(0, 0, 0, 0), size = UDim2.new(1, 0, 0, 100), anchor = Vector2.new(0, 0), rot = -90 },
		{ pos = UDim2.new(0, 0, 1, 0), size = UDim2.new(1, 0, 0, 100), anchor = Vector2.new(0, 1), rot = 90 },
		{ pos = UDim2.new(0, 0, 0, 0), size = UDim2.new(0, 100, 1, 0), anchor = Vector2.new(0, 0), rot = 0 },
		{ pos = UDim2.new(1, 0, 0, 0), size = UDim2.new(0, 100, 1, 0), anchor = Vector2.new(1, 0), rot = 180 },
	}) do
		local frame = Instance.new("Frame")
		frame.AnchorPoint = side.anchor
		frame.Position = side.pos
		frame.Size = side.size
		frame.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.Parent = gui
		local gradient = Instance.new("UIGradient")
		gradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1),
		})
		gradient.Rotation = side.rot
		gradient.Parent = frame
		table.insert(vignettes, frame)
	end
end

function LowHPController.Start()
	buildGui()

	RunService.RenderStepped:Connect(function(dt)
		local character = LocalPlayer.Character
		if not character then
			for _, v in ipairs(vignettes) do v.BackgroundTransparency = 1 end
			return
		end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then
			for _, v in ipairs(vignettes) do v.BackgroundTransparency = 1 end
			return
		end

		local hpPct = humanoid.Health / humanoid.MaxHealth
		if hpPct > 0.4 then
			for _, v in ipairs(vignettes) do v.BackgroundTransparency = 1 end
			return
		end

		-- Pulse rate scales with how low HP is
		local urgency = 1 - (hpPct / 0.4)  -- 0 to 1
		local pulseSpeed = 3 + urgency * 5  -- 3-8 Hz
		local pulse = math.abs(math.sin(tick() * pulseSpeed))
		local intensity = urgency * 0.4 + pulse * 0.3 * urgency
		for _, v in ipairs(vignettes) do
			v.BackgroundTransparency = math.max(0.2, 1 - intensity)
		end
	end)
end

return LowHPController
