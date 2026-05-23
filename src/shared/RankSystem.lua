-- RankSystem: 9 tier × 3 divisions + Radiant (top tier)
-- MMR ranges: Iron 1 = 0-99, Iron 2 = 100-199, ..., Radiant 2400+
-- Each rank = 100 MMR steps

local RankSystem = {}

RankSystem.Tiers = {
	{ name = "Iron",       color = Color3.fromRGB(80, 80, 90) },
	{ name = "Bronze",     color = Color3.fromRGB(150, 100, 50) },
	{ name = "Silver",     color = Color3.fromRGB(180, 180, 200) },
	{ name = "Gold",       color = Color3.fromRGB(255, 200, 50) },
	{ name = "Platinum",   color = Color3.fromRGB(80, 180, 200) },
	{ name = "Diamond",    color = Color3.fromRGB(200, 80, 220) },
	{ name = "Ascendant",  color = Color3.fromRGB(80, 220, 100) },
	{ name = "Immortal",   color = Color3.fromRGB(220, 60, 80) },
	{ name = "Radiant",    color = Color3.fromRGB(255, 240, 150) },
}

RankSystem.STARTING_MMR = 800       -- Silver 1 default
RankSystem.MMR_PER_RANK = 100
RankSystem.MMR_WIN = 25
RankSystem.MMR_LOSS = -25
RankSystem.MMR_HIGH_ACS_BONUS = 10   -- bonus for ACS > 250
RankSystem.MMR_LOW_ACS_PENALTY = -10 -- penalty for ACS < 100

function RankSystem.GetRank(mmr)
	mmr = math.max(0, mmr or 0)
	-- Radiant: top tier
	if mmr >= 2400 then
		return {
			tier = "Radiant",
			division = nil,
			displayName = "Radiant",
			color = RankSystem.Tiers[9].color,
			tierIndex = 9,
		}
	end
	-- Other 8 tiers × 3 divisions = 24 ranks (0-2399)
	local rankIndex = math.floor(mmr / 100)  -- 0-23
	local tierIndex = math.floor(rankIndex / 3) + 1
	local division = (rankIndex % 3) + 1
	local tier = RankSystem.Tiers[math.min(tierIndex, 8)]
	return {
		tier = tier.name,
		division = division,
		displayName = tier.name .. " " .. division,
		color = tier.color,
		tierIndex = tierIndex,
	}
end

function RankSystem.CalculateMMRChange(won, acs)
	local change = won and RankSystem.MMR_WIN or RankSystem.MMR_LOSS
	-- ACS performance modifier
	if acs and acs > 250 then
		change = change + RankSystem.MMR_HIGH_ACS_BONUS
	elseif acs and acs < 100 then
		change = change + RankSystem.MMR_LOW_ACS_PENALTY
	end
	return change
end

return RankSystem
