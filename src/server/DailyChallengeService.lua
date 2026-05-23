-- DailyChallengeService: 3 dzienne taski + bonus coins, reset 24h

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local DailyChallengeService = {}
local PlayerData

function DailyChallengeService.Init(deps)
	PlayerData = deps.playerData
end

-- Challenge templates (random pool)
local CHALLENGE_POOL = {
	{ id = "kills_5",      desc = "Get 5 kills",                   stat = "kills",    target = 5,  reward = 200 },
	{ id = "kills_10",     desc = "Get 10 kills",                  stat = "kills",    target = 10, reward = 400 },
	{ id = "kills_20",     desc = "Get 20 kills",                  stat = "kills",    target = 20, reward = 800 },
	{ id = "headshots_3",  desc = "Get 3 headshot kills",          stat = "headshots", target = 3,  reward = 300 },
	{ id = "plants_2",     desc = "Plant the spike 2 times",       stat = "plants",   target = 2,  reward = 300 },
	{ id = "defuses_2",    desc = "Defuse the spike 2 times",      stat = "defuses",  target = 2,  reward = 300 },
	{ id = "matches_3",    desc = "Play 3 matches",                stat = "matches",  target = 3,  reward = 200 },
	{ id = "wins_2",       desc = "Win 2 matches",                 stat = "wins",     target = 2,  reward = 500 },
	{ id = "agent_jett",   desc = "Get 3 kills as Jett",           stat = "kills_jett", target = 3, reward = 250 },
	{ id = "agent_sage",   desc = "Heal teammates 3 times",        stat = "heals",    target = 3,  reward = 250 },
	{ id = "cases_1",      desc = "Open 1 case",                   stat = "casesOpened", target = 1, reward = 100 },
}

local SECONDS_IN_DAY = 86400

local function pickRandomChallenges(count)
	local pool = table.clone(CHALLENGE_POOL)
	local result = {}
	for i = 1, count do
		if #pool == 0 then break end
		local idx = math.random(1, #pool)
		table.insert(result, table.clone(pool[idx]))
		table.remove(pool, idx)
	end
	-- Add progress = 0 to each
	for _, c in ipairs(result) do
		c.progress = 0
		c.completed = false
	end
	return result
end

local function shouldReset(profile)
	if not profile.DailyChallenges then return true end
	local lastReset = profile.DailyChallenges.lastReset or 0
	return os.time() - lastReset >= SECONDS_IN_DAY
end

local function resetForPlayer(player)
	local profile = PlayerData.Get(player)
	if not profile then return end
	math.randomseed(os.time() + player.UserId)
	profile.DailyChallenges = {
		lastReset = os.time(),
		challenges = pickRandomChallenges(3),
	}
end

function DailyChallengeService.GetChallenges(player)
	local profile = PlayerData.Get(player)
	if not profile then return {} end
	if shouldReset(profile) then resetForPlayer(player) end
	return profile.DailyChallenges and profile.DailyChallenges.challenges or {}
end

function DailyChallengeService.RecordProgress(player, statName, amount)
	local profile = PlayerData.Get(player)
	if not profile then return end
	if shouldReset(profile) then resetForPlayer(player) end

	local changed = false
	for _, c in ipairs(profile.DailyChallenges.challenges) do
		if c.stat == statName and not c.completed then
			c.progress = math.min(c.progress + (amount or 1), c.target)
			if c.progress >= c.target then
				c.completed = true
				profile.Coins = (profile.Coins or 0) + (c.reward or 0)
				-- Notify
				Remotes.ChallengeCompleted:FireClient(player, c.id, c.desc, c.reward)
			end
			changed = true
		end
	end

	if changed then
		Remotes.UpdateChallenges:FireClient(player, profile.DailyChallenges.challenges)
	end
end

function DailyChallengeService.SendInitial(player)
	local challenges = DailyChallengeService.GetChallenges(player)
	Remotes.UpdateChallenges:FireClient(player, challenges)
end

function DailyChallengeService.Start()
	Players.PlayerAdded:Connect(function(player)
		task.wait(3)
		DailyChallengeService.SendInitial(player)
	end)
end

return DailyChallengeService
