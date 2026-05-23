-- MatchUIController: score HUD (top center), round end, match end, halftime, round timer

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local MatchUIController = {}

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local gui
local scoreLabel
local timerLabel
local phaseLabel
local roundIndicator
local notificationLabel

local attackerScore = 0
local defenderScore = 0
local currentPhase = "PreMatch"
local currentRound = 0

local function buildUI()
	gui = Instance.new("ScreenGui")
	gui.Name = "MatchUI"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = PlayerGui

	-- Score bar (top center)
	local scoreBar = Instance.new("Frame")
	scoreBar.Name = "ScoreBar"
	scoreBar.Size = UDim2.fromOffset(400, 60)
	scoreBar.Position = UDim2.new(0.5, -200, 0, 8)
	scoreBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	scoreBar.BackgroundTransparency = 0.2
	scoreBar.BorderSizePixel = 0
	scoreBar.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = scoreBar

	local atkScore = Instance.new("TextLabel")
	atkScore.Name = "AttackerScore"
	atkScore.Size = UDim2.new(0.3, 0, 1, 0)
	atkScore.Position = UDim2.fromOffset(0, 0)
	atkScore.BackgroundTransparency = 1
	atkScore.Text = "0"
	atkScore.TextColor3 = Color3.fromRGB(255, 80, 80)
	atkScore.Font = Enum.Font.GothamBlack
	atkScore.TextSize = 32
	atkScore.Parent = scoreBar

	local defScore = Instance.new("TextLabel")
	defScore.Name = "DefenderScore"
	defScore.Size = UDim2.new(0.3, 0, 1, 0)
	defScore.Position = UDim2.fromScale(0.7, 0)
	defScore.BackgroundTransparency = 1
	defScore.Text = "0"
	defScore.TextColor3 = Color3.fromRGB(80, 120, 255)
	defScore.Font = Enum.Font.GothamBlack
	defScore.TextSize = 32
	defScore.Parent = scoreBar

	local centerLabel = Instance.new("TextLabel")
	centerLabel.Name = "CenterLabel"
	centerLabel.Size = UDim2.new(0.4, 0, 1, 0)
	centerLabel.Position = UDim2.fromScale(0.3, 0)
	centerLabel.BackgroundTransparency = 1
	centerLabel.Text = "0:00"
	centerLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
	centerLabel.Font = Enum.Font.GothamBold
	centerLabel.TextSize = 22
	centerLabel.Parent = scoreBar
	timerLabel = centerLabel

	-- Phase label (above score)
	local phaseLbl = Instance.new("TextLabel")
	phaseLbl.Name = "Phase"
	phaseLbl.Size = UDim2.fromOffset(200, 24)
	phaseLbl.Position = UDim2.new(0.5, -100, 0, 72)
	phaseLbl.BackgroundTransparency = 1
	phaseLbl.Text = "PRE-MATCH"
	phaseLbl.TextColor3 = Color3.fromRGB(180, 180, 200)
	phaseLbl.Font = Enum.Font.GothamMedium
	phaseLbl.TextSize = 14
	phaseLbl.Parent = gui
	phaseLabel = phaseLbl

	-- Round indicator
	local roundLbl = Instance.new("TextLabel")
	roundLbl.Name = "RoundIndicator"
	roundLbl.Size = UDim2.fromOffset(120, 20)
	roundLbl.Position = UDim2.new(0.5, -60, 0, 98)
	roundLbl.BackgroundTransparency = 1
	roundLbl.Text = "Round 0"
	roundLbl.TextColor3 = Color3.fromRGB(140, 140, 160)
	roundLbl.Font = Enum.Font.Gotham
	roundLbl.TextSize = 12
	roundLbl.Parent = gui
	roundIndicator = roundLbl

	-- Notification banner (round end, halftime, match end)
	local notif = Instance.new("Frame")
	notif.Name = "Notification"
	notif.Size = UDim2.fromOffset(600, 100)
	notif.Position = UDim2.new(0.5, -300, 0.5, -50)
	notif.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	notif.BackgroundTransparency = 0.3
	notif.BorderSizePixel = 0
	notif.Visible = false
	notif.Parent = gui
	local notifCorner = Instance.new("UICorner")
	notifCorner.CornerRadius = UDim.new(0, 12)
	notifCorner.Parent = notif
	local notifText = Instance.new("TextLabel")
	notifText.Size = UDim2.fromScale(1, 1)
	notifText.BackgroundTransparency = 1
	notifText.Text = ""
	notifText.TextColor3 = Color3.fromRGB(255, 255, 255)
	notifText.Font = Enum.Font.GothamBlack
	notifText.TextSize = 36
	notifText.Parent = notif
	notificationLabel = notifText

	scoreLabel = { atk = atkScore, def = defScore }
end

local function showNotification(text, color, duration)
	if not gui then return end
	local notif = gui:FindFirstChild("Notification")
	if not notif then return end
	notificationLabel.Text = text
	notificationLabel.TextColor3 = color or Color3.fromRGB(255, 255, 255)
	notif.Visible = true
	notif.BackgroundTransparency = 0.3
	task.delay(duration or 3, function()
		if notif then notif.Visible = false end
	end)
end

local function formatTime(seconds)
	seconds = math.max(0, math.floor(seconds))
	local mins = math.floor(seconds / 60)
	local secs = seconds % 60
	return string.format("%d:%02d", mins, secs)
end

function MatchUIController.Start()
	buildUI()

	Remotes.UpdateScore.OnClientEvent:Connect(function(atk, def)
		attackerScore = atk
		defenderScore = def
		if scoreLabel then
			scoreLabel.atk.Text = tostring(atk)
			scoreLabel.def.Text = tostring(def)
		end
	end)

	Remotes.RoundPhaseChanged.OnClientEvent:Connect(function(phase, extraData)
		currentPhase = phase
		if phase == "BuyPhase" then
			phaseLabel.Text = "BUY PHASE"
			phaseLabel.TextColor3 = Color3.fromRGB(255, 200, 80)
		elseif phase == "Round" then
			phaseLabel.Text = "ROUND"
			phaseLabel.TextColor3 = Color3.fromRGB(80, 220, 120)
		elseif phase == "PostRound" then
			phaseLabel.Text = "POST-ROUND"
			phaseLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
		elseif phase == "HalfTime" then
			phaseLabel.Text = "HALFTIME"
			phaseLabel.TextColor3 = Color3.fromRGB(255, 100, 80)
			showNotification("HALFTIME — SWAP SIDES", Color3.fromRGB(255, 100, 80), 5)
		elseif phase == "Overtime" then
			phaseLabel.Text = "OVERTIME"
			phaseLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
			showNotification("OVERTIME", Color3.fromRGB(255, 60, 60), 3)
		elseif phase == "MatchEnd" then
			phaseLabel.Text = "MATCH OVER"
		else
			phaseLabel.Text = phase:upper()
		end

		if extraData and type(extraData) == "table" and extraData.round then
			currentRound = extraData.round
			roundIndicator.Text = "Round " .. currentRound
		end
	end)

	Remotes.UpdateRoundTimer.OnClientEvent:Connect(function(phase, remaining)
		if timerLabel then
			timerLabel.Text = formatTime(remaining)
		end
	end)

	Remotes.RoundEnded.OnClientEvent:Connect(function(winner, reason, round)
		local reasonText = ({
			ATTACKERS_DETONATE = "SPIKE DETONATED",
			ATTACKERS_ELIM = "ATTACKERS ELIMINATED DEFENDERS",
			DEFENDERS_TIME = "TIME EXPIRED",
			DEFENDERS_ELIM = "DEFENDERS ELIMINATED ATTACKERS",
			DEFENDERS_DEFUSE = "SPIKE DEFUSED",
		})[reason] or reason
		local color = winner == "Attackers" and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(80, 120, 255)
		showNotification(winner:upper() .. " WIN — " .. reasonText, color, 5)
	end)

	-- Track match stats for MVP detection
	local matchStatsSnapshot = {}
	Remotes.UpdateMatchStats.OnClientEvent:Connect(function(snapshot)
		matchStatsSnapshot = snapshot or {}
	end)

	Remotes.MatchEnded.OnClientEvent:Connect(function(winner, atk, def)
		local color = winner == "Attackers" and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(80, 120, 255)
		showNotification(winner:upper() .. " WIN THE MATCH (" .. atk .. " — " .. def .. ")", color, 10)

		-- Find match MVP (highest mvps + ACS combination)
		local mvp
		local maxScore = -1
		for _, entry in ipairs(matchStatsSnapshot) do
			local score = (entry.mvps or 0) * 1000 + (entry.acs or 0)
			if score > maxScore then
				maxScore = score
				mvp = entry
			end
		end
		if mvp then
			task.delay(2, function()
				showNotification(
					"★ MATCH MVP: " .. mvp.name .. " (" .. (mvp.mvps or 0) .. " MVPs)",
					Color3.fromRGB(255, 215, 0),
					8
				)
			end)
		end

		-- ====== DRAMATIC MATCH END CELEBRATION ======
		local LocalPlayer = Players.LocalPlayer
		local playerTeam = LocalPlayer.Team and LocalPlayer.Team.Name
		local won = playerTeam == winner

		-- Fullscreen win/lose banner
		local celebrationGui = Instance.new("ScreenGui")
		celebrationGui.Name = "MatchCelebration"
		celebrationGui.IgnoreGuiInset = true
		celebrationGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

		local backdrop = Instance.new("Frame")
		backdrop.Size = UDim2.fromScale(1, 1)
		backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		backdrop.BackgroundTransparency = 0.5
		backdrop.BorderSizePixel = 0
		backdrop.Parent = celebrationGui

		local title = Instance.new("TextLabel")
		title.AnchorPoint = Vector2.new(0.5, 0.5)
		title.Position = UDim2.fromScale(0.5, 0.4)
		title.Size = UDim2.fromOffset(800, 150)
		title.BackgroundTransparency = 1
		title.Text = won and "VICTORY" or "DEFEAT"
		title.TextColor3 = won and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(180, 80, 80)
		title.TextStrokeTransparency = 0.5
		title.Font = Enum.Font.GothamBlack
		title.TextSize = 120
		title.TextTransparency = 1
		title.Parent = backdrop

		local subtitle = Instance.new("TextLabel")
		subtitle.AnchorPoint = Vector2.new(0.5, 0.5)
		subtitle.Position = UDim2.fromScale(0.5, 0.55)
		subtitle.Size = UDim2.fromOffset(700, 40)
		subtitle.BackgroundTransparency = 1
		subtitle.Text = string.format("Final Score: %d — %d", atk, def)
		subtitle.TextColor3 = Color3.fromRGB(220, 220, 240)
		subtitle.Font = Enum.Font.GothamBold
		subtitle.TextSize = 26
		subtitle.TextTransparency = 1
		subtitle.Parent = backdrop

		-- Fade in
		local TweenService = game:GetService("TweenService")
		TweenService:Create(title, TweenInfo.new(0.6, Enum.EasingStyle.Back), {
			TextTransparency = 0,
			Size = UDim2.fromOffset(1000, 200),
		}):Play()
		TweenService:Create(subtitle, TweenInfo.new(0.6), { TextTransparency = 0 }):Play()

		-- Fireworks for winning team (spawn random colored explosions in world)
		if won then
			task.spawn(function()
				for _ = 1, 20 do
					local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					if hrp then
						local pos = hrp.Position + Vector3.new(
							math.random(-30, 30),
							math.random(15, 30),
							math.random(-30, 30)
						)
						local firework = Instance.new("Part")
						firework.Shape = Enum.PartType.Ball
						firework.Size = Vector3.new(2, 2, 2)
						firework.Position = pos
						firework.Anchored = true
						firework.CanCollide = false
						local colors = {
							Color3.fromRGB(255, 100, 100),
							Color3.fromRGB(100, 255, 100),
							Color3.fromRGB(100, 100, 255),
							Color3.fromRGB(255, 220, 80),
							Color3.fromRGB(255, 100, 220),
						}
						firework.Color = colors[math.random(1, #colors)]
						firework.Material = Enum.Material.Neon
						firework.Parent = workspace

						local attach = Instance.new("Attachment")
						attach.Parent = firework
						local emitter = Instance.new("ParticleEmitter")
						emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
						emitter.Lifetime = NumberRange.new(0.5, 1.5)
						emitter.Speed = NumberRange.new(15, 30)
						emitter.SpreadAngle = Vector2.new(180, 180)
						emitter.Color = ColorSequence.new(firework.Color)
						emitter.Size = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 1),
							NumberSequenceKeypoint.new(1, 0),
						})
						emitter.LightEmission = 1
						emitter.Parent = attach
						emitter:Emit(80)

						TweenService:Create(firework, TweenInfo.new(0.5), { Transparency = 1, Size = Vector3.new(8, 8, 8) }):Play()
						game:GetService("Debris"):AddItem(firework, 2)
					end
					task.wait(0.2)
				end
			end)
		end

		-- Auto-remove after 8s
		task.delay(8, function()
			if celebrationGui.Parent then celebrationGui:Destroy() end
		end)
	end)

	Remotes.HalftimeStarted.OnClientEvent:Connect(function()
		showNotification("HALFTIME — SIDES SWAP", Color3.fromRGB(255, 100, 80), 8)
	end)
end

return MatchUIController
