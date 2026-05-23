-- SoundController: client-side sound playback dla round events, UI, ambient
-- Centralizuje wszystkie efekty dźwiękowe

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
local SoundIds = require(ReplicatedStorage.Shared:WaitForChild("SoundIds"))

local SoundController = {}

local LocalPlayer = Players.LocalPlayer

local function playSound(soundId, volume, parent)
	local s = Instance.new("Sound")
	s.SoundId = soundId
	s.Volume = volume or 0.7
	s.Parent = parent or SoundService
	s:Play()
	s.Ended:Connect(function() s:Destroy() end)
	Debris:AddItem(s, 8)
	return s
end

-- Spike tick audio (escalates as timer counts down)
local spikeTickLoop
local function startSpikeTick()
	if spikeTickLoop then return end
	spikeTickLoop = task.spawn(function()
		local startTime = tick()
		while spikeTickLoop do
			-- Tick rate accelerates
			local interval = 1.0
			-- We approximate timing — server-side has actual phase but client just ticks faster after a while
			local elapsed = tick() - startTime
			if elapsed > 20 then interval = 0.5 end
			if elapsed > 30 then interval = 0.3 end
			if elapsed > 40 then interval = 0.15 end

			playSound(SoundIds.Spike.TickSlow, 0.4)
			task.wait(interval)
		end
	end)
end

local function stopSpikeTick()
	if spikeTickLoop then
		task.cancel(spikeTickLoop)
		spikeTickLoop = nil
	end
end

local lastTickSecond = nil

function SoundController.Start()
	-- Round phase transitions
	Remotes.RoundPhaseChanged.OnClientEvent:Connect(function(phase)
		lastTickSecond = nil  -- reset tick on phase change
		stopSpikeTick()
		if phase == "BuyPhase" then
			playSound(SoundIds.Round.BuyPhaseStart, 0.6)
		elseif phase == "Round" then
			playSound(SoundIds.Round.RoundStart, 0.7)
		elseif phase == "PostRound" then
			-- handled by RoundEnded with winner
		elseif phase == "HalfTime" then
			playSound(SoundIds.Round.HalftimeStart, 0.8)
		elseif phase == "MatchEnd" then
			playSound(SoundIds.Round.MatchEnd, 1.0)
		end
	end)

	-- Round end win/lose
	Remotes.RoundEnded.OnClientEvent:Connect(function(winner, reason, round)
		stopSpikeTick()
		local playerTeam = LocalPlayer.Team and LocalPlayer.Team.Name
		if playerTeam == winner then
			playSound(SoundIds.Round.RoundWin, 0.7)
		else
			playSound(SoundIds.Round.RoundLose, 0.6)
		end
	end)

	-- Spike state
	Remotes.SpikeStateChanged.OnClientEvent:Connect(function(newState)
		if newState == "Planted" then
			playSound(SoundIds.Spike.Planted, 0.8)
			startSpikeTick()
		elseif newState == "Defused" then
			playSound(SoundIds.Spike.Defused, 0.8)
			stopSpikeTick()
		elseif newState == "Detonated" then
			playSound(SoundIds.Spike.Detonate, 1.0)
			stopSpikeTick()
		end
	end)

	-- Buy result sounds
	Remotes.BuyResult.OnClientEvent:Connect(function(success, message)
		if success then
			playSound(SoundIds.UI.Purchase, 0.5)
		else
			playSound(SoundIds.UI.Error, 0.4)
		end
	end)

	-- Round timer ticks (last 10s of buy phase, last 10s of round)
	Remotes.UpdateRoundTimer.OnClientEvent:Connect(function(phase, remaining)
		if not remaining then return end
		local secondsLeft = math.floor(remaining)
		-- Tick only during action phases with low time
		local urgent = (phase == "Round" and secondsLeft <= 10) or (phase == "BuyPhase" and secondsLeft <= 5)
		if urgent and secondsLeft >= 0 and secondsLeft ~= lastTickSecond then
			lastTickSecond = secondsLeft
			-- Play tick — louder/faster as countdown nears 0
			local vol = secondsLeft <= 3 and 0.6 or 0.3
			playSound(SoundIds.Spike.TickSlow, vol)
		end
	end)

	-- Damage taken — impact sound on local player
	LocalPlayer.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		local lastHealth = humanoid.Health
		humanoid.HealthChanged:Connect(function(newHealth)
			if newHealth < lastHealth - 1 then
				playSound(SoundIds.Hit.Body, 0.3)
			end
			lastHealth = newHealth
		end)
	end)
end

return SoundController
