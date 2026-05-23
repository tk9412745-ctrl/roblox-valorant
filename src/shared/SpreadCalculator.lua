-- SpreadCalculator: Pure helpers do liczenia spread + applying do direction vector
-- Spread (degrees) sumuje się: FirstBulletAccuracy + MovementError + FiringError

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WeaponDatabase = require(ReplicatedStorage.Shared.WeaponDatabase)

local SpreadCalculator = {}

-- Movement error per state (degrees)
SpreadCalculator.MovementError = {
	Crouched   = -0.17,  -- improves accuracy
	Stationary = 0.0,
	Walking    = 3.0,
	Running    = 6.2,
	Airborne   = 7.0,   -- +7° dla 0.225s po wyskoku
}

-- Firing error growth per shot (degrees, added per shot fired sustained)
SpreadCalculator.FiringErrorPerShot = {
	FullAuto = 0.4,
	SemiAuto = 0.2,
	BoltAction = 0.0,
	SemiAutoShotgun = 0.0,
	FullAutoShotgun = 0.3,
	Melee = 0.0,
}

SpreadCalculator.MaxFiringError = 5.0  -- cap
SpreadCalculator.FiringErrorDecayPerSec = 8.0  -- spread bloom resetuje

-- ADS-only accuracy weapons (0° FBA tylko w scope)
SpreadCalculator.ADSOnlyAccurate = {
	Guardian = true,
	Marshal = true,
	Outlaw = true,
	Operator = true,
}

function SpreadCalculator.GetMovementError(player, movementMode)
	local character = player.Character
	if not character then return SpreadCalculator.MovementError.Stationary end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return 0 end

	local moveDir = humanoid.MoveDirection
	local speed = moveDir.Magnitude * humanoid.WalkSpeed

	if humanoid.FloorMaterial == Enum.Material.Air or not humanoid.FloorMaterial then
		return SpreadCalculator.MovementError.Airborne
	end

	-- Crouch mode: accuracy bonus even if moving slowly
	if movementMode == "Crouch" and speed < 5 then
		return SpreadCalculator.MovementError.Crouched
	end

	if speed < 1 then
		return SpreadCalculator.MovementError.Stationary
	elseif speed < 10 then
		return SpreadCalculator.MovementError.Walking
	else
		return SpreadCalculator.MovementError.Running
	end
end

function SpreadCalculator.GetTotalSpread(weaponName, firingErrorAccumulated, movementError, isADS)
	local w = WeaponDatabase[weaponName]
	if not w then return 0 end

	local fba = w.FirstBulletAccuracy or 0
	if isADS and w.FirstBulletAccuracyADS ~= nil then
		fba = w.FirstBulletAccuracyADS
	end

	-- ADS-only accurate weapons: gigantyczny spread bez scope
	if SpreadCalculator.ADSOnlyAccurate[weaponName] and not isADS then
		fba = math.max(fba, 5.0)
	end

	local total = fba + (movementError or 0) + (firingErrorAccumulated or 0)
	if total < 0 then total = 0 end
	return total
end

-- Apply random spread to direction vector
function SpreadCalculator.ApplySpread(direction, spreadDegrees)
	if spreadDegrees <= 0.001 then return direction end

	-- Random offset within cone (uniform disk distribution)
	local maxOffset = math.tan(math.rad(spreadDegrees))
	local theta = math.random() * math.pi * 2
	local r = math.sqrt(math.random()) * maxOffset
	local offX = math.cos(theta) * r
	local offY = math.sin(theta) * r

	-- Build local coordinate frame from direction
	local fwd = direction.Unit
	local worldUp = Vector3.new(0, 1, 0)
	local right = fwd:Cross(worldUp)
	if right.Magnitude < 0.001 then
		right = Vector3.new(1, 0, 0)
	end
	right = right.Unit
	local up = right:Cross(fwd).Unit

	return (fwd + right * offX + up * offY).Unit
end

function SpreadCalculator.GetFiringErrorPerShot(weaponName)
	local w = WeaponDatabase[weaponName]
	if not w then return 0 end
	return SpreadCalculator.FiringErrorPerShot[w.FireMode] or 0.2
end

return SpreadCalculator
