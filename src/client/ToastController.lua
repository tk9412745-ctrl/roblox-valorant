-- ToastController: centralized notification toast utility
-- Inne controllery mogą wywoływać ToastController.Show(title, desc, color, duration)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local ToastController = {}

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local gui
local queue = {}
local showing = false

local function buildGui()
	gui = Instance.new("ScreenGui")
	gui.Name = "ToastQueue"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = PlayerGui
end

local function showNext()
	if showing then return end
	if #queue == 0 then return end
	local entry = table.remove(queue, 1)
	showing = true

	local toast = Instance.new("Frame")
	toast.AnchorPoint = Vector2.new(0.5, 1)
	toast.Position = UDim2.new(0.5, 0, 1, -200)
	toast.Size = UDim2.fromOffset(360, 60)
	toast.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	toast.BackgroundTransparency = 0.2
	toast.BorderSizePixel = 0
	toast.Parent = gui
	local tCorner = Instance.new("UICorner")
	tCorner.CornerRadius = UDim.new(0, 8)
	tCorner.Parent = toast

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2
	stroke.Color = entry.color or Color3.fromRGB(255, 200, 80)
	stroke.Parent = toast

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 24)
	title.Position = UDim2.fromOffset(0, 6)
	title.BackgroundTransparency = 1
	title.Text = entry.title or "Notification"
	title.TextColor3 = entry.color or Color3.fromRGB(255, 200, 80)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 14
	title.Parent = toast

	local desc = Instance.new("TextLabel")
	desc.Size = UDim2.new(1, 0, 0, 22)
	desc.Position = UDim2.fromOffset(0, 30)
	desc.BackgroundTransparency = 1
	desc.Text = entry.desc or ""
	desc.TextColor3 = Color3.fromRGB(220, 220, 240)
	desc.Font = Enum.Font.Gotham
	desc.TextSize = 13
	desc.Parent = toast

	-- Slide in
	toast.Position = UDim2.new(0.5, 0, 1, 100)
	TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
		Position = UDim2.new(0.5, 0, 1, -200),
	}):Play()

	local duration = entry.duration or 3
	task.delay(duration, function()
		TweenService:Create(toast, TweenInfo.new(0.3), {
			Position = UDim2.new(0.5, 0, 1, 100),
		}):Play()
		task.wait(0.4)
		toast:Destroy()
		showing = false
		showNext()
	end)
end

function ToastController.Show(title, desc, color, duration)
	table.insert(queue, {
		title = title,
		desc = desc,
		color = color,
		duration = duration,
	})
	showNext()
end

function ToastController.Start()
	buildGui()
end

return ToastController
