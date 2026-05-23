local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local AbilityService = {}

-- Registered agents: [agentName] = AgentModule
local agentModules = {}

-- Per-player state: [player] = { charges = {C=n,Q=n,E=n}, ultUsed = bool }
local playerStates = {}

-- Dependencies (set via Init)
local ultManager
local economy

function AbilityService.Init(deps)
	ultManager = deps.ult
	economy = deps.economy
end

function AbilityService.RegisterAgent(agentName, module)
	agentModules[agentName] = module
end

local function getState(player)
	if not playerStates[player] then
		playerStates[player] = { charges = {}, ultUsed = false }
	end
	return playerStates[player]
end

local function sendAbilityUpdate(player)
	local state = getState(player)
	local agent = ultManager and ultManager.GetAgent(player)
	Remotes.UpdateAbilityState:FireClient(player, agent, state.charges, state.ultUsed)
end

function AbilityService.SetCharges(player, key, amount)
	local state = getState(player)
	state.charges[key] = amount
	sendAbilityUpdate(player)
end

function AbilityService.AddCharges(player, key, amount)
	local state = getState(player)
	state.charges[key] = (state.charges[key] or 0) + amount
	sendAbilityUpdate(player)
end

function AbilityService.GetCharges(player, key)
	return getState(player).charges[key] or 0
end

function AbilityService.UseAbility(player, key)
	local agent = ultManager and ultManager.GetAgent(player)
	if not agent then return false end
	local module = agentModules[agent]
	if not module then return false end

	local state = getState(player)

	if key == "X" then
		if state.ultUsed then return false end
		if not ultManager.IsReady(player) then return false end
		if not module.canUseUlt or module.canUseUlt(player) then
			local ok = module.executeAbility(player, "X")
			if ok then
				ultManager.ConsumeUlt(player)
				state.ultUsed = true
				sendAbilityUpdate(player)
				return true
			end
		end
		return false
	end

	-- Basic abilities use charges
	if (state.charges[key] or 0) <= 0 then return false end

	local ok = module.executeAbility(player, key)
	if ok then
		state.charges[key] -= 1
		sendAbilityUpdate(player)
	end
	return ok
end

function AbilityService.BuyAbility(player, key, cost)
	local agent = ultManager and ultManager.GetAgent(player)
	if not agent then return false end
	local module = agentModules[agent]
	if not module or not module.abilityCosts or not module.abilityCosts[key] then return false end
	local realCost = module.abilityCosts[key]
	if cost ~= realCost then return false end  -- prevent client-side cost spoofing
	if not economy.SpendCredits(player, realCost) then return false end
	AbilityService.AddCharges(player, key, 1)
	return true
end

function AbilityService.OnRoundStart(player)
	local agent = ultManager and ultManager.GetAgent(player)
	local state = getState(player)
	state.ultUsed = false
	state.charges = {}

	if agent then
		local module = agentModules[agent]
		if module and module.signatureKey then
			-- Signature recharges every round to its max
			state.charges[module.signatureKey] = module.signatureMaxCharges or 1
		end
	end
	sendAbilityUpdate(player)
end

function AbilityService.SetAgent(player, agentName)
	if ultManager then ultManager.SetAgent(player, agentName) end
	AbilityService.OnRoundStart(player)
end

function AbilityService.Start()
	Remotes.UseAbility.OnServerEvent:Connect(function(player, key)
		if typeof(key) ~= "string" then return end
		if key ~= "C" and key ~= "Q" and key ~= "E" and key ~= "X" then return end
		AbilityService.UseAbility(player, key)
	end)

	Players.PlayerRemoving:Connect(function(player)
		playerStates[player] = nil
	end)
end

return AbilityService
