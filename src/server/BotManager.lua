-- BotManager: spawn AI bots żeby gra była playable solo
-- Stany: Idle → Patrol → Engage → (return to Patrol after losing target)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local PathfindingService = game:GetService("PathfindingService")
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local WeaponDatabase = require(ReplicatedStorage.Shared.WeaponDatabase)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local BotManager = {}

local bots = {}  -- [model] = state
local botsFolder
local nextBotId = 1

local BOT_NAMES = {
	"Phoenix-Bot", "Jett-Bot", "Sage-Bot", "Reyna-Bot", "Cypher-Bot",
	"Sova-Bot", "Omen-Bot", "Killjoy-Bot", "Raze-Bot", "Viper-Bot",
}

local STATE = {
	IDLE = "Idle",
	PATROL = "Patrol",
	ENGAGE = "Engage",
	DEAD = "Dead",
}

-- Bot difficulty profiles (Sprint 87)
BotManager.Difficulty = {
	Easy = { AimOffset = 4, FireIntervalMult = 3, HeadshotChance = 0.10, DetectionRange = 80 },
	Medium = { AimOffset = 2, FireIntervalMult = 2, HeadshotChance = 0.25, DetectionRange = 120 },
	Hard = { AimOffset = 1, FireIntervalMult = 1.2, HeadshotChance = 0.45, DetectionRange = 150 },
}
local currentDifficulty = "Medium"
function BotManager.SetDifficulty(level)
	if BotManager.Difficulty[level] then currentDifficulty = level end
end
function BotManager.GetDifficultyProfile()
	return BotManager.Difficulty[currentDifficulty] or BotManager.Difficulty.Medium
end

local TEAM_COLORS = {
	Attackers = Color3.fromRGB(220, 80, 80),
	Defenders = Color3.fromRGB(80, 100, 220),
}

local function ensureFolder()
	if not botsFolder or not botsFolder.Parent then
		botsFolder = Workspace:FindFirstChild("Bots")
		if not botsFolder then
			botsFolder = Instance.new("Folder")
			botsFolder.Name = "Bots"
			botsFolder.Parent = Workspace
		end
	end
	return botsFolder
end

local function createBotCharacter(name, position, team)
	local model = Instance.new("Model")
	model.Name = name

	local color = TEAM_COLORS[team] or Color3.fromRGB(180, 180, 200)

	-- HumanoidRootPart (invisible, physics root)
	local hrp = Instance.new("Part")
	hrp.Name = "HumanoidRootPart"
	hrp.Size = Vector3.new(2, 2, 1)
	hrp.Position = position
	hrp.Transparency = 1
	hrp.CanCollide = false
	hrp.TopSurface = Enum.SurfaceType.Smooth
	hrp.BottomSurface = Enum.SurfaceType.Smooth
	hrp.Parent = model

	-- UpperTorso
	local torso = Instance.new("Part")
	torso.Name = "UpperTorso"
	torso.Size = Vector3.new(2, 2, 1)
	torso.Position = position
	torso.Color = color
	torso.Material = Enum.Material.Fabric
	torso.TopSurface = Enum.SurfaceType.Smooth
	torso.BottomSurface = Enum.SurfaceType.Smooth
	torso.Parent = model

	-- Head
	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(1.2, 1.2, 1.2)
	head.Position = position + Vector3.new(0, 1.6, 0)
	head.Color = Color3.fromRGB(220, 180, 140)
	head.Material = Enum.Material.SmoothPlastic
	head.Shape = Enum.PartType.Block
	head.TopSurface = Enum.SurfaceType.Smooth
	head.BottomSurface = Enum.SurfaceType.Smooth
	head.Parent = model

	-- Legs
	local leftLeg = Instance.new("Part")
	leftLeg.Name = "LeftUpperLeg"
	leftLeg.Size = Vector3.new(1, 2, 1)
	leftLeg.Position = position + Vector3.new(-0.5, -2, 0)
	leftLeg.Color = Color3.fromRGB(30, 30, 50)
	leftLeg.Material = Enum.Material.Fabric
	leftLeg.Parent = model

	local rightLeg = Instance.new("Part")
	rightLeg.Name = "RightUpperLeg"
	rightLeg.Size = Vector3.new(1, 2, 1)
	rightLeg.Position = position + Vector3.new(0.5, -2, 0)
	rightLeg.Color = Color3.fromRGB(30, 30, 50)
	rightLeg.Material = Enum.Material.Fabric
	rightLeg.Parent = model

	-- Weld parts to HRP
	local function weld(part0, part1)
		local w = Instance.new("Weld")
		w.Part0 = part0
		w.Part1 = part1
		w.C0 = part0.CFrame:Inverse() * part1.CFrame
		w.Parent = part0
	end
	weld(hrp, torso)
	weld(hrp, head)
	weld(hrp, leftLeg)
	weld(hrp, rightLeg)

	-- Humanoid
	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth = 100
	humanoid.Health = 100
	humanoid.WalkSpeed = 12  -- slightly slower than players
	humanoid.JumpHeight = 7.5
	humanoid.RequiresNeck = false
	humanoid.BreakJointsOnDeath = false
	humanoid.Parent = model

	-- Mark as bot + team
	model:SetAttribute("Bot", true)
	model:SetAttribute("BotTeam", team)
	model:SetAttribute("BotName", name)

	-- BOT tag floating above head (Sprint 92)
	local botTag = Instance.new("BillboardGui")
	botTag.Name = "BotTag"
	botTag.Size = UDim2.fromOffset(120, 24)
	botTag.StudsOffset = Vector3.new(0, 3.5, 0)
	botTag.AlwaysOnTop = true
	botTag.LightInfluence = 0
	botTag.MaxDistance = 80
	botTag.Parent = head
	local tagLbl = Instance.new("TextLabel")
	tagLbl.Size = UDim2.fromScale(1, 1)
	tagLbl.BackgroundTransparency = 1
	tagLbl.Text = "[BOT] " .. name
	tagLbl.TextColor3 = TEAM_COLORS[team] or Color3.fromRGB(180, 180, 200)
	tagLbl.TextStrokeTransparency = 0
	tagLbl.Font = Enum.Font.GothamBold
	tagLbl.TextSize = 12
	tagLbl.Parent = botTag

	model.PrimaryPart = hrp
	model.Parent = ensureFolder()

	return model, humanoid, hrp
end

local function randomMapPosition()
	-- Returns random point within map bounds (~250 studs)
	local angle = math.random() * math.pi * 2
	local dist = math.random() * 80
	return Vector3.new(math.cos(angle) * dist, 3, math.sin(angle) * dist)
end

local function getEnemiesForBot(botModel)
	local botTeam = botModel:GetAttribute("BotTeam")
	if not botTeam then return {} end
	local enemies = {}

	-- Other bots
	for otherBot, state in pairs(bots) do
		if otherBot ~= botModel and state.state ~= STATE.DEAD then
			if otherBot:GetAttribute("BotTeam") ~= botTeam then
				table.insert(enemies, otherBot)
			end
		end
	end

	-- Real players
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Team and player.Team.Name ~= botTeam and player.Character then
			local hum = player.Character:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 then
				table.insert(enemies, player.Character)
			end
		end
	end

	return enemies
end

local function findVisibleEnemy(botHRP, enemies)
	for _, enemyChar in ipairs(enemies) do
		if enemyChar and enemyChar.Parent then
			local enemyHRP = enemyChar:FindFirstChild("HumanoidRootPart")
			if enemyHRP then
				local distance = (enemyHRP.Position - botHRP.Position).Magnitude
				if distance < 150 then  -- detection range
					-- LOS raycast
					local params = RaycastParams.new()
					params.FilterDescendantsInstances = { botHRP.Parent }
					params.FilterType = Enum.RaycastFilterType.Exclude
					local result = Workspace:Raycast(botHRP.Position + Vector3.new(0, 1, 0), enemyHRP.Position - botHRP.Position, params)
					if result then
						local resultChar = result.Instance:FindFirstAncestorWhichIsA("Model")
						if resultChar == enemyChar then
							return enemyChar, distance
						end
					end
				end
			end
		end
	end
	return nil, nil
end

-- Random ability cast (visual only — bots don't have ult points)
local BOT_ABILITY_INTERVAL = { 5, 12 }  -- seconds range between casts

local function botCastAbility(botModel)
	local hrp = botModel:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local agent = botModel:GetAttribute("BotAgent") or "Jett"

	-- Spawn visual effect based on agent
	local lookDir = hrp.CFrame.LookVector
	if agent == "Jett" then
		-- Cloudburst smoke
		local smoke = Instance.new("Part")
		smoke.Shape = Enum.PartType.Ball
		smoke.Size = Vector3.new(12, 12, 12)
		smoke.Position = hrp.Position + lookDir * 15 + Vector3.new(0, 3, 0)
		smoke.Anchored = true
		smoke.CanCollide = false
		smoke.Color = Color3.fromRGB(220, 220, 230)
		smoke.Material = Enum.Material.SmoothPlastic
		smoke.Transparency = 0.4
		smoke.Parent = Workspace
		Debris:AddItem(smoke, 2.5)
	elseif agent == "Sage" then
		-- Slow orb
		local slow = Instance.new("Part")
		slow.Shape = Enum.PartType.Cylinder
		slow.Size = Vector3.new(1, 14, 14)
		slow.CFrame = CFrame.new(hrp.Position + lookDir * 15 + Vector3.new(0, -1, 0)) * CFrame.Angles(0, 0, math.rad(90))
		slow.Anchored = true
		slow.CanCollide = false
		slow.Color = Color3.fromRGB(140, 180, 230)
		slow.Material = Enum.Material.Ice
		slow.Transparency = 0.5
		slow.Parent = Workspace
		Debris:AddItem(slow, 5)
	elseif agent == "Phoenix" then
		-- Hot Hands molotov
		local fire = Instance.new("Part")
		fire.Shape = Enum.PartType.Cylinder
		fire.Size = Vector3.new(1, 12, 12)
		fire.CFrame = CFrame.new(hrp.Position + lookDir * 15 + Vector3.new(0, -1, 0)) * CFrame.Angles(0, 0, math.rad(90))
		fire.Anchored = true
		fire.CanCollide = false
		fire.Color = Color3.fromRGB(255, 80, 20)
		fire.Material = Enum.Material.Neon
		fire.Transparency = 0.4
		fire.Parent = Workspace
		local fx = Instance.new("Fire")
		fx.Heat = 25
		fx.Size = 20
		fx.Parent = fire
		Debris:AddItem(fire, 4)
	end

	Remotes.AbilityFired:FireAllClients(nil, agent, "BotCast", hrp.Position)
end

local function botShoot(botModel, target, weaponName)
	local botHRP = botModel:FindFirstChild("HumanoidRootPart")
	local targetHRP = target:FindFirstChild("HumanoidRootPart")
	if not botHRP or not targetHRP then return end

	-- Aim slightly imperfectly (add small random offset for "AI skill")
	local aimAtHead = math.random() < 0.25  -- 25% chance of headshot attempt
	local targetPos = aimAtHead and (target:FindFirstChild("Head") and target.Head.Position or targetHRP.Position) or targetHRP.Position
	local randomOffset = Vector3.new((math.random() - 0.5) * 2, (math.random() - 0.5) * 2, (math.random() - 0.5) * 2)
	targetPos = targetPos + randomOffset

	local origin = botHRP.Position + Vector3.new(0, 1.5, 0)
	local direction = (targetPos - origin).Unit

	-- Direct raycast (skip server validation for bot shots)
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = { botModel }
	params.FilterType = Enum.RaycastFilterType.Exclude
	local result = Workspace:Raycast(origin, direction * 200, params)

	local hitPos = origin + direction * 200
	if result then
		hitPos = result.Position
		local hitChar = result.Instance:FindFirstAncestorWhichIsA("Model")
		if hitChar then
			local hitHum = hitChar:FindFirstChildOfClass("Humanoid")
			if hitHum and hitHum.Health > 0 then
				-- Damage based on body part
				local partName = result.Instance.Name
				local cfg = WeaponDatabase[weaponName] or WeaponDatabase.Vandal
				local damageTier = cfg.Damage[1]
				local damage = damageTier.Body
				if partName == "Head" then
					damage = damageTier.Head
				elseif partName:find("Leg") then
					damage = damageTier.Leg
				end
				hitHum:TakeDamage(damage)

				-- If victim is a player and died → fire hit marker for visual feedback (no killer credit for bot)
				local hitPlayer = Players:GetPlayerFromCharacter(hitChar)
				if hitPlayer then
					-- Just let damage do its thing; CombatService will detect death
				end
			end
		end
	end

	-- Broadcast tracer to all clients
	Remotes.WeaponFired:FireAllClients(nil, origin, hitPos, weaponName)
end

local function computePath(start, goal)
	local path = PathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true,
		AgentJumpHeight = 7,
		AgentMaxSlope = 45,
	})
	local ok = pcall(function()
		path:ComputeAsync(start, goal)
	end)
	if not ok or path.Status ~= Enum.PathStatus.Success then return nil end
	return path:GetWaypoints()
end

local function moveBotAlongPath(botModel, humanoid, waypoints)
	if not waypoints or #waypoints == 0 then return end
	-- Move to first waypoint
	local nextWp = waypoints[1]
	if nextWp then
		humanoid:MoveTo(nextWp.Position)
		if nextWp.Action == Enum.PathWaypointAction.Jump then
			humanoid.Jump = true
		end
	end
end

local function botStateTick(botModel, state, dt)
	if state.state == STATE.DEAD then return end

	local humanoid = botModel:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		state.state = STATE.DEAD
		return
	end

	local hrp = botModel:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	-- Look for enemy
	local enemies = getEnemiesForBot(botModel)
	local enemy, distance = findVisibleEnemy(hrp, enemies)

	if enemy then
		state.state = STATE.ENGAGE
		state.target = enemy
		state.lastSeenTarget = tick()

		-- Aim at enemy (rotate HRP to face)
		local targetHRP = enemy:FindFirstChild("HumanoidRootPart")
		if targetHRP then
			local lookAt = Vector3.new(targetHRP.Position.X, hrp.Position.Y, targetHRP.Position.Z)
			hrp.CFrame = CFrame.new(hrp.Position, lookAt)
		end

		-- Shoot at intervals based on weapon fire rate
		local cfg = WeaponDatabase[state.weapon] or WeaponDatabase.Vandal
		local fireInterval = 1 / cfg.FireRate * 2
		if not state.lastShot or (tick() - state.lastShot) > fireInterval then
			botShoot(botModel, enemy, state.weapon)
			state.lastShot = tick()
		end

		-- Path-find toward enemy if too far, away if too close
		if distance > 50 and targetHRP then
			-- Re-compute path every 1.5s
			if not state.lastPathCompute or (tick() - state.lastPathCompute) > 1.5 then
				state.currentPath = computePath(hrp.Position, targetHRP.Position)
				state.lastPathCompute = tick()
			end
			if state.currentPath then
				moveBotAlongPath(botModel, humanoid, state.currentPath)
			end
		elseif distance < 15 and targetHRP then
			local awayDir = (hrp.Position - targetHRP.Position).Unit
			humanoid:MoveTo(hrp.Position + awayDir * 10)
		else
			humanoid:MoveTo(hrp.Position)
		end
	else
		state.state = STATE.PATROL

		if not state.wanderTarget or (state.wanderTarget - hrp.Position).Magnitude < 5 then
			state.wanderTarget = randomMapPosition()
			state.currentPath = nil  -- recompute
		end

		-- Path-find to wander target
		if not state.lastPathCompute or (tick() - state.lastPathCompute) > 2.0 then
			state.currentPath = computePath(hrp.Position, state.wanderTarget)
			state.lastPathCompute = tick()
		end

		if state.currentPath then
			moveBotAlongPath(botModel, humanoid, state.currentPath)
		else
			humanoid:MoveTo(state.wanderTarget)
		end

		if state.target and state.lastSeenTarget and (tick() - state.lastSeenTarget) > 5 then
			state.target = nil
		end
	end
end

function BotManager.SpawnBot(team, spawnPosition, weaponName)
	local name = BOT_NAMES[((nextBotId - 1) % #BOT_NAMES) + 1] .. "_" .. nextBotId
	nextBotId += 1

	local model, humanoid, hrp = createBotCharacter(name, spawnPosition, team)

	-- Random agent
	local agents = { "Jett", "Sage", "Phoenix", "Cypher", "Reyna", "KAYO", "Sova", "Brimstone", "Viper" }
	local randomAgent = agents[math.random(1, #agents)]
	model:SetAttribute("BotAgent", randomAgent)

	-- Initial state
	bots[model] = {
		state = STATE.IDLE,
		weapon = weaponName or "Vandal",
		wanderTarget = nil,
		target = nil,
		lastShot = 0,
		lastSeenTarget = nil,
		lastAbilityCast = tick(),
		nextAbilityIn = math.random(BOT_ABILITY_INTERVAL[1], BOT_ABILITY_INTERVAL[2]),
	}

	-- Death handler
	humanoid.Died:Connect(function()
		bots[model] = bots[model] or {}
		bots[model].state = STATE.DEAD
		-- Respawn after delay if round still active
		task.delay(8, function()
			if model and model.Parent then
				model:Destroy()
				bots[model] = nil
			end
		end)
	end)

	return model
end

function BotManager.SpawnTeam(team, count, spawnPosition)
	local weapons = { "Vandal", "Phantom", "Sheriff", "Spectre", "Bulldog" }
	for i = 1, count do
		local offset = Vector3.new(math.random(-10, 10), 0, math.random(-10, 10))
		local weapon = weapons[math.random(1, #weapons)]
		BotManager.SpawnBot(team, spawnPosition + offset, weapon)
	end
end

function BotManager.GetAliveBots(team)
	local count = 0
	for model, state in pairs(bots) do
		if model and model.Parent and state.state ~= STATE.DEAD then
			if not team or model:GetAttribute("BotTeam") == team then
				count += 1
			end
		end
	end
	return count
end

function BotManager.ClearAll()
	for model, _ in pairs(bots) do
		if model and model.Parent then model:Destroy() end
	end
	bots = {}
end

function BotManager.Start()
	ensureFolder()

	-- Main AI tick loop
	task.spawn(function()
		while true do
			task.wait(0.15)
			for model, state in pairs(bots) do
				if model and model.Parent then
					botStateTick(model, state, 0.15)

					-- Random ability cast
					if state.state ~= STATE.DEAD and state.lastAbilityCast and tick() - state.lastAbilityCast > state.nextAbilityIn then
						botCastAbility(model)
						state.lastAbilityCast = tick()
						state.nextAbilityIn = math.random(BOT_ABILITY_INTERVAL[1], BOT_ABILITY_INTERVAL[2])
					end
				else
					bots[model] = nil
				end
			end
		end
	end)
end

return BotManager
