local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local RoundManager = {}

local STATES = {
	PRE_MATCH  = "PreMatch",
	WARMUP     = "Warmup",
	BUY_PHASE  = "BuyPhase",
	ROUND      = "Round",
	POST_ROUND = "PostRound",
	HALFTIME   = "HalfTime",
	OVERTIME   = "Overtime",
	MATCH_END  = "MatchEnd",
}

local WARMUP_DURATION = 30  -- seconds

local currentState = STATES.PRE_MATCH
local currentRound = 0
local roundEndReason = nil
local timerThread = nil
local timerExpiresAt = nil

-- Service dependencies (set via Init)
local svc = {}

local function setState(newState, extraData)
	currentState = newState
	Remotes.RoundPhaseChanged:FireAllClients(newState, extraData)
end

local function clearTimer()
	if timerThread then
		task.cancel(timerThread)
		timerThread = nil
	end
	timerExpiresAt = nil
end

local function startTimer(duration, callback)
	clearTimer()
	timerExpiresAt = tick() + duration
	timerThread = task.spawn(function()
		task.wait(duration)
		timerThread = nil
		timerExpiresAt = nil
		if callback then callback() end
	end)

	-- Tick remaining time to clients
	task.spawn(function()
		while timerExpiresAt do
			local remaining = math.max(0, timerExpiresAt - tick())
			Remotes.UpdateRoundTimer:FireAllClients(currentState, remaining)
			task.wait(0.25)
		end
	end)
end

local function respawnAllPlayers(restoreWeapons)
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then
			player.Character:Destroy()
		end
		player:LoadCharacter()
	end

	task.wait(0.5)

	-- Determine spawn positions per team
	for _, player in ipairs(Players:GetPlayers()) do
		local char = player.Character
		if char then
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if hrp then
				local spawnPos
				if player.Team and player.Team.Name == GameConfig.TEAM_ATTACKERS then
					spawnPos = Vector3.new(0, 3, -110)
				else
					spawnPos = Vector3.new(0, 3, 110)
				end
				hrp.CFrame = CFrame.new(spawnPos + Vector3.new(math.random(-5, 5), 0, math.random(-3, 3)))
			end
			-- Reset armor (lost on death)
			if svc.combat then
				svc.combat.GrantArmor(player, nil)  -- unsetting, no armor next round
			end
		end
	end
end

local function isFirstRoundOfHalf(round)
	return round == 1 or round == (GameConfig.HALFTIME_SWAP_AFTER + 1)
end

local function determineWinner(reason)
	if reason == "ATTACKERS_DETONATE" or reason == "ATTACKERS_ELIM" then
		return "Attackers"
	end
	return "Defenders"
end

function RoundManager.EnterBuyPhase()
	currentRound += 1
	roundEndReason = nil

	-- Respawn players, reset HP, restore weapons for survivors
	respawnAllPlayers(true)

	-- Clear and respawn bots for new round (fill teams to 5v5)
	if svc.bots then
		svc.bots.ClearAll()
		local attackerCount = #svc.team.GetAttackers()
		local defenderCount = #svc.team.GetDefenders()
		local botsAtk = math.max(0, GameConfig.TEAM_SIZE - attackerCount)
		local botsDef = math.max(0, GameConfig.TEAM_SIZE - defenderCount)
		if botsAtk > 0 then
			svc.bots.SpawnTeam(GameConfig.TEAM_ATTACKERS, botsAtk, Vector3.new(0, 3, -110))
		end
		if botsDef > 0 then
			svc.bots.SpawnTeam(GameConfig.TEAM_DEFENDERS, botsDef, Vector3.new(0, 3, 110))
		end
	end

	-- Spawn spike for attackers (random attacker gets it)
	local attackers = svc.team.GetAttackers()
	if #attackers > 0 then
		local spike_spawn = Vector3.new(0, 3, -110)
		svc.spike.SpawnForAttackers(spike_spawn)
	end

	-- Determine buy duration
	local duration = isFirstRoundOfHalf(currentRound) and GameConfig.BUY_PHASE_FIRST or GameConfig.BUY_PHASE_STANDARD
	if svc.match.IsOvertime() and isFirstRoundOfHalf(currentRound) then
		duration = GameConfig.OT_BUY_PHASE_FIRST
	end

	setState(STATES.BUY_PHASE, { round = currentRound, duration = duration })
	startTimer(duration, RoundManager.EnterRound)
end

function RoundManager.EnterRound()
	setState(STATES.ROUND, { round = currentRound })
	startTimer(GameConfig.ROUND_PHASE, function()
		if svc.spike.GetState() ~= "Planted" then
			RoundManager.EndRound("DEFENDERS_TIME")
		end
	end)
end

function RoundManager.OnSpikePlanted(planter)
	if currentState ~= STATES.ROUND then return end
	clearTimer()
	svc.economy.OnSpikePlanted(planter, svc.team.GetAttackers())
	svc.ult.OnSpikePlant(planter)
	startTimer(GameConfig.SPIKE_TIMER, function()
		-- Detonation handled by SpikeController; RoundEnd happens via listener
	end)
end

function RoundManager.OnSpikeDefused(defuser)
	svc.economy.OnSpikeDefused(svc.team.GetDefenders())
	svc.ult.OnSpikeDefuse(defuser)
	RoundManager.EndRound("DEFENDERS_DEFUSE")
end

function RoundManager.OnSpikeDetonated()
	RoundManager.EndRound("ATTACKERS_DETONATE")
end

function RoundManager.OnPlayerKilled(killer, victim)
	if killer and killer ~= victim then
		svc.economy.OnKill(killer, victim)
		svc.ult.OnKill(killer, victim)
	end

	if currentState ~= STATES.ROUND then return end

	-- Check if all enemies of one team are dead
	local function teamAlive(teamPlayers, teamName)
		for _, p in ipairs(teamPlayers) do
			if p.Character and p.Character:FindFirstChildOfClass("Humanoid") and p.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
				return true
			end
		end
		-- Check bots
		if svc.bots and svc.bots.GetAliveBots(teamName) > 0 then
			return true
		end
		return false
	end

	local attackersAlive = teamAlive(svc.team.GetAttackers(), GameConfig.TEAM_ATTACKERS)
	local defendersAlive = teamAlive(svc.team.GetDefenders(), GameConfig.TEAM_DEFENDERS)

	if not attackersAlive then
		RoundManager.EndRound("DEFENDERS_ELIM")
	elseif not defendersAlive then
		-- Attackers won, but if spike planted, let it tick
		if svc.spike.GetState() == "Planted" then
			return  -- waiting for detonate
		end
		RoundManager.EndRound("ATTACKERS_ELIM")
	end
end

function RoundManager.EndRound(reason)
	if currentState == STATES.POST_ROUND or currentState == STATES.MATCH_END then return end
	roundEndReason = reason
	clearTimer()

	local winner = determineWinner(reason)
	svc.match.RecordRoundWin(winner)
	svc.economy.DistributeRoundEndCredits(winner, Players:GetPlayers(), svc.team)

	-- Mark survivors (keep weapons next round)
	svc.economy.ClearSurvivors()
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character then
			local humanoid = p.Character:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				svc.economy.MarkSurvivor(p)
			end
		end
	end

	setState(STATES.POST_ROUND, { round = currentRound, reason = reason, winner = winner })
	Remotes.RoundEnded:FireAllClients(winner, reason, currentRound)
	svc.spike.Reset()
	-- Trigger round report
	if svc.stats then svc.stats.OnRoundEnd(winner) end

	startTimer(GameConfig.POST_ROUND_DELAY, function()
		if svc.match.IsMatchOver() then
			RoundManager.EnterMatchEnd()
		elseif svc.match.NeedsHalftime(currentRound) then
			RoundManager.EnterHalftime()
		elseif svc.match.NeedsOvertime() and not svc.match.IsOvertime() then
			RoundManager.EnterOvertime()
		else
			RoundManager.EnterBuyPhase()
		end
	end)
end

function RoundManager.EnterHalftime()
	setState(STATES.HALFTIME)
	Remotes.HalftimeStarted:FireAllClients()
	svc.team.SwapSides()
	svc.economy.ResetForNewHalf()
	-- Ult points carry through halftime — NIE reset
	startTimer(GameConfig.HALFTIME_DELAY, RoundManager.EnterBuyPhase)
end

function RoundManager.EnterOvertime()
	svc.match.EnterOvertime()
	setState(STATES.OVERTIME)
	svc.economy.SetAllCredits(GameConfig.OT_CREDITS)
	svc.ult.ResetAll()
	RoundManager.EnterBuyPhase()
end

function RoundManager.EnterMatchEnd()
	clearTimer()
	setState(STATES.MATCH_END)
	svc.match.EndMatch()
end

function RoundManager.GetState()
	return currentState
end

function RoundManager.GetRound()
	return currentRound
end

function RoundManager.GetTimeRemaining()
	if not timerExpiresAt then return 0 end
	return math.max(0, timerExpiresAt - tick())
end

function RoundManager.Init(services)
	svc = services

	-- Listen to spike events
	svc.spike.RegisterListener("onPlanted", RoundManager.OnSpikePlanted)
	svc.spike.RegisterListener("onDefused", RoundManager.OnSpikeDefused)
	svc.spike.RegisterListener("onDetonated", RoundManager.OnSpikeDetonated)
end

function RoundManager.EnterWarmup()
	setState(STATES.WARMUP, { duration = WARMUP_DURATION })
	-- Give all players free Vandal + unlimited credits for warmup
	for _, p in ipairs(Players:GetPlayers()) do
		if svc.economy then svc.economy.SetCredits(p, 9000) end
		if svc.combat then svc.combat.SetWeapon(p, "Vandal") end
	end
	-- Spawn warmup dummies
	for i = 1, 3 do
		local angle = (i - 1) * (math.pi * 2 / 3)
		local pos = Vector3.new(math.cos(angle) * 30, 3, math.sin(angle) * 30)
		-- Spawn bot at warmup spot
		if svc.bots then
			svc.bots.SpawnBot("Defenders", pos, "Vandal")
		end
	end

	startTimer(WARMUP_DURATION, function()
		-- Clear warmup bots and start real match
		if svc.bots then svc.bots.ClearAll() end
		RoundManager.EnterBuyPhase()
	end)
end

function RoundManager.StartMatch()
	svc.match.Reset()
	currentRound = 0
	RoundManager.EnterWarmup()
end

return RoundManager
