-- LoginBonusService: daily login streak + bonus coins

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local LoginBonusService = {}
local PlayerData

function LoginBonusService.Init(deps)
	PlayerData = deps.playerData
end

local SECONDS_IN_DAY = 86400

local function getDayNumber(timestamp)
	return math.floor((timestamp or os.time()) / SECONDS_IN_DAY)
end

local STREAK_REWARDS = {
	[1] = 100,
	[2] = 150,
	[3] = 200,
	[4] = 300,
	[5] = 400,
	[6] = 500,
	[7] = 1000,  -- milestone
}

local function getRewardForDay(day)
	day = math.min(day, 7)  -- cap at 7
	return STREAK_REWARDS[day] or 100
end

function LoginBonusService.CheckPlayer(player)
	local profile = PlayerData.Get(player)
	if not profile then return end
	profile.LoginStreak = profile.LoginStreak or { count = 0, lastLogin = 0 }

	local today = getDayNumber(os.time())
	local lastDay = getDayNumber(profile.LoginStreak.lastLogin)

	if today == lastDay then
		-- Already claimed today
		return
	end

	if today - lastDay == 1 then
		-- Consecutive day
		profile.LoginStreak.count += 1
	else
		-- Streak broken
		profile.LoginStreak.count = 1
	end

	-- Cap at 7 for reset
	if profile.LoginStreak.count > 7 then
		profile.LoginStreak.count = 1
	end

	local reward = getRewardForDay(profile.LoginStreak.count)
	profile.Coins = (profile.Coins or 0) + reward
	profile.LoginStreak.lastLogin = os.time()

	-- Notify client
	Remotes.AchievementUnlocked:FireClient(
		player,
		"login_" .. profile.LoginStreak.count,
		"Daily Login Bonus",
		"Day " .. profile.LoginStreak.count .. " of streak",
		"🎁",
		reward
	)
end

function LoginBonusService.Start()
	Players.PlayerAdded:Connect(function(player)
		task.wait(3)  -- wait for profile to load
		LoginBonusService.CheckPlayer(player)
	end)
	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(LoginBonusService.CheckPlayer, player)
	end
end

return LoginBonusService
