-- TutorialController: 5-step onboarding dla first-time players

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local TutorialController = {}

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local STEPS = {
	{
		title = "WITAJ W GRZE",
		text = "Taktyczny FPS 5v5 wzorowany na Valorancie.\n\nPress SPACJA aby kontynuować.",
		icon = "🎮",
	},
	{
		title = "PORUSZANIE SIĘ",
		text = "WASD do ruchu • SPACJA do skoku\nCtrl = kucanie (lepsza celność)\nShift = wolny chód (cicho)",
		icon = "🚶",
	},
	{
		title = "STRZELANIE",
		text = "LPM = strzał • PPM = ADS/scope\nR = przeładuj • Headshots zadają 4× więcej dmg!\n\nCelność spada przy ruchu i skokach.",
		icon = "🔫",
	},
	{
		title = "ABILITIES",
		text = "Wybierz agenta na początku meczu.\nC / Q = basic abilities (kupuj w buy phase)\nE = signature (free, recharge per round)\nX = ultimate (zbierz punkty)",
		icon = "⚡",
	},
	{
		title = "PINGI + MAPA",
		text = "Z = Watching • T = Danger\nG = Push • H = Need backup\nTAB = scoreboard • I = inventory\nB = buy menu • ESC = settings",
		icon = "📍",
	},
	{
		title = "SPIKE",
		text = "Atakujący sadzą spike na site (E przy site)\nObrońcy mogą rozbroić (E przy spike)\nPlant = 4s • Defuse = 7s (half-defuse = 3.5s)\n\nZwycięstwo: detonate / defuse / eliminate.",
		icon = "💣",
	},
}

local gui
local currentStep = 0
local active = false

local function buildGui()
	gui = Instance.new("ScreenGui")
	gui.Name = "Tutorial"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Enabled = false
	gui.Parent = PlayerGui

	local backdrop = Instance.new("Frame")
	backdrop.Name = "Backdrop"
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	backdrop.BackgroundTransparency = 0.3
	backdrop.BorderSizePixel = 0
	backdrop.Parent = gui

	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.Size = UDim2.fromOffset(540, 380)
	panel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	panel.BorderSizePixel = 0
	panel.Parent = backdrop
	local pCorner = Instance.new("UICorner")
	pCorner.CornerRadius = UDim.new(0, 12)
	pCorner.Parent = panel
	local pStroke = Instance.new("UIStroke")
	pStroke.Thickness = 2
	pStroke.Color = Color3.fromRGB(255, 100, 80)
	pStroke.Transparency = 0.3
	pStroke.Parent = panel

	local icon = Instance.new("TextLabel")
	icon.Name = "Icon"
	icon.AnchorPoint = Vector2.new(0.5, 0)
	icon.Position = UDim2.new(0.5, 0, 0, 30)
	icon.Size = UDim2.fromOffset(80, 80)
	icon.BackgroundTransparency = 1
	icon.Text = "🎮"
	icon.Font = Enum.Font.GothamBlack
	icon.TextSize = 60
	icon.Parent = panel

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.AnchorPoint = Vector2.new(0.5, 0)
	title.Position = UDim2.new(0.5, 0, 0, 120)
	title.Size = UDim2.new(1, 0, 0, 40)
	title.BackgroundTransparency = 1
	title.Text = "WITAJ W GRZE"
	title.TextColor3 = Color3.fromRGB(255, 100, 80)
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 28
	title.Parent = panel

	local body = Instance.new("TextLabel")
	body.Name = "Body"
	body.AnchorPoint = Vector2.new(0.5, 0)
	body.Position = UDim2.new(0.5, 0, 0, 170)
	body.Size = UDim2.new(1, -40, 0, 130)
	body.BackgroundTransparency = 1
	body.Text = ""
	body.TextColor3 = Color3.fromRGB(220, 220, 240)
	body.Font = Enum.Font.Gotham
	body.TextSize = 15
	body.TextWrapped = true
	body.Parent = panel

	local progress = Instance.new("TextLabel")
	progress.Name = "Progress"
	progress.AnchorPoint = Vector2.new(0.5, 1)
	progress.Position = UDim2.new(0.5, 0, 1, -60)
	progress.Size = UDim2.fromOffset(200, 24)
	progress.BackgroundTransparency = 1
	progress.Text = "1 / 6"
	progress.TextColor3 = Color3.fromRGB(180, 180, 200)
	progress.Font = Enum.Font.GothamBold
	progress.TextSize = 14
	progress.Parent = panel

	local nextBtn = Instance.new("TextButton")
	nextBtn.Name = "NextBtn"
	nextBtn.AnchorPoint = Vector2.new(0.5, 1)
	nextBtn.Position = UDim2.new(0.5, 0, 1, -20)
	nextBtn.Size = UDim2.fromOffset(200, 36)
	nextBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 80)
	nextBtn.BorderSizePixel = 0
	nextBtn.Text = "DALEJ [SPACE]"
	nextBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	nextBtn.Font = Enum.Font.GothamBlack
	nextBtn.TextSize = 14
	nextBtn.Parent = panel
	local nbCorner = Instance.new("UICorner")
	nbCorner.CornerRadius = UDim.new(0, 6)
	nbCorner.Parent = nextBtn
	nextBtn.Activated:Connect(function()
		TutorialController.Next()
	end)
end

function TutorialController.ShowStep(step)
	if not gui then return end
	local s = STEPS[step]
	if not s then
		TutorialController.End()
		return
	end
	gui.Enabled = true
	currentStep = step

	gui.Backdrop.Panel.Icon.Text = s.icon
	gui.Backdrop.Panel.Title.Text = s.title
	gui.Backdrop.Panel.Body.Text = s.text
	gui.Backdrop.Panel.Progress.Text = string.format("%d / %d", step, #STEPS)
end

function TutorialController.Next()
	if currentStep >= #STEPS then
		TutorialController.End()
	else
		TutorialController.ShowStep(currentStep + 1)
	end
end

function TutorialController.End()
	if not gui then return end
	gui.Enabled = false
	active = false
	-- Mark as completed
	Remotes.SaveSettings:FireServer({ tutorialCompleted = true })
end

function TutorialController.Begin()
	if active then return end
	active = true
	TutorialController.ShowStep(1)
end

function TutorialController.Start()
	buildGui()

	-- Listen for SPACE to advance tutorial
	UserInputService.InputBegan:Connect(function(input, processed)
		if active and not processed and input.KeyCode == Enum.KeyCode.Space then
			TutorialController.Next()
		end
	end)

	-- Check if first-time on join (after settings load)
	Remotes.LoadSettings.OnClientEvent:Connect(function(settings)
		if settings and settings.tutorialCompleted then
			-- Already done
			return
		end
		-- First-time: show tutorial after welcome screen
		task.delay(6, function()
			TutorialController.Begin()
		end)
	end)
end

return TutorialController
