-- Astra: nebula smoke + nova pulse + gravity well + cosmic divide
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local Astra = {}
Astra.signatureKey = nil
Astra.abilityCosts = { C = 150, Q = 150, E = 150 }

local function nebula(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end
	local pos = hrp.Position + hrp.CFrame.LookVector * 35 + Vector3.new(0, 4, 0)
	local smoke = Instance.new("Part")
	smoke.Shape = Enum.PartType.Ball
	smoke.Size = Vector3.new(16, 16, 16)
	smoke.Position = pos
	smoke.Anchored = true
	smoke.CanCollide = false
	smoke.Color = Color3.fromRGB(100, 80, 180)
	smoke.Material = Enum.Material.SmoothPlastic
	smoke.Transparency = 0.2
	smoke.Parent = Workspace
	Debris:AddItem(smoke, 15)
	Remotes.AbilityFired:FireAllClients(player, "Astra", "Nebula", pos)
	return true
end

local function novaPulse(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end
	local pos = hrp.Position + hrp.CFrame.LookVector * 35
	-- Charge time then concuss
	local pulse = Instance.new("Part")
	pulse.Shape = Enum.PartType.Ball
	pulse.Size = Vector3.new(2, 2, 2)
	pulse.Position = pos
	pulse.Anchored = true
	pulse.CanCollide = false
	pulse.Color = Color3.fromRGB(180, 100, 220)
	pulse.Material = Enum.Material.Neon
	pulse.Parent = Workspace
	task.wait(1.25)
	if pulse.Parent then
		-- Expand and concuss
		local TweenService = game:GetService("TweenService")
		TweenService:Create(pulse, TweenInfo.new(0.3), { Size = Vector3.new(20, 20, 20), Transparency = 0.6 }):Play()
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= player and p.Team ~= player.Team and p.Character then
				local phrp = p.Character:FindFirstChild("HumanoidRootPart")
				if phrp and (phrp.Position - pos).Magnitude < 10 then
					Remotes.AbilityFired:FireClient(p, "Astra", "Concussed", 1.5)
				end
			end
		end
		Debris:AddItem(pulse, 1)
	end
	Remotes.AbilityFired:FireAllClients(player, "Astra", "NovaPulse", pos)
	return true
end

local function gravityWell(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end
	local pos = hrp.Position + hrp.CFrame.LookVector * 30
	-- Pull enemies toward center
	local well = Instance.new("Part")
	well.Shape = Enum.PartType.Cylinder
	well.Size = Vector3.new(1, 16, 16)
	well.CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, math.rad(90))
	well.Anchored = true
	well.CanCollide = false
	well.Color = Color3.fromRGB(150, 80, 220)
	well.Material = Enum.Material.Neon
	well.Transparency = 0.3
	well.Parent = Workspace

	task.spawn(function()
		for _ = 1, 6 do
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= player and p.Team ~= player.Team and p.Character then
					local phrp = p.Character:FindFirstChild("HumanoidRootPart")
					if phrp and (phrp.Position - pos).Magnitude < 8 then
						-- Pull toward center
						local pull = (pos - phrp.Position).Unit * 8
						phrp.AssemblyLinearVelocity = pull
						p:SetAttribute("Vulnerable", true)
					end
				end
			end
			task.wait(0.5)
		end
		for _, p in ipairs(Players:GetPlayers()) do
			p:SetAttribute("Vulnerable", false)
		end
	end)
	Debris:AddItem(well, 3)
	Remotes.AbilityFired:FireAllClients(player, "Astra", "GravityWell", pos)
	return true
end

local function cosmicDivide(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end
	-- Massive wall blocking bullets
	local right = hrp.CFrame.RightVector
	local wallCenter = hrp.Position
	for i = -8, 8, 2 do
		local segment = Instance.new("Part")
		segment.Size = Vector3.new(4, 20, 1)
		segment.CFrame = CFrame.new(wallCenter + right * (i * 4) + Vector3.new(0, 10, 0))
		segment.Anchored = true
		segment.CanCollide = true
		segment.Color = Color3.fromRGB(180, 150, 240)
		segment.Material = Enum.Material.ForceField
		segment.Transparency = 0.3
		segment:SetAttribute("CosmicDivide", true)
		segment.Parent = Workspace
		Debris:AddItem(segment, 15)
	end
	Remotes.AbilityFired:FireAllClients(player, "Astra", "CosmicDivide", wallCenter)
	return true
end

function Astra.executeAbility(player, key)
	if key == "C" then return nebula(player) end
	if key == "Q" then return novaPulse(player) end
	if key == "E" then return gravityWell(player) end
	if key == "X" then return cosmicDivide(player) end
	return false
end

return Astra
