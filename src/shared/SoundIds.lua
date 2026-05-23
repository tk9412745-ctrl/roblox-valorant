-- SoundIds: centralna lista sound asset ID
-- Wszystkie ID są placeholderami — user może podmienić na własne uploady do Robloxa
-- rbxasset:// paths to built-in Roblox assets (zawsze dostępne free)

local SoundIds = {}

-- Weapon firing
SoundIds.Weapon = {
	-- Per weapon (placeholders — uploadnij własne assety i podstaw ID)
	Vandal       = "rbxassetid://9114149584",  -- placeholder rifle shot
	Phantom      = "rbxassetid://9114149584",
	Bulldog      = "rbxassetid://9114149584",
	Guardian     = "rbxassetid://9114149584",
	Ghost        = "rbxassetid://9114149584",
	Sheriff      = "rbxassetid://9114149584",
	Frenzy       = "rbxassetid://9114149584",
	Classic      = "rbxassetid://9114149584",
	Shorty       = "rbxassetid://9114149584",
	Bucky        = "rbxassetid://9114149584",
	Judge        = "rbxassetid://9114149584",
	Stinger      = "rbxassetid://9114149584",
	Spectre      = "rbxassetid://9114149584",
	Marshal      = "rbxassetid://9114149584",
	Outlaw       = "rbxassetid://9114149584",
	Operator     = "rbxassetid://9114149584",
	Ares         = "rbxassetid://9114149584",
	Odin         = "rbxassetid://9114149584",
	Knife        = "rbxassetid://9114149584",

	Reload       = "rbxasset://sounds/halloween/sword.wav",
	Equip        = "rbxasset://sounds/clickfast.wav",
	DryFire      = "rbxasset://sounds/short bell sound.wav",
}

-- Hit feedback
SoundIds.Hit = {
	Body      = "rbxasset://sounds/impact_water.wav",
	Head      = "rbxasset://sounds/halloween/sword.wav",  -- distinct headshot sfx
	Kill      = "rbxasset://sounds/bell.wav",
	Headshot  = "rbxassetid://5793355294",
}

-- Round events
SoundIds.Round = {
	BuyPhaseStart  = "rbxasset://sounds/electronicpingshort.wav",
	RoundStart     = "rbxasset://sounds/bass.wav",
	RoundWin       = "rbxasset://sounds/victory.wav",
	RoundLose      = "rbxasset://sounds/sad.wav",
	HalftimeStart  = "rbxasset://sounds/electronicpingshort.wav",
	MatchEnd       = "rbxasset://sounds/victory.wav",
}

-- Spike
SoundIds.Spike = {
	Plant         = "rbxasset://sounds/clickfast.wav",
	Planted       = "rbxasset://sounds/electronicpingshort.wav",
	TickSlow      = "rbxasset://sounds/short bell sound.wav",  -- 45-25s
	TickFast      = "rbxasset://sounds/short bell sound.wav",  -- 25-15s
	TickFinal     = "rbxasset://sounds/short bell sound.wav",  -- 15s-0
	Defusing      = "rbxasset://sounds/electronicpingshort.wav",
	Defused       = "rbxasset://sounds/victory.wav",
	Detonate      = "rbxasset://sounds/halloween/scream.wav",
}

-- Abilities
SoundIds.Ability = {
	JettDash       = "rbxasset://sounds/swoosh.wav",
	JettSmoke      = "rbxasset://sounds/impact_water.wav",
	JettUpdraft    = "rbxasset://sounds/swoosh.wav",
	JettKnives     = "rbxasset://sounds/halloween/sword.wav",
	SageWall       = "rbxasset://sounds/impact_water.wav",
	SageSlow       = "rbxasset://sounds/electronicpingshort.wav",
	SageHeal       = "rbxasset://sounds/clickfast.wav",
	SageRes        = "rbxasset://sounds/victory.wav",
	PhoenixBlaze   = "rbxasset://sounds/halloween/scream.wav",
	PhoenixFlash   = "rbxasset://sounds/electronicpingshort.wav",
	PhoenixHot     = "rbxasset://sounds/halloween/scream.wav",
	PhoenixRevive  = "rbxasset://sounds/victory.wav",
}

-- UI
SoundIds.UI = {
	Hover          = "rbxasset://sounds/button.wav",
	Click          = "rbxasset://sounds/clickfast.wav",
	Purchase       = "rbxasset://sounds/electronicpingshort.wav",
	Error          = "rbxasset://sounds/uuhhh.mp3",
}

-- Ambient
SoundIds.Ambient = {
	WindLoop       = "rbxasset://sounds/wind.mp3",
	RainLoop       = "rbxasset://sounds/Rain.mp3",
}

return SoundIds
