local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WeaponDatabase = require(ReplicatedStorage.Shared.WeaponDatabase)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local BuyService = {}

local economy, combat, ability, round, ult

function BuyService.Init(deps)
	economy = deps.economy
	combat = deps.combat
	ability = deps.ability
	round = deps.round
	ult = deps.ult
end

local function isBuyPhase()
	if not round then return true end  -- allow if RoundManager not wired
	local state = round.GetState()
	return state == "BuyPhase" or state == "PreMatch"
end

local function sendResult(player, success, message)
	Remotes.BuyResult:FireClient(player, success, message)
end

-- ============================================================
-- Weapon purchase
-- ============================================================
local function buyWeapon(player, weaponName)
	if not isBuyPhase() then
		sendResult(player, false, "Not in buy phase")
		return
	end

	local weapon = WeaponDatabase[weaponName]
	if not weapon or weapon.Category == "Melee" then
		sendResult(player, false, "Invalid weapon")
		return
	end

	if not economy.SpendCredits(player, weapon.Price) then
		sendResult(player, false, "Insufficient credits")
		return
	end

	combat.SetWeapon(player, weaponName)
	sendResult(player, true, "Bought " .. weaponName)
end

-- ============================================================
-- Armor purchase
-- ============================================================
local function buyArmor(player, armorType)
	if not isBuyPhase() then
		sendResult(player, false, "Not in buy phase")
		return
	end
	local cfg = WeaponDatabase.Armor[armorType]
	if not cfg then
		sendResult(player, false, "Invalid armor")
		return
	end

	-- Don't double-buy same armor type if already at max
	local current = combat.GetArmor(player)
	if current and current.type == armorType and current.hp >= cfg.MaxHp then
		sendResult(player, false, "Already has " .. armorType)
		return
	end

	if not economy.SpendCredits(player, cfg.Cost) then
		sendResult(player, false, "Insufficient credits")
		return
	end

	combat.GrantArmor(player, armorType)
	sendResult(player, true, "Bought " .. armorType)
end

-- ============================================================
-- Ability purchase
-- ============================================================
local function buyAbility(player, key)
	if not isBuyPhase() then
		sendResult(player, false, "Not in buy phase")
		return
	end

	-- AbilityService.BuyAbility validates cost vs agent module
	local agent = ult and ult.GetAgent(player)
	if not agent then
		sendResult(player, false, "No agent selected")
		return
	end

	local ok = ability.BuyAbility(player, key, nil)
	sendResult(player, ok, ok and "Ability bought" or "Buy failed")
end

-- ============================================================
-- Agent selection (one-time, persists through match)
-- ============================================================
local function selectAgent(player, agentName)
	if not ability then return end
	if not agentName or typeof(agentName) ~= "string" then return end

	-- Allow all 12 implemented agents
	local allowed = {
		Jett = true, Sage = true, Phoenix = true, Cypher = true, Reyna = true, KAYO = true,
		Sova = true, Brimstone = true, Viper = true, Astra = true, Omen = true, Killjoy = true,
	}
	if not allowed[agentName] then
		sendResult(player, false, "Agent not implemented")
		return
	end

	ability.SetAgent(player, agentName)
	sendResult(player, true, "Selected " .. agentName)
end

-- ============================================================
-- Defuser tool (Sprint 84)
-- ============================================================
local function buyDefuser(player)
	if not isBuyPhase() then
		sendResult(player, false, "Not in buy phase")
		return
	end
	if not player.Team or player.Team.Name ~= "Defenders" then
		sendResult(player, false, "Defenders only")
		return
	end
	if player:GetAttribute("HasDefuser") then
		sendResult(player, false, "Already has defuser")
		return
	end
	if not economy.SpendCredits(player, 400) then
		sendResult(player, false, "Insufficient credits")
		return
	end
	player:SetAttribute("HasDefuser", true)
	sendResult(player, true, "Bought Defuser")
end

-- ============================================================
-- Buy router
-- ============================================================
function BuyService.HandleBuyRequest(player, requestType, argument)
	if typeof(requestType) ~= "string" then return end

	if requestType == "weapon" then
		buyWeapon(player, argument)
	elseif requestType == "armor" then
		buyArmor(player, argument)
	elseif requestType == "ability" then
		buyAbility(player, argument)
	elseif requestType == "agent" then
		selectAgent(player, argument)
	elseif requestType == "defuser" then
		buyDefuser(player)
	end
end

function BuyService.Start()
	Remotes.RequestBuy.OnServerEvent:Connect(BuyService.HandleBuyRequest)
end

return BuyService
