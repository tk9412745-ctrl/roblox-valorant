local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local MatchManager = {}

local score = { Attackers = 0, Defenders = 0 }
local matchEnded = false
local inOvertime = false
local overtimeSets = 0
local overtimeWinsThisSet = { Attackers = 0, Defenders = 0 }

function MatchManager.GetScore()
	return score.Attackers, score.Defenders
end

local function sendScore()
	Remotes.UpdateScore:FireAllClients(score.Attackers, score.Defenders)
end

function MatchManager.RecordRoundWin(winnerTeam)
	if winnerTeam == "Attackers" then
		score.Attackers += 1
	elseif winnerTeam == "Defenders" then
		score.Defenders += 1
	end
	sendScore()

	if inOvertime and winnerTeam then
		overtimeWinsThisSet[winnerTeam] += 1
	end
end

function MatchManager.IsMatchOver()
	-- Standard win condition
	if not inOvertime then
		if score.Attackers >= GameConfig.ROUNDS_TO_WIN or score.Defenders >= GameConfig.ROUNDS_TO_WIN then
			return true
		end
		return false
	end
	-- Overtime: must win both rounds of a set
	if overtimeWinsThisSet.Attackers >= 2 then return true end
	if overtimeWinsThisSet.Defenders >= 2 then return true end
	return false
end

function MatchManager.GetWinner()
	if score.Attackers > score.Defenders then return "Attackers" end
	if score.Defenders > score.Attackers then return "Defenders" end
	return nil
end

function MatchManager.NeedsHalftime(currentRound)
	return currentRound == GameConfig.HALFTIME_SWAP_AFTER
end

function MatchManager.NeedsOvertime()
	return score.Attackers == 12 and score.Defenders == 12
end

function MatchManager.EnterOvertime()
	inOvertime = true
	overtimeSets += 1
	overtimeWinsThisSet = { Attackers = 0, Defenders = 0 }
end

function MatchManager.IsOvertime()
	return inOvertime
end

function MatchManager.OvertimeSetComplete()
	-- Set complete = 2 rundy zostały zagrane
	return overtimeWinsThisSet.Attackers + overtimeWinsThisSet.Defenders >= 2
end

function MatchManager.ResetOvertimeSet()
	overtimeWinsThisSet = { Attackers = 0, Defenders = 0 }
end

function MatchManager.EndMatch()
	matchEnded = true
	local winner = MatchManager.GetWinner()
	Remotes.MatchEnded:FireAllClients(winner, score.Attackers, score.Defenders)
	-- Trigger rank updates and match history recording (via end-of-match hook in Main)
	if MatchManager.OnEndCallback then MatchManager.OnEndCallback(winner) end
end

function MatchManager.SetOnEndCallback(cb)
	MatchManager.OnEndCallback = cb
end

function MatchManager.HasEnded()
	return matchEnded
end

function MatchManager.Reset()
	score = { Attackers = 0, Defenders = 0 }
	matchEnded = false
	inOvertime = false
	overtimeSets = 0
	overtimeWinsThisSet = { Attackers = 0, Defenders = 0 }
	sendScore()
end

return MatchManager
