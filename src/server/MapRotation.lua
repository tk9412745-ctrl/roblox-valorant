-- MapRotation: cykl map między meczami
-- Domyślnie: Ascent → Bind → Ascent (Split jako stretch goal)

local MapRotation = {}

MapRotation.Rotation = { "Ascent", "Bind", "Split", "Haven", "Fracture", "Lotus" }
local currentIndex = 1

function MapRotation.GetCurrent()
	return MapRotation.Rotation[currentIndex]
end

function MapRotation.Next()
	currentIndex = currentIndex + 1
	if currentIndex > #MapRotation.Rotation then
		currentIndex = 1
	end
	return MapRotation.Rotation[currentIndex]
end

function MapRotation.Set(mapName)
	for i, name in ipairs(MapRotation.Rotation) do
		if name == mapName then
			currentIndex = i
			return true
		end
	end
	return false
end

function MapRotation.Reset()
	currentIndex = 1
end

return MapRotation
