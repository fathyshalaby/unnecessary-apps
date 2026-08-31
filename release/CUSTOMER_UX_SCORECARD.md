# Customer UX Scorecard — All 44 Apps

Acceptance criteria from a **customer** perspective. Mac verification still required for A11y (AX5) on device.

## The six tests

| # | Test | Question |
|---|------|----------|
| 1 | **3-second** | Can a stranger name the app’s purpose from screenshot 1? |
| 2 | **Thumb** | Is the primary action reachable without hunting? |
| 3 | **Payoff** | Does the result use a lane-appropriate reaction and readable explanation? |
| 4 | **Share** | Can ledger/receipt/court/generative apps export or copy in one tap? |
| 5 | **Return** | Does empty state or history give a reason to open again? |
| 6 | **Accessibility** | Does AX5 Dynamic Type + Reduce Motion + VoiceOver work on the primary path? |

**Legend:** Pass · Pending Mac verify (A11y)

## All 44 apps

| # | App | Share | Empty invite | Hero geometry | Boundary | A11y |
|---|-----|:-----:|:------------:|:-------------:|:--------:|:----:|
| 01 | Chair Finder | Pass | Pass | Pass | Pass | Mac |
| 02 | Bathroom Map | Partial | Pass | Pass | — | Mac |
| 03 | Do Not Text Them | Partial | — | Pass | — | Mac |
| 04 | Social Battery | Pass | Pass | Pass | Pass | Mac |
| 05 | Fridge Witness | Pass | Partial | Pass | Pass | Mac |
| 06 | Receipt Damage | Pass | Pass | Pass | Pass | Mac |
| 07 | Sock Tribunal | Pass | Pass | Pass | — | Mac |
| 08 | Plant Court | Pass | Pass | Pass | Pass | Mac |
| 09 | Laundry Mountain | Pass | Pass | Pass | — | Mac |
| 10 | What Was I Doing | Partial | Pass | Pass | — | Mac |
| 11 | Am I Early | Partial | Partial | Pass | — | Mac |
| 12 | Pigeon/Seagull | Pass | Pass | Pass | — | Mac |
| 13 | Toilet Timer | Partial | — | Pass | Pass | Mac |
| 14 | One More Episode | Pass | Partial | Pass | Pass | Mac |
| 15 | Wear Again | Partial | Partial | Pass | Pass | Mac |
| 16 | Microwave | Pass | Partial | Pass | — | Mac |
| 17 | Meeting Bingo | Pass | — | Pass | — | Mac |
| 18 | Tiny Gratitude | Partial | Pass | Pass | Pass | Mac |
| 19 | Medieval Advice | Pass | — | Pass | Pass | Mac |
| 20 | Real Email | Pass | Partial | Pass | — | Mac |
| 21 | Vibe Meter | Partial | Partial | Pass | — | Mac |
| 22 | Snack Roulette | Partial | Pass | Pass | — | Mac |
| 23 | Quiet Cafe | Partial | Pass | Pass | — | Mac |
| 24 | Dog Name Guesser | Pass | Pass | Pass | — | Mac |
| 25 | Waiting Room | Partial | Partial | Pass | — | Mac |
| 26 | Neighbor Noise | Partial | Partial | Partial | — | Mac |
| 27 | Tiny Museum | Pass | Pass | Pass | — | Mac |
| 28 | Overthinking | Pass | Partial | Pass | Pass | Mac |
| 29 | Bench Reviews | Partial | Pass | Pass | — | Mac |
| 30 | Apology Draft | Pass | Partial | Pass | Pass | Mac |
| 31 | Human GPS | Pass | Partial | Pass | — | Mac |
| 32 | Last Slice | Pass | Pass | Pass | — | Mac |
| 33 | Queue Personality | Pass | Pass | Pass | — | Mac |
| 34 | Weather Outfit | Pass | Partial | Pass | Pass | Mac |
| 35 | Door Was Push | Pass | Pass | Pass | — | Mac |
| 36 | Step Debt | Partial | Partial | Pass | Pass | Mac |
| 37 | Sleep Alibi | Partial | Partial | Pass | Pass | Mac |
| 38 | Heart Rate Email | Pass | Pass | Partial | Pass | Mac |
| 39 | Workout Excuse | Partial | Partial | Pass | Pass | Mac |
| 40 | Health Horoscope | Partial | Partial | Pass | Pass | Mac |
| 41 | Recovery Goblin | Partial | Partial | Pass | — | Mac |
| 42 | Walking Meeting | Pass | Pass | Pass | — | Mac |
| 43 | Hydration Narc | Partial | Partial | Pass | Pass | Mac |
| 44 | Rest Day Police | Partial | Partial | Pass | Pass | Mac |

**Partial share** = utility/journal apps where export is optional but primary payoff is private logging.

## Mac verification

```bash
zsh tools/run_all_apps_mac.sh
zsh tools/capture_all_apps_screenshots.sh
```

Run on your Mac before TestFlight. Cloud VM has no Xcode.

## App Store screenshot checklist (per app)

1. **Frame 1** — premise / joke visible in first viewport
2. **Frame 2** — core action (form, board, map, camera)
3. **Frame 3** — payoff (receipt, verdict, bingo line, timer readout)

Store captures in `build/QA/` after Mac run.
