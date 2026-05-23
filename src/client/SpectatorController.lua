-- SpectatorController: po śmierci → spectate living teammates (Q/E switch)
-- Pokazuje "SPECTATING: name" + ich HP w UI

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local SpectatorController = {}

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

local spectating = false
local currentTarget  -- Player
local targetIndex = 1
local spectatorGui
local connection
local DEATH_CAM_DURATION = 3  -- killcam first, then spectator

local function buildGui()
	spectatorGui = Instance.new("ScreenGui")
	spectatorGui.Name = "SpectatorMode"
	spectatorGui.ResetOnSpawn = false
	spectatorGui.IgnoreGuiInset = true
	spectatorGui.Enabled = false
	spectatorGui.Parent = PlayerGui

	-- Top banner
	local banner = Instance.new("Frame")
	banner.AnchorPoint = Vector2.new(0.5, 0)
	banner.Position = UDim2.new(0.5, 0, 0, 220)
	banner.Size = UDim2.fromOffset(500, 60)
	banner.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	banner.BackgroundTransparency = 0.4
	banner.BorderSizePixel = 0
	banner.Parent = spectatorGui
	local bCorner = Instance.new("UICorner")
	bCorner.CornerRadius = UDim.new(0, 8)
	bCorner.Parent = banner

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 26)
	title.BackgroundTransparency = 1
	title.Text = "SPECTATING"
	title.TextColor3 = Color3.fromRGB(200, 200, 220)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 14
	title.Parent = banner

	local targetName = Instance.new("TextLabel")
	targetName.Name = "TargetName"
	targetName.Position = UDim2.fromOffset(0, 24)
	targetName.Size = UDim2.new(1, 0, 0, 30)
	targetName.BackgroundTransparency = 1
	targetName.Text = "?"
	targetName.TextColor3 = Color3.fromRGB(255, 220, 80)
	targetName.Font = Enum.Font.GothamBlack
	targetName.TextSize = 22
	targetName.Parent = banner

	-- Bottom hint
	local hint = Instance.new("TextLabel")
	hint.AnchorPoint = Vector2.new(0.5, 1)
	hint.Position = UDim2.new(0.5, 0, 1, -130)
	hint.Size = UDim2.fromOffset(400, 24)
	hint.BackgroundTransparency = 1
	hint.Text = "[Q] PREVIOUS  •  [E] NEXT"
	hint.TextColor3 = Color3.fromRGB(180, 180, 200)
	hint.Font = Enum.Font.GothamBold
	hint.TextSize = 14
	hint.Parent = spectatorGui

	-- Bottom HP indicator
	local hpBg = Instance.new("Frame")
	hpBg.Name = "HPBg"
	hpBg.AnchorPoint = Vector2.new(0.5, 1)
	hpBg.Position = UDim2.new(0.5, 0, 1, -90)
	hpBg.Size = UDim2.fromOffset(400, 16)
	hpBg.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	hpBg.BackgroundTransparency = 0.3
	hpBg.BorderSizePixel = 0
	hpBg.Parent = spectatorGui
	local hpCorner = Instance.new("UICorner")
	hpCorner.CornerRadius = UDim.new(0, 4)
	hpCorner.Parent = hpBg

	local hpBar = Instance.new("Frame")
	hpBar.Name = "HPBar"
	hpBar.Size = UDim2.fromScale(1, 1)
	hpBar.BackgroundColor3 = Color3.fromRGB(80, 220, 120)
	hpBar.BorderSizePixel = 0
	hpBar.Parent = hpBg
end

local function getLivingTeammates()
	local result = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Team == LocalPlayer.Team and p.Character then
			local hum = p.Character:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 then
				table.insert(result, p)
			end
		end
	end
	return result
end

local function updateCamera()
	if not currentTarget or not currentTarget.Character then return end
	local hrp = currentTarget.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	-- Third-person camera following target
	local lookDir = hrp.CFrame.LookVector
	local camPos = hrp.Position - lookDir * 10 + Vector3.new(0, 4, 0)
	camera.CFrame = CFrame.lookAt(camPos, hrp.Position + Vector3.new(0, 1, 0))

	-- Update UI
	if spectatorGui then
		local nameLbl = spectatorGui:FindFirstChild("TargetName", true)
		if nameLbl then nameLbl.Text = currentTarget.Name end
		local hpBg = spectatorGui:FindFirstChild("HPBg")
		if hpBg then
			local hpBar = hpBg:FindFirstChild("HPBar")
			local hum = currentTarget.Character:FindFirstChildOfClass("Humanoid")
			if hpBar and hum then
				hpBar.Size = UDim2.fromScale(math.max(0, hum.Health / hum.MaxHealth), 1)
				if hum.Health < 30 then hpBar.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
				elseif hum.Health < 70 then hpBar.BackgroundColor3 = Color3.fromRGB(255, 200, 80)
				else hpBar.BackgroundColor3 = Color3.fromRGB(80, 220, 120) end
			end
		end
	end
end

local function cycleTarget(direction)
	local teammates = getLivingTeammates()
	if #teammates == 0 then
		-- No teammates alive — end spectating
		SpectatorController.Stop()
		return
	end

	targetIndex = ((targetIndex - 1 + direction) % #teammates) + 1
	currentTarget = teammates[targetIndex]
end

function SpectatorController.Start()
	if spectating then return end
	spectating = true

	if not spectatorGui then buildGui() end
	spectatorGui.Enabled = true
	camera.CameraType = Enum.CameraType.Scriptable

	-- Wait for kill cam, then start cycling
	task.delay(DEATH_CAM_DURATION, function()
		if not spectating then return end
		targetIndex = 1
		local teammates = getLivingTeammates()
		if #teammates > 0 then
			currentTarget = teammates[1]
		else
			SpectatorController.Stop()
			return
		end

		connection = RunService.RenderStepped:Connect(updateCamera)
	end)
end

function SpectatorController.Stop()
	if not spectating then return end
	spectating = false
	if spectatorGui then spectatorGui.Enabled = false end
	camera.CameraType = Enum.CameraType.Custom
	if connection then
		connection:Disconnect()
		connection = nil
	end
	currentTarget = nil
end

function SpectatorController.StartListening()
	buildGui()

	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if not spectating then return end
		if input.KeyCode == Enum.KeyCode.E then
			cycleTarget(1)
		elseif input.KeyCode == Enum.KeyCode.Q then
			cycleTarget(-1)
		end
	end)

	-- On character death → start spectating
	LocalPlayer.CharacterAdded:Connect(function(character)
		-- Stop any active spectating (we have a new char)
		SpectatorController.Stop()

		local humanoid = character:WaitForChild("Humanoid")
		humanoid.Died:Connect(function()
			SpectatorController.Start()
		end)
	end)
	if LocalPlayer.Character then
		local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.Died:Connect(function()
				SpectatorController.Start()
			end)
		end
	end

	-- Stop on round phase change (respawn)
	Remotes.RoundPhaseChanged.OnClientEvent:Connect(function(phase)
		if phase == "BuyPhase" then
			SpectatorController.Stop()
		end
	end)
end

return SpectatorController
