local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local UltPointsManager = {}

local points = {}        -- [player] = number
local equippedAgent = {} -- [player] = "Jett" / "Sage" / "Phoenix"
local ultReady = {}      -- [player] = bool (ult charge consumed?)

local DEFAULT_ULT_COST = 7

local function getUltCost(player)
	local agent = equippedAgent[player]
	if not agent then return DEFAULT_ULT_COST end
	return GameConfig.AGENT_ULT_COSTS[agent] or DEFAULT_ULT_COST
end

local function sendUpdate(player)
	local current = points[player] or 0
	local max = getUltCost(player)
	Remotes.UpdateUltPoints:FireClient(player, current, max)
end

function UltPointsManager.GetPoints(player)
	return points[player] or 0
end

function UltPointsManager.GetMax(player)
	return getUltCost(player)
end

function UltPointsManager.IsReady(player)
	return (points[player] or 0) >= getUltCost(player)
end

function UltPointsManager.Award(player, amount)
	if not player then return end
	points[player] = math.min((points[player] or 0) + (amount or 1), getUltCost(player))
	sendUpdate(player)
end

function UltPointsManager.OnKill(killer, victim)
	if killer and killer ~= victim then UltPointsManager.Award(killer, 1) end
	if victim then UltPointsManager.Award(victim, 1) end
end

function UltPointsManager.OnSpikePlant(planter)
	UltPointsManager.Award(planter, 1)
end

function UltPointsManager.OnSpikeDefuse(defuser)
	UltPointsManager.Award(defuser, 1)
end

function UltPointsManager.OnOrbPickup(player)
	UltPointsManager.Award(player, 1)
end

function UltPointsManager.SetAgent(player, agent)
	equippedAgent[player] = agent
	sendUpdate(player)
end

function UltPointsManager.GetAgent(player)
	return equippedAgent[player]
end

function UltPointsManager.ConsumeUlt(player)
	if not UltPointsManager.IsReady(player) then return false end
	points[player] = 0
	sendUpdate(player)
	return true
end

function UltPointsManager.ResetAll()
	for player, _ in pairs(points) do
		points[player] = 0
		sendUpdate(player)
	end
end

function UltPointsManager.Start()
	Players.PlayerAdded:Connect(function(player)
		task.wait(0.5)
		points[player] = 0
		sendUpdate(player)
	end)
	Players.PlayerRemoving:Connect(function(player)
		points[player] = nil
		equippedAgent[player] = nil
	end)
end

return UltPointsManager
