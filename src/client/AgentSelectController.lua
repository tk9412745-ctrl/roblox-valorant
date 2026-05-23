-- AgentSelectController: pre-match modal screen z 3 agent cards + 30s timer + start countdown 5..0

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
local AgentDatabase = require(ReplicatedStorage.Shared:WaitForChild("AgentDatabase"))

local AgentSelectController = {}

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local AGENTS_AVAILABLE = { "Jett", "Sage", "Phoenix", "Cypher", "Reyna", "KAYO", "Sova", "Brimstone", "Viper", "Astra", "Omen", "Killjoy" }
local AGENT_DESCRIPTIONS = {
	Jett = { role = "Duelist", desc = "Wind mobility. Dash + smoke + updraft + 5 knives ult.", color = Color3.fromRGB(100, 200, 220) },
	Sage = { role = "Sentinel", desc = "Healer + wall. Slow orb + heal + resurrect ult.", color = Color3.fromRGB(150, 220, 255) },
	Phoenix = { role = "Duelist", desc = "Fire self-sustain. Wall + flash + molotov + respawn ult.", color = Color3.fromRGB(255, 120, 60) },
	Cypher = { role = "Sentinel", desc = "Tripwire + cage + reveal. Map-wide detection ult.", color = Color3.fromRGB(255, 100, 200) },
	Reyna = { role = "Duelist", desc = "Solo carry. Soul orbs from kills. Empress frenzy ult.", color = Color3.fromRGB(180, 50, 220) },
	KAYO = { role = "Initiator", desc = "Anti-ability. Suppression blade + flash + AOE pulse ult.", color = Color3.fromRGB(100, 200, 255) },
	Sova = { role = "Initiator", desc = "Bow recon. Owl drone + shock dart + bolt + 3-shot ult.", color = Color3.fromRGB(60, 180, 255) },
	Brimstone = { role = "Controller", desc = "Map-wide smokes. Stim + molotov + 3 smokes + orbital ult.", color = Color3.fromRGB(255, 180, 50) },
	Viper = { role = "Controller", desc = "Toxic walls. Snake bite + cloud + screen + Pit ult.", color = Color3.fromRGB(80, 200, 50) },
	Astra = { role = "Controller", desc = "Astral stars: smoke + concuss + gravity + Cosmic Divide wall.", color = Color3.fromRGB(150, 80, 220) },
	Omen = { role = "Controller", desc = "Phantom assassin: teleport + paranoia + smokes + map-wide ult.", color = Color3.fromRGB(70, 50, 120) },
	Killjoy = { role = "Sentinel", desc = "Tech ops: alarmbot + turret + nanoswarm + Lockdown detain ult.", color = Color3.fromRGB(255, 220, 50) },
}

local gui
local selectedAgent = nil
local selectionLocked = false
local countdownGui  -- 5..0 countdown overlay

local function buildGui()
	gui = Instance.new("ScreenGui")
	gui.Name = "AgentSelect"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Enabled = false
	gui.Parent = PlayerGui

	local backdrop = Instance.new("Frame")
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
	backdrop.BackgroundTransparency = 0.05
	backdrop.BorderSizePixel = 0
	backdrop.Parent = gui

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 80)
	title.Position = UDim2.fromOffset(0, 40)
	title.BackgroundTransparency = 1
	title.Text = "SELECT YOUR AGENT"
	title.TextColor3 = Color3.fromRGB(255, 100, 80)
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 42
	title.Parent = backdrop

	local timerLabel = Instance.new("TextLabel")
	timerLabel.Name = "Timer"
	timerLabel.Size = UDim2.fromOffset(200, 30)
	timerLabel.Position = UDim2.new(0.5, -100, 0, 130)
	timerLabel.BackgroundTransparency = 1
	timerLabel.Text = "30"
	timerLabel.TextColor3 = Color3.fromRGB(255, 200, 80)
	timerLabel.Font = Enum.Font.GothamBold
	timerLabel.TextSize = 24
	timerLabel.Parent = backdrop

	-- Card container (grid 3×3 dla 9 agentów)
	local cardContainer = Instance.new("Frame")
	cardContainer.Name = "CardContainer"
	cardContainer.AnchorPoint = Vector2.new(0.5, 0.5)
	cardContainer.Position = UDim2.fromScale(0.5, 0.55)
	cardContainer.Size = UDim2.fromOffset(760, 720)
	cardContainer.BackgroundTransparency = 1
	cardContainer.Parent = backdrop

	local layout = Instance.new("UIGridLayout")
	layout.CellSize = UDim2.fromOffset(220, 320)
	layout.CellPadding = UDim2.fromOffset(18, 20)
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = cardContainer

	for i, agentName in ipairs(AGENTS_AVAILABLE) do
		local info = AGENT_DESCRIPTIONS[agentName]
		local card = Instance.new("TextButton")
		card.Name = "Card_" .. agentName
		card.LayoutOrder = i
		card.Size = UDim2.fromOffset(220, 320)
		card.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
		card.BorderSizePixel = 0
		card.AutoButtonColor = false
		card.Text = ""
		card.Parent = cardContainer

		local cCorner = Instance.new("UICorner")
		cCorner.CornerRadius = UDim.new(0, 16)
		cCorner.Parent = card

		local cStroke = Instance.new("UIStroke")
		cStroke.Thickness = 3
		cStroke.Color = info.color
		cStroke.Transparency = 0.6
		cStroke.Parent = card

		-- Color accent strip top
		local accent = Instance.new("Frame")
		accent.Size = UDim2.new(1, 0, 0, 12)
		accent.BackgroundColor3 = info.color
		accent.BorderSizePixel = 0
		accent.Parent = card
		local aCorner = Instance.new("UICorner")
		aCorner.CornerRadius = UDim.new(0, 16)
		aCorner.Parent = accent

		-- Agent portrait area (placeholder box)
		local portrait = Instance.new("Frame")
		portrait.Size = UDim2.fromOffset(180, 140)
		portrait.Position = UDim2.new(0.5, -90, 0, 24)
		portrait.BackgroundColor3 = info.color
		portrait.BackgroundTransparency = 0.5
		portrait.BorderSizePixel = 0
		portrait.Parent = card
		local pCorner = Instance.new("UICorner")
		pCorner.CornerRadius = UDim.new(0, 8)
		pCorner.Parent = portrait

		-- Placeholder agent icon (text)
		local icon = Instance.new("TextLabel")
		icon.Size = UDim2.fromScale(1, 1)
		icon.BackgroundTransparency = 1
		icon.Text = string.sub(agentName, 1, 1)
		icon.TextColor3 = Color3.fromRGB(255, 255, 255)
		icon.Font = Enum.Font.GothamBlack
		icon.TextSize = 80
		icon.Parent = portrait

		-- Name
		local nameLbl = Instance.new("TextLabel")
		nameLbl.Size = UDim2.new(1, 0, 0, 30)
		nameLbl.Position = UDim2.fromOffset(0, 180)
		nameLbl.BackgroundTransparency = 1
		nameLbl.Text = agentName:upper()
		nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLbl.Font = Enum.Font.GothamBlack
		nameLbl.TextSize = 22
		nameLbl.Parent = card

		-- Role
		local roleLbl = Instance.new("TextLabel")
		roleLbl.Size = UDim2.new(1, 0, 0, 20)
		roleLbl.Position = UDim2.fromOffset(0, 210)
		roleLbl.BackgroundTransparency = 1
		roleLbl.Text = info.role:upper()
		roleLbl.TextColor3 = info.color
		roleLbl.Font = Enum.Font.GothamBold
		roleLbl.TextSize = 13
		roleLbl.Parent = card

		-- Description
		local descLbl = Instance.new("TextLabel")
		descLbl.Size = UDim2.new(1, -20, 0, 70)
		descLbl.Position = UDim2.fromOffset(10, 235)
		descLbl.BackgroundTransparency = 1
		descLbl.Text = info.desc
		descLbl.TextColor3 = Color3.fromRGB(200, 200, 220)
		descLbl.Font = Enum.Font.Gotham
		descLbl.TextSize = 11
		descLbl.TextWrapped = true
		descLbl.Parent = card

		card.MouseEnter:Connect(function()
			if not selectionLocked then
				card.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
				cStroke.Transparency = 0
			end
		end)
		card.MouseLeave:Connect(function()
			if selectedAgent ~= agentName then
				card.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
				cStroke.Transparency = 0.6
			end
		end)

		card.Activated:Connect(function()
			if selectionLocked then return end
			selectedAgent = agentName
			-- Visual: mark this card as selected
			for _, otherCard in ipairs(cardContainer:GetChildren()) do
				if otherCard:IsA("TextButton") then
					otherCard.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
					local s = otherCard:FindFirstChildOfClass("UIStroke")
					if s then s.Transparency = 0.6 end
				end
			end
			card.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
			cStroke.Transparency = 0
			-- Send to server
			Remotes.RequestBuy:FireServer("agent", agentName)
			Remotes.AgentSelected:FireServer(agentName)
		end)
	end
end

local function showSelect(duration)
	if not gui then buildGui() end
	gui.Enabled = true
	selectionLocked = false
	selectedAgent = nil

	local timerLabel = gui:FindFirstChild("Timer", true)
	local startTime = tick()
	task.spawn(function()
		while gui.Enabled and not selectionLocked do
			local remaining = math.max(0, duration - (tick() - startTime))
			if timerLabel then
				timerLabel.Text = string.format("%d", math.ceil(remaining))
			end
			if remaining <= 0 then
				-- Auto-pick if no selection
				if not selectedAgent then
					selectedAgent = "Jett"
					Remotes.RequestBuy:FireServer("agent", "Jett")
					Remotes.AgentSelected:FireServer("Jett")
				end
				selectionLocked = true
				break
			end
			task.wait(0.1)
		end
		task.wait(1.5)
		gui.Enabled = false
	end)
end

-- Match start countdown 5..0
local function buildCountdownGui()
	countdownGui = Instance.new("ScreenGui")
	countdownGui.Name = "MatchCountdown"
	countdownGui.ResetOnSpawn = false
	countdownGui.IgnoreGuiInset = true
	countdownGui.Enabled = false
	countdownGui.Parent = PlayerGui

	local number = Instance.new("TextLabel")
	number.Name = "Number"
	number.AnchorPoint = Vector2.new(0.5, 0.5)
	number.Position = UDim2.fromScale(0.5, 0.4)
	number.Size = UDim2.fromOffset(400, 200)
	number.BackgroundTransparency = 1
	number.Text = "5"
	number.TextColor3 = Color3.fromRGB(255, 200, 80)
	number.TextStrokeTransparency = 0
	number.Font = Enum.Font.GothamBlack
	number.TextSize = 180
	number.Parent = countdownGui

	local subtitle = Instance.new("TextLabel")
	subtitle.Name = "Subtitle"
	subtitle.AnchorPoint = Vector2.new(0.5, 0.5)
	subtitle.Position = UDim2.fromScale(0.5, 0.55)
	subtitle.Size = UDim2.fromOffset(400, 40)
	subtitle.BackgroundTransparency = 1
	subtitle.Text = "MATCH STARTING"
	subtitle.TextColor3 = Color3.fromRGB(220, 220, 240)
	subtitle.Font = Enum.Font.GothamBold
	subtitle.TextSize = 24
	subtitle.Parent = countdownGui
end

local function showCountdown(seconds)
	if not countdownGui then buildCountdownGui() end
	countdownGui.Enabled = true
	local number = countdownGui:FindFirstChild("Number")

	task.spawn(function()
		for i = seconds, 1, -1 do
			number.Text = tostring(i)
			number.TextColor3 = Color3.fromRGB(255, 200, 80)
			number.Size = UDim2.fromOffset(300, 150)
			TweenService:Create(number, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
				Size = UDim2.fromOffset(500, 250),
			}):Play()
			task.wait(1)
		end
		number.Text = "GO!"
		number.TextColor3 = Color3.fromRGB(100, 255, 120)
		task.wait(0.8)
		countdownGui.Enabled = false
	end)
end

function AgentSelectController.Start()
	buildGui()
	buildCountdownGui()

	Remotes.ShowAgentSelect.OnClientEvent:Connect(function(duration)
		showSelect(duration or 30)
	end)

	Remotes.MatchCountdown.OnClientEvent:Connect(function(seconds)
		showCountdown(seconds or 5)
	end)
end

return AgentSelectController
