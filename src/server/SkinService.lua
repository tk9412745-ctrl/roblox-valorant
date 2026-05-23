local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SkinDatabase = require(ReplicatedStorage.Shared.SkinDatabase)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local SkinService = {}
local PlayerData  -- set by Init

function SkinService.Init(deps)
	PlayerData = deps.playerData
end

-- Rate limit per player
local lastEquipTime = {}
local EQUIP_RATE_LIMIT = 0.2  -- 5 per second max

function SkinService.HandleEquip(player, weaponName, skinId)
	-- Type validation
	if typeof(weaponName) ~= "string" or typeof(skinId) ~= "string" then return false end

	-- Rate limit
	local now = tick()
	if lastEquipTime[player] and (now - lastEquipTime[player]) < EQUIP_RATE_LIMIT then
		return false
	end
	lastEquipTime[player] = now

	-- Whitelist validation
	local skin = SkinDatabase.Get(skinId)
	if not skin then return false end
	if skin.Weapon ~= weaponName then return false end

	-- Ownership validation (CRITICAL)
	if not PlayerData.OwnsSkin(player, skinId) then
		warn("[SkinService] Player " .. player.Name .. " attempted to equip unowned skin " .. skinId)
		return false
	end

	-- Apply
	PlayerData.SetEquipped(player, weaponName, skinId)
	Remotes.SkinEquipped:FireAllClients(player.UserId, weaponName, skinId)
	return true
end

function SkinService.GetEquipped(player, weaponName)
	if not PlayerData then return nil end
	return PlayerData.GetEquipped(player, weaponName)
end

function SkinService.GetEquippedSkinData(player, weaponName)
	local skinId = SkinService.GetEquipped(player, weaponName)
	if not skinId then return nil end
	return SkinDatabase.Get(skinId)
end

function SkinService.GrantSkin(player, skinId)
	if not PlayerData then return false end
	local skin = SkinDatabase.Get(skinId)
	if not skin then return false end
	return PlayerData.GrantSkin(player, skinId)
end

function SkinService.Start()
	Remotes.EquipSkin.OnServerEvent:Connect(SkinService.HandleEquip)
	Players.PlayerRemoving:Connect(function(player)
		lastEquipTime[player] = nil
	end)
end

return SkinService
