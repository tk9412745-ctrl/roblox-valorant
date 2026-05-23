-- DailyChallengeController: pokazuje daily challenges w widgecie HUD i popup po complete

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local DailyChallengeController = {}

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local gui
local widget  -- top-right small widget
local widgetExpanded = false
local challenges = {}

local function buildGui()
	gui = Instance.new("ScreenGui")
	gui.Name = "DailyChallenges"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = PlayerGui

	widget = Instance.new("Frame")
	widget.Name = "Widget"
	widget.AnchorPoint = Vector2.new(1, 1)
	widget.Position = UDim2.new(1, -20, 1, -120)
	widget.Size = UDim2.fromOffset(280, 36)
	widget.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	widget.BackgroundTransparency = 0.3
	widget.BorderSizePixel = 0
	widget.Parent = gui
	local wCorner = Instance.new("UICorner")
	wCorner.CornerRadius = UDim.new(0, 6)
	wCorner.Parent = widget

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.fromScale(1, 1)
	title.BackgroundTransparency = 1
	title.Text = "  📋 DAILY CHALLENGES (0/3)"
	title.TextColor3 = Color3.fromRGB(220, 220, 240)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 13
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = widget

	local clickBtn = Instance.new("TextButton")
	clickBtn.Size = UDim2.fromScale(1, 1)
	clickBtn.BackgroundTransparency = 1
	clickBtn.Text = ""
	clickBtn.Parent = widget
	clickBtn.Activated:Connect(function()
		widgetExpanded = not widgetExpanded
		DailyChallengeController.Refresh()
	end)

	-- Toast for completed challenge
	local toast = Instance.new("Frame")
	toast.Name = "CompleteToast"
	toast.AnchorPoint = Vector2.new(1, 1)
	toast.Position = UDim2.new(1, 20, 1, -160)
	toast.Size = UDim2.fromOffset(320, 70)
	toast.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
	toast.BackgroundTransparency = 0.2
	toast.BorderSizePixel = 0
	toast.Visible = false
	toast.Parent = gui
	local tCorner = Instance.new("UICorner")
	tCorner.CornerRadius = UDim.new(0, 8)
	tCorner.Parent = toast

	local tStroke = Instance.new("UIStroke")
	tStroke.Thickness = 2
	tStroke.Color = Color3.fromRGB(80, 220, 120)
	tStroke.Parent = toast

	local toastTitle = Instance.new("TextLabel")
	toastTitle.Size = UDim2.new(1, 0, 0, 24)
	toastTitle.Position = UDim2.fromOffset(0, 8)
	toastTitle.BackgroundTransparency = 1
	toastTitle.Text = "✓ CHALLENGE COMPLETE"
	toastTitle.TextColor3 = Color3.fromRGB(80, 220, 120)
	toastTitle.Font = Enum.Font.GothamBold
	toastTitle.TextSize = 12
	toastTitle.Parent = toast

	local toastDesc = Instance.new("TextLabel")
	toastDesc.Name = "Desc"
	toastDesc.Size = UDim2.new(1, 0, 0, 22)
	toastDesc.Position = UDim2.fromOffset(0, 28)
	toastDesc.BackgroundTransparency = 1
	toastDesc.Text = ""
	toastDesc.TextColor3 = Color3.fromRGB(240, 240, 240)
	toastDesc.Font = Enum.Font.GothamBold
	toastDesc.TextSize = 16
	toastDesc.Parent = toast

	local toastReward = Instance.new("TextLabel")
	toastReward.Name = "Reward"
	toastReward.Size = UDim2.new(1, 0, 0, 16)
	toastReward.Position = UDim2.fromOffset(0, 50)
	toastReward.BackgroundTransparency = 1
	toastReward.Text = ""
	toastReward.TextColor3 = Color3.fromRGB(255, 220, 80)
	toastReward.Font = Enum.Font.GothamBold
	toastReward.TextSize = 12
	toastReward.Parent = toast
end

function DailyChallengeController.Refresh()
	if not widget or not gui then return end
	-- Clear existing detail rows
	for _, child in ipairs(widget:GetChildren()) do
		if child:IsA("Frame") and child.Name:find("^Detail_") then
			child:Destroy()
		end
	end

	local completedCount = 0
	for _, c in ipairs(challenges) do
		if c.completed then completedCount += 1 end
	end

	local title = widget:FindFirstChild("Title")
	if title then
		title.Text = string.format("  📋 DAILY CHALLENGES (%d/%d)", completedCount, #challenges)
	end

	if widgetExpanded then
		widget.Size = UDim2.fromOffset(320, 36 + #challenges * 36)
		for i, c in ipairs(challenges) do
			local row = Instance.new("Frame")
			row.Name = "Detail_" .. i
			row.Position = UDim2.fromOffset(8, 36 + (i - 1) * 36)
			row.Size = UDim2.fromOffset(304, 32)
			row.BackgroundColor3 = c.completed and Color3.fromRGB(30, 60, 40) or Color3.fromRGB(40, 40, 55)
			row.BackgroundTransparency = 0.2
			row.BorderSizePixel = 0
			row.Parent = widget
			local rCorner = Instance.new("UICorner")
			rCorner.CornerRadius = UDim.new(0, 4)
			rCorner.Parent = row

			local descLbl = Instance.new("TextLabel")
			descLbl.Size = UDim2.new(0.7, 0, 1, 0)
			descLbl.Position = UDim2.fromOffset(8, 0)
			descLbl.BackgroundTransparency = 1
			descLbl.Text = "  " .. (c.desc or c.id)
			descLbl.TextColor3 = c.completed and Color3.fromRGB(80, 220, 120) or Color3.fromRGB(220, 220, 240)
			descLbl.Font = Enum.Font.GothamBold
			descLbl.TextSize = 11
			descLbl.TextXAlignment = Enum.TextXAlignment.Left
			descLbl.Parent = row

			local progLbl = Instance.new("TextLabel")
			progLbl.AnchorPoint = Vector2.new(1, 0)
			progLbl.Position = UDim2.new(1, -8, 0, 0)
			progLbl.Size = UDim2.fromOffset(80, 32)
			progLbl.BackgroundTransparency = 1
			progLbl.Text = c.completed and "✓" or string.format("%d/%d", c.progress or 0, c.target)
			progLbl.TextColor3 = c.completed and Color3.fromRGB(80, 220, 120) or Color3.fromRGB(255, 220, 80)
			progLbl.Font = Enum.Font.GothamBold
			progLbl.TextSize = 12
			progLbl.TextXAlignment = Enum.TextXAlignment.Right
			progLbl.Parent = row
		end
	else
		widget.Size = UDim2.fromOffset(280, 36)
	end
end

local function showCompleteToast(desc, reward)
	local toast = gui:FindFirstChild("CompleteToast")
	if not toast then return end
	local descLbl = toast:FindFirstChild("Desc")
	local rewardLbl = toast:FindFirstChild("Reward")
	if descLbl then descLbl.Text = desc end
	if rewardLbl then rewardLbl.Text = "+" .. reward .. " coins" end

	toast.Visible = true
	toast.Position = UDim2.new(1, 20, 1, -160)
	TweenService:Create(toast, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
		Position = UDim2.new(1, -20, 1, -160),
	}):Play()
	task.delay(4, function()
		TweenService:Create(toast, TweenInfo.new(0.3), {
			Position = UDim2.new(1, 20, 1, -160),
		}):Play()
		task.wait(0.4)
		toast.Visible = false
	end)
end

function DailyChallengeController.Start()
	buildGui()

	Remotes.UpdateChallenges.OnClientEvent:Connect(function(newChallenges)
		challenges = newChallenges or {}
		DailyChallengeController.Refresh()
	end)

	Remotes.ChallengeCompleted.OnClientEvent:Connect(function(id, desc, reward)
		showCompleteToast(desc or id, reward or 0)
	end)
end

return DailyChallengeController
