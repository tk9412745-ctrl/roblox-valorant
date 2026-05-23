-- Viper: snake bite + poison cloud + toxic screen + viper's pit
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local Viper = {}
Viper.signatureKey = "E"
Viper.signatureMaxCharges = 1
Viper.abilityCosts = { C = 200, Q = 200 }

local function snakeBite(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	local pos = hrp.Position + hrp.CFrame.LookVector * 25 + Vector3.new(0, -2, 0)
	local toxic = Instance.new("Part")
	toxic.Shape = Enum.PartType.Cylinder
	toxic.Size = Vector3.new(1, 14, 14)
	toxic.CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, math.rad(90))
	toxic.Anchored = true
	toxic.CanCollide = false
	toxic.Color = Color3.fromRGB(80, 200, 50)
	toxic.Material = Enum.Material.Neon
	toxic.Transparency = 0.4
	toxic.Parent = Workspace

	-- DOT + Vulnerable
	task.spawn(function()
		for _ = 1, 12 do  -- 6s
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= player and p.Team ~= player.Team and p.Character then
					local phrp = p.Character:FindFirstChild("HumanoidRootPart")
					if phrp and (phrp.Position - pos).Magnitude < 7 then
						local hum = p.Character:FindFirstChildOfClass("Humanoid")
						if hum then hum:TakeDamage(20) end
						p:SetAttribute("Vulnerable", true)  -- double damage taken
					end
				end
			end
			task.wait(0.5)
		end
		for _, p in ipairs(Players:GetPlayers()) do
			p:SetAttribute("Vulnerable", false)
		end
	end)

	Debris:AddItem(toxic, 6)
	Remotes.AbilityFired:FireAllClients(player, "Viper", "SnakeBite", pos)
	return true
end

local function poisonCloud(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	local pos = hrp.Position + hrp.CFrame.LookVector * 25 + Vector3.new(0, -2, 0)
	local emitter = Instance.new("Part")
	emitter.Size = Vector3.new(1, 1, 1)
	emitter.Position = pos
	emitter.Anchored = true
	emitter.CanCollide = false
	emitter.Color = Color3.fromRGB(60, 100, 30)
	emitter.Material = Enum.Material.Neon
	emitter.Parent = Workspace

	local smoke = Instance.new("Part")
	smoke.Shape = Enum.PartType.Ball
	smoke.Size = Vector3.new(18, 18, 18)
	smoke.Position = pos + Vector3.new(0, 5, 0)
	smoke.Anchored = true
	smoke.CanCollide = false
	smoke.Color = Color3.fromRGB(80, 180, 50)
	smoke.Material = Enum.Material.SmoothPlastic
	smoke.Transparency = 0.2
	smoke.Parent = Workspace

	-- Decay damage
	task.spawn(function()
		for _ = 1, 30 do  -- 15s
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= player and p.Team ~= player.Team and p.Character then
					local phrp = p.Character:FindFirstChild("HumanoidRootPart")
					if phrp and (phrp.Position - smoke.Position).Magnitude < 12 then
						local hum = p.Character:FindFirstChildOfClass("Humanoid")
						if hum then
							-- Decay damage (not killing, just reducing HP)
							hum.Health = math.max(1, hum.Health - 5)
						end
					end
				end
			end
			task.wait(0.5)
		end
	end)

	Debris:AddItem(emitter, 15)
	Debris:AddItem(smoke, 15)
	Remotes.AbilityFired:FireAllClients(player, "Viper", "PoisonCloud", pos)
	return true
end

local function toxicScreen(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	-- Long wall of poison
	local startPos = hrp.Position + hrp.CFrame.LookVector * 5
	local right = hrp.CFrame.RightVector
	for i = -3, 3 do
		local segment = Instance.new("Part")
		segment.Size = Vector3.new(8, 12, 1)
		segment.CFrame = CFrame.new(startPos + right * (i * 8) + Vector3.new(0, 6, 0))
		segment.Anchored = true
		segment.CanCollide = false
		segment.Color = Color3.fromRGB(80, 200, 50)
		segment.Material = Enum.Material.Neon
		segment.Transparency = 0.4
		segment.Parent = Workspace
		Debris:AddItem(segment, 20)
	end

	Remotes.AbilityFired:FireAllClients(player, "Viper", "ToxicScreen", startPos)
	return true
end

local function vipersPit(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	local center = hrp.Position
	local pit = Instance.new("Part")
	pit.Shape = Enum.PartType.Ball
	pit.Size = Vector3.new(40, 40, 40)
	pit.Position = center
	pit.Anchored = true
	pit.CanCollide = false
	pit.Color = Color3.fromRGB(60, 150, 30)
	pit.Material = Enum.Material.SmoothPlastic
	pit.Transparency = 0.3
	pit.Parent = Workspace

	-- Massive decay
	task.spawn(function()
		for _ = 1, 30 do  -- 15s
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= player and p.Team ~= player.Team and p.Character then
					local phrp = p.Character:FindFirstChild("HumanoidRootPart")
					if phrp and (phrp.Position - center).Magnitude < 25 then
						local hum = p.Character:FindFirstChildOfClass("Humanoid")
						if hum then
							hum.Health = math.max(1, hum.Health - 12)
						end
					end
				end
			end
			task.wait(0.5)
		end
	end)

	Debris:AddItem(pit, 15)
	Remotes.AbilityFired:FireAllClients(player, "Viper", "VipersPit", center)
	return true
end

function Viper.executeAbility(player, key)
	if key == "C" then return snakeBite(player) end
	if key == "Q" then return poisonCloud(player) end
	if key == "E" then return toxicScreen(player) end
	if key == "X" then return vipersPit(player) end
	return false
end

return Viper
