-- PolicyService wrapper: UK <18 detection for paid random items
-- API: Roblox PolicyService:GetPolicyInfoForPlayerAsync
-- If ArePaidRandomItemsRestricted=true → hide crate UI + block crate purchases

local Players = game:GetService("Players")
local PolicyServiceAPI = game:GetService("PolicyService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local PolicyService = {}

local restrictedFlags = {}  -- [userId] = true if paid-random items restricted

function PolicyService.IsRestricted(player)
	return restrictedFlags[player.UserId] == true
end

function PolicyService.GetPolicyInfo(player)
	local success, info = pcall(function()
		return PolicyServiceAPI:GetPolicyInfoForPlayerAsync(player)
	end)
	if success then return info end
	return nil
end

local function notifyClient(player)
	-- Inform client about their restriction status so UI can hide crate options
	if Remotes.SkinEquipped then  -- reuse a remote channel: just create a dedicated one
		-- Use a generic restricted flag event; if doesn't exist, just set via attribute
		player:SetAttribute("PaidRandomItemsRestricted", restrictedFlags[player.UserId] == true)
	end
end

function PolicyService.CheckPlayer(player)
	local info = PolicyService.GetPolicyInfo(player)
	if info and info.ArePaidRandomItemsRestricted then
		restrictedFlags[player.UserId] = true
	else
		restrictedFlags[player.UserId] = false
	end
	notifyClient(player)
end

function PolicyService.Start()
	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(PolicyService.CheckPlayer, player)
	end
	Players.PlayerAdded:Connect(function(player)
		task.spawn(PolicyService.CheckPlayer, player)
	end)
	Players.PlayerRemoving:Connect(function(player)
		restrictedFlags[player.UserId] = nil
	end)
end

return PolicyService
