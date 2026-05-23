-- ColorBlindPalette: kolory dostosowane do różnych typów ślepoty barw
-- Settings: Normal, Protanopia (red-blind), Deuteranopia (green-blind), Tritanopia (blue-blind)

local ColorBlindPalette = {}

local PALETTES = {
	Normal = {
		AttackerColor = Color3.fromRGB(255, 80, 80),     -- red
		DefenderColor = Color3.fromRGB(80, 120, 255),    -- blue
		FriendlyColor = Color3.fromRGB(80, 220, 120),    -- green
		DangerColor = Color3.fromRGB(220, 60, 60),       -- bright red
		WarningColor = Color3.fromRGB(255, 200, 80),     -- yellow-orange
		HeadshotColor = Color3.fromRGB(255, 220, 80),    -- gold
		HealColor = Color3.fromRGB(80, 220, 120),        -- green
		AmmoColor = Color3.fromRGB(255, 255, 255),       -- white
	},
	Protanopia = {  -- red-blind — replace red with orange
		AttackerColor = Color3.fromRGB(255, 150, 50),    -- orange (was red)
		DefenderColor = Color3.fromRGB(80, 120, 255),    -- blue OK
		FriendlyColor = Color3.fromRGB(80, 200, 220),    -- cyan (was green)
		DangerColor = Color3.fromRGB(255, 130, 50),
		WarningColor = Color3.fromRGB(255, 220, 100),
		HeadshotColor = Color3.fromRGB(255, 220, 80),
		HealColor = Color3.fromRGB(80, 200, 220),
		AmmoColor = Color3.fromRGB(255, 255, 255),
	},
	Deuteranopia = {  -- green-blind — replace green with cyan/blue
		AttackerColor = Color3.fromRGB(255, 80, 80),
		DefenderColor = Color3.fromRGB(80, 80, 255),     -- pure blue
		FriendlyColor = Color3.fromRGB(80, 200, 220),    -- cyan (was green)
		DangerColor = Color3.fromRGB(220, 60, 60),
		WarningColor = Color3.fromRGB(255, 180, 60),     -- shifted yellow
		HeadshotColor = Color3.fromRGB(255, 200, 60),
		HealColor = Color3.fromRGB(80, 200, 255),        -- light blue (was green)
		AmmoColor = Color3.fromRGB(255, 255, 255),
	},
	Tritanopia = {  -- blue-blind — shift blue to teal
		AttackerColor = Color3.fromRGB(255, 80, 80),
		DefenderColor = Color3.fromRGB(80, 200, 200),    -- teal (was blue)
		FriendlyColor = Color3.fromRGB(80, 220, 120),
		DangerColor = Color3.fromRGB(220, 60, 60),
		WarningColor = Color3.fromRGB(255, 180, 60),
		HeadshotColor = Color3.fromRGB(255, 200, 60),
		HealColor = Color3.fromRGB(80, 220, 120),
		AmmoColor = Color3.fromRGB(255, 220, 200),
	},
}

local currentMode = "Normal"

function ColorBlindPalette.SetMode(mode)
	if PALETTES[mode] then
		currentMode = mode
	end
end

function ColorBlindPalette.GetMode()
	return currentMode
end

function ColorBlindPalette.Get(colorKey)
	local palette = PALETTES[currentMode] or PALETTES.Normal
	return palette[colorKey] or PALETTES.Normal[colorKey]
end

function ColorBlindPalette.GetAvailableModes()
	return { "Normal", "Protanopia", "Deuteranopia", "Tritanopia" }
end

return ColorBlindPalette
