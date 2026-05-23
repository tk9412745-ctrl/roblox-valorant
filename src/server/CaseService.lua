-- CaseService: case opening with drop rates + bad luck protection
-- Compliance: drop rates MUST be displayed in UI before purchase (Roblox policy)
-- UK <18: blocked via PolicyService

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MonetizationConfig = require(ReplicatedStorage.Shared.MonetizationConfig)
local SkinDatabase = require(ReplicatedStorage.Shared.SkinDatabase)

local CaseService = {}
local PlayerData
local PolicyService

function CaseService.Init(deps)
	PlayerData = deps.playerData
	PolicyService = deps.policy
end

-- Rarity to skin tier mapping
local RARITY_TO_TIER = {
	Common = 1,
	Uncommon = 2,
	Rare = 3,
	VeryRare = 4,
	Legendary = 5,
}

local function rollRarity(case, profile)
	local rates = {}
	for rarity, baseRate in pairs(case.DropRates) do
		rates[rarity] = baseRate
	end

	-- Bad luck protection
	if MonetizationConfig.BadLuckProtection.Enabled then
		local cnt = profile.Consecutive_Cases_No_Legendary or 0
		if cnt >= MonetizationConfig.BadLuckProtection.GuaranteeAfterCases then
			return "Legendary"
		end
		for rarity, delta in pairs(MonetizationConfig.BadLuckProtection.IncreasePerCase) do
			if rates[rarity] then
				rates[rarity] = math.max(0, math.min(1, rates[rarity] + delta * cnt))
			end
		end
	end

	-- Normalize and roll
	local total = 0
	for _, r in pairs(rates) do total += r end
	if total <= 0 then return "Common" end

	local roll = math.random() * total
	local accum = 0
	for rarity, r in pairs(rates) do
		accum += r
		if roll <= accum then return rarity end
	end
	return "Common"
end

local function pickRandomSkinForTier(tier)
	local skins = SkinDatabase.GetByTier(tier)
	if #skins == 0 then return nil end
	return skins[math.random(1, #skins)]
end

function CaseService.GetCase(caseId)
	for _, c in ipairs(MonetizationConfig.Cases) do
		if c.Id == caseId then return c end
	end
	return nil
end

function CaseService.OpenCase(player, caseId)
	local case = CaseService.GetCase(caseId)
	if not case then return nil, "Invalid case" end

	-- UK <18 restriction check
	if PolicyService and PolicyService.IsRestricted(player) then
		return nil, "Restricted by policy"
	end

	local profile = PlayerData.Get(player)
	if not profile then return nil, "No profile" end

	-- Charge for case (Coins path)
	if case.PriceCoins then
		if (profile.Coins or 0) < case.PriceCoins then
			return nil, "Insufficient coins"
		end
		profile.Coins -= case.PriceCoins
	else
		return nil, "This case requires Robux purchase (use MarketplaceService)"
	end

	-- Roll rarity
	local rarity = rollRarity(case, profile)
	local tier = RARITY_TO_TIER[rarity] or 1
	local skin = pickRandomSkinForTier(tier)

	-- Bad luck counter update
	profile.Cases_Opened = (profile.Cases_Opened or 0) + 1
	if rarity == "Legendary" then
		profile.Consecutive_Cases_No_Legendary = 0
	else
		profile.Consecutive_Cases_No_Legendary = (profile.Consecutive_Cases_No_Legendary or 0) + 1
	end

	if not skin then return nil, "No skin in tier " .. tier end

	-- Grant (or duplicate refund)
	if profile.Owned_Skins[skin.Id] then
		-- Duplicate: refund partial coins (50% of tier-1 price = 50 coins)
		local refund = case.PriceCoins and math.floor(case.PriceCoins * 0.5) or 50
		profile.Coins += refund
		return {
			skin = skin,
			rarity = rarity,
			duplicate = true,
			refund = refund,
		}
	end
	PlayerData.GrantSkin(player, skin.Id)
	return {
		skin = skin,
		rarity = rarity,
		duplicate = false,
	}
end

-- Robux purchase path: triggered via MarketplaceService ProcessReceipt
function CaseService.GrantCaseFromPurchase(player, caseId)
	local case = CaseService.GetCase(caseId)
	if not case then return false end
	local profile = PlayerData.Get(player)
	if not profile then return false end

	-- Roll directly (Robux purchase = open immediately)
	local rarity = rollRarity(case, profile)
	local tier = RARITY_TO_TIER[rarity] or 1
	local skin = pickRandomSkinForTier(tier)

	profile.Cases_Opened = (profile.Cases_Opened or 0) + 1
	if rarity == "Legendary" then
		profile.Consecutive_Cases_No_Legendary = 0
	else
		profile.Consecutive_Cases_No_Legendary = (profile.Consecutive_Cases_No_Legendary or 0) + 1
	end

	if skin and not profile.Owned_Skins[skin.Id] then
		PlayerData.GrantSkin(player, skin.Id)
	end
	return true
end

return CaseService
