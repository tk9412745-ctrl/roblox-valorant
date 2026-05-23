-- VoiceLines: per-agent voice line table (placeholder sound IDs)
-- User podmienia na własne uploady do Robloxa

local VoiceLines = {}

local DEFAULT_VOICE = "rbxasset://sounds/clickfast.wav"

-- Per agent, per event
VoiceLines.Agent = {
	Jett = {
		ability_used = DEFAULT_VOICE,
		ult_ready = DEFAULT_VOICE,
		ult_used = DEFAULT_VOICE,
		kill = DEFAULT_VOICE,
		round_start = DEFAULT_VOICE,
	},
	Sage = {
		ability_used = DEFAULT_VOICE,
		ult_ready = DEFAULT_VOICE,
		ult_used = DEFAULT_VOICE,
		ally_resurrected = DEFAULT_VOICE,
		round_start = DEFAULT_VOICE,
	},
	Phoenix = {
		ability_used = DEFAULT_VOICE,
		ult_ready = DEFAULT_VOICE,
		ult_used = DEFAULT_VOICE,
		round_start = DEFAULT_VOICE,
	},
	Cypher = {
		ability_used = DEFAULT_VOICE,
		trapwire_triggered = DEFAULT_VOICE,
		ult_used = DEFAULT_VOICE,
	},
	Reyna = {
		ability_used = DEFAULT_VOICE,
		soul_consumed = DEFAULT_VOICE,
		empress_active = DEFAULT_VOICE,
		kill = DEFAULT_VOICE,
	},
	KAYO = {
		ability_used = DEFAULT_VOICE,
		ult_used = DEFAULT_VOICE,
		suppress = DEFAULT_VOICE,
	},
	Sova = {
		ability_used = DEFAULT_VOICE,
		recon_active = DEFAULT_VOICE,
		ult_used = DEFAULT_VOICE,
	},
	Brimstone = {
		ability_used = DEFAULT_VOICE,
		smoke_deployed = DEFAULT_VOICE,
		orbital_strike = DEFAULT_VOICE,
	},
	Viper = {
		ability_used = DEFAULT_VOICE,
		pit_active = DEFAULT_VOICE,
		gas_warning = DEFAULT_VOICE,
	},
}

-- Generic events (any agent)
VoiceLines.Generic = {
	taking_damage = DEFAULT_VOICE,
	low_health = DEFAULT_VOICE,
	spike_planted = DEFAULT_VOICE,
	spike_defused = DEFAULT_VOICE,
	round_win = DEFAULT_VOICE,
	round_lose = DEFAULT_VOICE,
	match_win = DEFAULT_VOICE,
	match_lose = DEFAULT_VOICE,
	enemy_spotted = DEFAULT_VOICE,
	clutch = DEFAULT_VOICE,  -- 1vN situation
	ace = DEFAULT_VOICE,     -- 5-kill round
}

function VoiceLines.GetAgentLine(agent, event)
	if not agent or not event then return nil end
	local agentVoices = VoiceLines.Agent[agent]
	if not agentVoices then return nil end
	return agentVoices[event]
end

function VoiceLines.GetGenericLine(event)
	if not event then return nil end
	return VoiceLines.Generic[event]
end

return VoiceLines
