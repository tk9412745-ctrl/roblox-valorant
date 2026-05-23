local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
local WeaponDatabase = require(ReplicatedStorage.Shared:WaitForChild("WeaponDatabase"))

local BuyMenuController = {}

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local gui
local currentCredits = 0
local menuOpen = false
local isBuyPhase = false

local function createMenu()
	gui = Instance.new("ScreenGui")
	gui.Name = "BuyMenu"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Enabled = false
	gui.Parent = PlayerGui

	local backdrop = Instance.new("Frame")
	backdrop.Name = "Backdrop"
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	backdrop.BackgroundTransparency = 0.4
	backdrop.BorderSizePixel = 0
	backdrop.Parent = gui

	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.Size = UDim2.fromOffset(800, 600)
	panel.Position = UDim2.new(0.5, -400, 0.5, -300)
	panel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	panel.BorderSizePixel = 0
	panel.Parent = backdrop

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = panel

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 60)
	title.Position = UDim2.fromOffset(0, 0)
	title.BackgroundTransparency = 1
	title.Text = "BUY MENU"
	title.TextColor3 = Color3.fromRGB(255, 100, 80)
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 32
	title.Parent = panel

	local creditsLabel = Instance.new("TextLabel")
	creditsLabel.Name = "CreditsLabel"
	creditsLabel.Size = UDim2.fromOffset(200, 40)
	creditsLabel.Position = UDim2.new(1, -220, 0, 20)
	creditsLabel.BackgroundTransparency = 1
	creditsLabel.Text = "0 cr"
	creditsLabel.TextColor3 = Color3.fromRGB(255, 220, 80)
	creditsLabel.Font = Enum.Font.GothamBold
	creditsLabel.TextSize = 24
	creditsLabel.TextXAlignment = Enum.TextXAlignment.Right
	creditsLabel.Parent = panel

	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Size = UDim2.new(1, -40, 1, -100)
	scrollFrame.Position = UDim2.fromOffset(20, 80)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.BorderSizePixel = 0
	scrollFrame.CanvasSize = UDim2.fromScale(0, 0)
	scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollFrame.ScrollBarThickness = 6
	scrollFrame.Parent = panel

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = scrollFrame

	-- Build category sections
	local function addCategoryHeader(name)
		local header = Instance.new("TextLabel")
		header.Size = UDim2.new(1, 0, 0, 36)
		header.BackgroundTransparency = 1
		header.Text = name
		header.TextColor3 = Color3.fromRGB(180, 180, 200)
		header.Font = Enum.Font.GothamBold
		header.TextSize = 20
		header.TextXAlignment = Enum.TextXAlignment.Left
		header.Parent = scrollFrame
		local pad = Instance.new("UIPadding")
		pad.PaddingLeft = UDim.new(0, 12)
		pad.Parent = header
	end

	local function addBuyButton(text, cost, buyType, argument)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 42)
		btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
		btn.BorderSizePixel = 0
		btn.AutoButtonColor = false
		btn.Text = ""
		btn.Parent = scrollFrame

		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 6)
		btnCorner.Parent = btn

		local btnText = Instance.new("TextLabel")
		btnText.Size = UDim2.fromScale(0.7, 1)
		btnText.Position = UDim2.fromOffset(12, 0)
		btnText.BackgroundTransparency = 1
		btnText.Text = text
		btnText.TextColor3 = Color3.fromRGB(240, 240, 240)
		btnText.Font = Enum.Font.GothamMedium
		btnText.TextSize = 18
		btnText.TextXAlignment = Enum.TextXAlignment.Left
		btnText.Parent = btn

		local btnCost = Instance.new("TextLabel")
		btnCost.Size = UDim2.fromScale(0.3, 1)
		btnCost.Position = UDim2.fromScale(0.7, 0)
		btnCost.BackgroundTransparency = 1
		btnCost.Text = cost .. " cr"
		btnCost.TextColor3 = Color3.fromRGB(255, 220, 80)
		btnCost.Font = Enum.Font.GothamBold
		btnCost.TextSize = 18
		btnCost.TextXAlignment = Enum.TextXAlignment.Right
		btnCost.Parent = btn
		local btnPad = Instance.new("UIPadding")
		btnPad.PaddingRight = UDim.new(0, 18)
		btnPad.Parent = btnCost

		btn.MouseEnter:Connect(function()
			btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
		end)
		btn.MouseLeave:Connect(function()
			btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
		end)

		btn.Activated:Connect(function()
			Remotes.RequestBuy:FireServer(buyType, argument)
		end)
	end

	-- ============================================================
	-- QUICK-BUY LOADOUT PRESETS (Sprint 81)
	-- ============================================================
	addCategoryHeader("Quick Loadout")
	local LOADOUTS = {
		{ name = "FULL BUY (Vandal + Heavy)", actions = {
			{ type = "weapon", arg = "Vandal" },
			{ type = "armor", arg = "HeavyShield" },
			{ type = "ability", arg = "C" },
			{ type = "ability", arg = "Q" },
		}, color = Color3.fromRGB(80, 220, 120) },
		{ name = "HALF BUY (Spectre + Light)", actions = {
			{ type = "weapon", arg = "Spectre" },
			{ type = "armor", arg = "LightShield" },
		}, color = Color3.fromRGB(255, 200, 80) },
		{ name = "ECO (Sheriff only)", actions = {
			{ type = "weapon", arg = "Sheriff" },
		}, color = Color3.fromRGB(180, 180, 200) },
	}
	for _, loadout in ipairs(LOADOUTS) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 42)
		btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
		btn.BorderSizePixel = 0
		btn.AutoButtonColor = false
		btn.Text = "  " .. loadout.name
		btn.TextColor3 = loadout.color
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 14
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.Parent = scrollFrame
		local bCorner = Instance.new("UICorner")
		bCorner.CornerRadius = UDim.new(0, 6)
		bCorner.Parent = btn
		btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80) end)
		btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55) end)
		btn.Activated:Connect(function()
			-- Execute loadout actions sequentially
			for _, action in ipairs(loadout.actions) do
				task.wait(0.1)
				Remotes.RequestBuy:FireServer(action.type, action.arg)
			end
		end)
	end

	-- Armor
	addCategoryHeader("Armor")
	addBuyButton("Light Shields (+25 HP)", WeaponDatabase.Armor.LightShield.Cost, "armor", "LightShield")
	addBuyButton("Heavy Shields (+50 HP)", WeaponDatabase.Armor.HeavyShield.Cost, "armor", "HeavyShield")

	-- Weapons by category
	for _, category in ipairs({ "Sidearm", "SMG", "Shotgun", "Rifle", "Sniper", "MachineGun" }) do
		addCategoryHeader(category)
		for _, weaponName in ipairs(WeaponDatabase.Categories[category]) do
			local w = WeaponDatabase[weaponName]
			if w and w.Price > 0 then
				addBuyButton(weaponName, w.Price, "weapon", weaponName)
			end
		end
	end

	-- Defuser (Sprint 84, defenders only)
	addCategoryHeader("Equipment")
	addBuyButton("Defuser (Half-defuse breaker)", 400, "defuser", "defuser")

	-- Agent select (one time)
	addCategoryHeader("Agent (select once)")
	addBuyButton("Jett (Duelist)", 0, "agent", "Jett")
	addBuyButton("Sage (Sentinel)", 0, "agent", "Sage")
	addBuyButton("Phoenix (Duelist)", 0, "agent", "Phoenix")
	addBuyButton("Cypher (Sentinel)", 0, "agent", "Cypher")
	addBuyButton("Reyna (Duelist)", 0, "agent", "Reyna")
	addBuyButton("KAY/O (Initiator)", 0, "agent", "KAYO")
	addBuyButton("Sova (Initiator)", 0, "agent", "Sova")
	addBuyButton("Brimstone (Controller)", 0, "agent", "Brimstone")
	addBuyButton("Viper (Controller)", 0, "agent", "Viper")

	return gui, creditsLabel
end

local creditsLabel

local function refreshCredits()
	if creditsLabel then
		creditsLabel.Text = tostring(currentCredits) .. " cr"
	end
end

local function setMenuOpen(open)
	menuOpen = open
	if gui then gui.Enabled = open and isBuyPhase end
end

function BuyMenuController.Start()
	_, creditsLabel = createMenu()

	Remotes.UpdateCredits.OnClientEvent:Connect(function(amount)
		currentCredits = amount
		refreshCredits()
	end)

	Remotes.RoundPhaseChanged.OnClientEvent:Connect(function(phase, extraData)
		isBuyPhase = phase == "BuyPhase" or phase == "PreMatch"
		if isBuyPhase then
			setMenuOpen(true)
		else
			setMenuOpen(false)
		end
	end)

	Remotes.BuyResult.OnClientEvent:Connect(function(success, message)
		if not success then
			-- Could show notification
			print("[Buy] " .. (message or "Failed"))
		end
	end)

	-- Toggle menu with B key
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.B and isBuyPhase then
			setMenuOpen(not menuOpen)
		elseif input.KeyCode == Enum.KeyCode.Escape and menuOpen then
			setMenuOpen(false)
		end
	end)
end

return BuyMenuController
