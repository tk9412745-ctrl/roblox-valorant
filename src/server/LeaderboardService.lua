-- LeaderboardService: global top players by MMR (OrderedDataStore)

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local RankSystem = require(ReplicatedStorage.Shared.RankSystem)

local LeaderboardService = {}
local PlayerData

local mmrStore
if not RunService:IsStudio() then
	mmrStore = DataStoreService:GetOrderedDataStore("MMR_Leaderboard_v1")
end

local cachedTop = {}
local lastFetch = 0
local CACHE_DURATION = 60  -- 60s refresh

function LeaderboardService.Init(deps)
	PlayerData = deps.playerData
end

function LeaderboardService.UpdateMMR(player, mmr)
	if not mmrStore then return end
	pcall(function()
		mmrStore:SetAsync(tostring(player.UserId), mmr)
	end)
end

function LeaderboardService.FetchTopPlayers()
	if not mmrStore then
		-- Studio mode: synthetic data
		return {
			{ userId = 0, mmr = 2500, rank = "Radiant", name = "TopPlayer" },
			{ userId = 0, mmr = 2200, rank = "Immortal 3", name = "Skilled" },
			{ userId = 0, mmr = 1800, rank = "Diamond 3", name = "Ranker" },
		}
	end
	if (tick() - lastFetch) < CACHE_DURATION and #cachedTop > 0 then
		return cachedTop
	end

	local success, pages = pcall(function()
		return mmrStore:GetSortedAsync(false, 100)
	end)
	if not success then return cachedTop end

	local result = {}
	local page = pages:GetCurrentPage()
	for _, entry in ipairs(page) do
		local userId = tonumber(entry.key)
		local mmr = entry.value
		local rank = RankSystem.GetRank(mmr).displayName
		local name = "?"
		pcall(function()
			name = Players:GetNameFromUserIdAsync(userId)
		end)
		table.insert(result, { userId = userId, mmr = mmr, rank = rank, name = name })
	end
	cachedTop = result
	lastFetch = tick()
	return result
end

function LeaderboardService.Start()
	Remotes.RequestLeaderboard.OnServerEvent:Connect(function(player)
		local top = LeaderboardService.FetchTopPlayers()
		Remotes.UpdateLeaderboard:FireClient(player, top)
	end)

	-- Update player MMR on join + on rank change
	Players.PlayerAdded:Connect(function(player)
		task.wait(3)
		local profile = PlayerData and PlayerData.Get(player)
		if profile and profile.MMR then
			LeaderboardService.UpdateMMR(player, profile.MMR)
		end
	end)
end

return LeaderboardService
