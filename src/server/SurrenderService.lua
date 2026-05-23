-- SurrenderService: /ff command, 4/5 team votes to forfeit match

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local SurrenderService = {}

local activeVotes = {}  -- [teamName] = { yesVotes = {[player]=true}, expiresAt }
local VOTE_DURATION = 30
local REQUIRED_RATIO = 0.8  -- 4/5
local match  -- match service ref

function SurrenderService.Init(deps)
	match = deps.match
end

local function getTeamPlayers(teamName)
	local result = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Team and p.Team.Name == teamName then
			table.insert(result, p)
		end
	end
	return result
end

local function checkVotePass(teamName)
	local vote = activeVotes[teamName]
	if not vote then return false end
	local teamPlayers = getTeamPlayers(teamName)
	if #teamPlayers == 0 then return false end
	local yes = 0
	for p, _ in pairs(vote.yesVotes) do
		if p.Team and p.Team.Name == teamName then yes += 1 end
	end
	return yes >= math.ceil(#teamPlayers * REQUIRED_RATIO)
end

local function broadcastVote(teamName)
	local vote = activeVotes[teamName]
	if not vote then return end
	local teamPlayers = getTeamPlayers(teamName)
	local yes = 0
	for _ in pairs(vote.yesVotes) do yes += 1 end
	for _, p in ipairs(teamPlayers) do
		p:SetAttribute("SurrenderVoteYes", yes)
		p:SetAttribute("SurrenderVoteRequired", math.ceil(#teamPlayers * REQUIRED_RATIO))
		p:SetAttribute("SurrenderVoteExpires", vote.expiresAt - tick())
	end
end

local function startVote(player, teamName)
	if activeVotes[teamName] then return false end  -- already active
	activeVotes[teamName] = {
		yesVotes = { [player] = true },
		expiresAt = tick() + VOTE_DURATION,
		initiator = player,
	}
	broadcastVote(teamName)

	-- Vote timeout
	task.delay(VOTE_DURATION, function()
		if activeVotes[teamName] then
			activeVotes[teamName] = nil
			for _, p in ipairs(getTeamPlayers(teamName)) do
				p:SetAttribute("SurrenderVoteYes", nil)
			end
		end
	end)
	return true
end

local function castVote(player, teamName)
	if not activeVotes[teamName] then return false end
	activeVotes[teamName].yesVotes[player] = true
	broadcastVote(teamName)

	if checkVotePass(teamName) then
		-- Forfeit — opposing team wins
		local enemyTeam = teamName == "Attackers" and "Defenders" or "Attackers"
		activeVotes[teamName] = nil
		if match then
			-- Award remaining rounds to enemy team
			for _ = 1, 5 do
				match.RecordRoundWin(enemyTeam)
			end
			if match.IsMatchOver and match.IsMatchOver() then
				match.EndMatch()
			end
		end
		return true
	end
	return false
end

function SurrenderService.Start()
	Players.PlayerAdded:Connect(function(player)
		player.Chatted:Connect(function(msg)
			if msg ~= "/ff" and msg ~= "/surrender" then return end
			if not player.Team then return end
			local teamName = player.Team.Name
			if not activeVotes[teamName] then
				startVote(player, teamName)
			else
				castVote(player, teamName)
			end
		end)
	end)
	Players.PlayerRemoving:Connect(function(player)
		for _, vote in pairs(activeVotes) do
			vote.yesVotes[player] = nil
		end
	end)
end

return SurrenderService
