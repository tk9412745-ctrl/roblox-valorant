-- MonetizationService: MarketplaceService integration
-- Game Passes (permanent) + Developer Products (consumable)
-- ProcessReceipt is the CRITICAL handler — must persist to DataStore BEFORE returning PurchaseGranted

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MonetizationConfig = require(ReplicatedStorage.Shared.MonetizationConfig)

local MonetizationService = {}
local PlayerData, BattlePassService, CaseService

function MonetizationService.Init(deps)
	PlayerData = deps.playerData
	BattlePassService = deps.battlePass
	CaseService = deps.caseService
end

-- ============================================================
-- PRODUCT ID MAPPING — replace with REAL Robux IDs after creating in Roblox dev portal
-- ============================================================
-- Developer Products (consumable)
MonetizationService.DevProducts = {
	-- coins
	[1000001] = { type = "coins", amount = 500 },
	[1000002] = { type = "coins", amount = 1200 },
	[1000003] = { type = "coins", amount = 3000 },
	[1000004] = { type = "coins", amount = 7000 },
	[1000005] = { type = "coins", amount = 20000 },
	-- cases
	[1000101] = { type = "case", caseId = "standard_case" },
	[1000102] = { type = "case", caseId = "premium_case" },
	[1000103] = { type = "case", caseId = "event_case" },
	[1000104] = { type = "case_bundle", caseId = "premium_case", quantity = 3 },
	-- battle pass
	[1000201] = { type = "battlepass" },
	[1000202] = { type = "battlepass_tier_skip", count = 1 },
	[1000203] = { type = "battlepass_tier_skip", count = 5 },
}

-- Game Passes (permanent)
MonetizationService.GamePasses = {
	[2000001] = { type = "vip_pass" },
	[2000002] = { type = "inventory_expansion" },
	[2000003] = { type = "credit_match_bonus" },
	[2000004] = { type = "founders_pack" },
}

-- ============================================================
-- Product handlers
-- ============================================================
local function handleDevProduct(receipt, player)
	local product = MonetizationService.DevProducts[receipt.ProductId]
	if not product then return false end

	if product.type == "coins" then
		PlayerData.AddCoins(player, product.amount)
		return true
	elseif product.type == "case" then
		CaseService.GrantCaseFromPurchase(player, product.caseId)
		return true
	elseif product.type == "case_bundle" then
		for i = 1, (product.quantity or 1) do
			CaseService.GrantCaseFromPurchase(player, product.caseId)
		end
		return true
	elseif product.type == "battlepass" then
		BattlePassService.GrantPremium(player)
		return true
	elseif product.type == "battlepass_tier_skip" then
		BattlePassService.SkipTiers(player, product.count or 1)
		return true
	end
	return false
end

-- ============================================================
-- ProcessReceipt — SINGLE callback for all developer products
-- ============================================================
MarketplaceService.ProcessReceipt = function(receipt)
	local player = Players:GetPlayerByUserId(receipt.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Wait for profile to load
	local profile = PlayerData.WaitForProfile(player, 5)
	if not profile then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local success, granted = pcall(handleDevProduct, receipt, player)
	if not success or not granted then
		warn("[Monetization] ProcessReceipt failed for product " .. receipt.ProductId)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Track Robux spend for analytics
	profile.Robux_Spent = (profile.Robux_Spent or 0) + (receipt.CurrencySpent or 0)

	return Enum.ProductPurchaseDecision.PurchaseGranted
end

-- ============================================================
-- Game Pass ownership check
-- ============================================================
local ownedPasses = {}  -- [userId] = { [passId] = true }

function MonetizationService.OwnsGamePass(player, passId)
	if ownedPasses[player.UserId] and ownedPasses[player.UserId][passId] then
		return true
	end
	local success, owns = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId)
	end)
	if success and owns then
		ownedPasses[player.UserId] = ownedPasses[player.UserId] or {}
		ownedPasses[player.UserId][passId] = true
		return true
	end
	return false
end

function MonetizationService.OnPlayerJoin(player)
	ownedPasses[player.UserId] = {}
	for passId, _ in pairs(MonetizationService.GamePasses) do
		task.spawn(function()
			local owns = MonetizationService.OwnsGamePass(player, passId)
			if owns then
				print("[Monetization] " .. player.Name .. " owns pass " .. passId)
			end
		end)
	end
end

function MonetizationService.Start()
	Players.PlayerAdded:Connect(MonetizationService.OnPlayerJoin)
	for _, player in ipairs(Players:GetPlayers()) do
		MonetizationService.OnPlayerJoin(player)
	end
	Players.PlayerRemoving:Connect(function(player)
		ownedPasses[player.UserId] = nil
	end)
end

return MonetizationService
