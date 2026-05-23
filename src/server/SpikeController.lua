local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local SpikeController = {}

local STATE_IDLE = "Idle"
local STATE_CARRIED = "Carried"
local STATE_DROPPED = "Dropped"
local STATE_PLANTED = "Planted"
local STATE_DEFUSED = "Defused"
local STATE_DETONATED = "Detonated"

local state = STATE_IDLE
local spikeModel  -- Instance — wizualny model spike
local carrier      -- player aktualnie noszący
local plantedAt    -- Vector3 pozycja po plancie
local plantTimerExpire  -- tick() kiedy detonacja
local plantedBy
local activeInteraction  -- { player, type = "plant" | "defuse", startTime, requiredDuration, halfProgress }
local defusedProgress = 0  -- 0-1 cumulative progress (saved on half-defuse breaker)

local plantAreaParts = {}  -- BasePart instances oznaczone jako plant area

local listeners = {
	onPlanted = {},
	onDefused = {},
	onDetonated = {},
}

local function setState(newState, extraData)
	state = newState
	Remotes.SpikeStateChanged:FireAllClients(newState, extraData)
end

function SpikeController.SetPlantAreas(parts)
	plantAreaParts = parts
end

function SpikeController.RegisterListener(eventName, callback)
	if listeners[eventName] then
		table.insert(listeners[eventName], callback)
	end
end

local function fireListener(eventName, ...)
	for _, cb in ipairs(listeners[eventName] or {}) do
		task.spawn(cb, ...)
	end
end

local function isInPlantArea(position)
	for _, part in ipairs(plantAreaParts) do
		if part and part.Parent then
			local distance = (position - part.Position).Magnitude
			if distance <= (part.Size.X + part.Size.Z) / 2 then
				return true, part
			end
		end
	end
	return false, nil
end

function SpikeController.SpawnForAttackers(attackerSpawnPos)
	-- Create simple visual model for spike
	if spikeModel then spikeModel:Destroy() end
	spikeModel = Instance.new("Part")
	spikeModel.Name = "Spike"
	spikeModel.Size = Vector3.new(1, 2, 1)
	spikeModel.Position = (attackerSpawnPos or Vector3.new(0, 5, -60)) + Vector3.new(0, 3, 0)
	spikeModel.Color = Color3.fromRGB(200, 50, 30)
	spikeModel.Material = Enum.Material.Neon
	spikeModel.Anchored = false
	spikeModel.CanCollide = false
	spikeModel:SetAttribute("Spike", true)
	spikeModel:SetAttribute("Planted", false)
	spikeModel.Parent = Workspace

	-- Auto-pickup by attackers on touch
	spikeModel.Touched:Connect(function(hit)
		if state ~= STATE_DROPPED then return end
		local character = hit:FindFirstAncestorWhichIsA("Model")
		if not character then return end
		local player = Players:GetPlayerFromCharacter(character)
		if not player then return end
		SpikeController.RequestPickup(player)
	end)

	-- Floating BillboardGui
	local bg = Instance.new("BillboardGui")
	bg.Size = UDim2.fromOffset(120, 40)
	bg.AlwaysOnTop = true
	bg.StudsOffset = Vector3.new(0, 2, 0)
	bg.Parent = spikeModel
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 100, 80)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 18
	label.Text = "SPIKE"
	label.TextStrokeTransparency = 0
	label.Parent = bg

	carrier = nil
	plantedAt = nil
	defusedProgress = 0
	activeInteraction = nil
	setState(STATE_DROPPED)
end

function SpikeController.RequestPickup(player)
	if state ~= STATE_DROPPED then return false end
	if not spikeModel or not spikeModel.Parent then return false end

	-- Only attackers can pick up
	if not player.Team or player.Team.Name ~= GameConfig.TEAM_ATTACKERS then return false end

	-- Must be near spike
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end
	if (hrp.Position - spikeModel.Position).Magnitude > 8 then return false end

	carrier = player
	spikeModel:SetAttribute("CarriedBy", player.UserId)
	setState(STATE_CARRIED, player.UserId)
	-- Visually attach to player (simplified: just teleport above their head each frame)
	task.spawn(function()
		while carrier == player and state == STATE_CARRIED do
			if char and char:FindFirstChild("HumanoidRootPart") then
				spikeModel.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, 4, 0)
			end
			task.wait(0.05)
		end
	end)
	return true
end

function SpikeController.RequestDrop(player)
	if state ~= STATE_CARRIED then return false end
	if carrier ~= player then return false end
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	carrier = nil
	spikeModel:SetAttribute("CarriedBy", nil)
	spikeModel.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 1, 0))
	setState(STATE_DROPPED)
	return true
end

function SpikeController.StartPlant(player)
	if state ~= STATE_CARRIED then return false end
	if carrier ~= player then return false end

	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	local inArea, _ = isInPlantArea(hrp.Position)
	if not inArea then return false end

	activeInteraction = {
		player = player,
		type = "plant",
		startTime = tick(),
		requiredDuration = GameConfig.SPIKE_PLANT_TIME,
	}
	Remotes.InteractProgress:FireClient(player, "plant", 0, GameConfig.SPIKE_PLANT_TIME)
	return true
end

function SpikeController.StartDefuse(player)
	if state ~= STATE_PLANTED then return false end
	if not player.Team or player.Team.Name ~= GameConfig.TEAM_DEFENDERS then return false end

	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp or not plantedAt then return false end
	if (hrp.Position - plantedAt).Magnitude > 5 then return false end

	activeInteraction = {
		player = player,
		type = "defuse",
		startTime = tick(),
		requiredDuration = GameConfig.SPIKE_DEFUSE_FULL,
		halfProgress = defusedProgress,  -- resume from breaker
	}
	Remotes.InteractProgress:FireClient(player, "defuse", defusedProgress, GameConfig.SPIKE_DEFUSE_FULL)
	return true
end

function SpikeController.CancelInteract(player)
	if activeInteraction and activeInteraction.player == player then
		-- For defuse: save progress at half-breaker point
		if activeInteraction.type == "defuse" then
			local elapsed = tick() - activeInteraction.startTime
			local progress = (activeInteraction.halfProgress or 0) + elapsed / activeInteraction.requiredDuration
			if progress >= 0.5 then
				defusedProgress = 0.5  -- save breaker
			end
		end
		Remotes.InteractProgress:FireClient(player, "cancel", 0, 0)
		activeInteraction = nil
	end
end

local function completePlant()
	local player = activeInteraction.player
	local char = player.Character
	if not char then activeInteraction = nil; return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then activeInteraction = nil; return end

	plantedAt = Vector3.new(hrp.Position.X, hrp.Position.Y, hrp.Position.Z)
	plantedBy = player
	plantTimerExpire = tick() + GameConfig.SPIKE_TIMER

	-- Move spike model to plant location (anchored, glowing)
	spikeModel.CFrame = CFrame.new(plantedAt)
	spikeModel.Anchored = true
	spikeModel.Color = Color3.fromRGB(255, 50, 30)
	spikeModel:SetAttribute("Planted", true)
	spikeModel:SetAttribute("CarriedBy", nil)
	carrier = nil

	-- Add pulsing red light to planted spike
	local light = Instance.new("PointLight")
	light.Name = "PlantedLight"
	light.Color = Color3.fromRGB(255, 50, 30)
	light.Range = 20
	light.Brightness = 2
	light.Parent = spikeModel

	activeInteraction = nil
	setState(STATE_PLANTED, plantedAt)
	fireListener("onPlanted", player)
end

local function completeDefuse()
	local player = activeInteraction.player
	activeInteraction = nil
	defusedProgress = 1
	if spikeModel then
		spikeModel:Destroy()
		spikeModel = nil
	end
	setState(STATE_DEFUSED)
	fireListener("onDefused", player)
end

local function detonate()
	if not plantedAt then return end

	-- Spawn dramatic explosion VFX
	local explosion = Instance.new("Part")
	explosion.Shape = Enum.PartType.Ball
	explosion.Size = Vector3.new(8, 8, 8)
	explosion.Position = plantedAt
	explosion.Anchored = true
	explosion.CanCollide = false
	explosion.Color = Color3.fromRGB(255, 220, 100)
	explosion.Material = Enum.Material.Neon
	explosion.Parent = Workspace

	-- Light
	local light = Instance.new("PointLight")
	light.Brightness = 5
	light.Color = Color3.fromRGB(255, 200, 80)
	light.Range = 60
	light.Parent = explosion

	-- Particle burst
	local attach = Instance.new("Attachment")
	attach.Parent = explosion
	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	emitter.Lifetime = NumberRange.new(0.5, 1.5)
	emitter.Rate = 0
	emitter.Speed = NumberRange.new(30, 60)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Color = ColorSequence.new(Color3.fromRGB(255, 220, 100))
	emitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 2),
		NumberSequenceKeypoint.new(1, 0),
	})
	emitter.Parent = attach
	emitter:Emit(200)

	-- Grow + fade
	local TweenService = game:GetService("TweenService")
	TweenService:Create(explosion, TweenInfo.new(1.5, Enum.EasingStyle.Quad), {
		Size = Vector3.new(80, 80, 80),
		Transparency = 1,
	}):Play()
	TweenService:Create(light, TweenInfo.new(1.5), { Brightness = 0 }):Play()
	game:GetService("Debris"):AddItem(explosion, 2)

	-- Shockwave ring (flat cylinder expanding)
	local shockwave = Instance.new("Part")
	shockwave.Shape = Enum.PartType.Cylinder
	shockwave.Size = Vector3.new(0.5, 4, 4)
	shockwave.CFrame = CFrame.new(plantedAt) * CFrame.Angles(0, 0, math.rad(90))
	shockwave.Anchored = true
	shockwave.CanCollide = false
	shockwave.Color = Color3.fromRGB(255, 240, 200)
	shockwave.Material = Enum.Material.Neon
	shockwave.Transparency = 0.3
	shockwave.Parent = Workspace
	TweenService:Create(shockwave, TweenInfo.new(1, Enum.EasingStyle.Quad), {
		Size = Vector3.new(0.3, 120, 120),
		Transparency = 1,
	}):Play()
	game:GetService("Debris"):AddItem(shockwave, 1.2)

	-- Damage everyone within radius
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
			local hrp = player.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				local distance = (hrp.Position - plantedAt).Magnitude
				if distance <= GameConfig.SPIKE_BLAST_RADIUS_STUDS then
					player.Character:FindFirstChildOfClass("Humanoid").Health = 0
				elseif distance <= GameConfig.SPIKE_OUTER_RADIUS_STUDS then
					local falloff = 1 - ((distance - GameConfig.SPIKE_BLAST_RADIUS_STUDS) / (GameConfig.SPIKE_OUTER_RADIUS_STUDS - GameConfig.SPIKE_BLAST_RADIUS_STUDS))
					player.Character:FindFirstChildOfClass("Humanoid"):TakeDamage(GameConfig.SPIKE_OUTER_DAMAGE * falloff)
				end
			end
		end
	end
	if spikeModel then
		spikeModel:Destroy()
		spikeModel = nil
	end
	setState(STATE_DETONATED)
	fireListener("onDetonated")
end

function SpikeController.GetState()
	return state
end

function SpikeController.GetPlantPosition()
	return plantedAt
end

function SpikeController.GetPlanter()
	return plantedBy
end

function SpikeController.Reset()
	if spikeModel then
		spikeModel:Destroy()
		spikeModel = nil
	end
	state = STATE_IDLE
	carrier = nil
	plantedAt = nil
	plantedBy = nil
	plantTimerExpire = nil
	defusedProgress = 0
	activeInteraction = nil
end

function SpikeController.Start()
	Remotes.RequestPlant.OnServerEvent:Connect(SpikeController.StartPlant)
	Remotes.RequestDefuse.OnServerEvent:Connect(SpikeController.StartDefuse)
	Remotes.CancelInteract.OnServerEvent:Connect(SpikeController.CancelInteract)

	-- Tick interactions + detonation
	task.spawn(function()
		while true do
			task.wait(0.1)
			if activeInteraction then
				local elapsed = tick() - activeInteraction.startTime
				local progressFromBase = activeInteraction.halfProgress or 0
				local progressAdd = elapsed / activeInteraction.requiredDuration
				local total = progressFromBase + progressAdd
				if activeInteraction.type == "plant" and elapsed >= activeInteraction.requiredDuration then
					completePlant()
				elseif activeInteraction.type == "defuse" and total >= 1 then
					completeDefuse()
				else
					Remotes.InteractProgress:FireClient(
						activeInteraction.player,
						activeInteraction.type,
						total,
						activeInteraction.requiredDuration
					)
				end
			end
			if state == STATE_PLANTED and plantTimerExpire and tick() >= plantTimerExpire then
				detonate()
				plantTimerExpire = nil
			end
		end
	end)
end

return SpikeController
