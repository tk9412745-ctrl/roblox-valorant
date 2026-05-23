-- InventoryService: send owned skins + match history to client on request

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local InventoryService = {}
local PlayerData

function InventoryService.Init(deps)
	PlayerData = deps.playerData
end

function InventoryService.SendInventory(player)
	local profile = PlayerData.Get(player)
	if not profile then return end
	Remotes.UpdateInventory:FireClient(player, {
		ownedSkins = profile.Owned_Skins or {},
		equipped = profile.Equipped or {},
		coins = profile.Coins or 0,
		mmr = profile.MMR or 800,
		matchHistory = profile.MatchHistory or {},
		stats = profile.Stats or {},
		battlePass = profile.Battle_Pass or { Tier = 0, XP = 0, Premium_Owned = false, Claimed_Rewards = {} },
		achievements = profile.Achievements or {},
		dailyChallenges = (profile.DailyChallenges and profile.DailyChallenges.challenges) or {},
	})
end

function InventoryService.Start()
	Remotes.RequestInventory.OnServerEvent:Connect(function(player)
		InventoryService.SendInventory(player)
	end)

	-- Auto-send on player join (after profile loads)
	Players.PlayerAdded:Connect(function(player)
		task.wait(2)
		InventoryService.SendInventory(player)
	end)
end

return InventoryService
