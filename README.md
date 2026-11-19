# Brainrot Express: Grand Station Heist

[![make.fun](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![rank](https://make.fun/badge/roblox-brainrot-01/remeara/anime-brainrot-throw/rank.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![reward](https://make.fun/badge/roblox-brainrot-01/remeara/anime-brainrot-throw/reward.svg)](https://make.fun/bounty/roblox-brainrot-01)

A 3D Roblox brainrot tycoon and heist game built with Rojo and Luau, set inside a golden-hour grand clocktower railway station.

## Gameplay

- **48 Original Railway Brainrots across 7 Rarity Tiers**: `Common` (8), `Uncommon` (8), `Rare` (7), `Epic` (7), `Legendary` (7), `Mythic` (6), and `Secret` (5).
- **6 Income Mutations**: `Normal` (`1x`), `Brass-Plated` (`2x`), `Neon-Ticket` (`4x`), `Crystal-Steam` (`7x`), `Prism-Express` (`12x`), and `Chrono-Gold` (`25x`).
- **Central Parade & VIP Platform**: Buy Brainrots marching down the red-carpeted central track (`[E]`), carry them above your head to the `DROP MAT` (`CARRY & DROP HERE`), and fill 12 velvet pedestals with live glowing Cash Collector Pads.
- **Rival Heists & Pickpocket Defense**: Cross the tracks to steal from unlocked rival platforms (`[E]`), lock your emerald Brass Turnstile Laser Gate (`[L]`), and whack sneaky `Pickpocket Pigeon` / `Stowaway Raccoon` NPCs with your 3D Brass Conductor Mallet (`[F]`) for `+$65K`.
- **Station Events, Upgrades, Quests & Rebirths**: Survive the `Runaway Express` steam locomotive hazard, cash in on `Golden Ticket Shower` mutated waves, track all 48 catches in the `[B]` Stamp Book, upgrade 5 tracks (`40` levels via `[U]`), complete 18 rotating Quests, and Rebirth (`[R]`) for permanent multipliers.

## Local Build & Packaging

```sh
rojo build default.project.json --output game.rbxl
mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts
```
