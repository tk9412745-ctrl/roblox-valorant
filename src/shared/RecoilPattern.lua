-- RecoilPattern: Deterministic per-weapon recoil offsets (vert, horiz) per shot index
-- Vandal: T-shape (3 tight, climb up-left, snap right)
-- Phantom: smoother straight-up
-- Bulldog/Spectre/Stinger/Ares/Odin/Guardian/Sheriff: weapon-specific

local RecoilPattern = {}

-- Pattern format: { {vertical, horizontal}, ... }
-- Vertical: positive = camera kicks up
-- Horizontal: positive = camera kicks right, negative = left

RecoilPattern.Patterns = {
	Vandal = {
		{ 0.0, 0.0 }, { 0.3, 0.1 }, { 0.6, 0.0 },   -- 1-3 tight cluster
		{ 1.2, -0.3 }, { 2.0, -0.5 }, { 2.8, -0.8 }, -- 4-6 climb up-left
		{ 3.2, 0.6 }, { 3.4, 1.4 }, { 3.5, 2.0 },    -- 7-9 snap right
		{ 3.6, 2.4 }, { 3.6, 1.8 }, { 3.6, 0.8 },    -- 10-12 drift back
		{ 3.6, -0.5 }, { 3.6, -1.5 }, { 3.6, -2.0 },  -- 13-15 left swing
	},
	Phantom = {
		{ 0.0, 0.0 }, { 0.2, 0.1 }, { 0.5, 0.2 },
		{ 1.0, 0.3 }, { 1.6, 0.3 }, { 2.2, 0.4 }, { 2.8, 0.5 }, -- 1-7 mostly vertical
		{ 3.2, 0.4 }, { 3.4, 0.0 }, { 3.5, -0.4 }, -- 8-10 slight drift
		{ 3.5, -0.9 }, { 3.5, -1.4 }, { 3.5, -1.8 }, -- 11-13 up-left
	},
	Bulldog = {
		{ 0.0, 0.0 }, { 0.4, 0.0 }, { 0.8, 0.2 },
		{ 1.4, -0.3 }, { 2.0, -0.6 }, { 2.6, -0.4 },
		{ 3.0, 0.5 }, { 3.2, 1.2 }, { 3.2, 1.8 },
	},
	Spectre = {
		{ 0.0, 0.0 }, { 0.1, 0.0 }, { 0.3, 0.1 }, { 0.5, 0.2 },
		{ 0.9, 0.3 }, { 1.4, 0.2 }, { 1.9, -0.1 }, { 2.4, -0.5 },
		{ 2.8, -1.0 }, { 3.0, -1.6 }, { 3.0, -2.0 }, -- high-left after 5
	},
	Stinger = {
		{ 0.0, 0.0 }, { 0.2, 0.2 }, { 0.4, 0.3 }, -- slight right drift
		{ 1.0, -0.3 }, { 1.8, -0.8 }, { 2.4, -1.4 }, { 2.8, -1.8 }, -- sharp left+up
	},
	Ares = {
		{ 0.0, 0.0 }, { 0.2, 0.2 }, { 0.4, 0.3 }, -- slight right early
		{ 0.8, 0.2 }, { 1.4, 0.0 }, { 2.0, -0.3 }, { 2.6, -0.7 },
		{ 3.0, -1.2 }, { 3.2, -1.6 }, -- up + veer left, forgiving
	},
	Odin = {
		{ 0.0, 0.0 }, { 0.2, 0.1 }, { 0.5, 0.2 }, -- tight burst 1-3
		{ 1.0, 0.0 }, { 1.6, -0.3 }, { 2.2, -0.6 }, { 2.8, -1.0 },
		{ 3.2, -1.5 }, { 3.4, -1.8 }, { 3.5, -1.9 }, -- sustained up+left
	},
	Guardian = {
		{ 1.5, 0.3 }, -- per-shot heavy kick, resets quickly
	},
	Sheriff = {
		{ 2.0, 0.4 }, -- massive per-shot vert + horiz drift
	},
	Marshal = { { 2.5, 0.0 } },
	Outlaw = { { 3.0, 0.0 } },
	Operator = { { 3.5, 0.0 } },
	Frenzy = {
		{ 0.0, 0.0 }, { 0.4, 0.2 }, { 0.8, -0.2 }, { 1.2, 0.3 }, -- alternating drift
		{ 1.5, -0.4 }, { 1.8, 0.5 },
	},
	Ghost = { { 0.6, 0.1 } },  -- per-shot reset
	Classic = { { 0.5, 0.1 } },
	Shorty = { { 2.5, 0.5 } },
	Bucky = { { 3.0, 0.5 } },
	Judge = { { 2.5, 0.4 }, { 3.0, 0.6 }, { 3.0, -0.4 } },
}

-- Recovery: spread/recoil resets gracefully when not firing
RecoilPattern.RecoveryDelay = 0.3  -- sekund bez strzału żeby zacząć reset
RecoilPattern.RecoveryRate = 0.85  -- recoil indeks * RecoveryRate co tick

-- Per-shot magnitude scale (Roblox camera kick w stopniach)
RecoilPattern.MagnitudeScale = {
	Vandal = 1.0,
	Phantom = 0.85,
	Bulldog = 1.0,
	Spectre = 0.7,
	Stinger = 0.6,
	Ares = 0.95,
	Odin = 1.05,
	Guardian = 1.2,
	Sheriff = 1.4,
	Marshal = 1.3,
	Outlaw = 1.4,
	Operator = 1.5,
	Frenzy = 0.8,
	Ghost = 0.5,
	Classic = 0.45,
	Shorty = 1.3,
	Bucky = 1.3,
	Judge = 1.1,
}

function RecoilPattern.GetOffset(weaponName, shotIndex)
	local pattern = RecoilPattern.Patterns[weaponName]
	if not pattern or #pattern == 0 then return 0, 0 end

	-- Past pattern length: random small drift (simulate uncontrolled sustained fire)
	if shotIndex > #pattern then
		local last = pattern[#pattern]
		local randomDrift = (math.random() - 0.5) * 2
		return last[1] + (math.random() - 0.5) * 1.5, last[2] + randomDrift
	end

	local entry = pattern[shotIndex]
	local mag = RecoilPattern.MagnitudeScale[weaponName] or 1.0
	return entry[1] * mag, entry[2] * mag
end

return RecoilPattern
