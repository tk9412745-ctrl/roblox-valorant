# Setup Guide — Roblox Valorant Project

## Wymagania

1. **Roblox Studio** (darmowe) — [https://create.roblox.com](https://create.roblox.com)
2. **Rojo CLI** + Studio plugin — sync plików lokalnych ↔ Studio
3. Windows / Mac / Linux (Studio działa na Windows i Mac)

## Krok 1 — Zainstaluj Rojo

### Windows
```powershell
winget install --id Rojo.Rojo
```
Lub pobierz binarka z [https://github.com/rojo-rbx/rojo/releases](https://github.com/rojo-rbx/rojo/releases)

### Mac/Linux
```bash
cargo install rojo  # if Rust installed
```
Lub Aftman: `aftman add rojo-rbx/rojo`

## Krok 2 — Zainstaluj Rojo Studio plugin

W Roblox Studio:
1. **Toolbox** → szukaj "Rojo"
2. Zainstaluj plugin (autor: LPGhatguy/Rojo Team)

Albo pobierz z [https://rojo.space/docs/v7/getting-started/installation/](https://rojo.space/docs/v7/getting-started/installation/)

## Krok 3 — Uruchom Rojo serwer

```powershell
cd "C:\Claude Code\roblox_valorant"
rojo serve
```
Output: `Rojo: Server listening on port 34872`

## Krok 4 — Podłącz Studio

1. Otwórz Roblox Studio
2. **New Place** → Baseplate template (lub empty)
3. Otwórz plugin **Rojo** (na pasku Plugins)
4. Kliknij **Connect** (default port 34872)
5. Plugin pokaże "Connected" — wszystkie pliki Lua zsynchronizowane

## Krok 5 — Uruchom test

W Studio:
- **F5** lub **Play** — gra startuje w trybie test
- Welcome screen → Lobby (15s) → Agent select (30s) → Match countdown 5..0 → Buy phase

## Sterowanie

| Klawisz | Akcja |
|---|---|
| WASD + Space | Ruch + skok |
| Ctrl | Crouch (lepsza celność) |
| Shift | Walk (cicho) |
| LPM / PPM | Strzał / ADS |
| R | Reload |
| 1 / 2 / 3 | Switch slot (primary/secondary/melee) |
| Y | Drop weapon |
| T (hold) | Inspect weapon |
| E | Plant / Defuse / Pickup spike |
| C / Q / E / X | Abilities |
| B / V | Buy menu / Chat |
| TAB | Scoreboard |
| I / P / K / L | Inventory / Battle Pass / Career / Leaderboard |
| ESC | Settings menu |
| Z / T / G / H | Pings |
| Q / E (po śmierci) | Spectator cycle |

## Chat commands

| Command | Akcja |
|---|---|
| `/dm` / `/dmexit` | Deathmatch mode |
| `/practice` / `/exit` | Practice range |
| `/aim` | Aim trainer (w practice) |
| `/host` / `/join CODE` / `/leave` | Custom lobby |
| `/addfriend NAME` / `/removefriend NAME` / `/friends` | Friend list |
| `/ff` / `/surrender` | Surrender vote |

## Production checklist

Przed publikacją gry:

### 1. Asset IDs
Podstaw realne Roblox asset IDs w:
- `src/server/MonetizationService.lua` — `DevProducts` (1000001-1000203) i `GamePasses` (2000001-2000004)
- `src/shared/SoundIds.lua` — sound assets per weapon/abilities
- `src/shared/SkinDatabase.lua` — mesh model IDs jeśli używasz custom meshów

Stwórz w Roblox Creator Dashboard:
- **Developer Products** (consumable purchases) — currency packs, cases, BP tier skips
- **Game Passes** (one-time permanent) — VIP, Inventory expansion, 2× Credits, Founder

### 2. ProfileService (zalecane dla produkcji)

`src/server/PlayerData.lua` to MVP wrapper na DataStoreService. Dla produkcji **zastąp ProfileService** od [madstudioroblox](https://github.com/MadStudioRoblox/ProfileService):
- Session locking — zapobiega item duplication via 2 servers
- Atomic writes — safer pod load
- GlobalUpdates — cross-server messaging

### 3. R15 character
Project ma już R15 ustawiony w `default.project.json`. To aktywuje **+42% DevEx boost** (April 2026 overhaul).

### 4. Content Maturity
Ustaw w Creator Dashboard:
- **Maturity: Mild** (cartoon stylization)
- **PolicyService** już zaimplementowany — UK <18 graczom auto-blokuje crates

### 5. PolicyService verification

W gotowej grze sprawdź czy `PolicyService.lua` correctly hides crate UI dla UK <18 (test z UK Roblox account).

### 6. R15 ready

Projekt jest ustawiony pod R15. Avatar customization gracza zachowuje się przez character.

### 7. Compliance UI

- Drop rates **widoczne przed zakupem** każdego case (mandatory by Roblox policy)
- **No real-money trading** — players nie mogą wymieniać skinów na Robux poza DevEx
- **No gambling-language** — "win/jackpot" zakazane

## Project structure

```
roblox_valorant/
├── default.project.json   # Rojo config
├── docs/
│   ├── VALORANT_REFERENCE.md  # Pełny raport researchu 1-97 sprintów
│   └── SETUP.md               # Ten plik
└── src/
    ├── shared/      # ReplicatedStorage.Shared (WeaponDatabase, AgentDatabase, etc)
    ├── server/      # ServerScriptService (CombatService, RoundManager, etc)
    └── client/      # StarterPlayerScripts (controllers)
```

## Troubleshooting

**Rojo connection failed:**
- Upewnij się że `rojo serve` działa
- Default port 34872 — możesz zmienić w `default.project.json`
- Firewall może blokować — sprawdź allow

**Skripty błędują w Studio:**
- Sprawdź F9 Output console
- Najczęstsze: brakujące asset IDs w MonetizationService → niewinne dla testu lokalnego

**Bots nie spawnują się:**
- BotManager spawnuje automatycznie żeby wypełnić 5v5 — sprawdź czy mapa ma SpawnLocations
- W rozgrywce z 1 graczem powinno być 9 botów (4 na drużynie attackers + 5 na defenders)

## Linki

- Roblox Studio: [create.roblox.com](https://create.roblox.com)
- Rojo docs: [rojo.space](https://rojo.space)
- ProfileService: [github.com/MadStudioRoblox/ProfileService](https://github.com/MadStudioRoblox/ProfileService)
- Valorant Wiki (research source): [valorant.fandom.com](https://valorant.fandom.com)
