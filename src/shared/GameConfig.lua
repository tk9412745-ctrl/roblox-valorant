-- GameConfig: Wszystkie konstanty rund, ekonomii, ult points
local GameConfig = {}

-- ============================================================
-- ROUND PHASE DURATIONS (sekundy)
-- ============================================================
GameConfig.BUY_PHASE_STANDARD    = 30
GameConfig.BUY_PHASE_FIRST       = 45  -- Rd 1, Rd 13, OT first round
GameConfig.ROUND_PHASE           = 100 -- pre-plant action time
GameConfig.SPIKE_TIMER           = 45  -- after plant, before detonation
GameConfig.SPIKE_PLANT_TIME      = 4
GameConfig.SPIKE_DEFUSE_FULL     = 7
GameConfig.SPIKE_DEFUSE_HALF     = 3.5
GameConfig.POST_ROUND_DELAY      = 7
GameConfig.HALFTIME_DELAY        = 15

-- ============================================================
-- MATCH FORMAT
-- ============================================================
GameConfig.ROUNDS_PER_HALF       = 12
GameConfig.ROUNDS_TO_WIN         = 13
GameConfig.HALFTIME_SWAP_AFTER   = 12
GameConfig.OT_CREDITS            = 5000
GameConfig.OT_BUY_PHASE_FIRST    = 45
GameConfig.MATCH_MAX_DRAW        = false  -- Valorant nie ma remisów w competitive

-- ============================================================
-- ECONOMY
-- ============================================================
GameConfig.STARTING_CREDITS      = 800
GameConfig.MAX_CREDITS           = 9000
GameConfig.KILL_REWARD           = 200   -- wszystkie bronie, łącznie z nożem
GameConfig.TEAMKILL_PENALTY      = -200
GameConfig.PLANT_REWARD          = 300   -- per attacker
GameConfig.DEFUSE_REWARD         = 300   -- per defender
GameConfig.WIN_BONUS             = 3000

GameConfig.LOSS_BONUS = {
	[1] = 1900,
	[2] = 2400,
	[3] = 2900,  -- cap
}
GameConfig.LOSS_BONUS_CAP        = 2900

-- ============================================================
-- BUY CATEGORIES (dla UI hint)
-- ============================================================
GameConfig.BUY_TIERS = {
	Eco       = { min = 0, max = 900 },
	HalfBuy   = { min = 2000, max = 3000 },
	FullBuy   = { min = 3900, max = 4900 },
}

-- ============================================================
-- ULT POINTS
-- ============================================================
GameConfig.ULT_POINT_KILL        = 1
GameConfig.ULT_POINT_DEATH       = 1
GameConfig.ULT_POINT_PLANT       = 1
GameConfig.ULT_POINT_DEFUSE      = 1
GameConfig.ULT_POINT_ORB         = 1
GameConfig.ULT_ORBS_PER_MAP      = 2  -- 4 dla Fracture

GameConfig.RESET_ULTS_ON_HALFTIME = false  -- carry through halftime
GameConfig.RESET_ULTS_ON_OT       = true   -- reset w OT

-- Ult cost per agent
GameConfig.AGENT_ULT_COSTS = {
	-- 6 punktów
	Phoenix = 6, Reyna = 6, Cypher = 6, Yoru = 6,
	-- 7 punktów
	Astra = 7, Brimstone = 7, Harbor = 7, Jett = 7, Killjoy = 7, Neon = 7, Omen = 7, Skye = 7,
	Iso = 7, Tejo = 7, Waylay = 7, Veto = 7, Clove = 7, Fade = 7, Gekko = 7, Deadlock = 7,
	-- 8 punktów
	Breach = 8, Chamber = 8, KAYO = 8, Raze = 8, Sage = 8, Sova = 8, Viper = 8, Vyse = 8,
}

-- ============================================================
-- SPIKE
-- ============================================================
GameConfig.SPIKE_BLAST_RADIUS_STUDS = 50  -- core kill zone (Valorant ~16m)
GameConfig.SPIKE_OUTER_RADIUS_STUDS = 80  -- damage falloff outer
GameConfig.SPIKE_INSTAKILL_CORE     = true
GameConfig.SPIKE_OUTER_DAMAGE       = 600  -- max dmg, falloff linearne

-- Audio escalation thresholds (sekundy do detonacji)
GameConfig.SPIKE_AUDIO_TICK_FAST    = 25
GameConfig.SPIKE_AUDIO_FASTER       = 15
GameConfig.SPIKE_AUDIO_FINAL        = 5

-- ============================================================
-- COMBAT SCORE / ACS
-- ============================================================
GameConfig.CS_KILL_BY_ENEMIES_ALIVE = {
	[5] = 150,  -- clutch start (1v5)
	[4] = 130,
	[3] = 110,
	[2] = 90,
	[1] = 70,   -- last enemy
}
GameConfig.CS_PER_DAMAGE = 1
GameConfig.KAST_TRADE_WINDOW = 5  -- sekundy

-- ============================================================
-- CHARACTER
-- ============================================================
GameConfig.PLAYER_MAX_HP         = 100
GameConfig.PLAYER_DEFAULT_HP     = 100
GameConfig.PLAYER_WALKSPEED_BASE = 16  -- studs/sec when holding knife (100%)
GameConfig.PLAYER_JUMP_HEIGHT    = 7.5
GameConfig.RESPAWN_TIME          = 0  -- żywi pozostają martwi do końca rundy

-- ============================================================
-- TEAMS
-- ============================================================
GameConfig.TEAM_SIZE             = 5  -- 5v5
GameConfig.TEAM_ATTACKERS        = "Attackers"
GameConfig.TEAM_DEFENDERS        = "Defenders"

return GameConfig
