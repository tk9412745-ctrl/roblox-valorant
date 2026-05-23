-- ChatService: server-side text chat z /team i /all channels

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local ChatService = {}

local chatCooldowns = {}
local CHAT_COOLDOWN = 0.5
local MAX_MSG_LENGTH = 120

local function isValid(msg)
	if typeof(msg) ~= "string" then return false end
	if #msg == 0 then return false end
	if #msg > MAX_MSG_LENGTH then return false end
	return true
end

function ChatService.Start()
	Remotes.SendChat.OnServerEvent:Connect(function(player, channel, message)
		if not isValid(message) or typeof(channel) ~= "string" then return end

		local now = tick()
		if chatCooldowns[player] and (now - chatCooldowns[player]) < CHAT_COOLDOWN then
			return
		end
		chatCooldowns[player] = now

		-- Strip dangerous chars
		message = message:gsub("[%c]", "")
		if #message == 0 then return end

		local senderName = player.Name
		local senderTeam = player.Team and player.Team.Name or "Spectator"

		if channel == "team" then
			-- Send only to teammates
			for _, p in ipairs(Players:GetPlayers()) do
				if p.Team == player.Team then
					Remotes.ChatReceived:FireClient(p, channel, senderName, senderTeam, message)
				end
			end
		else
			-- "all" channel — broadcast
			Remotes.ChatReceived:FireAllClients("all", senderName, senderTeam, message)
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		chatCooldowns[player] = nil
	end)
end

return ChatService
