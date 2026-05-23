-- BattlePassController: browseable BP screen, claim rewards per tier
-- Press P to toggle

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
local MonetizationConfig = require(ReplicatedStorage.Shared:WaitForChild("MonetizationConfig"))

local BattlePassController = {}

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local gui
local menuOpen = false
local inventory = {}

local function buildGui()
	gui = Instance.new("ScreenGui")
	gui.Name = "BattlePass"
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

	-- Title
	local title = Instance.new("TextLabel")
	title.AnchorPoint = Vector2.new(0.5, 0)
	title.Position = UDim2.new(0.5, 0, 0, 40)
	title.Size = UDim2.fromOffset(600, 60)
	title.BackgroundTransparency = 1
	title.Text = "⚡ BATTLE PASS — SEASON 1"
	title.TextColor3 = Color3.fromRGB(255, 200, 80)
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 32
	title.Parent = backdrop

	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.AnchorPoint = Vector2.new(1, 0)
	closeBtn.Position = UDim2.new(1, -30, 0, 40)
	closeBtn.Size = UDim2.fromOffset(120, 40)
	closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	closeBtn.Text = "CLOSE (P)"
	closeBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 14
	closeBtn.Parent = backdrop
	local cbCorner = Instance.new("UICorner")
	cbCorner.CornerRadius = UDim.new(0, 6)
	cbCorner.Parent = closeBtn
	closeBtn.Activated:Connect(function()
		menuOpen = false
		gui.Enabled = false
	end)

	-- Tier progress bar
	local progressBg = Instance.new("Frame")
	progressBg.Name = "ProgressBg"
	progressBg.AnchorPoint = Vector2.new(0.5, 0)
	progressBg.Position = UDim2.new(0.5, 0, 0, 110)
	progressBg.Size = UDim2.fromOffset(800, 24)
	progressBg.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
	progressBg.BackgroundTransparency = 0.2
	progressBg.BorderSizePixel = 0
	progressBg.Parent = backdrop
	local pgCorner = Instance.new("UICorner")
	pgCorner.CornerRadius = UDim.new(0, 12)
	pgCorner.Parent = progressBg

	local progressFill = Instance.new("Frame")
	progressFill.Name = "ProgressFill"
	progressFill.Size = UDim2.fromScale(0, 1)
	progressFill.BackgroundColor3 = Color3.fromRGB(255, 200, 80)
	progressFill.BorderSizePixel = 0
	progressFill.Parent = progressBg
	local pfCorner = Instance.new("UICorner")
	pfCorner.CornerRadius = UDim.new(0, 12)
	pfCorner.Parent = progressFill

	local tierLabel = Instance.new("TextLabel")
	tierLabel.Name = "TierLabel"
	tierLabel.Size = UDim2.fromScale(1, 1)
	tierLabel.BackgroundTransparency = 1
	tierLabel.Text = "Tier 0 / 50"
	tierLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	tierLabel.Font = Enum.Font.GothamBold
	tierLabel.TextSize = 14
	tierLabel.Parent = progressBg

	-- Premium CTA
	local premiumCTA = Instance.new("TextButton")
	premiumCTA.Name = "PremiumCTA"
	premiumCTA.AnchorPoint = Vector2.new(0.5, 0)
	premiumCTA.Position = UDim2.new(0.5, 0, 0, 150)
	premiumCTA.Size = UDim2.fromOffset(400, 50)
	premiumCTA.BackgroundColor3 = Color3.fromRGB(180, 80, 240)
	premiumCTA.BorderSizePixel = 0
	premiumCTA.Text = "UNLOCK PREMIUM PASS — 599 R$"
	premiumCTA.TextColor3 = Color3.fromRGB(255, 255, 255)
	premiumCTA.Font = Enum.Font.GothamBlack
	premiumCTA.TextSize = 18
	premiumCTA.Parent = backdrop
	local pcCorner = Instance.new("UICorner")
	pcCorner.CornerRadius = UDim.new(0, 8)
	pcCorner.Parent = premiumCTA

	-- Tier rewards grid
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "TierGrid"
	scrollFrame.AnchorPoint = Vector2.new(0.5, 0)
	scrollFrame.Position = UDim2.new(0.5, 0, 0, 220)
	scrollFrame.Size = UDim2.fromOffset(1100, 480)
	scrollFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	scrollFrame.BackgroundTransparency = 0.4
	scrollFrame.BorderSizePixel = 0
	scrollFrame.CanvasSize = UDim2.fromScale(0, 0)
	scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollFrame.ScrollBarThickness = 6
	scrollFrame.Parent = backdrop
	local sfCorner = Instance.new("UICorner")
	sfCorner.CornerRadius = UDim.new(0, 8)
	sfCorner.Parent = scrollFrame

	local layout = Instance.new("UIGridLayout")
	layout.CellSize = UDim2.fromOffset(180, 220)
	layout.CellPadding = UDim2.fromOffset(8, 8)
	layout.Parent = scrollFrame
	local sfPad = Instance.new("UIPadding")
	sfPad.PaddingTop = UDim.new(0, 12)
	sfPad.PaddingLeft = UDim.new(0, 12)
	sfPad.Parent = scrollFrame
end

local function refresh()
	if not gui then return end

	local bp = inventory.battlePass or { Tier = 0, XP = 0, Premium_Owned = false, Claimed_Rewards = {} }
	local progressBg = gui.Frame:FindFirstChild("ProgressBg") or gui:FindFirstChild("ProgressBg", true)
	if progressBg then
		local fill = progressBg:FindFirstChild("ProgressFill")
		local lbl = progressBg:FindFirstChild("TierLabel")
		local maxTier = MonetizationConfig.BattlePass.Tiers or 50
		local tier = bp.Tier or 0
		if fill then fill.Size = UDim2.fromScale(math.min(1, tier / maxTier), 1) end
		if lbl then lbl.Text = string.format("Tier %d / %d  •  %d XP", tier, maxTier, bp.XP or 0) end
	end

	-- Premium CTA
	local premiumCTA = gui:FindFirstChild("PremiumCTA", true)
	if premiumCTA then
		if bp.Premium_Owned then
			premiumCTA.Text = "✓ PREMIUM ACTIVE"
			premiumCTA.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
		else
			premiumCTA.Text = "UNLOCK PREMIUM PASS — 599 R$"
			premiumCTA.BackgroundColor3 = Color3.fromRGB(180, 80, 240)
		end
	end

	-- Tier cards
	local grid = gui:FindFirstChild("TierGrid", true)
	if not grid then return end
	for _, child in ipairs(grid:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	local maxTier = MonetizationConfig.BattlePass.Tiers or 50
	for tier = 1, maxTier do
		local card = Instance.new("Frame")
		card.BackgroundColor3 = (tier <= bp.Tier) and Color3.fromRGB(40, 50, 30) or Color3.fromRGB(25, 25, 40)
		card.BackgroundTransparency = 0.2
		card.BorderSizePixel = 0
		card.Parent = grid
		local cCorner = Instance.new("UICorner")
		cCorner.CornerRadius = UDim.new(0, 8)
		cCorner.Parent = card

		local tierLbl = Instance.new("TextLabel")
		tierLbl.Size = UDim2.new(1, 0, 0, 24)
		tierLbl.BackgroundTransparency = 1
		tierLbl.Text = "TIER " .. tier
		tierLbl.TextColor3 = Color3.fromRGB(255, 200, 80)
		tierLbl.Font = Enum.Font.GothamBold
		tierLbl.TextSize = 14
		tierLbl.Parent = card

		-- Free reward
		local freeReward = MonetizationConfig.BattlePass.FreeTrackRewards[tier]
		local premiumReward = MonetizationConfig.BattlePass.PremiumTrackRewards[tier]
		local function rewardDesc(reward)
			if not reward then return "—" end
			if reward.type == "skin" then return "Skin T" .. (reward.tier or 1) end
			if reward.type == "coins" then return (reward.amount or 0) .. " coins" end
			if reward.type == "case" then return "Case" end
			if reward.type == "spray" then return "Spray" end
			if reward.type == "callingcard" then return "Card" end
			return reward.type
		end

		local freeLbl = Instance.new("TextLabel")
		freeLbl.Size = UDim2.new(1, -10, 0, 70)
		freeLbl.Position = UDim2.fromOffset(5, 30)
		freeLbl.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
		freeLbl.BackgroundTransparency = 0.3
		freeLbl.Text = "FREE\n" .. rewardDesc(freeReward)
		freeLbl.TextColor3 = Color3.fromRGB(220, 220, 240)
		freeLbl.Font = Enum.Font.GothamBold
		freeLbl.TextSize = 11
		freeLbl.TextWrapped = true
		freeLbl.Parent = card
		local fCorner = Instance.new("UICorner")
		fCorner.CornerRadius = UDim.new(0, 4)
		fCorner.Parent = freeLbl

		local premLbl = Instance.new("TextLabel")
		premLbl.Size = UDim2.new(1, -10, 0, 70)
		premLbl.Position = UDim2.fromOffset(5, 108)
		premLbl.BackgroundColor3 = bp.Premium_Owned and Color3.fromRGB(80, 50, 100) or Color3.fromRGB(40, 40, 55)
		premLbl.BackgroundTransparency = 0.3
		premLbl.Text = "PREMIUM\n" .. rewardDesc(premiumReward)
		premLbl.TextColor3 = bp.Premium_Owned and Color3.fromRGB(255, 200, 80) or Color3.fromRGB(140, 140, 160)
		premLbl.Font = Enum.Font.GothamBold
		premLbl.TextSize = 11
		premLbl.TextWrapped = true
		premLbl.Parent = card
		local pCorner = Instance.new("UICorner")
		pCorner.CornerRadius = UDim.new(0, 4)
		pCorner.Parent = premLbl

		-- Claim button (only if unlocked + not yet claimed)
		local claimedFree = (bp.Claimed_Rewards or {})["free_" .. tier]
		local claimedPremium = (bp.Claimed_Rewards or {})["premium_" .. tier]
		if tier <= bp.Tier and freeReward and not claimedFree then
			local btn = Instance.new("TextButton")
			btn.AnchorPoint = Vector2.new(1, 0)
			btn.Position = UDim2.new(1, -5, 0, 32)
			btn.Size = UDim2.fromOffset(36, 20)
			btn.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
			btn.Text = "F✓"
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			btn.Font = Enum.Font.GothamBold
			btn.TextSize = 11
			btn.BorderSizePixel = 0
			btn.Parent = card
			local bCorner = Instance.new("UICorner")
			bCorner.CornerRadius = UDim.new(0, 4)
			bCorner.Parent = btn
			btn.Activated:Connect(function()
				Remotes.ClaimBPReward:FireServer(tier, "free")
			end)
		end
		if tier <= bp.Tier and bp.Premium_Owned and premiumReward and not claimedPremium then
			local btn = Instance.new("TextButton")
			btn.AnchorPoint = Vector2.new(1, 0)
			btn.Position = UDim2.new(1, -5, 0, 110)
			btn.Size = UDim2.fromOffset(36, 20)
			btn.BackgroundColor3 = Color3.fromRGB(180, 80, 240)
			btn.Text = "P✓"
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			btn.Font = Enum.Font.GothamBold
			btn.TextSize = 11
			btn.BorderSizePixel = 0
			btn.Parent = card
			local bCorner = Instance.new("UICorner")
			bCorner.CornerRadius = UDim.new(0, 4)
			bCorner.Parent = btn
			btn.Activated:Connect(function()
				Remotes.ClaimBPReward:FireServer(tier, "premium")
			end)
		end

		-- Status row
		local status = Instance.new("TextLabel")
		status.AnchorPoint = Vector2.new(0, 1)
		status.Position = UDim2.new(0, 5, 1, -5)
		status.Size = UDim2.new(1, -10, 0, 16)
		status.BackgroundTransparency = 1
		if tier <= bp.Tier then
			status.Text = "✓ UNLOCKED"
			status.TextColor3 = Color3.fromRGB(80, 220, 120)
		else
			status.Text = "LOCKED"
			status.TextColor3 = Color3.fromRGB(120, 120, 130)
		end
		status.Font = Enum.Font.GothamBold
		status.TextSize = 10
		status.Parent = card
	end
end

function BattlePassController.Start()
	buildGui()

	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.P then
			menuOpen = not menuOpen
			gui.Enabled = menuOpen
			if menuOpen then
				Remotes.RequestInventory:FireServer()
			end
		end
	end)

	-- Use inventory snapshot for BP data
	Remotes.UpdateInventory.OnClientEvent:Connect(function(data)
		if data then
			inventory.battlePass = data.battlePass or { Tier = 0, XP = 0, Premium_Owned = false, Claimed_Rewards = {} }
			if menuOpen then refresh() end
		end
	end)

	-- Refresh after claim
	Remotes.BPRewardClaimed.OnClientEvent:Connect(function(tier, track, success)
		if success then
			Remotes.RequestInventory:FireServer()
		end
	end)
end

return BattlePassController
