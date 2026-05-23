-- Omen: shrouded step + paranoia + dark cover + from the shadows
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local Omen = {}
Omen.signatureKey = "E"
Omen.signatureMaxCharges = 2
Omen.abilityCosts = { C = 100, Q = 250 }

local function shroudedStep(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end
	-- Teleport short range forward
	local destination = hrp.Position + hrp.CFrame.LookVector * 18 + Vector3.new(0, 0, 0)
	task.wait(1)  -- channel
	hrp.CFrame = CFrame.new(destination)
	Remotes.AbilityFired:FireAllClients(player, "Omen", "ShroudedStep", destination)
	return true
end

local function paranoia(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end
	-- Wall-piercing nearsight
	local lookDir = hrp.CFrame.LookVector
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player and p.Team ~= player.Team and p.Character then
			local phrp = p.Character:FindFirstChild("HumanoidRootPart")
			if phrp then
				local toEnemy = (phrp.Position - hrp.Position)
				if toEnemy.Magnitude < 50 and toEnemy.Unit:Dot(lookDir) > 0.7 then
					Remotes.AbilityFired:FireClient(p, "Omen", "Nearsight", 3)
				end
			end
		end
	end
	Remotes.AbilityFired:FireAllClients(player, "Omen", "Paranoia", hrp.Position)
	return true
end

local function darkCover(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end
	local pos = hrp.Position + hrp.CFrame.LookVector * 40 + Vector3.new(0, 4, 0)
	local smoke = Instance.new("Part")
	smoke.Shape = Enum.PartType.Ball
	smoke.Size = Vector3.new(15, 15, 15)
	smoke.Position = pos
	smoke.Anchored = true
	smoke.CanCollide = false
	smoke.Color = Color3.fromRGB(50, 30, 80)
	smoke.Material = Enum.Material.SmoothPlastic
	smoke.Transparency = 0.15
	smoke.Parent = Workspace
	Debris:AddItem(smoke, 15)
	Remotes.AbilityFired:FireAllClients(player, "Omen", "DarkCover", pos)
	return true
end

local function fromTheShadows(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end
	-- Large teleport (map-wide simplified)
	local destination = hrp.Position + hrp.CFrame.LookVector * 60
	task.wait(2)  -- channel
	hrp.CFrame = CFrame.new(destination)
	Remotes.AbilityFired:FireAllClients(player, "Omen", "FromTheShadows", destination)
	return true
end

function Omen.executeAbility(player, key)
	if key == "C" then return shroudedStep(player) end
	if key == "Q" then return paranoia(player) end
	if key == "E" then return darkCover(player) end
	if key == "X" then return fromTheShadows(player) end
	return false
end

return Omen
