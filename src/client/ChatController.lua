-- ChatController: V (all) / B-team chat (Y) — wpisuje wiadomość → enter wysyła
-- Wyświetla rolling history w lewym dolnym rogu

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local ChatController = {}

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local gui
local historyFrame
local inputBox
local currentChannel = "all"
local chatOpen = false
local MAX_HISTORY = 8

local function buildGui()
	gui = Instance.new("ScreenGui")
	gui.Name = "Chat"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = PlayerGui

	-- History (top-left area, above other HUD)
	historyFrame = Instance.new("Frame")
	historyFrame.Name = "History"
	historyFrame.Position = UDim2.fromOffset(20, 180)
	historyFrame.Size = UDim2.fromOffset(420, 220)
	historyFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	historyFrame.BackgroundTransparency = 0.5
	historyFrame.BorderSizePixel = 0
	historyFrame.Visible = false
	historyFrame.Parent = gui
	local hCorner = Instance.new("UICorner")
	hCorner.CornerRadius = UDim.new(0, 6)
	hCorner.Parent = historyFrame

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 2)
	layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	layout.Parent = historyFrame
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 8)
	pad.PaddingRight = UDim.new(0, 8)
	pad.PaddingTop = UDim.new(0, 4)
	pad.PaddingBottom = UDim.new(0, 4)
	pad.Parent = historyFrame

	-- Input box (bottom of screen, hidden by default)
	inputBox = Instance.new("Frame")
	inputBox.Name = "InputBox"
	inputBox.AnchorPoint = Vector2.new(0, 1)
	inputBox.Position = UDim2.new(0, 20, 1, -120)
	inputBox.Size = UDim2.fromOffset(500, 36)
	inputBox.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	inputBox.BackgroundTransparency = 0.2
	inputBox.BorderSizePixel = 0
	inputBox.Visible = false
	inputBox.Parent = gui
	local iCorner = Instance.new("UICorner")
	iCorner.CornerRadius = UDim.new(0, 6)
	iCorner.Parent = inputBox

	local channelLbl = Instance.new("TextLabel")
	channelLbl.Name = "Channel"
	channelLbl.Position = UDim2.fromOffset(8, 0)
	channelLbl.Size = UDim2.fromOffset(70, 36)
	channelLbl.BackgroundTransparency = 1
	channelLbl.Text = "[ALL]"
	channelLbl.TextColor3 = Color3.fromRGB(255, 220, 80)
	channelLbl.Font = Enum.Font.GothamBold
	channelLbl.TextSize = 13
	channelLbl.Parent = inputBox

	local textInput = Instance.new("TextBox")
	textInput.Name = "TextInput"
	textInput.Position = UDim2.fromOffset(85, 0)
	textInput.Size = UDim2.fromOffset(400, 36)
	textInput.BackgroundTransparency = 1
	textInput.Text = ""
	textInput.PlaceholderText = "Type message..."
	textInput.PlaceholderColor3 = Color3.fromRGB(140, 140, 160)
	textInput.TextColor3 = Color3.fromRGB(255, 255, 255)
	textInput.Font = Enum.Font.Gotham
	textInput.TextSize = 14
	textInput.TextXAlignment = Enum.TextXAlignment.Left
	textInput.ClearTextOnFocus = false
	textInput.Parent = inputBox

	textInput.FocusLost:Connect(function(enterPressed)
		if enterPressed and #textInput.Text > 0 then
			Remotes.SendChat:FireServer(currentChannel, textInput.Text)
		end
		textInput.Text = ""
		inputBox.Visible = false
		chatOpen = false
	end)
end

local function openChat(channel)
	if chatOpen then return end
	chatOpen = true
	currentChannel = channel or "all"
	inputBox.Visible = true
	historyFrame.Visible = true
	local channelLbl = inputBox:FindFirstChild("Channel")
	if channelLbl then
		if channel == "team" then
			channelLbl.Text = "[TEAM]"
			channelLbl.TextColor3 = Color3.fromRGB(80, 220, 120)
		else
			channelLbl.Text = "[ALL]"
			channelLbl.TextColor3 = Color3.fromRGB(255, 220, 80)
		end
	end
	local textInput = inputBox:FindFirstChild("TextInput")
	if textInput then textInput:CaptureFocus() end

	-- Auto-hide history when not in chat
	task.delay(8, function()
		if not chatOpen then historyFrame.Visible = false end
	end)
end

local function addMessage(channel, senderName, senderTeam, message)
	if not historyFrame then return end

	-- Build message label
	local row = Instance.new("TextLabel")
	row.Size = UDim2.new(1, 0, 0, 22)
	row.BackgroundTransparency = 1
	row.TextXAlignment = Enum.TextXAlignment.Left

	local channelTag = channel == "team" and "[TEAM] " or ""
	local teamColor = senderTeam == "Attackers" and "<font color=\"#ff5050\">"
		or senderTeam == "Defenders" and "<font color=\"#5070ff\">"
		or "<font color=\"#cccccc\">"
	row.RichText = true
	row.Text = string.format("%s%s%s:</font> %s", channelTag, teamColor, senderName, message)
	row.TextColor3 = Color3.fromRGB(240, 240, 240)
	row.Font = Enum.Font.Gotham
	row.TextSize = 13
	row.Parent = historyFrame

	-- Cap history
	local rows = {}
	for _, child in ipairs(historyFrame:GetChildren()) do
		if child:IsA("TextLabel") then table.insert(rows, child) end
	end
	if #rows > MAX_HISTORY then
		rows[1]:Destroy()
	end

	-- Show + auto-fade
	historyFrame.Visible = true
	task.delay(8, function()
		if not chatOpen then historyFrame.Visible = false end
	end)
end

function ChatController.Start()
	buildGui()

	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if not chatOpen then
			if input.KeyCode == Enum.KeyCode.V then
				openChat("all")
			elseif input.KeyCode == Enum.KeyCode.Slash then
				openChat("all")
			end
			-- /team key — use Numpad0 or maybe RightCtrl
		end
	end)

	Remotes.ChatReceived.OnClientEvent:Connect(function(channel, senderName, senderTeam, message)
		addMessage(channel, senderName, senderTeam, message)
	end)
end

return ChatController
