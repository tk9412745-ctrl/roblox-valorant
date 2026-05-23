-- SettingsService: persistowanie settings per player (przez PlayerData)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local SettingsService = {}
local PlayerData

function SettingsService.Init(deps)
	PlayerData = deps.playerData
end

function SettingsService.Save(player, settings)
	local profile = PlayerData.Get(player)
	if not profile then return end
	if not profile.Settings then profile.Settings = {} end
	for k, v in pairs(settings) do
		profile.Settings[k] = v
	end
end

function SettingsService.Load(player)
	local profile = PlayerData.Get(player)
	if not profile then return {} end
	return profile.Settings or {}
end

function SettingsService.Start()
	Remotes.SaveSettings.OnServerEvent:Connect(function(player, settings)
		if settings == nil then
			-- Request load
			Remotes.LoadSettings:FireClient(player, SettingsService.Load(player))
			return
		end
		if typeof(settings) ~= "table" then return end
		SettingsService.Save(player, settings)
	end)

	-- Auto-load on player join
	Players.PlayerAdded:Connect(function(player)
		task.wait(1.5)  -- wait for profile to load
		local s = SettingsService.Load(player)
		Remotes.LoadSettings:FireClient(player, s)
	end)
end

return SettingsService
