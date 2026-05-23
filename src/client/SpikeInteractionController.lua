-- SpikeInteractionController: E to plant/defuse, prompt UI, circular progress

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local SpikeInteractionController = {}

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local gui
local promptLabel
local progressFrame
local progressFill
local progressLabel
local interactStatus  -- { type, progress, duration }
local isHoldingE = false
local sentRequest = false
local cancelDistance = 5

local function buildGui()
	gui = Instance.new("ScreenGui")
	gui.Name = "SpikeInteraction"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = PlayerGui

	-- Prompt label (E to plant/defuse/pickup)
	promptLabel = Instance.new("TextLabel")
	promptLabel.Name = "Prompt"
	promptLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	promptLabel.Position = UDim2.new(0.5, 0, 0.65, 0)
	promptLabel.Size = UDim2.fromOffset(400, 50)
	promptLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	promptLabel.BackgroundTransparency = 0.4
	promptLabel.Text = "[E] PLANT"
	promptLabel.TextColor3 = Color3.fromRGB(255, 220, 80)
	promptLabel.Font = Enum.Font.GothamBold
	promptLabel.TextSize = 22
	promptLabel.Visible = false
	promptLabel.Parent = gui
	local pCorner = Instance.new("UICorner")
	pCorner.CornerRadius = UDim.new(0, 6)
	pCorner.Parent = promptLabel

	-- Circular progress bar
	progressFrame = Instance.new("Frame")
	progressFrame.Name = "ProgressBar"
	progressFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	progressFrame.Position = UDim2.new(0.5, 0, 0.7, 0)
	progressFrame.Size = UDim2.fromOffset(200, 200)
	progressFrame.BackgroundTransparency = 1
	progressFrame.Visible = false
	progressFrame.Parent = gui

	-- Background ring
	local bgRing = Instance.new("Frame")
	bgRing.Size = UDim2.fromScale(1, 1)
	bgRing.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	bgRing.BackgroundTransparency = 0.4
	bgRing.BorderSizePixel = 0
	bgRing.Parent = progressFrame
	local bgCorner = Instance.new("UICorner")
	bgCorner.CornerRadius = UDim.new(1, 0)
	bgCorner.Parent = bgRing

	-- Foreground "fill" — approximated by an outer ring with UIStroke
	progressFill = Instance.new("UIStroke")
	progressFill.Thickness = 8
	progressFill.Color = Color3.fromRGB(255, 200, 80)
	progressFill.Transparency = 0.1
	progressFill.Parent = bgRing
	-- Note: Roblox doesn't have native arc-fill; we simulate with a custom approach via gradient
	-- Simplified: use a separate "filled segment" frame that rotates/grows

	-- Center label
	progressLabel = Instance.new("TextLabel")
	progressLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	progressLabel.Position = UDim2.fromScale(0.5, 0.5)
	progressLabel.Size = UDim2.fromOffset(180, 60)
	progressLabel.BackgroundTransparency = 1
	progressLabel.Text = "PLANTING"
	progressLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	progressLabel.TextStrokeTransparency = 0
	progressLabel.Font = Enum.Font.GothamBlack
	progressLabel.TextSize = 22
	progressLabel.Parent = progressFrame

	-- Percent label below
	local percentLbl = Instance.new("TextLabel")
	percentLbl.Name = "Percent"
	percentLbl.AnchorPoint = Vector2.new(0.5, 0)
	percentLbl.Position = UDim2.fromScale(0.5, 0.55)
	percentLbl.Size = UDim2.fromOffset(180, 30)
	percentLbl.BackgroundTransparency = 1
	percentLbl.Text = "0%"
	percentLbl.TextColor3 = Color3.fromRGB(255, 220, 80)
	percentLbl.Font = Enum.Font.GothamBold
	percentLbl.TextSize = 18
	percentLbl.Parent = progressFrame
end

local function findSpike()
	return Workspace:FindFirstChild("Spike")
end

local function isInPlantArea(position)
	local activeMap = Workspace:FindFirstChild("ActiveMap")
	if not activeMap then return nil end
	for _, child in ipairs(activeMap:GetChildren()) do
		if child:IsA("BasePart") and child:GetAttribute("PlantArea") then
			local dist = (position - child.Position).Magnitude
			if dist <= (child.Size.X + child.Size.Z) / 2 then
				return child
			end
		end
	end
	return nil
end

local function updatePrompt()
	if not promptLabel then return end
	local character = LocalPlayer.Character
	if not character then promptLabel.Visible = false; return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then promptLabel.Visible = false; return end

	local spike = findSpike()
	local team = LocalPlayer.Team and LocalPlayer.Team.Name

	local promptText = nil

	-- If spike planted and player is defender, show defuse prompt if near
	if spike and spike:GetAttribute("Planted") then
		if team == "Defenders" and (hrp.Position - spike.Position).Magnitude < cancelDistance then
			promptText = "[E] DEFUSE"
		end
	elseif spike then
		-- Spike dropped or carried
		if team == "Attackers" then
			local carriedBy = spike:GetAttribute("CarriedBy")
			if not carriedBy then
				-- Dropped: pickup prompt
				if (hrp.Position - spike.Position).Magnitude < 8 then
					promptText = "[E] PICK UP SPIKE"
				end
			elseif carriedBy == LocalPlayer.UserId then
				-- Player carries it — show plant prompt if in plant area
				if isInPlantArea(hrp.Position) then
					promptText = "[E] PLANT SPIKE"
				end
			end
		end
	end

	if promptText then
		promptLabel.Text = promptText
		promptLabel.Visible = true
	else
		promptLabel.Visible = false
	end
end

local function updateProgress()
	if not interactStatus then
		if progressFrame then progressFrame.Visible = false end
		return
	end
	progressFrame.Visible = true

	local pct = math.clamp(interactStatus.progress, 0, 1)
	local percentLbl = progressFrame:FindFirstChild("Percent")
	if percentLbl then percentLbl.Text = string.format("%d%%", math.floor(pct * 100)) end

	-- Animate stroke transparency (visual progress hack)
	if interactStatus.type == "plant" then
		progressLabel.Text = "PLANTING"
		progressFill.Color = Color3.fromRGB(255, 180, 60)
	elseif interactStatus.type == "defuse" then
		progressLabel.Text = "DEFUSING"
		progressFill.Color = Color3.fromRGB(80, 200, 255)
	end

	-- Pulse effect for stroke
	progressFill.Thickness = 8 + math.sin(tick() * 8) * 2
end

local function onKeyE(state)
	isHoldingE = state
	if not state then
		-- Cancel interaction
		if sentRequest then
			Remotes.CancelInteract:FireServer()
			sentRequest = false
		end
		interactStatus = nil
		return
	end

	if sentRequest then return end  -- already requested
	if not promptLabel or not promptLabel.Visible then return end

	local promptText = promptLabel.Text
	if promptText:find("PLANT") then
		Remotes.RequestPlant:FireServer()
		sentRequest = true
	elseif promptText:find("DEFUSE") then
		Remotes.RequestDefuse:FireServer()
		sentRequest = true
	elseif promptText:find("PICK UP") then
		-- Pickup is auto via Touched event on server when player walks near; just send to be sure
		-- (SpikeController would need a RequestPickup remote — for now, walking on it is enough)
	end
end

function SpikeInteractionController.Start()
	buildGui()

	-- E key
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.E then
			onKeyE(true)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.E then
			onKeyE(false)
		end
	end)

	-- Progress updates from server
	Remotes.InteractProgress.OnClientEvent:Connect(function(interactType, current, duration)
		if interactType == "cancel" then
			interactStatus = nil
			sentRequest = false
			return
		end
		interactStatus = {
			type = interactType,
			progress = current,
			duration = duration,
		}
		if current >= 1 then
			-- Completed
			interactStatus = nil
			sentRequest = false
		end
	end)

	-- Spike state change
	Remotes.SpikeStateChanged.OnClientEvent:Connect(function(newState, extra)
		if newState == "Planted" then
			-- Mark spike as planted attribute (for prompt detection)
			local spike = Workspace:FindFirstChild("Spike")
			if spike then spike:SetAttribute("Planted", true) end
		elseif newState == "Defused" or newState == "Detonated" then
			interactStatus = nil
			sentRequest = false
		end
	end)

	RunService.Heartbeat:Connect(function()
		updatePrompt()
		updateProgress()
	end)
end

return SpikeInteractionController
