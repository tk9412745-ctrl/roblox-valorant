-- Cypher: trapwire + cyber cage + spycam + neural theft
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local Cypher = {}

Cypher.signatureKey = "E"  -- Spycam (free, recharges on destroy 45s)
Cypher.signatureMaxCharges = 1
Cypher.abilityCosts = {
	C = 200,  -- Trapwire (×2 charges)
	Q = 100,  -- Cyber Cage (×2 charges)
}

-- ============================================================
-- C: Trapwire (beam between 2 points, slow + reveal on cross)
-- ============================================================
local function trapwire(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	local startPos = hrp.Position + hrp.CFrame.LookVector * 8 + Vector3.new(0, -1, 0)
	local endPos = startPos + hrp.CFrame.LookVector * 12

	local wire = Instance.new("Part")
	wire.Name = "CypherTrapwire"
	wire.Anchored = true
	wire.CanCollide = false
	wire.Size = Vector3.new(0.1, 0.1, (endPos - startPos).Magnitude)
	wire.CFrame = CFrame.lookAt((startPos + endPos) / 2, endPos)
	wire.Color = Color3.fromRGB(255, 100, 200)
	wire.Material = Enum.Material.Neon
	wire.Transparency = 0.3
	wire.Parent = Workspace

	-- Trigger zone
	local zone = Instance.new("Part")
	zone.Anchored = true
	zone.CanCollide = false
	zone.Transparency = 1
	zone.Size = Vector3.new(2, 2, (endPos - startPos).Magnitude)
	zone.CFrame = wire.CFrame
	zone.Parent = wire

	zone.Touched:Connect(function(hit)
		local model = hit:FindFirstAncestorWhichIsA("Model")
		if not model then return end
		local hum = model:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 0 then return end
		-- Find player
		local p = Players:GetPlayerFromCharacter(model)
		if p and p.Team == player.Team then return end  -- skip teammates

		-- Slow + reveal
		hum.WalkSpeed = 6
		task.delay(3, function()
			if hum then hum.WalkSpeed = 16 end
		end)

		-- Visual reveal (Highlight)
		local highlight = Instance.new("Highlight")
		highlight.FillColor = Color3.fromRGB(255, 100, 200)
		highlight.OutlineColor = Color3.fromRGB(255, 100, 200)
		highlight.FillTransparency = 0.5
		highlight.Parent = model
		Debris:AddItem(highlight, 5)

		wire:Destroy()
	end)

	Debris:AddItem(wire, 60)
	Remotes.AbilityFired:FireAllClients(player, "Cypher", "Trapwire", startPos)
	return true
end

-- ============================================================
-- Q: Cyber Cage (vision-blocking smoke)
-- ============================================================
local function cyberCage(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	local landPos = hrp.Position + hrp.CFrame.LookVector * 20 + Vector3.new(0, 5, 0)

	local cage = Instance.new("Part")
	cage.Name = "CypherCage"
	cage.Shape = Enum.PartType.Ball
	cage.Size = Vector3.new(12, 12, 12)
	cage.Position = landPos
	cage.Anchored = true
	cage.CanCollide = false
	cage.Color = Color3.fromRGB(180, 150, 255)
	cage.Material = Enum.Material.Glass
	cage.Transparency = 0.2
	cage.Parent = Workspace

	Debris:AddItem(cage, 12)
	Remotes.AbilityFired:FireAllClients(player, "Cypher", "CyberCage", landPos)
	return true
end

-- ============================================================
-- E: Spycam (reveal enemy on dart hit)
-- ============================================================
local function spycam(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	-- Simplified: instant scan ahead — reveal all visible enemies for 3s
	local lookDir = hrp.CFrame.LookVector
	for _, otherPlayer in ipairs(Players:GetPlayers()) do
		if otherPlayer ~= player and otherPlayer.Team ~= player.Team and otherPlayer.Character then
			local otherHRP = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
			if otherHRP then
				local toEnemy = (otherHRP.Position - hrp.Position)
				if toEnemy.Magnitude < 60 and toEnemy.Unit:Dot(lookDir) > 0.5 then
					-- Reveal
					local highlight = Instance.new("Highlight")
					highlight.FillColor = Color3.fromRGB(255, 100, 200)
					highlight.OutlineColor = Color3.fromRGB(255, 100, 200)
					highlight.FillTransparency = 0.5
					highlight.Parent = otherPlayer.Character
					Debris:AddItem(highlight, 3)
				end
			end
		end
	end

	Remotes.AbilityFired:FireAllClients(player, "Cypher", "Spycam", hrp.Position)
	return true
end

-- ============================================================
-- X: Neural Theft (reveal all enemies twice)
-- ============================================================
local function neuralTheft(player)
	-- Reveal all alive enemies for 4s
	for _, otherPlayer in ipairs(Players:GetPlayers()) do
		if otherPlayer ~= player and otherPlayer.Team ~= player.Team and otherPlayer.Character then
			local hum = otherPlayer.Character:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 then
				local highlight = Instance.new("Highlight")
				highlight.FillColor = Color3.fromRGB(255, 100, 200)
				highlight.OutlineColor = Color3.fromRGB(255, 230, 80)
				highlight.FillTransparency = 0.4
				highlight.Parent = otherPlayer.Character
				Debris:AddItem(highlight, 4)
			end
		end
	end

	Remotes.AbilityFired:FireAllClients(player, "Cypher", "NeuralTheft", nil)
	return true
end

function Cypher.executeAbility(player, key)
	if key == "C" then return trapwire(player) end
	if key == "Q" then return cyberCage(player) end
	if key == "E" then return spycam(player) end
	if key == "X" then return neuralTheft(player) end
	return false
end

return Cypher
