-- StatsManager: per-match stats (K/D/A/ACS/HS%/$ per player)
-- Reset per match. Broadcasted do clients dla scoreboard

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local StatsManager = {}

local stats = {}  -- [player] = { kills, deaths, assists, headshots, totalDmg, combatScore, plants, defuses }
local roundStats = {}  -- [player] = { kills, dmg, plant, defuse } per CURRENT round
local lastDeathTime = {}  -- [player] = tick() of last death (for trade detection)
local TRADE_WINDOW = GameConfig.KAST_TRADE_WINDOW

local function ensureRound(player)
	if not roundStats[player] then
		roundStats[player] = { kills = 0, dmg = 0, plant = false, defuse = false }
	end
	return roundStats[player]
end

local function ensure(player)
	if not stats[player] then
		stats[player] = {
			kills = 0, deaths = 0, assists = 0,
			headshots = 0, totalDmg = 0,
			combatScore = 0, plants = 0, defuses = 0,
			rounds = 0, mvps = 0,
		}
	end
	return stats[player]
end

function StatsManager.OnKill(killer, victim, isHeadshot)
	if killer and killer ~= victim then
		local s = ensure(killer)
		s.kills += 1
		ensureRound(killer).kills += 1
		if isHeadshot then s.headshots += 1 end

		-- Combat score: depends on enemies alive at kill time
		local enemiesAlive = 0
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= killer and p.Team and killer.Team and p.Team ~= killer.Team then
				if p.Character then
					local hum = p.Character:FindFirstChildOfClass("Humanoid")
					if hum and hum.Health > 0 then
						enemiesAlive += 1
					end
				end
			end
		end
		local csKill = GameConfig.CS_KILL_BY_ENEMIES_ALIVE[math.min(enemiesAlive + 1, 5)] or 70
		s.combatScore += csKill
	end
	if victim then
		local s = ensure(victim)
		s.deaths += 1
		lastDeathTime[victim] = tick()
	end

	-- Trade detection: if victim died very recently, killer counts as trade
	-- (for KAST — assist credit retroactively)
	if killer and killer ~= victim then
		-- Was the killer's teammate just killed?
		for tm, deathT in pairs(lastDeathTime) do
			if tm ~= killer and tm.Team == killer.Team and (tick() - deathT) <= TRADE_WINDOW then
				-- This kill counts as a trade for tm — give assist credit? For simplicity, no.
			end
		end
	end

	StatsManager.BroadcastStats()
end

function StatsManager.OnDamage(attacker, dmg)
	if not attacker then return end
	local s = ensure(attacker)
	s.totalDmg += dmg
	s.combatScore += dmg * GameConfig.CS_PER_DAMAGE
	ensureRound(attacker).dmg += dmg
end

function StatsManager.OnPlant(player)
	if not player then return end
	ensure(player).plants += 1
	ensureRound(player).plant = true
	StatsManager.BroadcastStats()
end

function StatsManager.OnDefuse(player)
	if not player then return end
	ensure(player).defuses += 1
	ensureRound(player).defuse = true
	StatsManager.BroadcastStats()
end

function StatsManager.OnRoundEnd(winnerTeam)
	for _, p in ipairs(Players:GetPlayers()) do
		ensure(p).rounds += 1
	end
	StatsManager.BroadcastStats()

	-- Build round report
	local report = {}
	local mvp = nil
	local mvpPlayer = nil
	local mvpScore = -1
	for _, p in ipairs(Players:GetPlayers()) do
		local r = roundStats[p] or { kills = 0, dmg = 0, plant = false, defuse = false }
		local score = r.kills * 100 + r.dmg + (r.plant and 50 or 0) + (r.defuse and 50 or 0)
		table.insert(report, {
			userId = p.UserId,
			name = p.Name,
			team = p.Team and p.Team.Name,
			kills = r.kills,
			dmg = r.dmg,
			plant = r.plant,
			defuse = r.defuse,
			roundScore = score,
		})
		if score > mvpScore then
			mvpScore = score
			mvp = p.Name
			mvpPlayer = p
		end
	end

	-- Increment MVP counter
	if mvpPlayer then
		ensure(mvpPlayer).mvps += 1
	end

	Remotes.RoundReport:FireAllClients(winnerTeam, mvp, report)

	-- Reset per-round stats
	roundStats = {}
end

function StatsManager.GetStats(player)
	return ensure(player)
end

function StatsManager.GetACS(player)
	local s = ensure(player)
	if s.rounds == 0 then return 0 end
	return math.floor(s.combatScore / s.rounds)
end

function StatsManager.GetHSPct(player)
	local s = ensure(player)
	if s.kills == 0 then return 0 end
	return math.floor((s.headshots / s.kills) * 100)
end

function StatsManager.GetADR(player)
	local s = ensure(player)
	if s.rounds == 0 then return 0 end
	return math.floor(s.totalDmg / s.rounds)
end

function StatsManager.BroadcastStats()
	-- Build snapshot for all players
	local snapshot = {}
	for _, p in ipairs(Players:GetPlayers()) do
		local s = ensure(p)
		table.insert(snapshot, {
			userId = p.UserId,
			name = p.Name,
			team = p.Team and p.Team.Name or "Spectator",
			agent = p:GetAttribute("Agent") or nil,
			rank = p:GetAttribute("Rank") or nil,
			kills = s.kills,
			deaths = s.deaths,
			assists = s.assists,
			acs = StatsManager.GetACS(p),
			hsPct = StatsManager.GetHSPct(p),
			adr = StatsManager.GetADR(p),
			plants = s.plants,
			defuses = s.defuses,
			mvps = s.mvps or 0,
		})
	end
	Remotes.UpdateMatchStats:FireAllClients(snapshot)
end

function StatsManager.Reset()
	stats = {}
	lastDeathTime = {}
	StatsManager.BroadcastStats()
end

function StatsManager.Start()
	Players.PlayerRemoving:Connect(function(player)
		stats[player] = nil
		lastDeathTime[player] = nil
		StatsManager.BroadcastStats()
	end)

	-- Periodic broadcast (every 3s in case of missed updates)
	task.spawn(function()
		while true do
			task.wait(3)
			StatsManager.BroadcastStats()
		end
	end)
end

return StatsManager
