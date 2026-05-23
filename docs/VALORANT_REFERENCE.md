# VALORANT Reference Report — Roblox FPS Project

**Compiled:** 2026-05-23
**Project:** `C:\Claude Code\roblox_valorant\`
**Focus:** Weapons (monetization priority), minimal maps, 29 agents reference, complete round/economy system

---

## 0. Spis treści

1. [Executive Summary](#1-executive-summary)
2. [Bronie — 19 sztuk + armor + ekonomia](#2-bronie--19-sztuk--armor--ekonomia)
3. [Agenci — wszystkie 29](#3-agenci--wszystkie-29)
4. [Mapy — Ascent / Bind / Split](#4-mapy--ascent--bind--split)
5. [System rund + ekonomia + ult points](#5-system-rund--ekonomia--ult-points)
6. [Monetyzacja — skiny, cases, Battle Pass](#6-monetyzacja--skiny-cases-battle-pass)
7. [Implementation Roadmap (12 sprintów)](#7-implementation-roadmap-12-sprintów)
8. [Źródła](#8-źródła)

---

## 1. Executive Summary

**Główne liczby do zapamiętania:**

| Parametr | Wartość |
|---|---|
| Łączna liczba broni | 19 (Classic..Knife) + Bandit (2026 nowy) |
| Łączna liczba agentów | 29 (Jett..Veto, 4 role) |
| Format meczu | First-to-13, sides swap po rundzie 12 |
| Buy phase | 30s standardowo, 45s pierwsza w połowie |
| Round phase | 100s przed plant + 45s po plancie |
| Spike plant/defuse | 4s plant, 7s defuse (3.5s half) |
| Starting credits | 800 (pistol round) |
| Max credits | 9000 |
| Kill reward | 200 (każda broń) |
| Win bonus | 3000 |
| Loss bonus | 1900 → 2400 → 2900 cap |
| Player HP | 100 |
| Light shield | 25 HP / 400 cr |
| Heavy shield | 50 HP / 1000 cr |
| Armor reduction | 33% HP / 66% armor split |
| Ult points needed | 6-8 zależnie od agenta |
| Ult orbs per map | 2 (Fracture: 4) |
| One-shot HS broni | Vandal, Sheriff, Guardian, Marshal, Outlaw, Operator |
| One-shot body broni | Operator (always), Outlaw (light armor) |

**Konwersja Valorant → Roblox:**
- 1 metr Valorant ≈ **3 studs** Roblox
- WalkSpeed Roblox: knife=16, riffle=12.8 (80%), sniper=12.2 (76%)
- Wszystkie pociski to **hitscan** (raycast w Robloxie)
- Server-side validation: fire rate, magnitude direction, dystans origin od HRP

**Najważniejszy wniosek z researchu:** RIVALS (case-based, Counter-Strike-like) zarabia ~$1.74M/m-c na Robloxie. Realistyczny target dla naszego klona to **10% tego = $174k/m-c gross** = ~$135-155k netto po DevEx z R15 boostem.

---

## 2. Bronie — 19 sztuk + armor + ekonomia

### 2.1 Mechaniki globalne

**Spread system (warstwy się sumują):**
1. First Bullet Accuracy (FBA) — per weapon
2. Movement error: stojąc 0°, kucając -0.17°, chodząc ~3°, biegnąc 6.2°, w powietrzu +7° przez 0.225s
3. Firing error (recoil bloom przy sustained fire)
4. Guardian, Marshal, Outlaw, Operator: **0° tylko w ADS/scope**

**Armor formula (per hit, dopóki armor > 0):**
```
hp_loss     = floor(damage × 0.33)
armor_loss  = floor(damage × 0.66)
```
Po wyczerpaniu armoru — full damage na HP. Headshot bypassuje armor reduction (niektóre bronie 1-shot HS through heavy).

**Wall penetration tiers:**
- Low: ×0.5 dmg through wall (Classic, Shorty, Frenzy, Stinger, Bucky)
- Medium: ×0.65 dmg (Ghost, Spectre, Judge, Bulldog, Phantom, Vandal, Marshal)
- High: ×0.8 dmg (Sheriff, Guardian, Outlaw, Operator, Ares, Odin)
- Sheriff/Outlaw potwierdzone ~125 body dmg przez ścianę

### 2.2 Sidearms

| Bron | Cena | RPM | Mag | Reload | Head dmg | Body dmg | Notatki |
|---|---|---|---|---|---|---|---|
| Classic | 0 | 6.75 | 12/36 | 1.75s | 78/66 | 26/22 | 3-pellet shotgun burst RMB |
| Shorty | 300 | 3.3 | 2/6 | 1.75s | 24×15 (pellets) | 11×15 | Per-pellet, point-blank 165 dmg |
| Frenzy | 450 | 10 | 13/39 | 1.5s | 78/63 | 26/21 | Only full-auto pistol |
| Ghost | 500 | 6.75 | 15/45 | 1.5s | 105/87 | 30/25 | Silenced, 2-tap HS unarmored |
| **Sheriff** | **800** | 4 | 6/24 | 2.25s | **159/145** | 55/50 | **1-shot HS any range, any armor** |
| Bandit (NEW 2026) | 600 | - | 8/24 | 1.5s | - | - | Bridges Ghost/Sheriff, 1-shot HS vs light armor |

### 2.3 SMG

| Bron | Cena | RPM | Mag | Reload | Head 0-15m | Body 0-15m | Notatki |
|---|---|---|---|---|---|---|---|
| Stinger | 1100 | 16 / 8.47 ADS | 20/60 | 2.25s | 67 | 27 | Fastest RPM, melts close range, 4-round burst ADS |
| Spectre | 1600 | 13.33 / 12 ADS | 30/90 | 2.25s | 78 | 26 | Silenced, "second rifle", eco-round meta |

### 2.4 Shotguns

| Bron | Cena | RPM | Mag | Pellets | Head 0-8m | Body 0-8m | Notatki |
|---|---|---|---|---|---|---|---|
| Bucky | 850 | 1.1 | 5/10 | 15 | 40 | 20→17 (patch 12.09) | Airburst alt-fire (5 pellets, ~8m detonate) |
| Judge | 1850 | 3.5 | 5/10 | 12 | 34 | 17 | Auto-shotgun, can melt 2-3 in burst |

### 2.5 Rifles

| Bron | Cena | RPM | Mag | Reload | Head | Body | Notatki |
|---|---|---|---|---|---|---|---|
| Bulldog | 2050 | 9.15 / 6.32 ADS | 24/72 | 2.5s | 115 | 35 | Cheapest rifle, no falloff, 3-burst ADS |
| Guardian | 2250 | 5.25 / 4.275 ADS | 12/36 | 2.5s | **195** | 65 | **1-shot HS any range through heavy**, 2-tap body |
| Phantom | 2900 | 11 / 9.9 ADS | 30/90 | 2.5s | 156→124 | 39→31 | Silenced, smooth spray, falloff |
| **Vandal** | **2900** | 9.75 / 8.32 ADS | 25/75 | 2.5s | **160** | 40 | **1-shot HS ANY range ANY armor**, T-shape spray |

### 2.6 Sniper Rifles

| Bron | Cena | RPM | Mag | Scope | Head | Body | Notatki |
|---|---|---|---|---|---|---|---|
| Marshal | 950 | 1.5 | 5/15 | 2.5× | 202 | 101 | 1-shot HS through heavy, 1-shot body unarmored |
| Outlaw | 2400 | 2.75 | 2/10 | 2.5×/5× | 238 | 140 | Break-action, 1-shot body light armor, wallbang 125 |
| **Operator** | **4700** | 0.6 | 5/10 | 2.5×/5× | 255 | 150 | **1-shot kill anywhere any range any armor**, severe scope move penalty |

### 2.7 Machine Guns

| Bron | Cena | RPM | Mag | Reload | Head 0-30m | Body 0-30m | Notatki |
|---|---|---|---|---|---|---|---|
| Ares | 1550 | 13 const | 50/100 | 3.25s | 72 | 30 | Spammy wallbang, ADS reduces spread |
| Odin | 3200 | 12 → 15.6 spinup | 100/200 | 5.0s | 95 | 38 | Premier suppression/wallbang, 100-mag, ADS = instant 15.6 RPM |

### 2.8 Melee — Tactical Knife

| Mode | Front | Back |
|---|---|---|
| Primary slash | 50 | 100 |
| Alt heavy | 75 | 150 |

- **Backstab = instakill** (≥150 vs max HP 150 z heavy)
- **Knife jako jedyna broń daje 100% movement speed** (16 studs/s w naszym Roblox setupie)

### 2.9 Spray Patterns (skrótowe)

| Bron | Pierwsze 5 strzałów (vert / horiz) | Po 7. pocisku |
|---|---|---|
| Vandal | Tight cluster 1-3, potem góra-lewo 4-7 | Snap right |
| Phantom | Prosto w górę, slight right drift | Up-left |
| Bulldog | Tight 1-3, podniesienie + lewo | Mid-range burst |
| Spectre | Tight 1-4, potem high-left | Hard to control past 5 |
| Stinger | Slight right drift 1-3, potem lewo+góra od 4 | Najgorszy do kontroli past 5 |
| Ares | Slight right early, potem góra+lewo | Forgiving overall |
| Odin | Tight burst 1-3, sustained góra-lewo | 100-mag wymaga długiej kontroli |
| Sheriff | Massive vertical kick + horiz drift | Tap-fire only |

### 2.10 Ekonomia + armor

| Pozycja | Wartość |
|---|---|
| Starting cred (pistol round) | 800 |
| Half-time cred (round 13) | 800 |
| Max cap | 9000 |
| Kill (any weapon) | +200 |
| Teamkill | -200 |
| Plant | +300 (whole team if lost; planter only if won) |
| Defuse | +300 (per defender) |
| Win bonus | 3000 |
| Loss bonus | 1900 → 2400 → 2900 cap |
| Light Shields | 400 cr / 25 HP |
| Heavy Shields | 1000 cr / 50 HP |

**Buy tiers (orientacyjnie):**
- Eco / Save: 0-900 (pistol + 1 ability)
- Half-buy / Force: 2000-3000 (light + SMG/shotgun + abilities)
- Full Buy: 3900-4900 (heavy + Vandal/Phantom + full abilities)

### 2.11 Roblox implementacja — kluczowe wskazówki

**Damage formula z armor:**
```lua
function applyDamage(target, raw, isHeadshot)
    if isHeadshot then
        target.HP -= raw  -- HS bypassuje armor reduction
    elseif target.Armor > 0 then
        local hpLoss = math.floor(raw * 0.33)
        local armorLoss = math.floor(raw * 0.66)
        if armorLoss > target.Armor then
            local overflow = armorLoss - target.Armor
            target.HP -= (hpLoss + overflow)
            target.Armor = 0
        else
            target.Armor -= armorLoss
            target.HP -= hpLoss
        end
    else
        target.HP -= raw
    end
end
```

**Wall penetration:**
```lua
local result = workspace:Raycast(origin, direction * range, params)
if result and result.Instance:GetAttribute("Penetrable") then
    -- continue ray past wall with damage multiplier
    local mult = (WallPen=="Low" and 0.5) or (WallPen=="Medium" and 0.65) or 0.8
    -- damage = raw * mult
end
```

**Movement speed (studs/s):**
- Knife: 16 (100%)
- Rifles/SMG: 12.8-13.6 (80-85%)
- Snipers/heavies: 12.2 (76%)
- Operator scoped: 8.2 (~51%)

**Cross-source disagreements (resolved):**
- Ares fire rate: spin-up removed in patch, użyj **13 const**
- Ares price: **1550** (Liquipedia, recent)
- Bucky alt pellets: **5** (post-nerf)
- Outlaw HS dmg: **238** (Riot patch notes)
- Stinger falloff: 2-tier dla fidelity (0-9m / 9-15m / 15m+)

---

## 3. Agenci — wszystkie 29

### 3.1 System ult points + orbs

**1 punkt za każde:** kill, death, spike plant, spike defuse, orb pickup
**Orbs per map:** 2 (Fracture: 4)
**Total potrzebne:** 6-8 punktów w zależności od agenta
**Reset:** NIE w halftime, TAK w overtime

| Cost | Agenci |
|---|---|
| 6 punktów | Cypher, Phoenix, Reyna, Yoru |
| 7 punktów | Astra, Brimstone, Harbor, Jett, Killjoy, Neon, Omen, Skye, Iso, Tejo, Waylay, Veto, Clove, Fade, Gekko, Deadlock |
| 8 punktów | Breach, Chamber, KAY/O, Raze, Sage, Sova, Viper, Vyse |

### 3.2 Role + standardowy skład 5v5

**Komp:** 1 Controller + 1-2 Duelists + 1 Initiator + 1 Sentinel (5. slot meta-dependent).

- **Duelist** — frontline frag, mobility, entry power (Jett, Phoenix, Raze, Reyna, Yoru, Neon, Iso, Waylay)
- **Initiator** — intel, flash, breaking stalemates (Sova, Breach, Skye, KAY/O, Fade, Gekko, Tejo)
- **Sentinel** — site lockdown, flanks, traps (Cypher, Killjoy, Sage, Chamber, Deadlock, Vyse, Veto)
- **Controller** — smokes, walls, zone denial (Brimstone, Omen, Viper, Astra, Harbor, Clove)

### 3.3 Duelists (8)

| Agent | Kraj | Ult cost | C | Q | E (Signature) | X (Ultimate) |
|---|---|---|---|---|---|---|
| **Jett** | South Korea | 7 | Cloudburst (200) | Updraft (150) | Tailwind (dash) | Blade Storm (5 daggers) |
| Phoenix | UK | 6 | Blaze wall (200) | Curveball flash (250) | Hot Hands (200) | Run It Back (respawn) |
| Raze | Brazil | 8 | Boom Bot (300) | Blast Pack (200) | Paint Shells | Showstopper (rocket) |
| Reyna | Mexico | 6 | Leer (250) | Devour (100) | Dismiss (100) | Empress (frenzy) |
| Yoru | Japan | 7 | Fakeout (200) | Blindside (250) | Gatecrash (150) | Dimensional Drift |
| Neon | Philippines | 7 | Fast Lane (300) | Relay Bolt (200) | High Gear | Overdrive |
| Iso | China | 7 | Contingency (250) | Undercut (300) | Double Tap (150) | Kill Contract (1v1) |
| Waylay | Thailand | 7 | Saturate (200) | Light Speed (250) | Refract | Convergent Paths |

### 3.4 Initiators (7)

| Agent | Kraj | Ult cost | C | Q | E (Signature) | X (Ultimate) |
|---|---|---|---|---|---|---|
| Sova | Russia | 8 | Owl Drone (400) | Shock Dart (150) | Recon Bolt | Hunter's Fury (3 shots) |
| Breach | Sweden | 8 | Aftershock (200) | Flashpoint (250) | Fault Line | Rolling Thunder |
| Skye | Australia | 8 | Regrowth (200) | Trailblazer (250) | Guiding Light (250) | Seekers (3) |
| KAY/O | Future | 8 | FRAG/ment (200) | FLASH/drive (250) | ZERO/point | NULL/cmd (revivable) |
| Fade | Turkey | 8 | Prowler (250) | Seize (200) | Haunt | Nightfall |
| Gekko | USA | 7 | Mosh Pit (250) | Wingman (300) | Dizzy (250) | Thrash |
| Tejo | Colombia | 7 | Stealth Drone (300) | Special Delivery (200) | Guided Salvo | Armageddon |

### 3.5 Sentinels (7)

| Agent | Kraj | Ult cost | C | Q | E (Signature) | X (Ultimate) |
|---|---|---|---|---|---|---|
| Cypher | Morocco | 6 | Trapwire (200) | Cyber Cage (100) | Spycam | Neural Theft |
| Killjoy | Germany | 7 | Alarmbot (200) | Turret (FREE) | Nanoswarm (200) | Lockdown |
| **Sage** | China | 8 | Barrier Orb wall (400) | Slow Orb (200) | Healing Orb | Resurrection |
| Chamber | France | 8 | Trademark (200) | Headhunter (100/bullet) | Rendezvous | Tour de Force |
| Deadlock | Norway | 7 | GravNet (200) | Sonic Sensor (200) | Barrier Mesh (300) | Annihilation (cocoon) |
| Vyse | Unknown | 8 | Razorvine (150) | Shear (300) | Arc Rose | Steel Garden (lock weapons) |
| Veto | Senegal | 7 | Interceptor (250) | Chokehold (200) | Crosscut (200) | Evolution (mutation) |

### 3.6 Controllers (6)

| Agent | Kraj | Ult cost | C | Q | E (Signature) | X (Ultimate) |
|---|---|---|---|---|---|---|
| Brimstone | USA | 7 | Stim Beacon (100) | Incendiary (250) | Sky Smoke (100) | Orbital Strike |
| Omen | Phantom | 7 | Shrouded Step (100) | Paranoia (250) | Dark Cover (50) | From the Shadows |
| Viper | USA | 8 | Snake Bite (200) | Poison Cloud (200) | Toxic Screen | Viper's Pit |
| Astra | Ghana | 7 | Nebula/Dissipate (150) | Nova Pulse (150) | Gravity Well (150) | Cosmic Divide (wall) |
| Harbor | India | 7 | Cascade (150) | Cove (350) | High Tide | Reckoning |
| Clove | Scotland | 7 | Pick-me-up (100) | Meddle (250) | Ruse (150) | Not Dead Yet (self-rev) |

### 3.7 Priorytety implementacji w Roblox

**Tier 1 — Trivial (build first):**
1. **Jett** — pure-vector dash + BodyVelocity updraft + smoke = Part + projectile knives. Najczystszy pierwszy agent.
2. **Reyna** — Empress = buff multiplikatory, Soul Orbs spawn on kill, Devour = HoT timer, Dismiss = invuln tag. All single-target, no AOE.
3. **Sage** — Wall = Part z health pool, Slow Orb = Region3 trigger, Heal Orb = HoT, Rez = restore character. Wszystko mapuje na Roblox primitives.
4. **Phoenix** — Curveball = projectile (Bezier), Hot Hands = AOE Part, Blaze = wall, Run It Back = save position + respawn.

**Tier 2 — Easy:**
5. **Cypher** — Tripwire = Beam Part + Touched, Spycam = ViewportFrame feed, Cyber Cage = transparent box, Neural Theft = Highlight tag.
6. **KAY/O** — FRAG/ment = ticking AOE Part, FLASH/drive = ScreenGui white overlay LOS-check, ZERO/point = projectile + canUseAbilities flag.

**Avoid for v1:**
- Viper, Astra, Harbor, Omen, Brimstone — wymagają vision-occlusion przeciw lighting Roblox
- Sova, Fade — wall-piercing LOS reveal przez dynamic geometry, tedious
- Raze, Tejo — sub-munition explosions + tactical-map UI
- Yoru, Clove, Veto — decoys/post-death/self-revive vs Roblox Humanoid lifecycle
- Chamber, Killjoy, Deadlock, Vyse — custom hitscan guns, multi-piece turrets, weapon-jam ults

**Recommended build order:** Sprint 6 buduje Jett + Sage + Phoenix (1 duelist, 1 sentinel, 1 fire-flavored hybrid). Sprint 7+ dodaje Reyna + Cypher. Sprint 8+ KAY/O.

---

## 4. Mapy — Ascent / Bind / Split

Z research wybrane 3 najlepsze do MVP (z 11+ map Valoranta). Pomijamy Haven (3 sites), Fracture (H-shape), Pearl/Lotus/Icebox/Breeze (atypowe layouty).

### 4.1 ASCENT (build first — Easy)

- **Setting:** floating Italian Renaissance / Venice (beżowy kamień, terakota)
- **Dimensions:** ~300×300 studs
- **Layout:** 3-lane (A Main / Mid Courtyard / B Main), open mid
- **Bombsites:** 2 (A z Heaven + Generator, B z Triple Box + Boathouse)
- **Verticality:** tylko 1 Heaven na site (proste platformy)
- **Special:** mechanical doors A Link i Market (500 HP, switch w Tree/Boathouse, one-way per round)

**Callouty A:** A Lobby, A Main, A Site, A Heaven, Generator, Hell, Tree, Garden, Window, Catwalk
**Callouty B:** B Lobby, B Main, B Site, Boathouse, Logs, Market, Stairs, Triple Box
**Mid:** Mid Top, Mid Bottom, Courtyard, Pizza, Catwalk, Tiles, Screens

**Top Operator angles:** A Heaven across site to A Main, B Boathouse down B Main, Mid Top across Courtyard

**Roblox notes:** Geometry rectangular = perfect for Parts. Heaven = elevated SpawnLocation-style platform. Doors = ClickDetector + TweenService. **Easiest to clone.**

### 4.2 BIND (build second — Easy-Medium)

- **Setting:** Rabat, Morocco (sandstone, terakota, blue mosaics)
- **Dimensions:** ~250×250 studs (najmniejsza)
- **Layout:** NO MID — tylko 2 osobne lane'y połączone teleporterami
- **Bombsites:** 2 (A z Heaven, B z Hookah)
- **Signature mechanic:** 2 one-way teleporters (A Short → B Hookah, B Long → A Showers), z głośnym audio cue

**Callouty A:** A Lobby, A Short, A Bath, A Showers, A Site, A Heaven, A Lamps, Back Elbow
**Callouty B:** B Long, B Garden, B Hookah, B Window, B Site, B Elbow, B Backsite, B Hall

**Roblox notes:** Theme = warm-color Parts (BrickColor "Sand red"). NO mid = ~30% mniej geometrii niż Ascent. Teleporters = Touched event + CFrame reassign + sound. Drugi do buildu po Ascent.

### 4.3 SPLIT (build third — Medium-Hard)

- **Setting:** Tokyo, Japan / cyberpunk neon (dark steel + neon pink/blue)
- **Dimensions:** ~250×280 studs
- **Layout:** compact 2-site z tight mid, heavy vertical
- **Bombsites:** 2 (A z Tower+Rafters, B z Tower+Rafters)
- **Signature mechanic:** 3 ropes/ascenders (Mid Vent, B Tower, A Sewer) — w MVP zastąp Truss Parts (drabinami)

**Callouty A:** A Main, A Ramps, A Sewer, A Tower, A Heaven, A Rafters, A Screens, A Site
**Callouty B:** B Garage, B Main, B Link, B Alley, B Tower, B Heaven, B Rafters, Double Box
**Mid:** Mid Top, Mid Bottom, Mid Mail, Mail Room, Mid Vents, Mid Cubby

**Roblox notes:** Most vertical map = 4 Heaven/Rafters platforms + 3 ropes + Mid Top. Tight corridors wymagają careful collision testing. Visually most striking = best wow factor. Stretch goal po Ascent + Bind.

### 4.4 Implementation order (z research)

| Mapa | Złożoność | Recognizability | Dimensions (studs) | Build w |
|---|---|---|---|---|
| **Ascent** | LOW | Highest | 300×300 | Sprint 9 |
| **Bind** | LOW-MEDIUM | High | 250×250 | Sprint 11 |
| **Split** | MEDIUM-HIGH | High | 250×280 | Post-MVP |

---

## 5. System rund + ekonomia + ult points

### 5.1 Phase durations

| Phase | Time | Notes |
|---|---|---|
| **Buy phase standardowa** | 30s | Barriers up, can't cross midline |
| **Buy phase pierwsza w połowie** | 45s | R1, R13, OT pierwsza runda |
| **Round phase** | 100s | Pre-plant action |
| **Spike timer (po plant)** | 45s | Resets round timer |
| **Spike plant** | 4s | Continuous, can't resume if interrupted |
| **Spike defuse full** | 7s | |
| **Spike defuse half (breaker)** | 3.5s | Progress saved at midpoint |
| **Post-round delay** | 7s | |

### 5.2 Match format

- **First to 13 wins**
- **Halftime swap po rundzie 12**
- **Overtime (12-12):** 2-round sets (jeden atak + jeden obrona). Trzeba wygrać OBA = win. Jeśli 1-1, OT się powtarza.
- **OT economy:** wszyscy reset do **5000 creds**, **ults reset to 0**
- **OT first buy phase:** 45s

### 5.3 Win conditions

| Condition | Winner |
|---|---|
| Eliminate all enemies | Either |
| Timer expires no plant | Defenders |
| Spike detonates | Attackers |
| Spike defused | Defenders |

### 5.4 Spike explosion

- **Damage:** instakill w core radius
- **Radius:** ~50 studs core (footstep audio ring), falloff outer ~80 studs
- **Audio escalation:** tick rate 2x przy 25s, faster przy 15s, final acceleration 5s

### 5.5 Ekonomia (już opisana w sekcji 2.10, tu kontekst)

**Carryover broni:** Survivor zachowuje broń + armor (no repurchase). Death = total loss.

**Buy phase strategy (heuristic):**
- **Eco/Save:** 0-900 → pistol + maybe 1 ability
- **Half-buy/Force:** 2000-3000 → light shields + SMG/shotgun + some abilities
- **Full buy:** 3900-4900 → heavy + Vandal/Phantom + full abilities

### 5.6 Combat Score / ACS

| Enemies alive at kill | CS gained |
|---|---|
| 5 (clutch start) | 150 |
| 4 | 130 |
| 3 | 110 |
| 2 | 90 |
| 1 (last enemy) | 70 |

Plus: **1 dmg = 1 CS**. Good ACS = 200-300+. Good KAST = 70%+.

**KAST trade window:** ~5s po śmierci, jeśli teammate killuje killera → liczy się jako "traded".

### 5.7 RoundManager state machine (pseudokod)

```lua
States: PreMatch → BuyPhase → Round → PostRound → (Halftime|Overtime|MatchEnd)

EnterBuyPhase():
    currentRound += 1
    spikePlanted = false
    isFirstOfHalf = (currentRound==1 or ==13)
    duration = isFirstOfHalf ? 45 : 30
    Players:RespawnAll() (Survivors keep weapons)
    Abilities:RechargeSignatures()
    Map:RaiseBarriers()
    UI:OpenBuyMenu(duration)
    StartTimer(duration, EnterRound)

EnterRound():
    Map:LowerBarriers()
    Spike:SpawnForAttackers()
    StartTimer(100, () => if not planted then EndRound("DEFENDERS_TIME"))

OnSpikePlanted(planter):
    spikePlanted = true
    CancelTimer()
    Economy:GrantTeamBonus("ATTACKERS", 300)
    UltPoints:Award(planter, 1)
    StartTimer(45, () => EndRound("ATTACKERS_DETONATE"); Spike:Detonate())

OnSpikeDefused(defuser):
    Economy:GrantTeamBonus("DEFENDERS", 300)
    UltPoints:Award(defuser, 1)
    EndRound("DEFENDERS_DEFUSE")

EndRound(reason):
    state = POST_ROUND
    winner = DetermineWinner(reason)
    Match:RecordRoundWin(winner)
    Economy:DistributeEndOfRoundCredits(winner)
    UI:ShowRoundEndScreen(reason)
    StartTimer(7, () =>
        if Match:IsOver() then EnterMatchEnd
        elseif currentRound==12 then EnterHalftime
        elseif Match:NeedsOT() then EnterOvertime
        else EnterBuyPhase
    )

EnterHalftime():
    Team:SwapSides()
    Economy:ResetForNewHalf(800)
    -- UltPoints carry through, NOT reset
    UI:ShowHalftimeScreen()
    StartTimer(15, EnterBuyPhase)

EnterOvertime():
    Economy:SetAllCredits(5000)
    UltPoints:ResetAll()
    EnterBuyPhase()  -- 45s first round
```

---

## 6. Monetyzacja — skiny, cases, Battle Pass

### 6.1 Mechanizmy Roblox

**Game Passes** — one-time permanent (VIP, exclusive skins). API: `PromptGamePassPurchase`, weryfikacja `UserOwnsGamePassAsync`.

**Developer Products** — consumable (crate keys, currency packs, BP tier skips). API: `PromptProductPurchase` + **ProcessReceipt** (krytyczne, ZAWSZE persist do DataStore przed return `PurchaseGranted`).

**Roblox Plus** (April 2026, $4.99/m-c) — subscribers dostają 10-20% discount, ale **Roblox absorbuje koszt** — dev dostaje full per-item revenue. Plus: dev zarabia Robux za każdego nowego subscribera acquired via game (do 3 m-cy).

**R15 character** = **+42% DevEx boost** (April 2026 overhaul). MUST use R15 not R6.

### 6.2 Opłaty + DevEx (new rate post-Sept 2025)

- Roblox bierze **30%** każdej Robux transakcji
- Dev exchange rate: $0.0038 per Robux (US 18+ verified: ~$0.0054 od czerwca 2026)
- R15 boost: +42%

**Effective USD per sale:**
- 199 R$ skin → ~$0.53 dev take
- 999 R$ skin → ~$2.66 dev take
- 1999 R$ skin → ~$5.32 dev take

**Wniosek:** Premium/Ultra tiers (999-1999 R$) są dramatycznie bardziej dochodowe per unit. Whales prefer high-tier — nie underprice top.

### 6.3 Skin tier system (5 tierów, wzór Valorant)

| Tier | Nazwa | Robux | Coins | Features |
|---|---|---|---|---|
| 1 Common | Standard | 99 | 1000 | Texture/color variant only |
| 2 Uncommon | Refined | 299 | 3000 | Custom mesh + equip anim + 1 chroma |
| 3 Rare | Elite | 699 | nie | Reload anim + fire VFX + kill banner + 3 chromas |
| 4 VeryRare | Legendary | 1299 (30-day limited) | nie | All Elite + finisher anim + kill counter |
| 5 Legendary | Mythic | 1999 (bundle only) | nie | All Legendary + evolving form + death effect |

### 6.4 Cases

| Case | Robux | Coins | Drop rates |
|---|---|---|---|
| **Standard** | 49 | 500 | 60% Common / 26% Uncommon / 10% Rare / 3% VeryRare / 1% Legendary |
| **Premium** (key req) | 199 + 49 key | nie | 0/40/38/18/4 |
| **Event** (limited) | 299 | nie | 0/30/45/20/5 |
| **3× Premium bundle** | 549 (save 48 R$) | - | - |

**Bad luck protection:** Po 50 cases bez Legendary → guarantee. Plus rates dynamic: +0.25% Legendary, +0.5% VeryRare per case bez (Phantom Forces style).

### 6.5 Battle Pass

- **Cena:** 599 R$ / sezon 60 dni / 50 tiers + 5 Epilogue
- **Free track:** 6-8 nagród (calling cards, sprays, 1 Tier-1 skin, 500 Coins)
- **Premium track:** ~6000 Coins przez 50 tierów (gracz odzyskuje koszt) + 3 Tier-2 skins + 1 Tier-3 finale skin + exclusive melee at Tier 50
- **Tier skip:** 49 R$ per tier, max 25 skips
- **Subscription:** 499 R$/m-c (auto-renew, saves 100 R$/season + bonus skin)

### 6.6 Game Passes

| Pass | Robux | Benefit |
|---|---|---|
| VIP Pass | 799 | +20% XP permanent, lobby chat color, VIP tag, exclusive starter skin |
| Inventory Expansion | 299 | +50 slots (50→100) |
| 2× Credit Bonus | 499 | Permanent 2× match Credits |
| **Founder's Pack** (limited 30 days) | 1499 | VIP + 2× Credits + 3 exclusive launch skins |

### 6.7 Limited bundles

- **Seasonal bundle (co 60 dni):** 4 weapons (Tier 3) + melee + buddy + spray = **2499 R$** (saves 32% vs unbundled)
- **Champions/Event bundle (1-2/rok):** Premium-tier set + cinematic finisher = **3999 R$**, never returns

### 6.8 Daily shop + Night Market

- Daily shop: 6 items rotating every 24h, mix Tier 1-3
- Night Market (2× rok, 7 dni): 30-50% off Tier 1-3 (nigdy Exclusive/Mythic)

### 6.9 Compliance (KRYTYCZNE)

**Drop rates MUST be displayed BEFORE purchase** (Roblox policy from Aug 2019):
```
Common: 60.00%
Uncommon: 26.00%
Rare: 10.00%
Very Rare: 3.00%
Legendary: 1.00%
```

**UK <18 restriction** (effective Aug 13, 2024):
```lua
local PolicyService = game:GetService("PolicyService")
Players.PlayerAdded:Connect(function(player)
    local ok, info = pcall(function()
        return PolicyService:GetPolicyInfoForPlayerAsync(player)
    end)
    if ok and info.ArePaidRandomItemsRestricted then
        -- Hide crate UI, server-block opens
    end
end)
```

**Cosmetic-only crates** (no stat advantage). Soft currency path do Tier 1-2 (F2P promise). **NO** real-money trading, **NO** gambling-like UI ("win", "jackpot" zakazane).

### 6.10 ProfileService (data persistence)

**Use ProfileService, nie raw DataStoreService.** Session locking zapobiega item duplication. Source: `madstudioroblox/ProfileService` GitHub.

```lua
ProfileTemplate = {
    Robux_Currency = 0,
    Coins_Currency = 0,
    Owned_Skins = {},  -- [skinId] = {level=1, variant=1, kills=0}
    Equipped = { Vandal = nil, Phantom = nil, ... },
    Battle_Pass = { Season = 1, XP = 0, Tier = 0, Premium_Owned = false, Claimed = {} },
    Inventory_Slots = 50,
    Consecutive_Cases_No_Legendary = 0,  -- bad luck protection
}
```

### 6.11 Anti-exploit pattern

```lua
EquipEvent.OnServerEvent:Connect(function(player, weaponName, skinId)
    -- Type checks
    if typeof(weaponName) ~= "string" or typeof(skinId) ~= "string" then return end
    -- Whitelist
    if not ValidWeapons[weaponName] then return end
    if not SkinDatabase[skinId] then return end
    -- Ownership (CRITICAL)
    local profile = ProfileCache[player.UserId]
    if not profile then return end
    if not profile.Data.Owned_Skins[skinId] then return end  -- log/ban
    -- Cross-validate skin matches weapon class
    if SkinDatabase[skinId].Weapon ~= weaponName then return end
    -- Apply
    profile.Data.Equipped[weaponName] = skinId
end)
```

Plus: rate limiting (5 equips/s), honeypot remotes (auto-ban any client firing).

### 6.12 Revenue model (10% scale of RIVALS @ $1.74M/m-c)

**Target:** $174k gross/m-c → ~$135-155k netto po DevEx z R15 boostem
**Annual:** $1.6M-$1.9M USD

| Source | % |
|---|---|
| Cases | 45% |
| Battle Pass | 25% |
| Direct skins / bundles | 20% |
| Game Passes | 5% |
| Currency packs | 5% |

### 6.13 Launch cadence

| Miesiąc | Content |
|---|---|
| Launch | 5 weapons, 30 base skins (6/weapon), 8 Tier-2, 2 Tier-3, Standard Case, BP Season 1 |
| M2 | First event (themed crate), 2 new weapons, 10 Tier-2, Premium Case launches |
| M3 | BP Season 2, first Tier-4 bundle, Founder's Pack window closes |
| M6 | Tier-5 Mythic via mid-anniversary |

---

## 7. Implementation Roadmap (12 sprintów)

| # | Sprint | Status | Description |
|---|---|---|---|
| 1 | MVP FPS shooter | ✅ | FPS camera + Vandal + raycast + HP + dummy + HUD |
| 2 | Setup Rojo + test w Studio | ⏳ | User runs Rojo + connects Studio, F5 test |
| 3 | Pełna WeaponDatabase (19 broni) + armor system | ✅ | 19 broni + armor 33/66 |
| 4 | Recoil + spread + wall penetration | ✅ | Per-weapon recoil patterns, spread bloom, wallbang mult |
| 5 | Pełny system rund + ekonomia + spike | ✅ | RoundManager, EconomyManager, SpikeController, UltPointsManager, MatchManager |
| 6 | Agenci MVP: Jett + Sage + Phoenix | ✅ | 3 agentów z full abilities |
| 7 | Skin system + PlayerData + ownership | ✅ | DataStoreService persistence, server-side equip validation, 5 tier skin DB |
| 8 | Monetyzacja: cases + BP + Game Passes | ✅ | MarketplaceService, ProcessReceipt, drop rates, BP 599 R$, PolicyService UK<18 |
| 9 | Mapa #1: Ascent | ✅ | ~300×300 studs z Heaven/Mid/Sites |
| 10 | Buy Menu UI + ekwipunek | ✅ | B key, kategoryzowane bronie, agent select |
| 11 | Mapa #2: Bind + rotation | ✅ | Teleporters z audio cue + MapRotation |
| 12 | Polish + AntiCheat + R15 | ✅ | Honeypot remotes, killcam, content maturity Mild |
| 13 | Visual polish (VFX + killfeed + lighting) | ✅ | Muzzle flash, impacts, killfeed, HUD v2, sound, atmosphere |
| 14 | ADS scope + reload anim + shells | ✅ | RMB ADS, FOV zoom, sniper scope overlay, reload rotation, shell ejection |
| 15 | Skin visual swap + tier VFX | ✅ | Tier 3+ fire VFX, tier 4+ kill banner, tier 5 evolving |
| 16 | Minimap | ✅ | Top-right radar z teammates + spike |
| 17 | Scoreboard TAB | ✅ | K/D/A/ACS/HS%/ADR z StatsManager |
| 18 | Agent select + countdown | ✅ | Pre-match modal z 6 cards, countdown 5..0 |
| 19 | Plant/Defuse UI | ✅ | E prompt, circular progress, plant area |
| 20 | Settings + crosshair customizer | ✅ | ESC menu z color/thickness/gap/dot, persistence |
| 21 | Lobby + welcome screen | ✅ | Pre-match team panels |
| 22 | Ambient props + nametagi | ✅ | Lamp posts, barrels, banners + team-color HP nametag |
| 23 | Bot AI | ✅ | State machine, LOS, shooting, fill 5v5 |
| 24 | Practice range | ✅ | Osobna arena z moving dummies + /practice command |
| 25 | Cypher + Reyna + KAY/O | ✅ | 3 nowi agenci (łącznie 6) |
| 26 | Split mapa | ✅ | Ropes (TrussParts) + dodana do rotation |
| 27 | Rank system + MMR | ✅ | Iron-Radiant, +/-25 per match, ACS modifier |
| 28 | Match history | ✅ | Last 20 matches w PlayerData |
| 29 | Skin inventory UI | ✅ | I key, browse owned skins, rotating preview |
| 30 | Ping system | ✅ | Z/T/G/H hotkeys, world markers, teammates only |
| 31 | Spectator mode | ✅ | Q/E cycle living teammates po śmierci |
| 32 | Map vote | ✅ | Between-match 20s voting |
| 33 | Multi-part weapon meshes | ✅ | Per category: receiver/barrel/stock/grip/mag/sight/scope |
| 34 | Final polish + audit | ✅ | Bug fixes, memory update, docs |
| 35 | Crouch + walk movement | ✅ | Ctrl=crouch, Shift=walk, accuracy bonus crouch, silent walk |
| 36 | Combat report MVP | ✅ | Round-end MVP banner z personal stats |
| 37 | Achievement system | ✅ | 12 milestones, popup notifications, coin rewards |
| 38 | Daily challenges | ✅ | 3 random tasks z reset 24h, top-right widget |
| 39 | Sova + Brimstone + Viper | ✅ | 9 total agents |
| 40 | Haven mapa | ✅ | 4. mapa, 3 bombsites A/B/C |
| 41 | Leaderboards | ✅ | OrderedDataStore top 100 MMR, L key UI |
| 42 | Tutorial onboarding | ✅ | 6-step first-time walkthrough |
| 43 | Custom games | ✅ | /host + /join CODE chat commands |
| 44 | Footstep sounds | ✅ | Per-surface, walking/crouch silent, landing |
| 45 | Final polish | ✅ | Bug fixes, memory |
| 46 | Battle Pass UI | ✅ | P key, tier grid free + premium tracks |
| 47 | Career stats + win streak | ✅ | K key all-time stats, 🔥 HUD badge |
| 48 | Death ragdoll | ✅ | BallSocketConstraint, blood pool, gun drop |
| 49 | Voice line system | ✅ | Per-agent + generic voice lines table |
| 50 | Final comprehensive review | ✅ | Memory + sprint list update |
| 51 | Deathmatch mode | ✅ | /dm FFA, auto-respawn 5s, score to 40 |
| 52 | Weekly challenges | ✅ | 3 tasks, 7-day reset, ~2000 coins/each |
| 53 | Aim trainer | ✅ | /aim w practice range, 20 targets time-attack |
| 54 | Toast queue utility | ✅ | Centralized ToastController.Show() |
| 55 | MVP medal scoreboard | ✅ | ★N prefix przy nazwie + rank passed do snapshot |
| 56 | Final comprehensive docs | ✅ | Pełna lista sprintów 1-56, struktura update |
| 57 | Bot pathfinding | ✅ | PathfindingService — bots omijają ściany, jumping nad obstacles |
| 58 | BP claim button | ✅ | Per-tier claim F✓/P✓ buttons, ClaimBPReward remote endpoint |
| 59 | Bots use abilities | ✅ | Random agent assignment, 5-12s cooldown ability cast (visual only) |
| 60 | Final wrap | ✅ | Stats: 95+ files, 16000+ lines, 555+ KB Luau code |
| 61 | Damage direction indicator | ✅ | Arc HUD pokazujący direction otrzymanego damage'u, TookDamage remote |
| 62 | Drop + pickup weapons | ✅ | Y key drop, Touched pickup, DroppedWeapon Part z BillboardGui |
| 63 | Spike detonation VFX | ✅ | Dramatic explosion (8→80 studs), particle burst, shockwave ring, PointLight |
| 64 | Match end celebration | ✅ | VICTORY/DEFEAT banner, fireworks (20 colored bursts) dla winners |
| 65 | Final mega-summary | ✅ | Complete sprint list 1-65, comprehensive structure update |
| 66 | Friend system | ✅ | FriendService /addfriend /removefriend /friends, cap 50, PlayerData.Friends |
| 67 | Performance opts | ✅ | PerformanceController — nametag LOD 60 studs, cull distant decals/weapons, particle limits |
| 68 | Expand skin database | ✅ | +30 skins: Vandal/Phantom/Ghost/Sheriff/Operator extras + defaults dla wszystkich broni + karambit/butterfly/dragon knives |
| 69 | Daily login bonus | ✅ | LoginBonusService — streak counter, +100→1000 coins escalating (day 7 milestone) |
| 70 | ABSOLUTE FINAL summary | ✅ | Sprint list 1-70 complete, structure comprehensive |
| 71 | Text chat UI | ✅ | V key chat input, /all + /team channels, RichText history, ChatService server-side |
| 72 | Round timer audio | ✅ | Tick sounds last 10s round/5s buy, escalating volume w SoundController |
| 73 | Custom skybox per map | ✅ | SkyboxConfig per mapa: Ascent day, Bind sunny desert, Split night neon, Haven morning fog |
| 74 | Ability cooldown HUD | ✅ | AbilityHUDController — 4 boxes (C/Q/E/X) z charges/ult ready, color-coded |
| 75 | Color blind modes | ✅ | ColorBlindPalette shared (Normal/Protanopia/Deuteranopia/Tritanopia), settings cycle toggle |
| 76 | Volume sliders + final wrap | ✅ | SFX/Voice volume sliders w settings, ColorBlindPalette loaded from settings |
| 77 | Player level (XP) | ✅ | Account level separate od MMR, +100 XP/match + 200 coins/level (LevelService) |
| 78 | Weapon slots (1/2/3) | ✅ | Primary/Secondary/Melee z auto-assign, WeaponSlotController + CombatService.SwitchSlot |
| 79 | Inspect weapon (T) | ✅ | Trzymaj T → centered viewmodel rotating + weapon stats overlay |
| 80 | Pre-game warmup | ✅ | 30s przed round 1 z bots + free Vandal + 9000 cr (STATES.WARMUP) |
| 81 | Quick-buy loadouts | ✅ | Full Buy/Half Buy/Eco preset buttons w buy menu |
| 82 | Equip time delay | ✅ | EquipTime cooldown blokuje firing podczas weapon swap |
| 83 | Fall damage | ✅ | FallDamageService, >10 studs = damage (3/stud), >40 studs = death |
| 84 | Defuser tool | ✅ | 400 cr defender-only, HasDefuser attribute, w buy menu Equipment |
| 85 | Match MVP | ✅ | Match-end overlay z player z najwięcej round MVPs + ACS combo |
| 86 | Absolute absolute final | ✅ | 108+ Lua files, sprint list complete 1-86 |
| 87 | Bot difficulty levels | ✅ | Easy/Medium/Hard profiles — AimOffset, FireIntervalMult, HeadshotChance, DetectionRange |
| 88 | Spawn invulnerability | ✅ | 3s invuln po respawnie z pulsing blue Highlight, blocks all damage |
| 89 | Reload cancel + final | ✅ | Strzelanie podczas reload cancelluje go jeśli mag > 0, 111+ files final |
| 90 | Surrender vote (/ff) | ✅ | SurrenderService — 4/5 ratio team vote → forfeit, 30s timeout, chat trigger |
| 91 | AFK detection + auto-kick | ✅ | AFKService — 60s warn, 120s kick, MarkActive na fire/ability/buy |
| 92 | BOT tag w nametag | ✅ | "[BOT] Name" BillboardGui nad każdym botem, team-color |
| 93 | Spike urgency visual | ✅ | SpikeUrgencyController — red pulsing screen edge gdy timer <10s |
| 94 | Final completion | ✅ | Stats: 113 Lua files, 17468 linii, 620.6 KB, 94 sprintów total |
| 95 | Astra + Omen + Killjoy | ✅ | 12 agentów total — Controllers (Astra/Omen) + Sentinel (Killjoy) |
| 96 | Fracture + Lotus maps | ✅ | 6 map total — Fracture H-shape 2 sites + 4 orbs, Lotus 3 sites |
| 97 | Setup guide | ✅ | docs/SETUP.md z instalacją Rojo + production checklist |
| 98 | Spike timer HUD | ✅ | Centered countdown widget 45s post-plant, pulsing red < 10s |
| 99 | Low HP heartbeat | ✅ | Red vignette pulsing przy HP < 40%, speed scales with low HP |
| 100 | Round counter dots | ✅ | 13 dots per team (red atk / blue def), light up after each round win |
| 101 | Compendium screen (F1) | ✅ | Browse all 12 agents + 6 maps + 19 weapons z stats + role colors |
| 102 | Absolute final | ✅ | Final stats: 122 Lua files, 18800+ linii, 660+ KB, 102 sprintów total |

**Krytyczne decyzje już podjęte:**
- ✅ Rojo sync (default.project.json) + Luau
- ✅ Hitscan (Roblox Raycast) — wszystkie pociski natychmiastowe
- ✅ Server-authoritative damage + ammo
- ✅ ProfileService (nie DataStore raw) dla persistencji
- ✅ R15 character (DevEx boost)
- ✅ Cosmetic-only crates (TOS compliance)
- ✅ 5-tier skin system z F2P path do Tier 1-2

---

## 8. Źródła

### Bronie / armor / ekonomia
- [Liquipedia VALORANT Wiki](https://liquipedia.net/valorant/) — primary canonical stats
- [MetaBot.GG Weapon Stats 2026](https://metabot.gg/en/valorant/weapon/)
- [Digital Trends Valorant Weapons Guide](https://www.digitaltrends.com/gaming/valorant-weapons-guide/)
- [Dexerto — Damage stats](https://www.dexerto.com/valorant/valorant-weapon-guide-damage-stats-for-all-guns-1369047/)
- [Pro Game Guides — Spray Patterns](https://progameguides.com/valorant/every-weapon-spray-pattern-in-valorant/)
- [Esports.gg — Patch 12.09 nerfs](https://esports.gg/news/valorant/shotguns-nerfs-explained-valorant-patch-notes-12-09/)
- [Dotesports — Bandit 2026 announcement](https://dotesports.com/valorant/news/valorant-adds-bandit-sidearm-for-2026)
- [Valorant Armor Wiki](https://valorant.fandom.com/wiki/Armor_and_Shield)

### Agenci
- [Valorant Wiki — Agents](https://valorant.fandom.com/wiki/Agents)
- [PlayValorant Agents](https://playvalorant.com/en-us/agents/)
- [Valorant Wiki — Orbs](https://valorant.fandom.com/wiki/Orbs)
- [Sportskeeda — Real names & countries](https://www.sportskeeda.com/valorant/all-valorant-agents-real-name-country-origin)
- [Switchblade — Ability Economy](https://www.switchbladegaming.com/valorant/ability-economy/)
- [Mobalytics — Ability & Ultimate Costs](https://mobalytics.gg/blog/valorant/valorant-agents-ability-ultimate-costs/)

### Mapy
- [PlayValorant Maps](https://playvalorant.com/en-us/maps/)
- [VALIION — Map Callouts](https://valiion.com/maps/)
- [Beebom Map Guides](https://beebom.com/valorant-ascent-map-guide/)
- [Mobalytics Maps Overview](https://mobalytics.gg/blog/valorant-maps-overview/)
- [TheSpike — VCT 2026 Trends](https://www.thespike.gg/valorant/news/vct-2026-kickoff-map-trends-the-most-picked-and-banned-maps-in-each-region/7641)

### Round system / ekonomia
- [Valorant Wiki — Spike](https://valorant.fandom.com/wiki/Spike)
- [Valorant Wiki — Credits](https://valorant.fandom.com/wiki/Credits)
- [Switchblade — Spike Mechanics](https://www.switchbladegaming.com/valorant/spike-mechanics-guide/)
- [Eloboss — Economy Guide](https://eloboss.net/blog/valorant-economy-guide)
- [Tracker.gg — ACS Explained](https://tracker.gg/valorant/articles/what-is-acs-in-valorant-and-how-does-it-work)
- [PlayVS Rulebook](https://help.playvs.com/en/articles/8673214-valorant-rulebook)

### Monetyzacja Roblox
- [MarketplaceService Docs](https://create.roblox.com/docs/reference/engine/classes/MarketplaceService)
- [Developer Products Guide](https://create.roblox.com/docs/production/monetization/developer-products)
- [Random Items Guidelines (DevForum)](https://devforum.roblox.com/t/guidelines-around-users-paying-for-random-virtual-items/307189)
- [UK Under-18 Update (DevForum)](https://devforum.roblox.com/t/update-on-paid-random-items-restriction-for-uk-users-under-18/3072183)
- [ProfileService Docs](https://madstudioroblox.github.io/ProfileService/)
- [Anti-Exploit Guide (DevForum)](https://devforum.roblox.com/t/creating-proper-anti-exploits-the-ultimate-guide/2172882)

### Case studies Roblox FPS
- [RIVALS Stats](https://rowatcher.com/games/6035872082/rivals)
- [Phantom Forces Skins Wiki](https://roblox-phantom-forces.fandom.com/wiki/Skins)
- [Counter Blox Cases](https://counter-blox.fandom.com/wiki/Category:Cases)
- [Arsenal Cases Wiki](https://robloxarsenal.fandom.com/wiki/Cases)
- [Top revenue Roblox FPS Jan 2026](https://www.pcgamesn.com/roblox/highest-revenue-jan-2026)

### Valorant skin economy (reference)
- [Valorant Skin Price Tiers Official](https://support-valorant.riotgames.com/hc/en-us/articles/360048520913-Price-Tiers-for-Skins-in-VALORANT)
- [Battle Pass Guide](https://www.thespike.gg/valorant/valorant-battle-pass-guide)
- [Radianite Points](https://www.dexerto.com/valorant/radianite-points-guide-valorant-weapon-upgrades-cost-more-1374342/)

### Roblox 2026 economy context
- [Roblox Plus Launch](https://playtoearn.com/news/roblox-plus-launches-april-30-at-499-monthly-replacing-premium-with-discount-first-model)
- [R15 DevEx Boost](https://www.msn.com/en-us/news/other/the-2026-roblox-economy-is-shifting-to-r15-boosted-payouts-and-recurring-revenue/gm-GM0DA16154)

---

**EOF.**
Pliki danych w `src/shared/`:
- [WeaponDatabase.lua](../src/shared/WeaponDatabase.lua) — 19 broni full stats
- [AgentDatabase.lua](../src/shared/AgentDatabase.lua) — 29 agentów
- [MapData.lua](../src/shared/MapData.lua) — 3 mapy
- [GameConfig.lua](../src/shared/GameConfig.lua) — rundy + ekonomia + ult points
- [MonetizationConfig.lua](../src/shared/MonetizationConfig.lua) — skiny + cases + BP
