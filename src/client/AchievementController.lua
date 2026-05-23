-- AchievementController: popup notification when achievement unlocked

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local AchievementController = {}

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local gui
local notificationQueue = {}
local showing = false

local function buildGui()
	gui = Instance.new("ScreenGui")
	gui.Name = "Achievements"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = PlayerGui
end

local function showNotification(name, desc, icon, reward)
	local notif = Instance.new("Frame")
	notif.AnchorPoint = Vector2.new(1, 0)
	notif.Position = UDim2.new(1, 20, 0, 130)
	notif.Size = UDim2.fromOffset(360, 90)
	notif.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	notif.BackgroundTransparency = 0.2
	notif.BorderSizePixel = 0
	notif.Parent = gui
	local nCorner = Instance.new("UICorner")
	nCorner.CornerRadius = UDim.new(0, 10)
	nCorner.Parent = notif

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2
	stroke.Color = Color3.fromRGB(255, 215, 0)
	stroke.Parent = notif

	-- Icon
	local iconLbl = Instance.new("TextLabel")
	iconLbl.Size = UDim2.fromOffset(80, 80)
	iconLbl.Position = UDim2.fromOffset(8, 5)
	iconLbl.BackgroundTransparency = 1
	iconLbl.Text = icon or "🏆"
	iconLbl.TextColor3 = Color3.fromRGB(255, 220, 100)
	iconLbl.Font = Enum.Font.GothamBlack
	iconLbl.TextSize = 48
	iconLbl.Parent = notif

	-- Title
	local title = Instance.new("TextLabel")
	title.Position = UDim2.fromOffset(95, 8)
	title.Size = UDim2.new(1, -105, 0, 22)
	title.BackgroundTransparency = 1
	title.Text = "ACHIEVEMENT UNLOCKED"
	title.TextColor3 = Color3.fromRGB(255, 215, 0)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 11
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = notif

	-- Name
	local nameLbl = Instance.new("TextLabel")
	nameLbl.Position = UDim2.fromOffset(95, 28)
	nameLbl.Size = UDim2.new(1, -105, 0, 24)
	nameLbl.BackgroundTransparency = 1
	nameLbl.Text = name or ""
	nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLbl.Font = Enum.Font.GothamBlack
	nameLbl.TextSize = 18
	nameLbl.TextXAlignment = Enum.TextXAlignment.Left
	nameLbl.Parent = notif

	-- Desc
	local descLbl = Instance.new("TextLabel")
	descLbl.Position = UDim2.fromOffset(95, 52)
	descLbl.Size = UDim2.new(1, -105, 0, 18)
	descLbl.BackgroundTransparency = 1
	descLbl.Text = desc or ""
	descLbl.TextColor3 = Color3.fromRGB(180, 180, 200)
	descLbl.Font = Enum.Font.Gotham
	descLbl.TextSize = 12
	descLbl.TextXAlignment = Enum.TextXAlignment.Left
	descLbl.Parent = notif

	-- Reward
	local rewardLbl = Instance.new("TextLabel")
	rewardLbl.Position = UDim2.fromOffset(95, 70)
	rewardLbl.Size = UDim2.new(1, -105, 0, 16)
	rewardLbl.BackgroundTransparency = 1
	rewardLbl.Text = "+" .. (reward or 0) .. " coins"
	rewardLbl.TextColor3 = Color3.fromRGB(255, 220, 80)
	rewardLbl.Font = Enum.Font.GothamBold
	rewardLbl.TextSize = 11
	rewardLbl.TextXAlignment = Enum.TextXAlignment.Left
	rewardLbl.Parent = notif

	-- Slide in
	TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
		Position = UDim2.new(1, -20, 0, 130),
	}):Play()

	-- Hide after 4s
	task.delay(4, function()
		TweenService:Create(notif, TweenInfo.new(0.3), {
			Position = UDim2.new(1, 20, 0, 130),
		}):Play()
		task.wait(0.4)
		notif:Destroy()
	end)
	Debris:AddItem(notif, 5)
end

local function processQueue()
	if showing then return end
	if #notificationQueue == 0 then return end
	showing = true
	local entry = table.remove(notificationQueue, 1)
	showNotification(entry.name, entry.desc, entry.icon, entry.reward)
	task.delay(1.5, function()
		showing = false
		processQueue()
	end)
end

function AchievementController.Start()
	buildGui()

	Remotes.AchievementUnlocked.OnClientEvent:Connect(function(id, name, desc, icon, reward)
		table.insert(notificationQueue, { name = name, desc = desc, icon = icon, reward = reward })
		processQueue()
	end)
end

return AchievementController
