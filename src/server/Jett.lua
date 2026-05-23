-- Jett: dash + updraft + smoke + 5 throwing knives ultimate
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local Jett = {}

Jett.signatureKey = "E"  -- Tailwind
Jett.signatureMaxCharges = 1

Jett.abilityCosts = {
	C = 200,  -- Cloudburst (×2 charges per buy)
	Q = 150,  -- Updraft
}

-- ============================================================
-- C: Cloudburst (smoke cloud)
-- ============================================================
local function cloudburst(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	local lookDir = hrp.CFrame.LookVector
	local smokePos = hrp.Position + lookDir * 30 + Vector3.new(0, 5, 0)

	local smoke = Instance.new("Part")
	smoke.Name = "JettSmoke"
	smoke.Shape = Enum.PartType.Ball
	smoke.Size = Vector3.new(15, 15, 15)
	smoke.Position = smokePos
	smoke.Anchored = true
	smoke.CanCollide = false
	smoke.Material = Enum.Material.SmoothPlastic
	smoke.Color = Color3.fromRGB(220, 220, 230)
	smoke.Transparency = 0.3
	smoke.Parent = Workspace

	-- Add particle effect for visual
	local particles = Instance.new("ParticleEmitter")
	particles.Texture = "rbxasset://textures/particles/smoke_main.dds"
	particles.Lifetime = NumberRange.new(2, 3)
	particles.Rate = 50
	particles.Speed = NumberRange.new(2, 5)
	particles.Color = ColorSequence.new(Color3.fromRGB(220, 220, 240))
	particles.Size = NumberSequence.new(8)
	particles.Parent = smoke

	Debris:AddItem(smoke, 2.5)
	Remotes.AbilityFired:FireAllClients(player, "Jett", "Cloudburst", smokePos)
	return true
end

-- ============================================================
-- Q: Updraft
-- ============================================================
local function updraft(player)
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then return false end

	-- Apply upward impulse via velocity (BodyVelocity deprecated, use direct AssemblyLinearVelocity)
	hrp.AssemblyLinearVelocity = Vector3.new(
		hrp.AssemblyLinearVelocity.X,
		60,  -- upward boost
		hrp.AssemblyLinearVelocity.Z
	)
	Remotes.AbilityFired:FireAllClients(player, "Jett", "Updraft", hrp.Position)
	return true
end

-- ============================================================
-- E: Tailwind (dash) — adds visible dash trail
-- ============================================================
local activeDashWindow = {}  -- [player] = expireTick

local function spawnDashTrail(player, startPos, endPos)
	-- Visible trail particles along dash path
	local trailPart = Instance.new("Part")
	trailPart.Name = "JettDashTrail"
	trailPart.Anchored = true
	trailPart.CanCollide = false
	trailPart.CastShadow = false
	trailPart.Size = Vector3.new(0.5, 0.5, (endPos - startPos).Magnitude)
	trailPart.CFrame = CFrame.lookAt((startPos + endPos) / 2, endPos)
	trailPart.Material = Enum.Material.Neon
	trailPart.Color = Color3.fromRGB(150, 200, 255)
	trailPart.Transparency = 0.4
	trailPart.Parent = Workspace

	-- Fade out
	task.spawn(function()
		for i = 0, 1, 0.1 do
			trailPart.Transparency = 0.4 + i * 0.6
			task.wait(0.03)
		end
		trailPart:Destroy()
	end)
end

local function tailwind(player)
	-- First press: open 7.5s window
	if not activeDashWindow[player] or tick() > activeDashWindow[player] then
		activeDashWindow[player] = tick() + 7.5
		Remotes.AbilityFired:FireAllClients(player, "Jett", "TailwindReady", nil)
		return true  -- consume charge, open window
	end

	-- Second press within window: dash
	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then return false end

	-- Dash direction: humanoid move direction or forward if not moving
	local dir = humanoid.MoveDirection
	if dir.Magnitude < 0.1 then
		dir = hrp.CFrame.LookVector
	end
	dir = Vector3.new(dir.X, 0, dir.Z).Unit

	local startPos = hrp.Position
	hrp.AssemblyLinearVelocity = dir * 90 + Vector3.new(0, 5, 0)
	activeDashWindow[player] = nil
	spawnDashTrail(player, startPos, startPos + dir * 25)
	Remotes.AbilityFired:FireAllClients(player, "Jett", "TailwindDash", hrp.Position)
	return true
end

-- ============================================================
-- X: Blade Storm (5 throwing knives)
-- ============================================================
local bladeStormState = {}  -- [player] = { knivesLeft = 5 }

local function startBladeStorm(player)
	bladeStormState[player] = { knivesLeft = 5 }
	Remotes.AbilityFired:FireAllClients(player, "Jett", "BladeStormStart", nil)
	-- After 20s, end blade storm
	task.delay(20, function()
		if bladeStormState[player] then
			bladeStormState[player] = nil
			Remotes.AbilityFired:FireAllClients(player, "Jett", "BladeStormEnd", nil)
		end
	end)
	return true
end

function Jett.IsInBladeStorm(player)
	return bladeStormState[player] ~= nil
end

function Jett.ThrowKnife(player, direction)
	if not bladeStormState[player] then return false end
	if bladeStormState[player].knivesLeft <= 0 then return false end

	local char = player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	-- Raycast as instant projectile
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = { char }
	params.FilterType = Enum.RaycastFilterType.Exclude
	local result = Workspace:Raycast(hrp.Position + Vector3.new(0, 1, 0), direction * 200, params)

	bladeStormState[player].knivesLeft -= 1

	if result then
		local hitModel = result.Instance:FindFirstAncestorWhichIsA("Model")
		if hitModel then
			local hum = hitModel:FindFirstChildOfClass("Humanoid")
			if hum and hum ~= char:FindFirstChildOfClass("Humanoid") then
				hum:TakeDamage(50)  -- knife body dmg
				if hum.Health <= 0 then
					-- Restore all knives on kill
					bladeStormState[player].knivesLeft = 5
				end
			end
		end
	end

	if bladeStormState[player].knivesLeft <= 0 then
		bladeStormState[player] = nil
		Remotes.AbilityFired:FireAllClients(player, "Jett", "BladeStormEnd", nil)
	end
	return true
end

-- ============================================================
-- Dispatcher
-- ============================================================
function Jett.executeAbility(player, key)
	if key == "C" then return cloudburst(player) end
	if key == "Q" then return updraft(player) end
	if key == "E" then return tailwind(player) end
	if key == "X" then return startBladeStorm(player) end
	return false
end

function Jett.canUseUlt(player)
	return true
end

return Jett
