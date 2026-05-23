-- LevelService: player account level (separate od MMR), XP-based

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local LevelService = {}
local PlayerData

local XP_PER_LEVEL = 1000
local LEVEL_COIN_REWARD = 200  -- coins per level up

function LevelService.Init(deps)
	PlayerData = deps.playerData
end

function LevelService.GetLevel(player)
	local profile = PlayerData.Get(player)
	if not profile then return 1 end
	return profile.Level or 1
end

function LevelService.GetXP(player)
	local profile = PlayerData.Get(player)
	if not profile then return 0 end
	return profile.LevelXP or 0
end

function LevelService.AddXP(player, amount)
	local profile = PlayerData.Get(player)
	if not profile then return end
	profile.LevelXP = (profile.LevelXP or 0) + amount

	-- Check level up
	while profile.LevelXP >= XP_PER_LEVEL do
		profile.LevelXP -= XP_PER_LEVEL
		profile.Level = (profile.Level or 1) + 1
		profile.Coins = (profile.Coins or 0) + LEVEL_COIN_REWARD

		-- Notify
		Remotes.AchievementUnlocked:FireClient(
			player,
			"level_" .. profile.Level,
			"LEVEL UP",
			"Reached level " .. profile.Level,
			"🎖️",
			LEVEL_COIN_REWARD
		)
	end

	player:SetAttribute("Level", profile.Level)
	player:SetAttribute("LevelXP", profile.LevelXP)
end

function LevelService.OnMatchEnd(player, won, kills, mvp)
	local xp = 100  -- base
	xp = xp + (kills or 0) * 10
	if won then xp = xp + 200 end
	if mvp then xp = xp + 100 end
	LevelService.AddXP(player, xp)
end

function LevelService.Start()
	Players.PlayerAdded:Connect(function(player)
		task.wait(3)
		local profile = PlayerData.Get(player)
		if profile then
			player:SetAttribute("Level", profile.Level or 1)
			player:SetAttribute("LevelXP", profile.LevelXP or 0)
		end
	end)
end

return LevelService
