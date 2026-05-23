-- BattlePassService: XP tracking, tier progression, reward claiming

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MonetizationConfig = require(ReplicatedStorage.Shared.MonetizationConfig)
local SkinDatabase = require(ReplicatedStorage.Shared.SkinDatabase)

local BattlePassService = {}
local PlayerData

local XP_PER_TIER = 1000
local XP_PER_KILL = 50
local XP_PER_WIN = 500
local XP_PER_MATCH = 200

function BattlePassService.Init(deps)
	PlayerData = deps.playerData
end

local function calculateTier(xp)
	return math.floor((xp or 0) / XP_PER_TIER)
end

function BattlePassService.AddXP(player, amount)
	local profile = PlayerData.Get(player)
	if not profile then return end
	profile.Battle_Pass.XP = (profile.Battle_Pass.XP or 0) + amount
	profile.Battle_Pass.Tier = calculateTier(profile.Battle_Pass.XP)
end

function BattlePassService.OnKill(player)
	BattlePassService.AddXP(player, XP_PER_KILL)
end

function BattlePassService.OnMatchEnd(player, won)
	BattlePassService.AddXP(player, XP_PER_MATCH + (won and XP_PER_WIN or 0))
end

function BattlePassService.GetTier(player)
	local profile = PlayerData.Get(player)
	if not profile then return 0 end
	return profile.Battle_Pass.Tier or 0
end

function BattlePassService.GetXP(player)
	local profile = PlayerData.Get(player)
	if not profile then return 0 end
	return profile.Battle_Pass.XP or 0
end

function BattlePassService.HasPremium(player)
	local profile = PlayerData.Get(player)
	if not profile then return false end
	return profile.Battle_Pass.Premium_Owned == true
end

function BattlePassService.GrantPremium(player)
	local profile = PlayerData.Get(player)
	if not profile then return false end
	profile.Battle_Pass.Premium_Owned = true
	return true
end

function BattlePassService.SkipTiers(player, count)
	local profile = PlayerData.Get(player)
	if not profile then return false end
	if count > MonetizationConfig.BattlePass.TierSkipMaxCount then
		count = MonetizationConfig.BattlePass.TierSkipMaxCount
	end
	profile.Battle_Pass.XP = (profile.Battle_Pass.XP or 0) + count * XP_PER_TIER
	profile.Battle_Pass.Tier = calculateTier(profile.Battle_Pass.XP)
	return true
end

local function grantReward(player, reward)
	if not reward then return end
	if reward.type == "skin" then
		-- Map tier to specific skin (simplified: first skin of tier+weapon if available)
		local skinIdToGrant
		for _, skin in pairs(SkinDatabase.Skins) do
			if skin.Tier == reward.tier and skin.Weapon == reward.weapon then
				skinIdToGrant = skin.Id
				break
			end
		end
		if skinIdToGrant then
			PlayerData.GrantSkin(player, skinIdToGrant)
		end
	elseif reward.type == "coins" then
		PlayerData.AddCoins(player, reward.amount or 0)
	elseif reward.type == "case" then
		local profile = PlayerData.Get(player)
		if profile then
			-- Grant as deferred (player opens manually) — simplified: just give equivalent coins
			PlayerData.AddCoins(player, 500)
		end
	end
end

function BattlePassService.ClaimReward(player, tier, track)
	-- track: "free" or "premium"
	local profile = PlayerData.Get(player)
	if not profile then return false end
	if (profile.Battle_Pass.Tier or 0) < tier then return false end

	local claimKey = track .. "_" .. tier
	if profile.Battle_Pass.Claimed_Rewards[claimKey] then return false end

	if track == "premium" and not profile.Battle_Pass.Premium_Owned then return false end

	local rewardTable = track == "free" and MonetizationConfig.BattlePass.FreeTrackRewards or MonetizationConfig.BattlePass.PremiumTrackRewards
	local reward = rewardTable[tier]
	if not reward then return false end

	grantReward(player, reward)
	profile.Battle_Pass.Claimed_Rewards[claimKey] = true
	return true
end

function BattlePassService.GetUnclaimedRewards(player)
	local profile = PlayerData.Get(player)
	if not profile then return {} end
	local maxTier = profile.Battle_Pass.Tier or 0
	local unclaimed = {}
	for tier = 1, maxTier do
		if MonetizationConfig.BattlePass.FreeTrackRewards[tier]
			and not profile.Battle_Pass.Claimed_Rewards["free_" .. tier] then
			table.insert(unclaimed, { tier = tier, track = "free" })
		end
		if profile.Battle_Pass.Premium_Owned
			and MonetizationConfig.BattlePass.PremiumTrackRewards[tier]
			and not profile.Battle_Pass.Claimed_Rewards["premium_" .. tier] then
			table.insert(unclaimed, { tier = tier, track = "premium" })
		end
	end
	return unclaimed
end

function BattlePassService.Start()
	local Players = game:GetService("Players")
	Remotes.ClaimBPReward.OnServerEvent:Connect(function(player, tier, track)
		if typeof(tier) ~= "number" or typeof(track) ~= "string" then return end
		if track ~= "free" and track ~= "premium" then return end
		local ok = BattlePassService.ClaimReward(player, tier, track)
		Remotes.BPRewardClaimed:FireClient(player, tier, track, ok)
	end)
end

return BattlePassService
