-- AFKService: track player inactivity (no movement 60s), warn 90s, kick 120s

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local AFKService = {}

local WARN_THRESHOLD = 60
local KICK_THRESHOLD = 120

local lastActivity = {}  -- [player] = tick() of last detected movement/action

local function updateActivity(player)
	lastActivity[player] = tick()
end

function AFKService.MarkActive(player)
	updateActivity(player)
end

local function checkPlayer(player)
	local last = lastActivity[player] or tick()
	local elapsed = tick() - last

	if elapsed > KICK_THRESHOLD then
		player:Kick("Disconnected: inactive for " .. KICK_THRESHOLD .. " seconds")
	elseif elapsed > WARN_THRESHOLD then
		player:SetAttribute("AFKWarning", true)
		player:SetAttribute("AFKSecondsLeft", KICK_THRESHOLD - elapsed)
	else
		player:SetAttribute("AFKWarning", false)
	end
end

function AFKService.Start()
	-- Track movement input
	Players.PlayerAdded:Connect(function(player)
		updateActivity(player)
		player.CharacterAdded:Connect(function(character)
			updateActivity(player)
			local humanoid = character:WaitForChild("Humanoid", 5)
			if humanoid then
				humanoid.Running:Connect(function() updateActivity(player) end)
				humanoid.Jumping:Connect(function() updateActivity(player) end)
				humanoid.StateChanged:Connect(function() updateActivity(player) end)
			end
		end)
	end)

	Players.PlayerRemoving:Connect(function(player)
		lastActivity[player] = nil
	end)

	-- Periodic check
	task.spawn(function()
		while true do
			task.wait(5)
			for _, player in ipairs(Players:GetPlayers()) do
				checkPlayer(player)
			end
		end
	end)
end

return AFKService
