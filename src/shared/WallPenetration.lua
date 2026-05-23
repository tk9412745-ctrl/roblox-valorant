-- WallPenetration: Server-side raycast continuation through Penetrable parts
-- Część może być przebijalna jeśli ma atrybut "Penetrable" = true lub "PenetrationDepth" > 0

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WeaponDatabase = require(ReplicatedStorage.Shared.WeaponDatabase)

local WallPenetration = {}

WallPenetration.MAX_PENETRATIONS = 2  -- max wallbangs per shot
WallPenetration.MAX_WALL_THICKNESS_STUDS = 8  -- nie przebijaj grubych ścian

-- Wykonuje kompletny raycast z wallbang continuation
-- Returns: list of hit results { {result, damageMultiplier}, ... }
function WallPenetration.PenetratingRaycast(weaponName, origin, direction, maxRange, ignoreList)
	local hits = {}
	local currentOrigin = origin
	local currentDir = direction
	local currentMult = 1.0
	local rangeRemaining = maxRange

	local wallPenTier = WeaponDatabase[weaponName] and WeaponDatabase[weaponName].WallPen
	local wallPenMult = WeaponDatabase.WallPenetration[wallPenTier] or 0

	local ignored = {}
	for _, inst in ipairs(ignoreList or {}) do
		table.insert(ignored, inst)
	end

	for penetrationIndex = 0, WallPenetration.MAX_PENETRATIONS do
		local params = RaycastParams.new()
		params.FilterDescendantsInstances = ignored
		params.FilterType = Enum.RaycastFilterType.Exclude

		local result = Workspace:Raycast(currentOrigin, currentDir * rangeRemaining, params)
		if not result then break end

		table.insert(hits, {
			result = result,
			damageMultiplier = currentMult,
			penetrationIndex = penetrationIndex,
		})

		-- Jeśli trafiliśmy w humanoid character, koniec
		local hitPart = result.Instance
		local hitModel = hitPart:FindFirstAncestorWhichIsA("Model")
		if hitModel and hitModel:FindFirstChildOfClass("Humanoid") then
			break
		end

		-- Spróbuj wallbang
		if wallPenMult <= 0 then break end
		if penetrationIndex >= WallPenetration.MAX_PENETRATIONS then break end
		if not hitPart:GetAttribute("Penetrable") then
			-- Default behavior: tylko Penetrable=true parts pozwalają na wallbang
			-- Można rozszerzyć: enable wallbang dla wszystkich części cieńszych niż X studs
			if hitPart.Size.Magnitude > WallPenetration.MAX_WALL_THICKNESS_STUDS then break end
		end

		-- Continue ray past wall
		local exitOrigin = result.Position + currentDir * 0.1  -- nudge past surface
		-- Find exit point — raycast in reverse from far point
		local farPoint = result.Position + currentDir * 20  -- assume wall < 20 studs thick
		local reverseParams = RaycastParams.new()
		reverseParams.FilterDescendantsInstances = { hitPart }
		reverseParams.FilterType = Enum.RaycastFilterType.Include
		local exitResult = Workspace:Raycast(farPoint, -currentDir * 20, reverseParams)

		if exitResult then
			exitOrigin = exitResult.Position + currentDir * 0.05
			local wallThickness = (exitResult.Position - result.Position).Magnitude
			if wallThickness > WallPenetration.MAX_WALL_THICKNESS_STUDS then break end
		end

		-- Update state for next iteration
		rangeRemaining -= (exitOrigin - currentOrigin).Magnitude
		if rangeRemaining <= 0 then break end
		currentOrigin = exitOrigin
		currentMult *= wallPenMult
		table.insert(ignored, hitPart)
	end

	return hits
end

function WallPenetration.GetFirstHumanoidHit(hits)
	for _, h in ipairs(hits) do
		local model = h.result.Instance:FindFirstAncestorWhichIsA("Model")
		if model and model:FindFirstChildOfClass("Humanoid") then
			return h, model
		end
	end
	return nil, nil
end

return WallPenetration
