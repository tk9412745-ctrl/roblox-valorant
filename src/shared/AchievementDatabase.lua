-- AchievementDatabase: lista achievements + warunki + nagrody

local AchievementDatabase = {}

AchievementDatabase.Achievements = {
	{ id = "first_kill", name = "First Blood", desc = "Get your first kill", icon = "🎯", reward = 50, stat = "kills", threshold = 1 },
	{ id = "kills_10", name = "Rookie", desc = "Get 10 kills total", icon = "🔫", reward = 100, stat = "kills", threshold = 10 },
	{ id = "kills_100", name = "Veteran", desc = "Get 100 kills total", icon = "💀", reward = 500, stat = "kills", threshold = 100 },
	{ id = "kills_1000", name = "Legend", desc = "Get 1000 kills total", icon = "👑", reward = 2000, stat = "kills", threshold = 1000 },
	{ id = "hs_10", name = "Sharpshooter", desc = "Get 10 headshot kills", icon = "🎯", reward = 200, stat = "headshotKills", threshold = 10 },
	{ id = "hs_50", name = "Headhunter", desc = "Get 50 headshot kills", icon = "🎯", reward = 500, stat = "headshotKills", threshold = 50 },
	{ id = "matches_10", name = "Dedicated", desc = "Play 10 matches", icon = "🏆", reward = 200, stat = "matchesPlayed", threshold = 10 },
	{ id = "wins_5", name = "Winner", desc = "Win 5 matches", icon = "🏆", reward = 300, stat = "matchesWon", threshold = 5 },
	{ id = "wins_50", name = "Champion", desc = "Win 50 matches", icon = "🏆", reward = 2000, stat = "matchesWon", threshold = 50 },
	{ id = "plants_5", name = "Demolitionist", desc = "Plant 5 spikes", icon = "💣", reward = 150, stat = "plants", threshold = 5 },
	{ id = "defuses_5", name = "Defuser", desc = "Defuse 5 spikes", icon = "🛡️", reward = 150, stat = "defuses", threshold = 5 },
	{ id = "casesOpened_10", name = "Lucky", desc = "Open 10 cases", icon = "📦", reward = 100, stat = "casesOpened", threshold = 10 },
}

function AchievementDatabase.GetById(id)
	for _, a in ipairs(AchievementDatabase.Achievements) do
		if a.id == id then return a end
	end
	return nil
end

return AchievementDatabase
