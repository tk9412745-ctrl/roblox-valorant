-- PracticeRange: osobna arena treningowa z poruszającymi się dummy + time-attack
-- Lokalizacja: Y=200, oddzielona od głównej mapy
-- Wejście: portal na lobby spawn lub przycisk z settings

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local PracticeRange = {}

local RANGE_CENTER = Vector3.new(500, 200, 500)
local RANGE_SIZE = Vector3.new(80, 30, 100)
local TARGET_COUNT = 10
local rangeBuilt = false
local rangeFolder

-- Per-player practice state
local playerScores = {}  -- [player] = { hits, startTime }

local function buildRange()
	if rangeBuilt then return end
	rangeBuilt = true

	rangeFolder = Instance.new("Folder")
	rangeFolder.Name = "PracticeRange"
	rangeFolder.Parent = Workspace

	-- Floor
	local floor = Instance.new("Part")
	floor.Name = "Floor"
	floor.Size = Vector3.new(RANGE_SIZE.X, 1, RANGE_SIZE.Z)
	floor.Position = RANGE_CENTER - Vector3.new(0, RANGE_SIZE.Y / 2, 0)
	floor.Anchored = true
	floor.Color = Color3.fromRGB(70, 70, 80)
	floor.Material = Enum.Material.Concrete
	floor.Parent = rangeFolder

	-- Walls
	local wallHeight = RANGE_SIZE.Y
	for _, side in ipairs({
		{ name = "WallN", pos = RANGE_CENTER + Vector3.new(0, 0, RANGE_SIZE.Z / 2), size = Vector3.new(RANGE_SIZE.X, wallHeight, 2) },
		{ name = "WallS", pos = RANGE_CENTER - Vector3.new(0, 0, RANGE_SIZE.Z / 2), size = Vector3.new(RANGE_SIZE.X, wallHeight, 2) },
		{ name = "WallE", pos = RANGE_CENTER + Vector3.new(RANGE_SIZE.X / 2, 0, 0), size = Vector3.new(2, wallHeight, RANGE_SIZE.Z) },
		{ name = "WallW", pos = RANGE_CENTER - Vector3.new(RANGE_SIZE.X / 2, 0, 0), size = Vector3.new(2, wallHeight, RANGE_SIZE.Z) },
	}) do
		local wall = Instance.new("Part")
		wall.Name = side.name
		wall.Size = side.size
		wall.Position = side.pos
		wall.Anchored = true
		wall.Color = Color3.fromRGB(50, 50, 60)
		wall.Material = Enum.Material.Concrete
		wall.Parent = rangeFolder
	end

	-- Spawn pad
	local spawnPad = Instance.new("Part")
	spawnPad.Name = "PracticeSpawn"
	spawnPad.Size = Vector3.new(8, 1, 8)
	spawnPad.Position = RANGE_CENTER - Vector3.new(0, RANGE_SIZE.Y / 2 - 0.5, RANGE_SIZE.Z / 2 - 10)
	spawnPad.Anchored = true
	spawnPad.Color = Color3.fromRGB(100, 200, 255)
	spawnPad.Material = Enum.Material.Neon
	spawnPad.Parent = rangeFolder

	-- Floating label
	local bg = Instance.new("BillboardGui")
	bg.Size = UDim2.fromOffset(300, 60)
	bg.StudsOffset = Vector3.new(0, 8, 0)
	bg.AlwaysOnTop = true
	bg.Parent = spawnPad
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.fromScale(1, 1)
	lbl.BackgroundTransparency = 1
	lbl.Text = "PRACTICE RANGE"
	lbl.TextColor3 = Color3.fromRGB(100, 200, 255)
	lbl.Font = Enum.Font.GothamBlack
	lbl.TextSize = 32
	lbl.TextStrokeTransparency = 0
	lbl.Parent = bg

	-- Exit portal
	local exit = Instance.new("Part")
	exit.Name = "ExitPortal"
	exit.Size = Vector3.new(6, 8, 0.5)
	exit.Position = spawnPad.Position + Vector3.new(0, 4, -2)
	exit.Anchored = true
	exit.CanCollide = false
	exit.Color = Color3.fromRGB(255, 100, 80)
	exit.Material = Enum.Material.Neon
	exit.Transparency = 0.3
	exit.Parent = rangeFolder
	local eBg = Instance.new("BillboardGui")
	eBg.Size = UDim2.fromOffset(160, 30)
	eBg.StudsOffset = Vector3.new(0, 4, 0)
	eBg.AlwaysOnTop = true
	eBg.Parent = exit
	local eLbl = Instance.new("TextLabel")
	eLbl.Size = UDim2.fromScale(1, 1)
	eLbl.BackgroundTransparency = 1
	eLbl.Text = "EXIT [E]"
	eLbl.TextColor3 = Color3.fromRGB(255, 100, 80)
	eLbl.Font = Enum.Font.GothamBlack
	eLbl.TextSize = 18
	eLbl.Parent = eBg
	exit.Touched:Connect(function(hit)
		local model = hit:FindFirstAncestorWhichIsA("Model")
		if not model then return end
		local player = Players:GetPlayerFromCharacter(model)
		if player then PracticeRange.ExitPlayer(player) end
	end)

	-- Build targets (moving dummies)
	for i = 1, TARGET_COUNT do
		local x = (i - TARGET_COUNT / 2) * 6
		local z = 15 + (i % 3) * 8
		PracticeRange.BuildTarget(RANGE_CENTER + Vector3.new(x, -RANGE_SIZE.Y / 2 + 4, z))
	end
end

function PracticeRange.BuildTarget(position)
	local model = Instance.new("Model")
	model.Name = "PracticeTarget"

	local hrp = Instance.new("Part")
	hrp.Name = "HumanoidRootPart"
	hrp.Size = Vector3.new(1.5, 4, 1)
	hrp.Position = position
	hrp.Anchored = true
	hrp.CanCollide = false
	hrp.Transparency = 1
	hrp.Parent = model

	local torso = Instance.new("Part")
	torso.Name = "UpperTorso"
	torso.Size = Vector3.new(1.5, 2, 1)
	torso.Position = position
	torso.Anchored = true
	torso.Color = Color3.fromRGB(200, 80, 80)
	torso.Material = Enum.Material.Plastic
	torso.Parent = model

	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(1, 1, 1)
	head.Position = position + Vector3.new(0, 1.5, 0)
	head.Anchored = true
	head.Color = Color3.fromRGB(255, 220, 100)
	head.Material = Enum.Material.Plastic
	head.Parent = model

	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth = 100
	humanoid.Health = 100
	humanoid.Parent = model

	model.PrimaryPart = hrp
	model:SetAttribute("PracticeTarget", true)
	model:SetAttribute("OriginPosition", position)
	model.Parent = rangeFolder

	-- Move target back and forth
	local startTime = math.random() * 10
	task.spawn(function()
		while model and model.Parent do
			local elapsed = tick() - startTime
			local offset = math.sin(elapsed * 1.5) * 6  -- 6 studs amplitude
			if hrp.Parent then
				hrp.CFrame = CFrame.new(position + Vector3.new(offset, 0, 0))
				torso.CFrame = CFrame.new(position + Vector3.new(offset, 0, 0))
				head.CFrame = CFrame.new(position + Vector3.new(offset, 1.5, 0))
			end
			task.wait(0.05)
		end
	end)

	-- Respawn on death
	humanoid.Died:Connect(function()
		-- Find player who killed it (last damager attribute) — for now any player gets credit
		task.delay(2, function()
			if model and model.Parent then
				humanoid.Health = 100
				torso.Transparency = 0
				head.Transparency = 0
			end
		end)
		-- Hide while dead
		torso.Transparency = 0.7
		head.Transparency = 0.7
	end)

	return model
end

function PracticeRange.EnterPlayer(player)
	buildRange()
	local character = player.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	-- Teleport to spawn pad
	hrp.CFrame = CFrame.new(RANGE_CENTER - Vector3.new(0, RANGE_SIZE.Y / 2 - 2, RANGE_SIZE.Z / 2 - 10))
	player:SetAttribute("InPractice", true)
	playerScores[player] = { hits = 0, startTime = tick() }
end

function PracticeRange.ExitPlayer(player)
	local character = player.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	-- Teleport back to main map spawn (Attackers spawn as default)
	hrp.CFrame = CFrame.new(Vector3.new(0, 3, -110))
	player:SetAttribute("InPractice", false)
	playerScores[player] = nil
end

function PracticeRange.GetScore(player)
	return playerScores[player]
end

-- ============================================================
-- AIM TRAINER MODE
-- ============================================================
local aimTrainerState = {}  -- [player] = { active, targetsHit, shotsFired, startTime, currentTarget }
local AIM_TARGETS = 20

local function spawnAimTarget(playerData)
	-- Single highlighted target at random position in range
	local pos = RANGE_CENTER + Vector3.new(
		math.random(-20, 20),
		math.random(-5, 5),
		math.random(10, 40)
	)

	local target = Instance.new("Part")
	target.Name = "AimTarget"
	target.Shape = Enum.PartType.Ball
	target.Size = Vector3.new(2, 2, 2)
	target.Position = pos
	target.Anchored = true
	target.Color = Color3.fromRGB(255, 100, 100)
	target.Material = Enum.Material.Neon
	target.Parent = rangeFolder
	target:SetAttribute("AimTarget", true)

	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth = 1
	humanoid.Health = 1
	humanoid.Parent = target

	humanoid.Died:Connect(function()
		if playerData and playerData.active then
			playerData.targetsHit += 1
			target:Destroy()
			if playerData.targetsHit >= AIM_TARGETS then
				-- Complete
				local elapsed = tick() - playerData.startTime
				local accuracy = playerData.shotsFired > 0 and (playerData.targetsHit / playerData.shotsFired) or 1
				playerData.active = false
				-- Notify via attribute (client could read)
				if playerData.player then
					playerData.player:SetAttribute("AimTrainerTime", elapsed)
					playerData.player:SetAttribute("AimTrainerAccuracy", accuracy * 100)
				end
			else
				-- Spawn next
				task.wait(0.3)
				playerData.currentTarget = spawnAimTarget(playerData)
			end
		end
	end)

	return target
end

function PracticeRange.StartAimTrainer(player)
	buildRange()
	-- Teleport to range
	PracticeRange.EnterPlayer(player)
	-- Setup state
	aimTrainerState[player] = {
		active = true,
		targetsHit = 0,
		shotsFired = 0,
		startTime = tick(),
		player = player,
		currentTarget = nil,
	}
	-- Spawn first target
	aimTrainerState[player].currentTarget = spawnAimTarget(aimTrainerState[player])
	player:SetAttribute("AimTrainerActive", true)
end

function PracticeRange.StopAimTrainer(player)
	if aimTrainerState[player] then
		if aimTrainerState[player].currentTarget then
			aimTrainerState[player].currentTarget:Destroy()
		end
		aimTrainerState[player] = nil
		player:SetAttribute("AimTrainerActive", false)
	end
end

function PracticeRange.Start()
	Players.PlayerAdded:Connect(function(player)
		player.Chatted:Connect(function(msg)
			if msg == "/practice" then
				PracticeRange.EnterPlayer(player)
			elseif msg == "/exit" then
				PracticeRange.ExitPlayer(player)
				PracticeRange.StopAimTrainer(player)
			elseif msg == "/aim" then
				PracticeRange.StartAimTrainer(player)
			end
		end)
	end)
	Players.PlayerRemoving:Connect(function(player)
		aimTrainerState[player] = nil
	end)
end

return PracticeRange
