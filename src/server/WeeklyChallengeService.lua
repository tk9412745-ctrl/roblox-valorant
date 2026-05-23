-- WeeklyChallengeService: 3 weekly tasks, większe rewards, reset co 7 dni

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local WeeklyChallengeService = {}
local PlayerData

function WeeklyChallengeService.Init(deps)
	PlayerData = deps.playerData
end

local CHALLENGE_POOL = {
	{ id = "w_kills_50",    desc = "Get 50 kills this week",         stat = "kills",    target = 50,  reward = 1500 },
	{ id = "w_wins_5",      desc = "Win 5 matches this week",        stat = "wins",     target = 5,   reward = 2000 },
	{ id = "w_headshots_15", desc = "Get 15 headshot kills",         stat = "headshots", target = 15, reward = 1500 },
	{ id = "w_matches_10",  desc = "Play 10 matches this week",      stat = "matches",  target = 10,  reward = 1000 },
	{ id = "w_plants_10",   desc = "Plant the spike 10 times",       stat = "plants",   target = 10,  reward = 1200 },
	{ id = "w_cases_3",     desc = "Open 3 cases this week",         stat = "casesOpened", target = 3, reward = 800 },
}

local SECONDS_IN_WEEK = 604800

local function pickRandomChallenges(count)
	local pool = table.clone(CHALLENGE_POOL)
	local result = {}
	for i = 1, count do
		if #pool == 0 then break end
		local idx = math.random(1, #pool)
		table.insert(result, table.clone(pool[idx]))
		table.remove(pool, idx)
	end
	for _, c in ipairs(result) do
		c.progress = 0
		c.completed = false
	end
	return result
end

local function shouldReset(profile)
	if not profile.WeeklyChallenges then return true end
	local lastReset = profile.WeeklyChallenges.lastReset or 0
	return os.time() - lastReset >= SECONDS_IN_WEEK
end

local function resetForPlayer(player)
	local profile = PlayerData.Get(player)
	if not profile then return end
	math.randomseed(os.time() + player.UserId * 7)
	profile.WeeklyChallenges = {
		lastReset = os.time(),
		challenges = pickRandomChallenges(3),
	}
end

function WeeklyChallengeService.RecordProgress(player, statName, amount)
	local profile = PlayerData.Get(player)
	if not profile then return end
	if shouldReset(profile) then resetForPlayer(player) end

	for _, c in ipairs(profile.WeeklyChallenges.challenges) do
		if c.stat == statName and not c.completed then
			c.progress = math.min(c.progress + (amount or 1), c.target)
			if c.progress >= c.target then
				c.completed = true
				profile.Coins = (profile.Coins or 0) + (c.reward or 0)
				Remotes.ChallengeCompleted:FireClient(player, c.id, c.desc, c.reward)
			end
		end
	end
end

function WeeklyChallengeService.Start()
	Players.PlayerAdded:Connect(function(player)
		task.wait(3)
		local profile = PlayerData.Get(player)
		if profile and shouldReset(profile) then resetForPlayer(player) end
	end)
end

return WeeklyChallengeService
