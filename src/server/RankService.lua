-- RankService: tracks MMR per player, awards on match end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RankSystem = require(ReplicatedStorage.Shared.RankSystem)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local RankService = {}
local PlayerData

function RankService.Init(deps)
	PlayerData = deps.playerData
end

function RankService.GetMMR(player)
	local profile = PlayerData and PlayerData.Get(player)
	if not profile then return RankSystem.STARTING_MMR end
	return profile.MMR or RankSystem.STARTING_MMR
end

function RankService.SetMMR(player, mmr)
	local profile = PlayerData and PlayerData.Get(player)
	if not profile then return end
	profile.MMR = math.max(0, mmr)
	-- Update attribute for clients
	player:SetAttribute("MMR", profile.MMR)
	player:SetAttribute("Rank", RankSystem.GetRank(profile.MMR).displayName)
end

function RankService.AddMMR(player, delta)
	local current = RankService.GetMMR(player)
	RankService.SetMMR(player, current + delta)
end

function RankService.OnMatchEnd(player, won, acs)
	local delta = RankSystem.CalculateMMRChange(won, acs)
	local oldMMR = RankService.GetMMR(player)
	RankService.AddMMR(player, delta)
	local newMMR = RankService.GetMMR(player)
	local oldRank = RankSystem.GetRank(oldMMR)
	local newRank = RankSystem.GetRank(newMMR)
	-- Notify player of rank change
	if oldRank.displayName ~= newRank.displayName then
		-- Rank up/down notification (broadcast via attribute)
		player:SetAttribute("RankChanged", true)
		task.delay(5, function()
			if player then player:SetAttribute("RankChanged", false) end
		end)
	end
end

function RankService.Start()
	-- Set initial attributes on join
	Players.PlayerAdded:Connect(function(player)
		task.wait(2)  -- wait for profile load
		local mmr = RankService.GetMMR(player)
		player:SetAttribute("MMR", mmr)
		player:SetAttribute("Rank", RankSystem.GetRank(mmr).displayName)
	end)
end

return RankService
