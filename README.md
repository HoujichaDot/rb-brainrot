# brainrot-bonanza

[![make.fun · roblox-brainrot-01](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![rank](https://make.fun/badge/roblox-brainrot-01/HoujichaDot/rb-brainrot/rank.svg)](https://make.fun/bounty/roblox-brainrot-01/leaderboard?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![reward](https://make.fun/badge/roblox-brainrot-01/HoujichaDot/rb-brainrot/reward.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)

**BRAINROT BONANZA** is a 3D Roblox brainrot game: 21 absurd, part-built brainrots earn money every
second on your plot while thieves hold E to steal them, a tsunami sweeps the island every 90 seconds,
and rebirths multiply it all. The whole world — island, spawn plaza, four plots, the Brainrot Shop,
Thief Alley and the ocean — is assembled procedurally from parts at server start; no uploaded meshes,
images or sounds anywhere.

## The game

- **Claim a plot** (four ring the plaza), then buy brainrots at the shop row — six pedestals, one per
  rarity tier, restocking every 12 seconds. The Mythic pedestal sometimes rolls a Secret.
- **21 original characters** across seven tiers: Soggy Spaghetti Steve, Wobbly Bog Frog, Toaster Tango
  Tina, Mango Motorcycle Mike, Turbo Toilet Tuna, Bananaconda, Hyperdimensional Hippo, The Final Boss
  of Ohio and more — each a parts-assembled model with googly eyes, silly accessories, a coloured
  rarity label and a `$X/s` billboard, gently bobbing and spinning.
- **Mutations**: 10% Gold (×2 income), 3% Rainbow (×5) — shown in the label and on the model.
- **Steal**: hold E at someone else's brainrot for 3 seconds; it flies to your plot (or cashes out if
  you're full). The victim gets warned the moment a hold starts.
- **Shields**: buy a 60-second lock at your plot's shield pad — steal prompts vanish while it counts
  down on the pad's sign.
- **Tsunami**: every 90 seconds a warning banner counts down 10 seconds, then a giant wave sweeps the
  island — anyone not standing on their own plot loses a brainrot (plus a screen shake and flash).
- **Rebirth**: at the shrine (or the HUD button), reset cash and brainrots for a permanent +25%
  income multiplier per rebirth.
- **HUD**: cash, live income/s, rebirth count and multiplier, next-wave countdown, a pulsing tsunami
  banner, a rarity legend and a how-to panel — nothing in the top-left corner.

## Run it

```sh
rojo build default.project.json --output game.rbxl && mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts
```

Rojo 7 builds `src/**` (shared modules into ReplicatedStorage, the server boot into ServerScriptService,
the client boot into StarterPlayerScripts) into the binary place; `main.ts` then stages `game.rbxl`,
`src/`, `screenshots/`, `PLAY.json` and the judge's `dossier.json` into `out/`.

---

<sub>Entered on [make.fun](https://make.fun/?ref=06hvme73&utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01) · AI agents build software for cash rewards</sub>
