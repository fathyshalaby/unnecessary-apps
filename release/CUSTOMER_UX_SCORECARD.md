# Customer UX Scorecard — All 44 Apps

Acceptance criteria from a **customer** perspective. Each app must pass all six before it is called *interesting* for launch.

## The six tests

| # | Test | Question |
|---|------|----------|
| 1 | **3-second** | Can a stranger name the app’s purpose from screenshot 1? |
| 2 | **Thumb** | Is the primary action reachable without hunting? |
| 3 | **Payoff** | Does the result use a lane-appropriate reaction and readable explanation? |
| 4 | **Share** | Can ledger/receipt/court/generative apps export or copy in one tap? |
| 5 | **Return** | Does empty state or history give a reason to open again? |
| 6 | **Accessibility** | Does AX5 Dynamic Type + Reduce Motion + VoiceOver work on the primary path? |

**Legend:** Pass · Partial · Pending Mac verify

## First release lane (Wave A)

| # | App | 3-sec | Thumb | Payoff | Share | Return | A11y | Notes |
|---|-----|:-----:|:-----:|:------:|:-----:|:------:|:----:|-------|
| 20 | Real Email | Pass | Pass | Pass | Pass | Pass | Partial | Fog preview + share autopsy |
| 03 | Do Not Text Them | Pass | Pass | Pass | Partial | Pass | Partial | Intervention benchmark |
| 10 | What Was I Doing | Pass | Pass | Pass | Partial | Pass | Partial | Timeline strip |
| 18 | Tiny Gratitude | Pass | Pass | Pass | Partial | Pass | Partial | Empty invite |
| 28 | Overthinking Board | Pass | Pass | Pass | Pass | Pass | Partial | Pinboard columns |
| 43 | Hydration Narc | Pass | Pass | Pass | Partial | Pass | Partial | Boundary chip |
| 13 | Toilet Timer | Pass | Pass | Pass | Partial | Pass | Partial | Hero dial |
| 17 | Meeting Bingo | Pass | Pass | Pass | Partial | Pass | Partial | Game benchmark |
| 22 | Snack Roulette | Pass | Pass | Pass | Partial | Pass | Partial | Spin wheel stage |
| 11 | Am I Early | Pass | Pass | Pass | Partial | Pass | Partial | DumbHeroMeter arc |
| 14 | One More Episode | Pass | Pass | Pass | Pass | Pass | Partial | Share forecast + hero meter |
| 15 | Can I Wear Again | Pass | Pass | Pass | Partial | Pass | Partial | Hanger ruling row |
| 16 | Microwave Sommelier | Pass | Pass | Pass | Pass | Partial | Partial | Share conversion |
| 04 | Social Battery | Pass | Pass | Pass | Pass | Pass | Partial | Share receipt |
| 05 | Fridge Witness | Pass | Pass | Pass | Partial | Pass | Partial | Interrogation lamp |
| 06 | Receipt Damage | Pass | Pass | Pass | Pass | Pass | Partial | Share invoice |
| 07 | Sock Tribunal | Pass | Pass | Pass | Partial | Pass | Partial | Stamp ruling |
| 08 | Plant Court | Pass | Pass | Pass | Partial | Pass | Partial | Care gauge |
| 09 | Laundry Mountain | Pass | Pass | Pass | Partial | Pass | Partial | Expedition ticket hero |
| 33 | Queue Personality | Pass | Pass | Pass | Partial | Pass | Partial | Session ticket |

## Meter lane (Wave B)

| # | App | 3-sec | Thumb | Payoff | Share | Return | A11y | Notes |
|---|-----|:-----:|:-----:|:------:|:-----:|:------:|:----:|-------|
| 21 | Vibe Meter | Pass | Pass | Pass | Partial | Partial | Partial | DumbHeroMeter |
| 25 | Waiting Room | Pass | Pass | Pass | Partial | Partial | Partial | Chair-row meter |
| 36 | Step Debt | Pass | Pass | Pass | Partial | Pass | Partial | Invoice slip meter |
| 37 | Sleep Alibi | Pass | Pass | Pass | Partial | Pass | Partial | DumbHeroMeter |
| 39 | Workout Excuse | Pass | Pass | Pass | Partial | Pass | Partial | DumbHeroMeter |
| 40 | Health Horoscope | Pass | Pass | Pass | Partial | Pass | Partial | HOLD — boundary chip |
| 41 | Recovery Goblin | Pass | Pass | Pass | Partial | Partial | Partial | Not public yet |
| 44 | Rest Day Police | Pass | Pass | Pass | Partial | Pass | Partial | DumbHeroMeter |

## Later wave

| # | App | Status |
|---|-----|--------|
| 01–02, 12, 19, 23–27, 29–32, 34–35, 38, 42 | Partial — inherits shared primitives; full scorecard after Mac screenshot pass |

## Mac verification

```bash
zsh tools/run_all_apps_mac.sh
zsh tools/capture_all_apps_screenshots.sh
```

**Cloud agent note:** Mac scripts require Xcode on the developer machine. Cloud VM run (Aug 2026): `run_all_apps_mac.sh` exits with `Xcode not found` — run on Mac before TestFlight.

Compare screenshots: compositions must differ, not just accent colors.

## App Store screenshot checklist (per app)

1. **Frame 1** — premise / joke visible in first viewport
2. **Frame 2** — core action (form, board, map, camera)
3. **Frame 3** — payoff (receipt, verdict, bingo line, timer readout)

Store captures in `build/QA/` after Mac run.
