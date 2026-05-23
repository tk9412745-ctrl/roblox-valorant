-- Brimstone: stim beacon + incendiary + sky smoke + orbital strike
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local Brimstone = {}
Brimstone.signatureKey = "E"
Brimstone.signatureMaxCharges = 3  -- 3 smokes
Brimstone.abilityCosts = { C = 100, Q = 250 }

local function stimBeacon(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	local pos = hrp.Position + hrp.CFrame.LookVector * 8 + Vector3.new(0, -2, 0)
	local beacon = Instance.new("Part")
	beacon.Shape = Enum.PartType.Cylinder
	beacon.Size = Vector3.new(1, 12, 12)
	beacon.CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, math.rad(90))
	beacon.Anchored = true
	beacon.CanCollide = false
	beacon.Color = Color3.fromRGB(255, 180, 50)
	beacon.Material = Enum.Material.Neon
	beacon.Transparency = 0.6
	beacon.Parent = Workspace

	-- Stim teammates inside (speed + fire rate buff via attribute)
	task.spawn(function()
		for _ = 1, 24 do  -- 12s duration
			for _, p in ipairs(Players:GetPlayers()) do
				if p.Team == player.Team and p.Character then
					local phrp = p.Character:FindFirstChild("HumanoidRootPart")
					if phrp and (phrp.Position - pos).Magnitude < 6 then
						local hum = p.Character:FindFirstChildOfClass("Humanoid")
						if hum then hum.WalkSpeed = 18 end
						p:SetAttribute("Stimmed", true)
					end
				end
			end
			task.wait(0.5)
		end
		-- Restore
		for _, p in ipairs(Players:GetPlayers()) do
			if p:GetAttribute("Stimmed") then
				p:SetAttribute("Stimmed", false)
				if p.Character then
					local hum = p.Character:FindFirstChildOfClass("Humanoid")
					if hum then hum.WalkSpeed = 16 end
				end
			end
		end
	end)

	Debris:AddItem(beacon, 12)
	Remotes.AbilityFired:FireAllClients(player, "Brimstone", "StimBeacon", pos)
	return true
end

local function incendiary(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	local pos = hrp.Position + hrp.CFrame.LookVector * 25 + Vector3.new(0, -2, 0)
	local molly = Instance.new("Part")
	molly.Shape = Enum.PartType.Cylinder
	molly.Size = Vector3.new(1, 16, 16)
	molly.CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, math.rad(90))
	molly.Anchored = true
	molly.CanCollide = false
	molly.Color = Color3.fromRGB(255, 80, 30)
	molly.Material = Enum.Material.Neon
	molly.Transparency = 0.4
	molly.Parent = Workspace

	local fire = Instance.new("Fire")
	fire.Heat = 25
	fire.Size = 30
	fire.Color = Color3.fromRGB(255, 100, 0)
	fire.Parent = molly

	-- Damage enemies in radius
	task.spawn(function()
		for _ = 1, 16 do  -- 8s, every 0.5s tick
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= player and p.Team ~= player.Team and p.Character then
					local phrp = p.Character:FindFirstChild("HumanoidRootPart")
					if phrp and (phrp.Position - pos).Magnitude < 8 then
						local hum = p.Character:FindFirstChildOfClass("Humanoid")
						if hum then hum:TakeDamage(30) end
					end
				end
			end
			task.wait(0.5)
		end
	end)

	Debris:AddItem(molly, 8)
	Remotes.AbilityFired:FireAllClients(player, "Brimstone", "Incendiary", pos)
	return true
end

local function skySmoke(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	local pos = hrp.Position + hrp.CFrame.LookVector * 35 + Vector3.new(0, 5, 0)
	local smoke = Instance.new("Part")
	smoke.Shape = Enum.PartType.Ball
	smoke.Size = Vector3.new(16, 16, 16)
	smoke.Position = pos
	smoke.Anchored = true
	smoke.CanCollide = false
	smoke.Color = Color3.fromRGB(140, 140, 160)
	smoke.Material = Enum.Material.SmoothPlastic
	smoke.Transparency = 0.2
	smoke.Parent = Workspace

	Debris:AddItem(smoke, 19)
	Remotes.AbilityFired:FireAllClients(player, "Brimstone", "SkySmoke", pos)
	return true
end

local function orbitalStrike(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	local pos = hrp.Position + hrp.CFrame.LookVector * 30
	-- Vertical beam from sky
	local beam = Instance.new("Part")
	beam.Size = Vector3.new(12, 200, 12)
	beam.CFrame = CFrame.new(pos + Vector3.new(0, 100, 0))
	beam.Anchored = true
	beam.CanCollide = false
	beam.Color = Color3.fromRGB(255, 150, 80)
	beam.Material = Enum.Material.Neon
	beam.Transparency = 0.5
	beam.Parent = Workspace

	-- Damage over 3s
	task.spawn(function()
		for _ = 1, 12 do  -- 6s, every 0.5s tick
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= player and p.Team ~= player.Team and p.Character then
					local phrp = p.Character:FindFirstChild("HumanoidRootPart")
					if phrp and (Vector3.new(phrp.Position.X, pos.Y, phrp.Position.Z) - pos).Magnitude < 6 then
						local hum = p.Character:FindFirstChildOfClass("Humanoid")
						if hum then hum:TakeDamage(80) end
					end
				end
			end
			task.wait(0.5)
		end
	end)

	Debris:AddItem(beam, 6)
	Remotes.AbilityFired:FireAllClients(player, "Brimstone", "OrbitalStrike", pos)
	return true
end

function Brimstone.executeAbility(player, key)
	if key == "C" then return stimBeacon(player) end
	if key == "Q" then return incendiary(player) end
	if key == "E" then return skySmoke(player) end
	if key == "X" then return orbitalStrike(player) end
	return false
end

return Brimstone
