-- AgentDatabase: 29 agentów Valoranta (2026), abilities z key bindings i kosztami
-- Każdy agent ma 4 abilities: 2 Basic (C/Q kupowane), 1 Signature (E, free, recharge), 1 Ultimate (X, ult points)
-- Source: valorant.fandom.com + playvalorant.com

local AgentDatabase = {}

local function ability(name, key, abilityType, cost, charges, effect)
	return {
		Name = name,
		Key = key,
		Type = abilityType,  -- "Basic" | "Signature" | "Ultimate"
		Cost = cost,
		Charges = charges,
		Effect = effect,
	}
end

-- ============================================================
-- DUELISTS
-- ============================================================

AgentDatabase.Jett = {
	Role = "Duelist",
	Country = "South Korea",
	RealName = "Han Sunwoo",
	ReleaseDate = "2020-04-07",
	UltCost = 7,
	ImplementationPriority = 1,  -- najłatwiejszy do implementacji
	Abilities = {
		C = ability("Cloudburst", "C", "Basic", 200, 2, "Curveable fog cloud blocks vision 2.5s"),
		Q = ability("Updraft", "Q", "Basic", 150, 1, "Propels Jett upward after brief windup"),
		E = ability("Tailwind", "E", "Signature", 0, 1, "Activate 7.5s window; second press dashes short distance in move direction. Resets after 2 kills"),
		X = ability("Blade Storm", "X", "Ultimate", 0, 5, "5 throwing knives; LMB single, RMB burst. Kill restores all"),
	},
}

AgentDatabase.Phoenix = {
	Role = "Duelist",
	Country = "United Kingdom",
	RealName = "Jamie Adeyemi",
	ReleaseDate = "2020-06-02",
	UltCost = 6,
	ImplementationPriority = 3,
	Abilities = {
		C = ability("Blaze", "C", "Basic", 200, 1, "Curved flame wall blocks vision, dmg 30/s enemies, heal 12.5/s self"),
		Q = ability("Curveball", "Q", "Basic", 250, 2, "Flare orb curves left/right, flash on detonation"),
		E = ability("Hot Hands", "E", "Signature", 200, 1, "Fireball ignites ground; dmg enemies, heal self. Resets after 2 kills"),
		X = ability("Run It Back", "X", "Ultimate", 0, 1, "Marks position; on death/timer (10s) respawn at marker full HP"),
	},
}

AgentDatabase.Raze = {
	Role = "Duelist",
	Country = "Brazil",
	RealName = "Tayane Alves",
	ReleaseDate = "2020-06-02",
	UltCost = 8,
	ImplementationPriority = 7,
	Abilities = {
		C = ability("Boom Bot", "C", "Basic", 300, 1, "Bouncing robot locks onto enemies in cone, explodes 80 dmg"),
		Q = ability("Blast Pack", "Q", "Basic", 200, 2, "Sticky explosive; manual detonation, satchel-jump capable. 50 dmg"),
		E = ability("Paint Shells", "E", "Signature", 0, 1, "Cluster grenade + sub-munitions ~55 dmg each. Resets after 2 kills"),
		X = ability("Showstopper", "X", "Ultimate", 0, 1, "Rocket launcher, massive AOE on impact"),
	},
}

AgentDatabase.Reyna = {
	Role = "Duelist",
	Country = "Mexico",
	RealName = "Zyanya Mondragón",
	ReleaseDate = "2020-06-02",
	UltCost = 6,
	ImplementationPriority = 2,
	Abilities = {
		C = ability("Leer", "C", "Basic", 250, 1, "Ethereal eye nearsights enemies who look at it 2s"),
		Q = ability("Devour", "Q", "Basic", 100, 4, "Consume Soul Orb (from kills); heal up to 100, overheal to 150"),
		E = ability("Dismiss", "E", "Basic", 100, 4, "Consume Soul Orb; intangible + speed 2s. Invisible if Empress"),
		X = ability("Empress", "X", "Ultimate", 0, 1, "Frenzy: faster fire/equip/reload, infinite Devour/Dismiss. Kills extend duration"),
	},
}

AgentDatabase.Yoru = {
	Role = "Duelist",
	Country = "Japan",
	RealName = "Kiritani Ryo",
	ReleaseDate = "2021-01-12",
	UltCost = 7,
	ImplementationPriority = 8,
	Abilities = {
		C = ability("Fakeout", "C", "Basic", 200, 1, "Mirror-image clone runs forward (audible footsteps); can be placed stationary"),
		Q = ability("Blindside", "Q", "Basic", 250, 1, "Invisible fragment bounces off surfaces, flashes"),
		E = ability("Gatecrash", "E", "Signature", 150, 2, "Rift tether forward; reactivate to teleport. Resets after 2 kills"),
		X = ability("Dimensional Drift", "X", "Ultimate", 0, 1, "Other dimension: intangible, no weapons, dampened audio. Exit anywhere"),
	},
}

AgentDatabase.Neon = {
	Role = "Duelist",
	Country = "Philippines",
	RealName = "Tala Valdez",
	ReleaseDate = "2022-01-11",
	UltCost = 7,
	ImplementationPriority = 5,
	Abilities = {
		C = ability("Fast Lane", "C", "Basic", 300, 1, "Two electric lines forward, rise into walls blocking vision 6s"),
		Q = ability("Relay Bolt", "Q", "Basic", 200, 2, "Bolt bounces once, concusses"),
		E = ability("High Gear", "E", "Signature", 0, 1, "Sprint at high speed; LMB to slide. Energy bar"),
		X = ability("Overdrive", "X", "Ultimate", 0, 1, "Passive High Gear + electric beam from fingertips, DOT"),
	},
}

AgentDatabase.Iso = {
	Role = "Duelist",
	Country = "China",
	RealName = "Li Zhao Yu",
	ReleaseDate = "2023-10-31",
	UltCost = 7,
	ImplementationPriority = 6,
	Abilities = {
		C = ability("Contingency", "C", "Basic", 250, 1, "Indestructible bullet-blocking energy wall"),
		Q = ability("Undercut", "Q", "Basic", 300, 1, "Bolt through walls; applies Vulnerable + Suppress 4s"),
		E = ability("Double Tap", "E", "Signature", 150, 1, "Focus timer; kills/damage drop orbs granting one-hit shield. Resets after 2 kills"),
		X = ability("Kill Contract", "X", "Ultimate", 0, 1, "Pulls one enemy to 1v1 arena; winner returns full HP"),
	},
}

AgentDatabase.Waylay = {
	Role = "Duelist",
	Country = "Thailand",
	ReleaseDate = "2025-03-05",
	UltCost = 7,
	ImplementationPriority = 9,
	Abilities = {
		C = ability("Saturate", "C", "Basic", 200, 1, "Light cluster debuffs Hindering (slows vertical/reload)"),
		Q = ability("Light Speed", "Q", "Basic", 250, 1, "Two dashes; first can aim upward"),
		E = ability("Refract", "E", "Signature", 0, 1, "Place beacon; reactivate teleport back, briefly invulnerable"),
		X = ability("Convergent Paths", "X", "Ultimate", 0, 1, "Prismatic burst Hinders enemies in AOE"),
	},
}

-- ============================================================
-- INITIATORS
-- ============================================================

AgentDatabase.Sova = {
	Role = "Initiator",
	Country = "Russia",
	RealName = "Sasha Novikov",
	ReleaseDate = "2020-04-07",
	UltCost = 8,
	ImplementationPriority = 12,
	Abilities = {
		C = ability("Owl Drone", "C", "Basic", 400, 1, "Pilotable drone (100 HP) fires marking darts"),
		Q = ability("Shock Dart", "Q", "Basic", 150, 2, "Explosive arrow, 2 wall bounces, 75-90 dmg"),
		E = ability("Recon Bolt", "E", "Signature", 0, 1, "Reveals enemies in LOS (40s CD)"),
		X = ability("Hunter's Fury", "X", "Ultimate", 0, 3, "3 wall-piercing energy blasts, mark + 80 dmg"),
	},
}

AgentDatabase.Breach = {
	Role = "Initiator",
	Country = "Sweden",
	RealName = "Erik Torsten",
	ReleaseDate = "2020-06-02",
	UltCost = 8,
	ImplementationPriority = 11,
	Abilities = {
		C = ability("Aftershock", "C", "Basic", 200, 1, "Fault line through walls, 2 ticks 80 dmg"),
		Q = ability("Flashpoint", "Q", "Basic", 250, 2, "Wall-piercing fast flash"),
		E = ability("Fault Line", "E", "Signature", 0, 1, "Wall-piercing concuss 3.5s (60s CD)"),
		X = ability("Rolling Thunder", "X", "Ultimate", 0, 1, "Massive cone of concusses + knock-ups through walls"),
	},
}

AgentDatabase.Skye = {
	Role = "Initiator",
	Country = "Australia",
	RealName = "Kirra Foster",
	ReleaseDate = "2020-10-27",
	UltCost = 8,
	ImplementationPriority = 13,
	Abilities = {
		C = ability("Regrowth", "C", "Basic", 200, 1, "Channels healing to allies (100 HP pool, no self-heal)"),
		Q = ability("Trailblazer", "Q", "Basic", 250, 1, "Pilotable Tasmanian tiger leaps + concusses"),
		E = ability("Guiding Light", "E", "Signature", 250, 2, "Hawk-form flash, can be guided. Resets after 2 kills"),
		X = ability("Seekers", "X", "Ultimate", 0, 3, "3 trackers (120 HP) toward closest enemies, nearsight on hit"),
	},
}

AgentDatabase.KAYO = {
	Role = "Initiator",
	Country = "Future (time-traveler)",
	RealName = "KAY/O",
	ReleaseDate = "2021-06-22",
	UltCost = 8,
	ImplementationPriority = 6,  -- suppression mechanic is core but simple flag
	Abilities = {
		C = ability("FRAG/ment", "C", "Basic", 200, 1, "Sticky explosive detonates in periodic pulses"),
		Q = ability("FLASH/drive", "Q", "Basic", 250, 2, "Curveball flash, fast detonation"),
		E = ability("ZERO/point", "E", "Signature", 0, 1, "Suppression blade; enemies can't use abilities 8s (resets on 1 kill)"),
		X = ability("NULL/cmd", "X", "Ultimate", 0, 1, "Pulses suppression in radius + fire-rate buff; revivable if downed"),
	},
}

AgentDatabase.Fade = {
	Role = "Initiator",
	Country = "Turkey",
	RealName = "Hazal Eyletmez",
	ReleaseDate = "2022-04-27",
	UltCost = 8,
	ImplementationPriority = 14,
	Abilities = {
		C = ability("Prowler", "C", "Basic", 250, 2, "Tracks terror trails, nearsights on hit 2.75s"),
		Q = ability("Seize", "Q", "Basic", 200, 1, "Tethers enemies; deafen + decay 75 HP over 4.5s"),
		E = ability("Haunt", "E", "Signature", 0, 1, "Watcher reveals + leaves terror trails 12s (40s CD)"),
		X = ability("Nightfall", "X", "Ultimate", 0, 1, "Wave through walls; terror-trail + deafen + decay 75 HP"),
	},
}

AgentDatabase.Gekko = {
	Role = "Initiator",
	Country = "USA",
	RealName = "Mateo Armendáriz De la Fuente",
	ReleaseDate = "2023-03-08",
	UltCost = 7,
	ImplementationPriority = 15,
	Abilities = {
		C = ability("Mosh Pit", "C", "Basic", 250, 1, "AOE burst 150 inner / 75 outer dmg/0.2s"),
		Q = ability("Wingman", "Q", "Basic", 300, 1, "Pet forward concusses cone; can plant/defuse spike"),
		E = ability("Dizzy", "E", "Signature", 250, 1, "Pet flies, flashes LOS enemies; recoverable orb"),
		X = ability("Thrash", "X", "Ultimate", 0, 1, "Pilot creature 6s; detonate detains enemies 6s"),
	},
}

AgentDatabase.Tejo = {
	Role = "Initiator",
	Country = "Colombia",
	ReleaseDate = "2025-01-08",
	UltCost = 7,
	ImplementationPriority = 16,
	Abilities = {
		C = ability("Stealth Drone", "C", "Basic", 300, 1, "Long-range invisible drone; pulse reveals + suppresses 8s"),
		Q = ability("Special Delivery", "Q", "Basic", 200, 1, "Sticky concuss grenade; alt-fire bounces once"),
		E = ability("Guided Salvo", "E", "Signature", 0, 2, "Tactical map; 2 missile strikes"),
		X = ability("Armageddon", "X", "Ultimate", 0, 1, "Linear airstrike across path, cascade damage"),
	},
}

-- ============================================================
-- SENTINELS
-- ============================================================

AgentDatabase.Cypher = {
	Role = "Sentinel",
	Country = "Morocco",
	RealName = "Amir El Amari",
	ReleaseDate = "2020-04-07",
	UltCost = 6,
	ImplementationPriority = 5,
	Abilities = {
		C = ability("Trapwire", "C", "Basic", 200, 2, "Tripwire across chokepoint; slow + reveal"),
		Q = ability("Cyber Cage", "Q", "Basic", 100, 2, "Vision-blocking cage with audio cue"),
		E = ability("Spycam", "E", "Signature", 0, 1, "Wall camera; alt-fire reveal-dart (45s CD if destroyed)"),
		X = ability("Neural Theft", "X", "Ultimate", 0, 1, "Mark enemy corpse; reveals all living enemies twice"),
	},
}

AgentDatabase.Killjoy = {
	Role = "Sentinel",
	Country = "Germany",
	RealName = "Klara Böhringer",
	ReleaseDate = "2020-08-04",
	UltCost = 7,
	ImplementationPriority = 17,
	Abilities = {
		C = ability("Alarmbot", "C", "Basic", 200, 1, "Hunts enemies; explodes Vulnerable 4s (double damage)"),
		Q = ability("Turret", "Q", "Signature", 0, 1, "Auto-firing 100 HP turret in 100° cone (60s CD)"),
		E = ability("Nanoswarm", "E", "Basic", 200, 2, "Hidden swarm; deploy damaging cloud 45 dmg/s for 4s"),
		X = ability("Lockdown", "X", "Ultimate", 0, 1, "Large dome (13s windup); detains all enemies inside 8s"),
	},
}

AgentDatabase.Sage = {
	Role = "Sentinel",
	Country = "China",
	RealName = "Ling Ying Wei",
	ReleaseDate = "2020-04-07",
	UltCost = 8,
	ImplementationPriority = 3,
	Abilities = {
		C = ability("Barrier Orb", "C", "Basic", 400, 1, "4-segment wall (400 HP, 800 fortified after 3s, 40s)"),
		Q = ability("Slow Orb", "Q", "Basic", 200, 2, "Ground field slows players inside"),
		E = ability("Healing Orb", "E", "Signature", 0, 1, "Ally +100 HP over 5s, or self +50 (45s CD)"),
		X = ability("Resurrection", "X", "Ultimate", 0, 1, "Channel 3.3s; revive dead ally full HP"),
	},
}

AgentDatabase.Chamber = {
	Role = "Sentinel",
	Country = "France",
	RealName = "Vincent Fabron",
	ReleaseDate = "2021-11-16",
	UltCost = 8,
	ImplementationPriority = 18,
	Abilities = {
		C = ability("Trademark", "C", "Basic", 200, 1, "Trap detects enemies, slow field"),
		Q = ability("Headhunter", "Q", "Basic", 100, 8, "Hitscan pistol, no falloff. ADS available"),
		E = ability("Rendezvous", "E", "Signature", 0, 2, "2 anchors; instantly teleport between"),
		X = ability("Tour de Force", "X", "Ultimate", 0, 1, "Hitscan sniper; kills create slow fields"),
	},
}

AgentDatabase.Deadlock = {
	Role = "Sentinel",
	Country = "Norway",
	ReleaseDate = "2023-06-27",
	UltCost = 7,
	ImplementationPriority = 19,
	Abilities = {
		C = ability("GravNet", "C", "Basic", 200, 1, "Net forces crouch + slow movement"),
		Q = ability("Sonic Sensor", "Q", "Basic", 200, 2, "Detects enemy sounds + concusses"),
		E = ability("Barrier Mesh", "E", "Signature", 300, 1, "Disc generates 4 impassable barriers"),
		X = ability("Annihilation", "X", "Ultimate", 0, 1, "Cone of nanowires; cocoon dragged enemy, killed if not destroyed"),
	},
}

AgentDatabase.Vyse = {
	Role = "Sentinel",
	Country = "Unknown (presumed Korean)",
	ReleaseDate = "2024-08-28",
	UltCost = 8,
	ImplementationPriority = 20,
	Abilities = {
		C = ability("Razorvine", "C", "Basic", 150, 2, "Hidden vine; nest slows + dmg 10/1.25m for 6s"),
		Q = ability("Shear", "Q", "Basic", 300, 1, "Hidden wall trap raises barrier behind crosser"),
		E = ability("Arc Rose", "E", "Signature", 0, 2, "Hidden rose; remotely blind LOS enemies"),
		X = ability("Steel Garden", "X", "Ultimate", 0, 1, "Lock all enemy primary weapons in large area"),
	},
}

AgentDatabase.Veto = {
	Role = "Sentinel",
	Country = "Senegal",
	ReleaseDate = "2025-10-07",
	UltCost = 7,
	ImplementationPriority = 21,
	Abilities = {
		Q = ability("Chokehold", "Q", "Basic", 200, 1, "Viscous fragment holds enemies; deafen + decay"),
		C = ability("Interceptor", "C", "Basic", 250, 1, "Shield drone (20 HP, 10s); destroys enemy projectiles"),
		E = ability("Crosscut", "E", "Signature", 200, 2, "Place vortex; teleport in"),
		X = ability("Evolution", "X", "Ultimate", 0, 1, "Mutation: +10% fire/reload/equip, 40 HP/s regen, debuff immune"),
	},
}

-- ============================================================
-- CONTROLLERS
-- ============================================================

AgentDatabase.Brimstone = {
	Role = "Controller",
	Country = "USA",
	RealName = "Liam Byrne",
	ReleaseDate = "2020-04-07",
	UltCost = 7,
	ImplementationPriority = 22,
	Abilities = {
		C = ability("Stim Beacon", "C", "Basic", 100, 2, "Field grants Combat Stim (+fire rate, equip, +15% speed)"),
		Q = ability("Incendiary", "Q", "Basic", 250, 1, "Bouncing molotov, damaging floor"),
		E = ability("Sky Smoke", "E", "Signature", 100, 3, "Map UI; place 3 smokes 19.25s anywhere in range"),
		X = ability("Orbital Strike", "X", "Ultimate", 0, 1, "Map-targeted laser, dmg over 3s AOE"),
	},
}

AgentDatabase.Omen = {
	Role = "Controller",
	Country = "Unknown (phantom/wraith)",
	ReleaseDate = "2020-04-07",
	UltCost = 7,
	ImplementationPriority = 23,
	Abilities = {
		C = ability("Shrouded Step", "C", "Basic", 100, 2, "Short teleport, audio cue"),
		Q = ability("Paranoia", "Q", "Basic", 250, 1, "Wall-piercing nearsight orb"),
		E = ability("Dark Cover", "E", "Signature", 50, 2, "Smoke orb ~15s; retrievable before placement (30s recharge)"),
		X = ability("From the Shadows", "X", "Ultimate", 0, 1, "Map-wide teleport; shade can be shot to cancel"),
	},
}

AgentDatabase.Viper = {
	Role = "Controller",
	Country = "USA",
	RealName = "Sabine Callas",
	ReleaseDate = "2020-04-07",
	UltCost = 8,
	ImplementationPriority = 24,
	Abilities = {
		C = ability("Snake Bite", "C", "Basic", 200, 2, "Toxic AOE dmg + Vulnerable"),
		Q = ability("Poison Cloud", "Q", "Basic", 200, 1, "Toggleable smoke; uses gas meter"),
		E = ability("Toxic Screen", "E", "Signature", 0, 1, "Long line of poison wall; toggle via gas"),
		X = ability("Viper's Pit", "X", "Ultimate", 0, 1, "Massive cloud around Viper; decay damage inside"),
	},
}

AgentDatabase.Astra = {
	Role = "Controller",
	Country = "Ghana",
	RealName = "Efia Danso",
	ReleaseDate = "2021-03-02",
	UltCost = 7,
	ImplementationPriority = 25,
	Abilities = {
		C = ability("Nebula/Dissipate", "C", "Basic", 150, 2, "Convert star to smoke or fake decoy"),
		Q = ability("Nova Pulse", "Q", "Basic", 150, 1, "Star charges then concusses radius"),
		E = ability("Gravity Well", "E", "Basic", 150, 1, "Pulls enemies, bursts, Vulnerable"),
		X = ability("Cosmic Divide", "X", "Ultimate", 0, 1, "Massive infinite wall blocks bullets + sound"),
	},
	Notes = "Plus passive Astral Form (free) — toggle to place 5 stars across map",
}

AgentDatabase.Harbor = {
	Role = "Controller",
	Country = "India",
	RealName = "Varun Batra",
	ReleaseDate = "2022-10-18",
	UltCost = 7,
	ImplementationPriority = 26,
	Abilities = {
		C = ability("Cascade/Storm Surge", "C", "Basic", 150, 2, "Wave of water slows enemies 30%"),
		Q = ability("Cove", "Q", "Basic", 350, 1, "Bullet-blocking water sphere 15s"),
		E = ability("High Tide", "E", "Signature", 0, 1, "Aimable water wall; slows touchers (40s CD)"),
		X = ability("Reckoning", "X", "Ultimate", 0, 1, "Geyser AOE; periodic concusses 9s"),
	},
}

AgentDatabase.Clove = {
	Role = "Controller",
	Country = "Scotland",
	ReleaseDate = "2024-03-26",
	UltCost = 7,
	ImplementationPriority = 27,
	Abilities = {
		C = ability("Pick-me-up", "C", "Basic", 100, 1, "After score/dmg-then-kill: speed boost + overheal"),
		Q = ability("Meddle", "Q", "Basic", 250, 1, "Grenade 90 HP decay radius"),
		E = ability("Ruse", "E", "Signature", 150, 2, "Map smoke; usable after Clove dies!"),
		X = ability("Not Dead Yet", "X", "Ultimate", 0, 1, "Self-revive full HP within post-death window"),
	},
}

-- ============================================================
-- HELPERS
-- ============================================================

function AgentDatabase.GetByRole(role)
	local result = {}
	for name, data in pairs(AgentDatabase) do
		if type(data) == "table" and data.Role == role then
			result[name] = data
		end
	end
	return result
end

function AgentDatabase.GetMVPAgents()
	-- 3 najprostsze do implementacji w MVP (Sprint 6)
	return {
		Jett = AgentDatabase.Jett,
		Sage = AgentDatabase.Sage,
		Phoenix = AgentDatabase.Phoenix,
	}
end

function AgentDatabase.GetAllNames()
	local names = {}
	for name, data in pairs(AgentDatabase) do
		if type(data) == "table" and data.Role then
			table.insert(names, name)
		end
	end
	table.sort(names)
	return names
end

AgentDatabase.Roles = { "Duelist", "Initiator", "Sentinel", "Controller" }

return AgentDatabase
