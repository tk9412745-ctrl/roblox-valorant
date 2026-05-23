-- Reyna: leer + devour + dismiss + empress
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local Reyna = {}

Reyna.signatureKey = nil  -- Reyna ma 2 basic abilities (Devour/Dismiss) + soul orbs from kills
Reyna.signatureMaxCharges = 0
Reyna.abilityCosts = {
	C = 250,  -- Leer
	Q = 100,  -- Devour (uses Soul Orb)
}

local soulOrbs = {}        -- [player] = count of available soul orbs
local empressActive = {}   -- [player] = expire time
local empressKills = {}    -- [player] = current empress kills

-- ============================================================
-- HOOK: gain soul orb on kill
-- ============================================================
function Reyna.OnPlayerKill(killer)
	if not killer then return end
	-- Only matters if Reyna is the killer (check agent)
	local agent = killer:GetAttribute("Agent")
	if agent ~= "Reyna" then return end
	soulOrbs[killer] = (soulOrbs[killer] or 0) + 1
	-- Empress kills also extend duration
	if empressActive[killer] and tick() < empressActive[killer] then
		empressActive[killer] = empressActive[killer] + 5  -- +5s per kill in Empress
		empressKills[killer] = (empressKills[killer] or 0) + 1
	end
end

-- ============================================================
-- C: Leer (nearsight enemies)
-- ============================================================
local function leer(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	local lookPos = hrp.Position + hrp.CFrame.LookVector * 25 + Vector3.new(0, 3, 0)

	local eye = Instance.new("Part")
	eye.Name = "ReynaEye"
	eye.Shape = Enum.PartType.Ball
	eye.Size = Vector3.new(2, 2, 2)
	eye.Position = lookPos
	eye.Anchored = true
	eye.CanCollide = false
	eye.Color = Color3.fromRGB(180, 50, 220)
	eye.Material = Enum.Material.Neon
	eye.Parent = Workspace

	-- Nearsight enemies looking at it
	task.spawn(function()
		for _ = 1, 4 do  -- 2 seconds, check 4 times
			if not eye.Parent then break end
			for _, otherPlayer in ipairs(Players:GetPlayers()) do
				if otherPlayer ~= player and otherPlayer.Team ~= player.Team and otherPlayer.Character then
					local oHRP = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
					if oHRP then
						local toEye = (eye.Position - oHRP.Position).Unit
						local lookVec = oHRP.CFrame.LookVector
						if toEye:Dot(lookVec) > 0.5 then
							Remotes.AbilityFired:FireClient(otherPlayer, "Reyna", "Flashed", 0.5)
						end
					end
				end
			end
			task.wait(0.5)
		end
	end)

	Debris:AddItem(eye, 2)
	Remotes.AbilityFired:FireAllClients(player, "Reyna", "Leer", lookPos)
	return true
end

-- ============================================================
-- Q: Devour (consume Soul Orb, heal 100)
-- ============================================================
local function devour(player)
	if (soulOrbs[player] or 0) <= 0 then return false end
	local char = player.Character
	if not char then return false end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return false end

	soulOrbs[player] -= 1
	-- Heal up to 150 (overheal allowed)
	hum.MaxHealth = 150
	hum.Health = math.min(hum.MaxHealth, hum.Health + 100)
	-- After 25s, return to 100 max
	task.delay(25, function()
		if hum then
			hum.MaxHealth = 100
			hum.Health = math.min(hum.MaxHealth, hum.Health)
		end
	end)

	Remotes.AbilityFired:FireAllClients(player, "Reyna", "Devour", char.PrimaryPart and char.PrimaryPart.Position or Vector3.new(0,0,0))
	return true
end

-- ============================================================
-- E: Dismiss (consume Soul Orb, intangible 2s)
-- ============================================================
local function dismiss(player)
	if (soulOrbs[player] or 0) <= 0 then return false end
	local char = player.Character
	if not char then return false end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return false end

	soulOrbs[player] -= 1

	-- Make character invulnerable + transparent for 2s
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			part.LocalTransparencyModifier = 0.5
			part.CollisionGroup = "Dismissed"  -- collision group set on server too
		end
	end
	hum.WalkSpeed = hum.WalkSpeed * 1.5

	-- Empress: also invisible
	local isEmpress = empressActive[player] and tick() < empressActive[player]
	if isEmpress then
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				part.LocalTransparencyModifier = 0.95
			end
		end
	end

	-- Apply temporary invuln (cheap method: max health for 2s)
	local oldMaxHP = hum.MaxHealth
	hum.MaxHealth = 999999
	hum.Health = hum.Health + (999999 - oldMaxHP)
	task.delay(2, function()
		if hum and char.Parent then
			local healthRatio = hum.Health / hum.MaxHealth
			hum.MaxHealth = oldMaxHP
			hum.Health = math.min(oldMaxHP, hum.Health)
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.LocalTransparencyModifier = 0
				end
			end
			hum.WalkSpeed = 16
		end
	end)

	Remotes.AbilityFired:FireAllClients(player, "Reyna", "Dismiss", nil)
	return true
end

-- ============================================================
-- X: Empress (frenzy mode)
-- ============================================================
local function empress(player)
	local char = player.Character
	if not char then return false end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return false end

	empressActive[player] = tick() + 30
	empressKills[player] = 0
	-- Boost fire/reload via attribute (read by client/server)
	player:SetAttribute("EmpressActive", true)
	hum.WalkSpeed = 18

	task.spawn(function()
		while tick() < (empressActive[player] or 0) do
			task.wait(1)
		end
		empressActive[player] = nil
		player:SetAttribute("EmpressActive", false)
		if hum and char.Parent then hum.WalkSpeed = 16 end
	end)

	Remotes.AbilityFired:FireAllClients(player, "Reyna", "Empress", nil)
	return true
end

function Reyna.executeAbility(player, key)
	if key == "C" then return leer(player) end
	if key == "Q" then return devour(player) end
	if key == "E" then return dismiss(player) end
	if key == "X" then return empress(player) end
	return false
end

function Reyna.GetSoulOrbs(player)
	return soulOrbs[player] or 0
end

return Reyna
