local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local EconomyManager = {}

local credits = {}              -- [player] = number
local consecutiveLosses = {}    -- [player] = number
local roundSurvivor = {}        -- [player] = bool (kept weapon next round)

function EconomyManager.GetCredits(player)
	return credits[player] or 0
end

function EconomyManager.SetCredits(player, amount)
	credits[player] = math.clamp(amount, 0, GameConfig.MAX_CREDITS)
	Remotes.UpdateCredits:FireClient(player, credits[player])
end

function EconomyManager.AddCredits(player, amount)
	EconomyManager.SetCredits(player, (credits[player] or 0) + amount)
end

function EconomyManager.CanAfford(player, cost)
	return (credits[player] or 0) >= cost
end

function EconomyManager.SpendCredits(player, cost)
	if not EconomyManager.CanAfford(player, cost) then return false end
	EconomyManager.SetCredits(player, credits[player] - cost)
	return true
end

function EconomyManager.OnKill(killer, victim)
	if not killer or killer == victim then return end
	EconomyManager.AddCredits(killer, GameConfig.KILL_REWARD)
end

function EconomyManager.OnSpikePlanted(planter, attackerTeamPlayers)
	for _, p in ipairs(attackerTeamPlayers) do
		EconomyManager.AddCredits(p, GameConfig.PLANT_REWARD)
	end
end

function EconomyManager.OnSpikeDefused(defenderTeamPlayers)
	for _, p in ipairs(defenderTeamPlayers) do
		EconomyManager.AddCredits(p, GameConfig.DEFUSE_REWARD)
	end
end

function EconomyManager.DistributeRoundEndCredits(winnerTeam, allPlayers, teamServiceModule)
	for _, p in ipairs(allPlayers) do
		local playerTeam = teamServiceModule.GetTeam(p)
		local amount
		if playerTeam == winnerTeam then
			amount = GameConfig.WIN_BONUS
			consecutiveLosses[p] = 0
		else
			consecutiveLosses[p] = (consecutiveLosses[p] or 0) + 1
			local idx = math.min(consecutiveLosses[p], 3)
			amount = GameConfig.LOSS_BONUS[idx] or GameConfig.LOSS_BONUS_CAP
		end
		EconomyManager.AddCredits(p, amount)
	end
end

function EconomyManager.ResetForNewHalf()
	for _, p in ipairs(Players:GetPlayers()) do
		EconomyManager.SetCredits(p, GameConfig.STARTING_CREDITS)
		consecutiveLosses[p] = 0
	end
end

function EconomyManager.SetAllCredits(amount)
	for _, p in ipairs(Players:GetPlayers()) do
		EconomyManager.SetCredits(p, amount)
	end
end

function EconomyManager.MarkSurvivor(player)
	roundSurvivor[player] = true
end

function EconomyManager.WasSurvivor(player)
	return roundSurvivor[player] == true
end

function EconomyManager.ClearSurvivors()
	roundSurvivor = {}
end

function EconomyManager.Start()
	Players.PlayerAdded:Connect(function(player)
		task.wait(0.5)
		EconomyManager.SetCredits(player, GameConfig.STARTING_CREDITS)
	end)
	Players.PlayerRemoving:Connect(function(player)
		credits[player] = nil
		consecutiveLosses[player] = nil
		roundSurvivor[player] = nil
	end)
end

return EconomyManager
