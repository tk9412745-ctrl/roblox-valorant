-- Killjoy: alarmbot + turret + nanoswarm + lockdown
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local Killjoy = {}
Killjoy.signatureKey = "Q"  -- Turret (free, 60s CD if destroyed)
Killjoy.signatureMaxCharges = 1
Killjoy.abilityCosts = { C = 200, E = 200 }

local function alarmbot(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end
	local pos = hrp.Position + hrp.CFrame.LookVector * 8 + Vector3.new(0, -1, 0)
	local bot = Instance.new("Part")
	bot.Name = "KillJoyAlarmbot"
	bot.Size = Vector3.new(1, 1, 1.5)
	bot.Position = pos
	bot.Anchored = true
	bot.CanCollide = true
	bot.Color = Color3.fromRGB(255, 220, 50)
	bot.Material = Enum.Material.Metal
	bot.Parent = Workspace

	-- Detect enemies in range
	task.spawn(function()
		while bot.Parent do
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= player and p.Team ~= player.Team and p.Character then
					local phrp = p.Character:FindFirstChild("HumanoidRootPart")
					if phrp and (phrp.Position - bot.Position).Magnitude < 6 then
						-- Explode + apply Vulnerable
						p:SetAttribute("Vulnerable", true)
						task.delay(4, function() if p then p:SetAttribute("Vulnerable", false) end end)
						-- Visual explosion
						local explosion = Instance.new("Part")
						explosion.Shape = Enum.PartType.Ball
						explosion.Size = Vector3.new(4, 4, 4)
						explosion.Position = bot.Position
						explosion.Anchored = true
						explosion.CanCollide = false
						explosion.Color = Color3.fromRGB(255, 220, 50)
						explosion.Material = Enum.Material.Neon
						explosion.Parent = Workspace
						Debris:AddItem(explosion, 0.5)
						bot:Destroy()
						return
					end
				end
			end
			task.wait(0.3)
		end
	end)
	Debris:AddItem(bot, 60)
	Remotes.AbilityFired:FireAllClients(player, "Killjoy", "Alarmbot", pos)
	return true
end

local function turret(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end
	local pos = hrp.Position + hrp.CFrame.LookVector * 5 + Vector3.new(0, -1, 0)
	local turretPart = Instance.new("Part")
	turretPart.Name = "KillJoyTurret"
	turretPart.Size = Vector3.new(1.5, 2, 1.5)
	turretPart.Position = pos
	turretPart.Anchored = true
	turretPart.CanCollide = true
	turretPart.Color = Color3.fromRGB(255, 200, 50)
	turretPart.Material = Enum.Material.Metal
	turretPart.Parent = Workspace

	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth = 100
	humanoid.Health = 100
	humanoid.Parent = turretPart  -- so it can take damage

	-- Auto-fire at enemies in cone
	task.spawn(function()
		while turretPart.Parent and humanoid.Health > 0 do
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= player and p.Team ~= player.Team and p.Character then
					local phrp = p.Character:FindFirstChild("HumanoidRootPart")
					if phrp and (phrp.Position - turretPart.Position).Magnitude < 50 then
						-- Fire raycast
						local params = RaycastParams.new()
						params.FilterDescendantsInstances = { turretPart, char }
						params.FilterType = Enum.RaycastFilterType.Exclude
						local origin = turretPart.Position + Vector3.new(0, 1, 0)
						local dir = (phrp.Position - origin).Unit
						local result = Workspace:Raycast(origin, dir * 50, params)
						if result and result.Instance:FindFirstAncestorWhichIsA("Model") == p.Character then
							local hum = p.Character:FindFirstChildOfClass("Humanoid")
							if hum then hum:TakeDamage(15) end
							Remotes.WeaponFired:FireAllClients(nil, origin, result.Position, "Vandal")
						end
					end
				end
			end
			task.wait(0.5)
		end
		if turretPart.Parent then turretPart:Destroy() end
	end)
	Remotes.AbilityFired:FireAllClients(player, "Killjoy", "Turret", pos)
	return true
end

local function nanoswarm(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end
	local pos = hrp.Position + hrp.CFrame.LookVector * 15 + Vector3.new(0, -2, 0)
	local swarm = Instance.new("Part")
	swarm.Name = "Nanoswarm"
	swarm.Size = Vector3.new(0.5, 0.5, 0.5)
	swarm.Position = pos
	swarm.Anchored = true
	swarm.CanCollide = false
	swarm.Transparency = 1
	swarm.Parent = Workspace

	-- After 1s, activate damaging cloud
	task.wait(1)
	if swarm.Parent then
		local cloud = Instance.new("Part")
		cloud.Shape = Enum.PartType.Ball
		cloud.Size = Vector3.new(10, 10, 10)
		cloud.Position = pos
		cloud.Anchored = true
		cloud.CanCollide = false
		cloud.Color = Color3.fromRGB(255, 180, 50)
		cloud.Material = Enum.Material.Neon
		cloud.Transparency = 0.4
		cloud.Parent = Workspace

		task.spawn(function()
			for _ = 1, 8 do  -- 4s
				for _, p in ipairs(Players:GetPlayers()) do
					if p ~= player and p.Team ~= player.Team and p.Character then
						local phrp = p.Character:FindFirstChild("HumanoidRootPart")
						if phrp and (phrp.Position - pos).Magnitude < 5 then
							local hum = p.Character:FindFirstChildOfClass("Humanoid")
							if hum then hum:TakeDamage(22.5) end
						end
					end
				end
				task.wait(0.5)
			end
		end)

		Debris:AddItem(cloud, 4)
		Debris:AddItem(swarm, 4)
	end
	Remotes.AbilityFired:FireAllClients(player, "Killjoy", "Nanoswarm", pos)
	return true
end

local function lockdown(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end
	-- Large dome, 13s windup
	local pos = hrp.Position
	local dome = Instance.new("Part")
	dome.Shape = Enum.PartType.Ball
	dome.Size = Vector3.new(2, 2, 2)
	dome.Position = pos
	dome.Anchored = true
	dome.CanCollide = false
	dome.Color = Color3.fromRGB(255, 200, 50)
	dome.Material = Enum.Material.Neon
	dome.Transparency = 0.6
	dome.Parent = Workspace

	-- Grow during windup
	local TweenService = game:GetService("TweenService")
	TweenService:Create(dome, TweenInfo.new(13), { Size = Vector3.new(50, 50, 50) }):Play()

	task.wait(13)
	if dome.Parent then
		-- Detain all enemies in radius
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= player and p.Team ~= player.Team and p.Character then
				local phrp = p.Character:FindFirstChild("HumanoidRootPart")
				if phrp and (phrp.Position - pos).Magnitude < 25 then
					-- Detain — set walkspeed = 0 + suppress
					local hum = p.Character:FindFirstChildOfClass("Humanoid")
					if hum then hum.WalkSpeed = 0 end
					p:SetAttribute("Suppressed", true)
					task.delay(8, function()
						if p and hum then
							hum.WalkSpeed = 16
							p:SetAttribute("Suppressed", false)
						end
					end)
				end
			end
		end
		Debris:AddItem(dome, 8)
	end
	Remotes.AbilityFired:FireAllClients(player, "Killjoy", "Lockdown", pos)
	return true
end

function Killjoy.executeAbility(player, key)
	if key == "C" then return alarmbot(player) end
	if key == "Q" then return turret(player) end
	if key == "E" then return nanoswarm(player) end
	if key == "X" then return lockdown(player) end
	return false
end

return Killjoy
