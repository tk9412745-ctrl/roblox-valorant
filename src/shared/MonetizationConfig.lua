-- MonetizationConfig: Skin tiery, cases, Battle Pass, Game Passes, currency packs
-- WAŻNE: Drop rates MUSZĄ być wyświetlone w UI przed zakupem (Roblox policy)
-- UK <18: PolicyService:GetPolicyInfoForPlayerAsync → ArePaidRandomItemsRestricted=true → ukryć crate UI

local MonetizationConfig = {}

-- ============================================================
-- CURRENCY ARCHITECTURE
-- ============================================================

MonetizationConfig.Currencies = {
	Credits = {  -- soft currency, in-match buy menu
		DisplayName = "Credits",
		StartingBalance = 800,
		MaxBalance = 9000,
		EarnedVia = "Match rewards (kills, wins, plants)",
	},
	Coins = {  -- soft currency, persistent (shop, cases)
		DisplayName = "Coins",
		StartingBalance = 0,
		MaxBalance = math.huge,
		EarnedVia = "Match XP, daily challenges, BP progression",
	},
	Robux = {  -- hard currency, real money
		DisplayName = "Robux",
		EarnedVia = "Purchase via MarketplaceService",
	},
}

-- Currency pack developer products (Robux → Coins)
MonetizationConfig.CurrencyPacks = {
	{ id = "coins_500",   coins = 500,   robux = 99,   bonusPct = 0 },
	{ id = "coins_1200",  coins = 1200,  robux = 199,  bonusPct = 20 },
	{ id = "coins_3000",  coins = 3000,  robux = 399,  bonusPct = 50 },  -- breakpoint deal
	{ id = "coins_7000",  coins = 7000,  robux = 799,  bonusPct = 75 },  -- whale-friendly
	{ id = "coins_20000", coins = 20000, robux = 1999, bonusPct = 100 }, -- best value, dolphin/whale
}

-- ============================================================
-- SKIN TIER SYSTEM (5 tierów, wzorowane na Valorant)
-- ============================================================

MonetizationConfig.SkinTiers = {
	{
		Tier = 1,
		Name = "Standard",
		PriceRobux = 99,
		PriceCoins = 1000,
		Features = { "Texture variant", "Color recolor" },
		FreeViaGameplay = true,  -- dostępne przez Coins z gry
		Rarity = "Common",
	},
	{
		Tier = 2,
		Name = "Refined",
		PriceRobux = 299,
		PriceCoins = 3000,
		Features = { "Custom mesh", "Custom equip animation", "1 chroma variant" },
		FreeViaGameplay = true,
		Rarity = "Uncommon",
	},
	{
		Tier = 3,
		Name = "Elite",
		PriceRobux = 699,
		PriceCoins = nil,  -- NIE dostępne via Coins (tylko Robux)
		Features = { "Custom reload animation", "Custom fire VFX", "Custom SFX", "Kill banner", "3 chromas" },
		FreeViaGameplay = false,
		Rarity = "Rare",
	},
	{
		Tier = 4,
		Name = "Legendary",
		PriceRobux = 1299,
		PriceCoins = nil,
		Features = { "All Elite features", "Finisher animation", "Variant kill counter on inspect" },
		FreeViaGameplay = false,
		LimitedTime = 30,  -- dni dostępności
		Rarity = "VeryRare",
	},
	{
		Tier = 5,
		Name = "Mythic",
		PriceRobux = 1999,
		PriceCoins = nil,
		Features = { "All Legendary features", "Evolving form (kills upgrade visuals)", "Custom death effect for victims" },
		FreeViaGameplay = false,
		BundleOnly = true,  -- tylko w bundlach event/season
		Rarity = "Legendary",
	},
}

-- ============================================================
-- CRATES / CASES
-- ============================================================

MonetizationConfig.Cases = {
	{
		Id = "standard_case",
		Name = "Standard Case",
		PriceRobux = 49,
		PriceCoins = 500,
		KeyRequired = false,
		DropRates = {
			Common = 0.60,     -- 60%
			Uncommon = 0.26,   -- 26%
			Rare = 0.10,       -- 10%
			VeryRare = 0.03,   -- 3%
			Legendary = 0.01,  -- 1%
		},
	},
	{
		Id = "premium_case",
		Name = "Premium Case",
		PriceRobux = 199,
		PriceCoins = nil,  -- tylko Robux
		KeyRequired = true,
		KeyPriceRobux = 49,
		DropRates = {
			Common = 0.0,
			Uncommon = 0.40,
			Rare = 0.38,
			VeryRare = 0.18,
			Legendary = 0.04,
		},
		BulkDeal = {
			Quantity = 3,
			PriceRobux = 549,  -- saves 48R$ vs 3×199
			SavingsR = 48,
		},
	},
	{
		Id = "event_case",
		Name = "Event Crate (Limited)",
		PriceRobux = 299,
		PriceCoins = nil,
		KeyRequired = false,
		LimitedTime = true,
		DropRates = {
			Common = 0.0,
			Uncommon = 0.30,
			Rare = 0.45,
			VeryRare = 0.20,
			Legendary = 0.05,
		},
	},
}

-- Bad luck protection: gwarancja Legendary po 50 cases bez Legendary
MonetizationConfig.BadLuckProtection = {
	Enabled = true,
	GuaranteeAfterCases = 50,
	IncreasePerCase = {  -- Phantom Forces style: rate rośnie z każdym openem
		Legendary = 0.0025,  -- +0.25% per case
		VeryRare = 0.005,    -- +0.5% per case
		Common = -0.005,     -- -0.5% per case
		Uncommon = -0.0025,  -- -0.25% per case
	},
}

-- ============================================================
-- BATTLE PASS
-- ============================================================

MonetizationConfig.BattlePass = {
	Name = "Season Pass",
	PriceRobux = 599,
	DurationDays = 60,
	Tiers = 50,
	EpilogueTiers = 5,
	FreeTrackRewards = {  -- 5-10 nagród przez 50 tierów
		[5] = { type = "spray", id = "spray_basic_1" },
		[10] = { type = "coins", amount = 100 },
		[15] = { type = "callingcard", id = "card_basic_1" },
		[25] = { type = "skin", tier = 1, weapon = "Classic" },
		[40] = { type = "spray", id = "spray_basic_2" },
		[50] = { type = "coins", amount = 500 },
	},
	PremiumTrackRewards = {
		-- Generuje >= 6000 Coins przez 50 tierów żeby gracz odzyskał koszt BP
		[1] = { type = "skin", tier = 1, weapon = "Vandal" },
		[5] = { type = "coins", amount = 200 },
		[10] = { type = "skin", tier = 2, weapon = "Ghost" },
		[15] = { type = "coins", amount = 400 },
		[20] = { type = "skin", tier = 2, weapon = "Phantom" },
		[25] = { type = "case", id = "premium_case" },
		[30] = { type = "skin", tier = 2, weapon = "Sheriff" },
		[35] = { type = "coins", amount = 1000 },
		[40] = { type = "skin", tier = 3, weapon = "Vandal" },
		[45] = { type = "coins", amount = 2000 },
		[50] = { type = "skin", tier = 3, weapon = "Knife", exclusive = true },  -- finale melee
	},
	TierSkipPriceRobux = 49,   -- per tier
	TierSkipMaxCount = 25,
	SubscriptionPriceRobux = 499,  -- recurring, saves 100R$ + bonus skin
}

-- ============================================================
-- GAME PASSES (one-time permanent purchases)
-- ============================================================

MonetizationConfig.GamePasses = {
	{
		Id = "vip_pass",
		Name = "VIP Pass",
		PriceRobux = 799,
		Benefits = { "+20% XP permanent", "Lobby chat color", "VIP tag", "Exclusive starter skin" },
	},
	{
		Id = "inventory_expansion",
		Name = "Inventory Expansion",
		PriceRobux = 299,
		Benefits = { "+50 inventory slots (default 50 → 100)" },
	},
	{
		Id = "credit_match_bonus",
		Name = "2× Credit Match Bonus",
		PriceRobux = 499,
		Benefits = { "Permanent 2× Credits earn from matches" },
	},
	{
		Id = "founders_pack",
		Name = "Founder's Pack",
		PriceRobux = 1499,
		LimitedTime = true,
		LimitedToDays = 30,
		Benefits = { "VIP Pass", "2× Credits Pass", "3 exclusive launch skins" },
	},
}

-- ============================================================
-- LIMITED TIME / EVENT BUNDLES
-- ============================================================

MonetizationConfig.SeasonalBundles = {
	Frequency = 60,  -- co 60 dni, aligned with BP season
	Contents = "4 weapons (Tier 3) + melee + buddy + spray",
	PriceRobux = 2499,
	StandalonePriceRobux = 3696,  -- gdyby kupić osobno
	SavingsPct = 32,
}

MonetizationConfig.ChampionsBundle = {
	Frequency = "Annual / event",  -- 1-2 razy w roku
	Contents = "Premium-tier set + cinematic finisher",
	PriceRobux = 3999,
	NeverReturns = true,
}

-- ============================================================
-- DAILY SHOP (rotating)
-- ============================================================

MonetizationConfig.DailyShop = {
	RotationHours = 24,
	ItemsPerDay = 6,
	TierMix = { "Tier1", "Tier2", "Tier3" },
}

-- ============================================================
-- NIGHT MARKET (Valorant equivalent, discount store)
-- ============================================================

MonetizationConfig.NightMarket = {
	FrequencyPerYear = 2,
	DurationDays = 7,
	DiscountRange = { 30, 50 },  -- 30-50% off
	ExcludedTiers = { 4, 5 },    -- nigdy Exclusive/Mythic
}

-- ============================================================
-- ROBLOX PLUS INTEGRATION (April 2026 feature)
-- ============================================================

MonetizationConfig.RobloxPlusPromo = {
	Enabled = true,
	PromoSlotInShop = true,
	-- Roblox absorbs the 10% Plus discount, dev gets full revenue
	-- Plus dev earns Robux per new subscriber acquired via game for 3 months
}

-- ============================================================
-- COMPLIANCE
-- ============================================================

MonetizationConfig.Compliance = {
	-- Mandatory: drop rates visible BEFORE purchase
	ShowDropRatesUI = true,
	-- UK <18 restriction via PolicyService
	CheckUKPolicyOnJoin = true,
	HideCratesForRestrictedUsers = true,
	-- No real-money trading
	AllowSecondaryMarket = false,
	-- Soft currency path exists to Tier 1-2 skins
	FreeToPlaySkinPath = true,
	-- Content maturity
	ContentMaturity = "Mild",  -- cartoon stylization, no excessive gore
	-- R15 character (42% DevEx boost)
	UseR15Character = true,
}

-- ============================================================
-- REVENUE TARGETS (modelowane na RIVALS @ 10% scale)
-- ============================================================

MonetizationConfig.RevenueTargets = {
	MonthlyGrossUSD = 174000,   -- target launch
	RevenueMix = {
		Cases = 0.45,            -- 45% przychód z case openings
		BattlePass = 0.25,       -- 25% recurring
		DirectSkinsAndBundles = 0.20,  -- 20% whale-driven
		GamePasses = 0.05,       -- 5% whale acquisition
		CurrencyPacks = 0.05,    -- 5% consumable
	},
}

-- ============================================================
-- LAUNCH CADENCE
-- ============================================================

MonetizationConfig.LaunchPlan = {
	Month1 = "5 weapons, 30 base skins (6/weapon), 8 Tier-2 skins, 2 Tier-3 skins, Standard Case, BP Season 1",
	Month2 = "First event (themed crate), 2 new weapons, 10 Tier-2 skins, Premium Case launches",
	Month3 = "BP Season 2, first Tier-4 Legendary bundle, Founder's Pack window closes",
	Month6 = "Tier-5 Mythic via mid-anniversary event",
}

return MonetizationConfig
