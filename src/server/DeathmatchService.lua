-- DeathmatchService: FFA mode dla quick play
-- /dm chat command toggles deathmatch mode
-- Auto-respawn 5s, score to 40 kills wins

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DeathmatchService = {}

local dmPlayers = {}    -- [player] = { score, deaths }
local DM_KILLS_TO_WIN = 40
local DM_RESPAWN_TIME = 5

local function isInDM(player)
	return dmPlayers[player] ~= nil
end

local function enterDM(player)
	if dmPlayers[player] then return end
	dmPlayers[player] = { score = 0, deaths = 0 }
	player:SetAttribute("DMMode", true)
	-- Respawn at random position
	if player.Character then player.Character:Destroy() end
	player:LoadCharacter()
end

local function exitDM(player)
	if not dmPlayers[player] then return end
	dmPlayers[player] = nil
	player:SetAttribute("DMMode", false)
	if player.Character then player.Character:Destroy() end
	player:LoadCharacter()
end

local function handleDMRespawn(player)
	if not dmPlayers[player] then return end
	task.wait(DM_RESPAWN_TIME)
	if not dmPlayers[player] then return end
	if player.Parent then
		player:LoadCharacter()
		task.wait(0.3)
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			-- Random spawn point
			local randomPos = Vector3.new(
				math.random(-50, 50),
				3,
				math.random(-50, 50)
			)
			player.Character.HumanoidRootPart.CFrame = CFrame.new(randomPos)
		end
	end
end

local function handleDMKill(killer, victim)
	if not killer or not victim then return end
	if dmPlayers[killer] then
		dmPlayers[killer].score += 1
		killer:SetAttribute("DMScore", dmPlayers[killer].score)
		-- Check win
		if dmPlayers[killer].score >= DM_KILLS_TO_WIN then
			-- Broadcast winner
			for _, p in ipairs(Players:GetPlayers()) do
				p:SetAttribute("DMWinner", killer.Name)
			end
			-- Exit all DM players
			for p, _ in pairs(dmPlayers) do
				task.wait(3)
				exitDM(p)
			end
		end
	end
	if dmPlayers[victim] then
		dmPlayers[victim].deaths += 1
	end
end

function DeathmatchService.Start()
	Players.PlayerAdded:Connect(function(player)
		player.Chatted:Connect(function(msg)
			if msg == "/dm" then
				enterDM(player)
			elseif msg == "/dmexit" then
				exitDM(player)
			end
		end)
		player.CharacterAdded:Connect(function(character)
			if dmPlayers[player] then
				local humanoid = character:WaitForChild("Humanoid", 5)
				if humanoid then
					humanoid.Died:Connect(function()
						handleDMRespawn(player)
					end)
				end
			end
		end)
	end)

	Players.PlayerRemoving:Connect(function(player)
		dmPlayers[player] = nil
	end)
end

function DeathmatchService.OnKill(killer, victim)
	handleDMKill(killer, victim)
end

function DeathmatchService.IsInDM(player)
	return isInDM(player)
end

function DeathmatchService.GetScore(player)
	return dmPlayers[player] and dmPlayers[player].score or 0
end

return DeathmatchService
