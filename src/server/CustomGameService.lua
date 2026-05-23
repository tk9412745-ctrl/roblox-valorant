-- CustomGameService: custom matches z 4-cyfrowym kodem
-- MVP: tylko host-side w aktualnym serwerze (cross-server via TeleportService = TODO)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CustomGameService = {}

local activeLobbies = {}  -- [code] = { host, settings, players }

local function genCode()
	local code
	repeat
		code = tostring(math.random(1000, 9999))
	until not activeLobbies[code]
	return code
end

function CustomGameService.CreateLobby(host, settings)
	if not host then return nil end
	-- Cleanup any existing for this host
	for code, lobby in pairs(activeLobbies) do
		if lobby.host == host then
			activeLobbies[code] = nil
		end
	end

	local code = genCode()
	activeLobbies[code] = {
		host = host,
		settings = settings or {},
		players = { host },
		created = os.time(),
	}
	-- Set attribute so host sees the code
	host:SetAttribute("CustomLobbyCode", code)
	host:SetAttribute("CustomLobbyHost", true)
	return code
end

function CustomGameService.JoinLobby(player, code)
	local lobby = activeLobbies[code]
	if not lobby then return false, "Invalid code" end
	if #lobby.players >= 10 then return false, "Lobby full" end
	for _, p in ipairs(lobby.players) do
		if p == player then return true end
	end
	table.insert(lobby.players, player)
	player:SetAttribute("CustomLobbyCode", code)
	return true
end

function CustomGameService.LeaveLobby(player)
	for code, lobby in pairs(activeLobbies) do
		for i, p in ipairs(lobby.players) do
			if p == player then
				table.remove(lobby.players, i)
				player:SetAttribute("CustomLobbyCode", nil)
				player:SetAttribute("CustomLobbyHost", nil)
				if #lobby.players == 0 then
					activeLobbies[code] = nil
				end
				return
			end
		end
	end
end

function CustomGameService.GetLobby(code)
	return activeLobbies[code]
end

function CustomGameService.Start()
	-- Players can use /host and /join CODE via chat
	Players.PlayerAdded:Connect(function(player)
		player.Chatted:Connect(function(msg)
			if msg == "/host" then
				local code = CustomGameService.CreateLobby(player, {})
				if code then
					player:SetAttribute("CustomLobbyMessage", "Custom lobby created: " .. code)
				end
			elseif msg:sub(1, 6) == "/join " then
				local code = msg:sub(7)
				local ok, err = CustomGameService.JoinLobby(player, code)
				player:SetAttribute("CustomLobbyMessage", ok and "Joined lobby" or err)
			elseif msg == "/leave" then
				CustomGameService.LeaveLobby(player)
				player:SetAttribute("CustomLobbyMessage", "Left lobby")
			end
		end)
	end)

	Players.PlayerRemoving:Connect(function(player)
		CustomGameService.LeaveLobby(player)
	end)
end

return CustomGameService
