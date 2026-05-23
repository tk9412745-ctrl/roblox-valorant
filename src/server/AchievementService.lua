local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AchievementDatabase = require(ReplicatedStorage.Shared.AchievementDatabase)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local AchievementService = {}
local PlayerData

function AchievementService.Init(deps)
	PlayerData = deps.playerData
end

local function getStat(profile, statName)
	if statName == "kills" then return (profile.Stats and profile.Stats.Kills) or 0 end
	if statName == "headshotKills" then return (profile.Stats and profile.Stats.HeadshotKills) or 0 end
	if statName == "matchesPlayed" then return (profile.Stats and profile.Stats.MatchesPlayed) or 0 end
	if statName == "matchesWon" then return (profile.Stats and profile.Stats.MatchesWon) or 0 end
	if statName == "plants" then return (profile.Stats and profile.Stats.Plants) or 0 end
	if statName == "defuses" then return (profile.Stats and profile.Stats.Defuses) or 0 end
	if statName == "casesOpened" then return profile.Cases_Opened or 0 end
	return 0
end

function AchievementService.CheckPlayer(player)
	local profile = PlayerData.Get(player)
	if not profile then return end
	profile.Achievements = profile.Achievements or {}

	for _, ach in ipairs(AchievementDatabase.Achievements) do
		if not profile.Achievements[ach.id] then
			local statVal = getStat(profile, ach.stat)
			if statVal >= ach.threshold then
				profile.Achievements[ach.id] = { unlockedAt = os.time() }
				-- Grant reward
				profile.Coins = (profile.Coins or 0) + (ach.reward or 0)
				-- Notify client
				Remotes.AchievementUnlocked:FireClient(player, ach.id, ach.name, ach.desc, ach.icon, ach.reward)
			end
		end
	end
end

function AchievementService.RecordKill(player, isHeadshot)
	local profile = PlayerData.Get(player)
	if not profile then return end
	profile.Stats = profile.Stats or {}
	profile.Stats.Kills = (profile.Stats.Kills or 0) + 1
	if isHeadshot then
		profile.Stats.HeadshotKills = (profile.Stats.HeadshotKills or 0) + 1
	end
	AchievementService.CheckPlayer(player)
end

function AchievementService.RecordMatchEnd(player, won)
	local profile = PlayerData.Get(player)
	if not profile then return end
	profile.Stats = profile.Stats or {}
	profile.Stats.MatchesPlayed = (profile.Stats.MatchesPlayed or 0) + 1
	if won then
		profile.Stats.MatchesWon = (profile.Stats.MatchesWon or 0) + 1
		profile.Stats.WinStreak = (profile.Stats.WinStreak or 0) + 1
		profile.Stats.BestWinStreak = math.max(profile.Stats.BestWinStreak or 0, profile.Stats.WinStreak)
	else
		profile.Stats.WinStreak = 0
	end
	AchievementService.CheckPlayer(player)
end

function AchievementService.RecordPlant(player)
	local profile = PlayerData.Get(player)
	if not profile then return end
	profile.Stats = profile.Stats or {}
	profile.Stats.Plants = (profile.Stats.Plants or 0) + 1
	AchievementService.CheckPlayer(player)
end

function AchievementService.RecordDefuse(player)
	local profile = PlayerData.Get(player)
	if not profile then return end
	profile.Stats = profile.Stats or {}
	profile.Stats.Defuses = (profile.Stats.Defuses or 0) + 1
	AchievementService.CheckPlayer(player)
end

function AchievementService.Start()
	Players.PlayerAdded:Connect(function(player)
		task.wait(3)
		AchievementService.CheckPlayer(player)
	end)
end

return AchievementService
