local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
local SoundIds = require(ReplicatedStorage.Shared:WaitForChild("SoundIds"))

local AbilityController = {}

local ABILITY_SOUNDS = {
	Jett = {
		Cloudburst = SoundIds.Ability.JettSmoke,
		Updraft = SoundIds.Ability.JettUpdraft,
		TailwindReady = SoundIds.Ability.JettDash,
		TailwindDash = SoundIds.Ability.JettDash,
		BladeStormStart = SoundIds.Ability.JettKnives,
	},
	Sage = {
		BarrierOrb = SoundIds.Ability.SageWall,
		SlowOrb = SoundIds.Ability.SageSlow,
		HealingOrb = SoundIds.Ability.SageHeal,
		ResChannel = SoundIds.Ability.SageRes,
		ResComplete = SoundIds.Ability.SageRes,
	},
	Phoenix = {
		Blaze = SoundIds.Ability.PhoenixBlaze,
		Curveball = SoundIds.Ability.PhoenixFlash,
		HotHands = SoundIds.Ability.PhoenixHot,
		RunItBack = SoundIds.Ability.PhoenixRevive,
	},
}

local function playSound(soundId, volume)
	local s = Instance.new("Sound")
	s.SoundId = soundId
	s.Volume = volume or 0.7
	s.Parent = SoundService
	s:Play()
	Debris:AddItem(s, 5)
end

local currentAgent = nil
local charges = {}
local ultUsed = false

local KEY_BINDINGS = {
	[Enum.KeyCode.C] = "C",
	[Enum.KeyCode.Q] = "Q",
	[Enum.KeyCode.E] = "E",
	[Enum.KeyCode.X] = "X",
}

local function onInputBegan(input, processed)
	if processed then return end
	local key = KEY_BINDINGS[input.KeyCode]
	if not key then return end
	Remotes.UseAbility:FireServer(key)
end

local function onFlashed(duration)
	-- Show white overlay temporarily
	local player = Players.LocalPlayer
	local gui = player.PlayerGui:FindFirstChild("HUD")
	if not gui then return end
	local flash = Instance.new("Frame")
	flash.Size = UDim2.fromScale(1, 1)
	flash.Position = UDim2.fromScale(0, 0)
	flash.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	flash.BackgroundTransparency = 0
	flash.ZIndex = 100
	flash.Parent = gui
	-- Fade out
	task.spawn(function()
		local TweenService = game:GetService("TweenService")
		local tween = TweenService:Create(flash, TweenInfo.new(duration, Enum.EasingStyle.Linear), { BackgroundTransparency = 1 })
		tween:Play()
		tween.Completed:Wait()
		flash:Destroy()
	end)
end

function AbilityController.GetState()
	return currentAgent, charges, ultUsed
end

function AbilityController.Start()
	UserInputService.InputBegan:Connect(onInputBegan)

	Remotes.UpdateAbilityState.OnClientEvent:Connect(function(agent, newCharges, used)
		currentAgent = agent
		charges = newCharges or {}
		ultUsed = used or false
	end)

	Remotes.AbilityFired.OnClientEvent:Connect(function(playerOrAgent, agentName, abilityName, data)
		-- Flash overlay
		if abilityName == "Flashed" then
			onFlashed(data or 1.5)
			return
		end

		-- Play sound effect for the ability
		local agentSounds = ABILITY_SOUNDS[agentName]
		if agentSounds and agentSounds[abilityName] then
			playSound(agentSounds[abilityName], 0.6)
		end
	end)
end

return AbilityController
