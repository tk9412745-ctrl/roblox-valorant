-- PingService: broadcast pings do teammates (Valorant style)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local PingService = {}

local pingCooldowns = {}  -- [player] = last ping time
local PING_COOLDOWN = 0.5
local PING_TYPES = {
	Watching = true,
	Danger = true,
	Push = true,
	Backup = true,
	Default = true,
}

function PingService.Start()
	Remotes.SendPing.OnServerEvent:Connect(function(player, position, pingType)
		if typeof(position) ~= "Vector3" then return end
		if typeof(pingType) ~= "string" then pingType = "Default" end
		if not PING_TYPES[pingType] then return end

		local now = tick()
		if pingCooldowns[player] and (now - pingCooldowns[player]) < PING_COOLDOWN then
			return  -- rate limit
		end
		pingCooldowns[player] = now

		-- Broadcast to teammates only
		for _, teammate in ipairs(Players:GetPlayers()) do
			if teammate.Team == player.Team then
				Remotes.PingReceived:FireClient(teammate, player.Name, position, pingType)
			end
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		pingCooldowns[player] = nil
	end)
end

return PingService
