-- Sage: wall + slow orb + healing orb + resurrection ultimate
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local Sage = {}

Sage.signatureKey = "E"  -- Healing Orb
Sage.signatureMaxCharges = 1

Sage.abilityCosts = {
	C = 400,  -- Barrier Orb (wall)
	Q = 200,  -- Slow Orb
}

local signatureLastUsed = {}  -- [player] = tick() of last Healing Orb (45s CD)
Sage.SIGNATURE_COOLDOWN = 45

-- ============================================================
-- C: Barrier Orb (wall, 4 segments, 400 HP each, 800 fortified after 3s)
-- ============================================================
local function barrierOrb(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	local lookDir = hrp.CFrame.LookVector
	local center = hrp.Position + lookDir * 8

	-- Build 4-segment wall perpendicular to look direction
	local right = Vector3.new(-lookDir.Z, 0, lookDir.X).Unit
	local segments = {}
	for i = -1.5, 1.5 do
		local segment = Instance.new("Part")
		segment.Name = "SageWall"
		segment.Size = Vector3.new(4, 8, 1)
		segment.CFrame = CFrame.new(center + right * (i * 4), center + right * (i * 4) + lookDir)
		segment.Anchored = true
		segment.CanCollide = true
		segment.Material = Enum.Material.Ice
		segment.Color = Color3.fromRGB(150, 220, 255)
		segment.Transparency = 0.2
		segment:SetAttribute("WallHP", 400)
		segment:SetAttribute("WallMaxHP", 400)
		segment.Parent = Workspace
		table.insert(segments, segment)
	end

	-- Fortify after 3s (HP → 800)
	task.delay(3, function()
		for _, seg in ipairs(segments) do
			if seg.Parent then
				seg:SetAttribute("WallHP", 800)
				seg:SetAttribute("WallMaxHP", 800)
			end
		end
	end)

	-- Destroy after 40s
	for _, seg in ipairs(segments) do
		Debris:AddItem(seg, 40)
	end

	Remotes.AbilityFired:FireAllClients(player, "Sage", "BarrierOrb", center)
	return true
end

-- ============================================================
-- Q: Slow Orb
-- ============================================================
local function slowOrb(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	local lookDir = hrp.CFrame.LookVector
	local landingPos = hrp.Position + lookDir * 25 + Vector3.new(0, -2, 0)

	local field = Instance.new("Part")
	field.Name = "SageSlow"
	field.Size = Vector3.new(20, 1, 20)
	field.Shape = Enum.PartType.Cylinder
	field.CFrame = CFrame.new(landingPos) * CFrame.Angles(0, 0, math.rad(90))
	field.Anchored = true
	field.CanCollide = false
	field.Material = Enum.Material.Ice
	field.Color = Color3.fromRGB(140, 180, 230)
	field.Transparency = 0.4
	field.Parent = Workspace

	-- Slow players inside
	local slowConnection
	slowConnection = task.spawn(function()
		while field.Parent do
			for _, p in ipairs(Players:GetPlayers()) do
				local pchar = p.Character
				if pchar and pchar:FindFirstChild("HumanoidRootPart") then
					local dist = (pchar.HumanoidRootPart.Position - landingPos).Magnitude
					if dist < 10 then
						local hum = pchar:FindFirstChildOfClass("Humanoid")
						if hum then
							hum.WalkSpeed = 6  -- slowed from 16
						end
					else
						local hum = pchar:FindFirstChildOfClass("Humanoid")
						if hum and hum.WalkSpeed < 16 then
							hum.WalkSpeed = 16
						end
					end
				end
			end
			task.wait(0.1)
		end
	end)

	Debris:AddItem(field, 7)
	task.delay(7, function()
		-- Restore all players' walkspeed
		for _, p in ipairs(Players:GetPlayers()) do
			local pchar = p.Character
			if pchar then
				local hum = pchar:FindFirstChildOfClass("Humanoid")
				if hum then hum.WalkSpeed = 16 end
			end
		end
	end)

	Remotes.AbilityFired:FireAllClients(player, "Sage", "SlowOrb", landingPos)
	return true
end

-- ============================================================
-- E: Healing Orb (signature, 45s CD, +100 HP over 5s ally or +50 self)
-- ============================================================
local function healingOrb(player)
	local now = tick()
	if signatureLastUsed[player] and (now - signatureLastUsed[player]) < Sage.SIGNATURE_COOLDOWN then
		return false
	end

	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	-- Target: closest teammate ally within 8 studs in look direction, else self
	local target = player
	local lookDir = hrp.CFrame.LookVector
	local closest = nil
	local closestDist = math.huge
	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= player and other.Team == player.Team and other.Character then
			local ohrp = other.Character:FindFirstChild("HumanoidRootPart")
			if ohrp then
				local toOther = (ohrp.Position - hrp.Position)
				if toOther.Magnitude < 15 and toOther.Unit:Dot(lookDir) > 0.7 then
					if toOther.Magnitude < closestDist then
						closest = other
						closestDist = toOther.Magnitude
					end
				end
			end
		end
	end
	if closest then target = closest end

	local isSelf = target == player
	local healAmount = isSelf and 50 or 100

	-- Heal over 5s
	task.spawn(function()
		local tchar = target.Character
		if not tchar then return end
		local hum = tchar:FindFirstChildOfClass("Humanoid")
		if not hum then return end
		local ticks = 10
		local perTick = healAmount / ticks
		for _ = 1, ticks do
			if hum.Health > 0 then
				hum.Health = math.min(hum.MaxHealth, hum.Health + perTick)
			end
			task.wait(0.5)
		end
	end)

	signatureLastUsed[player] = now
	Remotes.AbilityFired:FireAllClients(player, "Sage", "HealingOrb", target.UserId)

	-- Refund charge after cooldown
	task.delay(Sage.SIGNATURE_COOLDOWN, function()
		-- AbilityService should handle this via signal; for now just refresh after delay
	end)
	return true
end

-- ============================================================
-- X: Resurrection (channel 3.3s, revive ally near corpse)
-- ============================================================
local function resurrection(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	-- Find dead teammate within range
	local target = nil
	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= player and other.Team == player.Team then
			-- Was killed this round — check char if present and humanoid dead
			if other.Character then
				local hum = other.Character:FindFirstChildOfClass("Humanoid")
				if hum and hum.Health <= 0 then
					local ohrp = other.Character:FindFirstChild("HumanoidRootPart")
					if ohrp and (ohrp.Position - hrp.Position).Magnitude < 10 then
						target = other
						break
					end
				end
			end
		end
	end

	if not target then return false end

	-- Channel 3.3s
	Remotes.AbilityFired:FireAllClients(player, "Sage", "ResChannel", target.UserId)
	task.delay(3.3, function()
		if target and target.Parent then
			target:LoadCharacter()
			task.wait(0.3)
			-- Move resurrected player near Sage
			if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
				target.Character.HumanoidRootPart.CFrame = CFrame.new(hrp.Position + hrp.CFrame.LookVector * 5)
			end
			Remotes.AbilityFired:FireAllClients(player, "Sage", "ResComplete", target.UserId)
		end
	end)
	return true
end

-- ============================================================
-- Dispatcher
-- ============================================================
function Sage.executeAbility(player, key)
	if key == "C" then return barrierOrb(player) end
	if key == "Q" then return slowOrb(player) end
	if key == "E" then return healingOrb(player) end
	if key == "X" then return resurrection(player) end
	return false
end

return Sage
