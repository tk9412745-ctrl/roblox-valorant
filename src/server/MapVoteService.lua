-- MapVoteService: between-match voting (20s window)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local MapVoteService = {}

local activeVote  -- { options = {...}, votes = {[player] = mapName}, endTime }
local VOTE_DURATION = 20

local function getCurrentTallies()
	if not activeVote then return {} end
	local tally = {}
	for _, opt in ipairs(activeVote.options) do tally[opt] = 0 end
	for _, vote in pairs(activeVote.votes) do
		if tally[vote] then tally[vote] = tally[vote] + 1 end
	end
	return tally
end

local function broadcastUpdate()
	if not activeVote then return end
	Remotes.MapVoteUpdate:FireAllClients(activeVote.options, getCurrentTallies(), math.max(0, activeVote.endTime - tick()))
end

function MapVoteService.StartVote(mapOptions)
	if activeVote then return end  -- vote in progress

	activeVote = {
		options = mapOptions,
		votes = {},
		endTime = tick() + VOTE_DURATION,
	}
	Remotes.MapVoteStart:FireAllClients(mapOptions, VOTE_DURATION)

	-- Ticker
	task.spawn(function()
		while activeVote and tick() < activeVote.endTime do
			broadcastUpdate()
			task.wait(1)
		end
	end)
end

function MapVoteService.GetResult()
	if not activeVote then return nil end
	local tally = getCurrentTallies()
	local winner
	local maxVotes = -1
	-- Tie-break: random among tied
	local tied = {}
	for opt, count in pairs(tally) do
		if count > maxVotes then
			maxVotes = count
			tied = { opt }
		elseif count == maxVotes then
			table.insert(tied, opt)
		end
	end
	if #tied > 0 then
		winner = tied[math.random(1, #tied)]
	end
	activeVote = nil
	return winner
end

function MapVoteService.Start()
	Remotes.MapVoteCast.OnServerEvent:Connect(function(player, mapName)
		if not activeVote then return end
		if typeof(mapName) ~= "string" then return end
		-- Verify it's in current vote options
		local valid = false
		for _, opt in ipairs(activeVote.options) do
			if opt == mapName then valid = true; break end
		end
		if not valid then return end
		activeVote.votes[player] = mapName
		broadcastUpdate()
	end)

	Players.PlayerRemoving:Connect(function(player)
		if activeVote then activeVote.votes[player] = nil end
	end)
end

return MapVoteService
