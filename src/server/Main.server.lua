local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Initialize Remotes (creates RemoteEvents in ReplicatedStorage.Remotes)
require(ReplicatedStorage.Shared.Remotes)

-- Load services
local CombatService = require(ServerScriptService.CombatService)
local SpawnService = require(ServerScriptService.SpawnService)
local MapBuilder = require(ServerScriptService.MapBuilder)
local TeamService = require(ServerScriptService.TeamService)
local EconomyManager = require(ServerScriptService.EconomyManager)
local UltPointsManager = require(ServerScriptService.UltPointsManager)
local MatchManager = require(ServerScriptService.MatchManager)
local SpikeController = require(ServerScriptService.SpikeController)
local RoundManager = require(ServerScriptService.RoundManager)
local AbilityService = require(ServerScriptService.AbilityService)
local Jett = require(ServerScriptService.Jett)
local Sage = require(ServerScriptService.Sage)
local Phoenix = require(ServerScriptService.Phoenix)
local Cypher = require(ServerScriptService.Cypher)
local Reyna = require(ServerScriptService.Reyna)
local KAYO = require(ServerScriptService.KAYO)
local Sova = require(ServerScriptService.Sova)
local Brimstone = require(ServerScriptService.Brimstone)
local Viper = require(ServerScriptService.Viper)
local Astra = require(ServerScriptService.Astra)
local Omen = require(ServerScriptService.Omen)
local Killjoy = require(ServerScriptService.Killjoy)
local PlayerData = require(ServerScriptService.PlayerData)
local SkinService = require(ServerScriptService.SkinService)
local PolicyService = require(ServerScriptService.PolicyService)
local CaseService = require(ServerScriptService.CaseService)
local BattlePassService = require(ServerScriptService.BattlePassService)
local MonetizationService = require(ServerScriptService.MonetizationService)
local BuyService = require(ServerScriptService.BuyService)
local MapRotation = require(ServerScriptService.MapRotation)
local AntiCheat = require(ServerScriptService.AntiCheat)
local StatsManager = require(ServerScriptService.StatsManager)
local SettingsService = require(ServerScriptService.SettingsService)
local BotManager = require(ServerScriptService.BotManager)
local PracticeRange = require(ServerScriptService.PracticeRange)
local RankService = require(ServerScriptService.RankService)
local InventoryService = require(ServerScriptService.InventoryService)
local PingService = require(ServerScriptService.PingService)
local MapVoteService = require(ServerScriptService.MapVoteService)
local AchievementService = require(ServerScriptService.AchievementService)
local DailyChallengeService = require(ServerScriptService.DailyChallengeService)
local WeeklyChallengeService = require(ServerScriptService.WeeklyChallengeService)
local LeaderboardService = require(ServerScriptService.LeaderboardService)
local CustomGameService = require(ServerScriptService.CustomGameService)
local RagdollService = require(ServerScriptService.RagdollService)
local DeathmatchService = require(ServerScriptService.DeathmatchService)
local WeaponDropService = require(ServerScriptService.WeaponDropService)
local FriendService = require(ServerScriptService.FriendService)
local LoginBonusService = require(ServerScriptService.LoginBonusService)
local ChatService = require(ServerScriptService.ChatService)
local LevelService = require(ServerScriptService.LevelService)
local FallDamageService = require(ServerScriptService.FallDamageService)
local SpawnInvulnService = require(ServerScriptService.SpawnInvulnService)
local SurrenderService = require(ServerScriptService.SurrenderService)
local AFKService = require(ServerScriptService.AFKService)

-- Build map from rotation (Ascent first, then Bind, repeat)
local mapInfo = MapBuilder.Build(MapRotation.GetCurrent())

-- Start services
PlayerData.Start()
SpawnService.Start()
CombatService.Start()
TeamService.Start()
EconomyManager.Start()
UltPointsManager.Start()
SpikeController.Start()
SkinService.Init({ playerData = PlayerData })
SkinService.Start()
PolicyService.Start()
CaseService.Init({ playerData = PlayerData, policy = PolicyService })
BattlePassService.Init({ playerData = PlayerData })
BattlePassService.Start()
MonetizationService.Init({
	playerData = PlayerData,
	battlePass = BattlePassService,
	caseService = CaseService,
})
MonetizationService.Start()

BuyService.Init({
	economy = EconomyManager,
	combat = CombatService,
	ability = AbilityService,
	ult = UltPointsManager,
})
BuyService.Start()
AntiCheat.Start()
StatsManager.Start()
SettingsService.Init({ playerData = PlayerData })
SettingsService.Start()
BotManager.Start()
PracticeRange.Start()
RankService.Init({ playerData = PlayerData })
RankService.Start()
InventoryService.Init({ playerData = PlayerData })
InventoryService.Start()
PingService.Start()
MapVoteService.Start()
AchievementService.Init({ playerData = PlayerData })
AchievementService.Start()
DailyChallengeService.Init({ playerData = PlayerData })
DailyChallengeService.Start()
WeeklyChallengeService.Init({ playerData = PlayerData })
WeeklyChallengeService.Start()
LeaderboardService.Init({ playerData = PlayerData })
LeaderboardService.Start()
CustomGameService.Start()
RagdollService.Start()
DeathmatchService.Start()
WeaponDropService.Init({ combat = CombatService })
WeaponDropService.Start()
FriendService.Init({ playerData = PlayerData })
FriendService.Start()
LoginBonusService.Init({ playerData = PlayerData })
LoginBonusService.Start()
ChatService.Start()
FallDamageService.Start()
SpawnInvulnService.Start()
SurrenderService.Init({ match = MatchManager })
SurrenderService.Start()
AFKService.Start()
LevelService.Init({ playerData = PlayerData })
LevelService.Start()

CombatService.OnPlayerKilled(function(killer, victim)
	DeathmatchService.OnKill(killer, victim)
end)

-- Hook stats for achievements + daily challenges
CombatService.OnPlayerKilled(function(killer, victim)
	if killer then
		AchievementService.RecordKill(killer, false)
		DailyChallengeService.RecordProgress(killer, "kills", 1)
		WeeklyChallengeService.RecordProgress(killer, "kills", 1)
	end
end)
SpikeController.RegisterListener("onPlanted", function(player)
	if player then
		AchievementService.RecordPlant(player)
		DailyChallengeService.RecordProgress(player, "plants", 1)
	end
end)
SpikeController.RegisterListener("onDefused", function(player)
	if player then
		AchievementService.RecordDefuse(player)
		DailyChallengeService.RecordProgress(player, "defuses", 1)
	end
end)

-- Wire StatsManager to combat events
CombatService.OnPlayerKilled(function(killer, victim)
	-- Pull last hit category from CombatService internal table — use lastHitCategory key
	StatsManager.OnKill(killer, victim, false)  -- TODO: pass isHeadshot
end)

-- Pass plant areas from map to spike controller
if mapInfo and mapInfo.plantAreas then
	SpikeController.SetPlantAreas(mapInfo.plantAreas)
end

-- Wire AbilityService + register agents
AbilityService.Init({ ult = UltPointsManager, economy = EconomyManager })
AbilityService.RegisterAgent("Jett", Jett)
AbilityService.RegisterAgent("Sage", Sage)
AbilityService.RegisterAgent("Phoenix", Phoenix)
AbilityService.RegisterAgent("Cypher", Cypher)
AbilityService.RegisterAgent("Reyna", Reyna)
AbilityService.RegisterAgent("KAYO", KAYO)
AbilityService.RegisterAgent("Sova", Sova)
AbilityService.RegisterAgent("Brimstone", Brimstone)
AbilityService.RegisterAgent("Viper", Viper)
AbilityService.RegisterAgent("Astra", Astra)
AbilityService.RegisterAgent("Omen", Omen)
AbilityService.RegisterAgent("Killjoy", Killjoy)

-- Hook Reyna kill events for soul orbs
CombatService.OnPlayerKilled(function(killer, victim)
	if killer then Reyna.OnPlayerKill(killer) end
end)
AbilityService.Start()

-- Wire RoundManager with all its dependencies
RoundManager.Init({
	team = TeamService,
	economy = EconomyManager,
	ult = UltPointsManager,
	match = MatchManager,
	spike = SpikeController,
	combat = CombatService,
	ability = AbilityService,
	bots = BotManager,
	stats = StatsManager,
})

-- Wire CombatService kill events into RoundManager
CombatService.OnPlayerKilled(function(killer, victim)
	RoundManager.OnPlayerKilled(killer, victim)
end)

-- On match end: update MMR + record history per player
MatchManager.SetOnEndCallback(function(winningTeam)
	for _, p in ipairs(game.Players:GetPlayers()) do
		local pTeam = p.Team and p.Team.Name or nil
		local won = pTeam == winningTeam
		local stats = StatsManager.GetStats(p)
		local acs = StatsManager.GetACS(p)
		RankService.OnMatchEnd(p, won, acs)
		AchievementService.RecordMatchEnd(p, won)
		DailyChallengeService.RecordProgress(p, "matches", 1)
		if won then DailyChallengeService.RecordProgress(p, "wins", 1) end
		-- Update leaderboard
		local profile = PlayerData.Get(p)
		if profile and profile.MMR then
			LeaderboardService.UpdateMMR(p, profile.MMR)
		end
		-- Award XP
		LevelService.OnMatchEnd(p, won, stats.kills, false)
		-- Record match history (Sprint 28)
		local profile = PlayerData.Get(p)
		if profile then
			profile.MatchHistory = profile.MatchHistory or {}
			table.insert(profile.MatchHistory, 1, {
				date = os.time(),
				won = won,
				agent = p:GetAttribute("Agent"),
				kills = stats.kills,
				deaths = stats.deaths,
				assists = stats.assists,
				acs = acs,
				mapName = MapRotation.GetCurrent(),
			})
			-- Cap at 20 entries
			while #profile.MatchHistory > 20 do
				table.remove(profile.MatchHistory)
			end
		end
	end
end)

-- Wire agent selection RemoteEvent (player sends choice → AbilityService sets agent)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
Remotes.AgentSelected.OnServerEvent:Connect(function(player, agentName)
	if typeof(agentName) ~= "string" then return end
	local allowed = {
		Jett = true, Sage = true, Phoenix = true, Cypher = true, Reyna = true, KAYO = true,
		Sova = true, Brimstone = true, Viper = true, Astra = true, Omen = true, Killjoy = true,
	}
	if not allowed[agentName] then return end
	AbilityService.SetAgent(player, agentName)
	player:SetAttribute("Agent", agentName)
end)

-- Optional: start match after delay with lobby → agent select → countdown
task.spawn(function()
	-- Lobby phase: wait for at least 1 player or 30s timeout
	for _, p in ipairs(game.Players:GetPlayers()) do
		Remotes.LobbyState:FireClient(p, "Waiting", "Match begins in 15 seconds...")
	end
	-- Add new players as they join
	game.Players.PlayerAdded:Connect(function(p)
		task.wait(1)
		Remotes.LobbyState:FireClient(p, "Waiting", "Match begins shortly...")
	end)

	task.wait(15)
	print("[Server] Pre-match: agent select")

	for _, p in ipairs(game.Players:GetPlayers()) do
		Remotes.LobbyState:FireClient(p, "AgentSelect", "")
		Remotes.ShowAgentSelect:FireClient(p, 30)
	end
	task.wait(32)
	print("[Server] Match countdown 5..0")
	Remotes.MatchCountdown:FireAllClients(5)
	task.wait(6)
	print("[Server] Starting first match on " .. MapRotation.GetCurrent())
	for _, p in ipairs(game.Players:GetPlayers()) do
		Remotes.LobbyState:FireClient(p, "InMatch", "")
	end
	RoundManager.StartMatch()
end)

-- Map rotation: after each match end, map vote → rebuild + start new match
task.spawn(function()
	while true do
		task.wait(2)
		if MatchManager.HasEnded() then
			task.wait(8)  -- show end screen
			-- Start map vote
			local allMaps = MapRotation.Rotation
			MapVoteService.StartVote(allMaps)
			task.wait(22)  -- vote duration + buffer
			local winner = MapVoteService.GetResult() or MapRotation.Next()
			MapRotation.Set(winner)
			print("[Server] Map vote winner: " .. winner)
			local newMapInfo = MapBuilder.Build(winner)
			if newMapInfo and newMapInfo.plantAreas then
				SpikeController.SetPlantAreas(newMapInfo.plantAreas)
			end
			MatchManager.Reset()
			task.wait(3)
			RoundManager.StartMatch()
		end
	end
end)

print("[Server] Roblox Valorant — all services loaded")
