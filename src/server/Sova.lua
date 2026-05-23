-- Sova: owl drone + shock dart + recon bolt + hunter's fury
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local Sova = {}
Sova.signatureKey = "E"
Sova.signatureMaxCharges = 1
Sova.abilityCosts = { C = 400, Q = 150 }

local function owlDrone(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	-- Simplified: spawn drone that flies forward 50 studs, reveals enemies along path
	local startPos = hrp.Position + Vector3.new(0, 3, 0)
	local lookDir = hrp.CFrame.LookVector
	local drone = Instance.new("Part")
	drone.Name = "SovaDrone"
	drone.Size = Vector3.new(0.8, 0.5, 1.2)
	drone.Position = startPos
	drone.Anchored = true
	drone.CanCollide = false
	drone.Color = Color3.fromRGB(80, 180, 220)
	drone.Material = Enum.Material.Neon
	drone.Parent = Workspace

	-- Fly forward
	task.spawn(function()
		for i = 1, 30 do
			if not drone.Parent then break end
			drone.Position = startPos + lookDir * (i * 2)
			-- Reveal enemies nearby
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= player and p.Team ~= player.Team and p.Character then
					local phrp = p.Character:FindFirstChild("HumanoidRootPart")
					if phrp and (phrp.Position - drone.Position).Magnitude < 30 then
						local highlight = Instance.new("Highlight")
						highlight.FillColor = Color3.fromRGB(80, 180, 220)
						highlight.FillTransparency = 0.6
						highlight.Parent = p.Character
						Debris:AddItem(highlight, 2)
					end
				end
			end
			task.wait(0.1)
		end
		if drone.Parent then drone:Destroy() end
	end)

	Remotes.AbilityFired:FireAllClients(player, "Sova", "OwlDrone", startPos)
	return true
end

local function shockDart(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	-- Direct linear arrow, detonates at target
	local lookDir = hrp.CFrame.LookVector
	local landPos = hrp.Position + lookDir * 40 + Vector3.new(0, 5, 0)

	local arrow = Instance.new("Part")
	arrow.Size = Vector3.new(0.2, 0.2, 1)
	arrow.CFrame = CFrame.lookAt(landPos, landPos + lookDir)
	arrow.Anchored = true
	arrow.CanCollide = false
	arrow.Color = Color3.fromRGB(100, 220, 255)
	arrow.Material = Enum.Material.Neon
	arrow.Parent = Workspace

	-- Explosion at land position
	task.wait(0.3)
	if arrow.Parent then
		-- AOE damage
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= player and p.Team ~= player.Team and p.Character then
				local phrp = p.Character:FindFirstChild("HumanoidRootPart")
				if phrp and (phrp.Position - landPos).Magnitude < 8 then
					local hum = p.Character:FindFirstChildOfClass("Humanoid")
					if hum then hum:TakeDamage(85) end
				end
			end
		end
		arrow:Destroy()
	end
	Remotes.AbilityFired:FireAllClients(player, "Sova", "ShockDart", landPos)
	return true
end

local function reconBolt(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	local lookDir = hrp.CFrame.LookVector
	local stickPos = hrp.Position + lookDir * 30 + Vector3.new(0, 5, 0)

	local bolt = Instance.new("Part")
	bolt.Name = "ReconBolt"
	bolt.Size = Vector3.new(0.6, 0.6, 0.6)
	bolt.Position = stickPos
	bolt.Anchored = true
	bolt.CanCollide = false
	bolt.Color = Color3.fromRGB(60, 180, 255)
	bolt.Material = Enum.Material.Neon
	bolt.Parent = Workspace

	-- Reveal enemies in LOS for 4s
	task.spawn(function()
		for _ = 1, 4 do
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= player and p.Team ~= player.Team and p.Character then
					local phrp = p.Character:FindFirstChild("HumanoidRootPart")
					if phrp and (phrp.Position - stickPos).Magnitude < 40 then
						-- LOS check
						local params = RaycastParams.new()
						params.FilterDescendantsInstances = { p.Character }
						params.FilterType = Enum.RaycastFilterType.Exclude
						local r = Workspace:Raycast(stickPos, phrp.Position - stickPos, params)
						if not r or r.Instance:FindFirstAncestorWhichIsA("Model") == p.Character then
							local highlight = Instance.new("Highlight")
							highlight.FillColor = Color3.fromRGB(60, 180, 255)
							highlight.FillTransparency = 0.5
							highlight.Parent = p.Character
							Debris:AddItem(highlight, 1.2)
						end
					end
				end
			end
			task.wait(1)
		end
		if bolt.Parent then bolt:Destroy() end
	end)

	Remotes.AbilityFired:FireAllClients(player, "Sova", "ReconBolt", stickPos)
	return true
end

local function huntersFury(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	-- Fire 3 wall-piercing blasts forward, 0.5s apart
	task.spawn(function()
		for shot = 1, 3 do
			if not char.Parent then break end
			local origin = hrp.Position + Vector3.new(0, 1, 0)
			local lookDir = hrp.CFrame.LookVector

			-- Apply damage to all enemies in line (ignore walls)
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= player and p.Team ~= player.Team and p.Character then
					local phrp = p.Character:FindFirstChild("HumanoidRootPart")
					if phrp then
						local toEnemy = (phrp.Position - origin)
						if toEnemy.Magnitude < 200 and toEnemy.Unit:Dot(lookDir) > 0.95 then
							local hum = p.Character:FindFirstChildOfClass("Humanoid")
							if hum then hum:TakeDamage(80) end
							-- Reveal
							local highlight = Instance.new("Highlight")
							highlight.FillColor = Color3.fromRGB(60, 180, 255)
							highlight.FillTransparency = 0.4
							highlight.Parent = p.Character
							Debris:AddItem(highlight, 5)
						end
					end
				end
			end

			-- Visual beam
			local beam = Instance.new("Part")
			beam.Size = Vector3.new(0.5, 0.5, 200)
			beam.CFrame = CFrame.lookAt(origin + lookDir * 100, origin + lookDir * 200)
			beam.Anchored = true
			beam.CanCollide = false
			beam.Color = Color3.fromRGB(60, 180, 255)
			beam.Material = Enum.Material.Neon
			beam.Transparency = 0.4
			beam.Parent = Workspace
			Debris:AddItem(beam, 0.3)

			task.wait(0.5)
		end
	end)

	Remotes.AbilityFired:FireAllClients(player, "Sova", "HuntersFury", hrp.Position)
	return true
end

function Sova.executeAbility(player, key)
	if key == "C" then return owlDrone(player) end
	if key == "Q" then return shockDart(player) end
	if key == "E" then return reconBolt(player) end
	if key == "X" then return huntersFury(player) end
	return false
end

return Sova
