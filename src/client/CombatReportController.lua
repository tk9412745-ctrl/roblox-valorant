-- CombatReportController: po każdej rundzie pokazuje krótki report z MVP highlight

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local CombatReportController = {}

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local gui
local mvpBanner

local function buildGui()
	gui = Instance.new("ScreenGui")
	gui.Name = "CombatReport"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = PlayerGui

	mvpBanner = Instance.new("Frame")
	mvpBanner.Name = "MVPBanner"
	mvpBanner.AnchorPoint = Vector2.new(0.5, 0)
	mvpBanner.Position = UDim2.new(0.5, 0, 0, 200)
	mvpBanner.Size = UDim2.fromOffset(500, 80)
	mvpBanner.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	mvpBanner.BackgroundTransparency = 1
	mvpBanner.BorderSizePixel = 0
	mvpBanner.Visible = false
	mvpBanner.Parent = gui
	local mCorner = Instance.new("UICorner")
	mCorner.CornerRadius = UDim.new(0, 10)
	mCorner.Parent = mvpBanner

	local mStroke = Instance.new("UIStroke")
	mStroke.Thickness = 2
	mStroke.Color = Color3.fromRGB(255, 215, 0)
	mStroke.Transparency = 1
	mStroke.Parent = mvpBanner

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0.4, 0)
	title.BackgroundTransparency = 1
	title.Text = "★ ROUND MVP ★"
	title.TextColor3 = Color3.fromRGB(255, 215, 0)
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 18
	title.TextTransparency = 1
	title.Parent = mvpBanner

	local nameLbl = Instance.new("TextLabel")
	nameLbl.Name = "MVPName"
	nameLbl.Position = UDim2.fromScale(0, 0.4)
	nameLbl.Size = UDim2.new(1, 0, 0.6, 0)
	nameLbl.BackgroundTransparency = 1
	nameLbl.Text = ""
	nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLbl.Font = Enum.Font.GothamBlack
	nameLbl.TextSize = 32
	nameLbl.TextTransparency = 1
	nameLbl.Parent = mvpBanner
end

local function showMVP(winnerTeam, mvpName, report)
	if not mvpBanner then return end

	-- Find my row in report
	local myRow
	for _, row in ipairs(report or {}) do
		if row.name == LocalPlayer.Name then
			myRow = row
			break
		end
	end

	mvpBanner.Visible = true
	local title = mvpBanner:FindFirstChild("Title")
	local nameLbl = mvpBanner:FindFirstChild("MVPName")
	local stroke = mvpBanner:FindFirstChildOfClass("UIStroke")

	if mvpName == LocalPlayer.Name then
		title.Text = "★ YOU ARE ROUND MVP ★"
		nameLbl.Text = string.format("%d kills • %d dmg", myRow and myRow.kills or 0, myRow and myRow.dmg or 0)
		nameLbl.TextColor3 = Color3.fromRGB(255, 215, 0)
	else
		title.Text = "★ ROUND MVP ★"
		nameLbl.Text = mvpName or "—"
		nameLbl.TextColor3 = Color3.fromRGB(220, 220, 240)
	end

	-- Fade in
	TweenService:Create(mvpBanner, TweenInfo.new(0.4), { BackgroundTransparency = 0.3 }):Play()
	TweenService:Create(stroke, TweenInfo.new(0.4), { Transparency = 0 }):Play()
	TweenService:Create(title, TweenInfo.new(0.4), { TextTransparency = 0 }):Play()
	TweenService:Create(nameLbl, TweenInfo.new(0.4), { TextTransparency = 0 }):Play()

	-- Pop animation
	mvpBanner.Size = UDim2.fromOffset(400, 80)
	TweenService:Create(mvpBanner, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
		Size = UDim2.fromOffset(520, 80),
	}):Play()

	-- Fade out after 3s
	task.delay(3, function()
		TweenService:Create(mvpBanner, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
		TweenService:Create(stroke, TweenInfo.new(0.5), { Transparency = 1 }):Play()
		TweenService:Create(title, TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
		TweenService:Create(nameLbl, TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
		task.wait(0.5)
		mvpBanner.Visible = false
	end)
end

function CombatReportController.Start()
	buildGui()

	Remotes.RoundReport.OnClientEvent:Connect(showMVP)
end

return CombatReportController
