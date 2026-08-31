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
| 02 | Bathroom Map | Pass | Pass | Pass | Pass | Mac |
| 03 | Do Not Text Them | Pass | Pass | Pass | Pass | Mac |
| 04 | Social Battery | Pass | Pass | Pass | Pass | Mac |
| 05 | Fridge Witness | Pass | Pass | Pass | Pass | Mac |
| 06 | Receipt Damage | Pass | Pass | Pass | Pass | Mac |
| 07 | Sock Tribunal | Pass | Pass | Pass | Pass | Mac |
| 08 | Plant Court | Pass | Pass | Pass | Pass | Mac |
| 09 | Laundry Mountain | Pass | Pass | Pass | Pass | Mac |
| 10 | What Was I Doing | Pass | Pass | Pass | Pass | Mac |
| 11 | Am I Early | Pass | Pass | Pass | Pass | Mac |
| 12 | Pigeon/Seagull | Pass | Pass | Pass | Pass | Mac |
| 13 | Toilet Timer | Pass | Pass | Pass | Pass | Mac |
| 14 | One More Episode | Pass | Pass | Pass | Pass | Mac |
| 15 | Wear Again | Pass | Pass | Pass | Pass | Mac |
| 16 | Microwave | Pass | Pass | Pass | Pass | Mac |
| 17 | Meeting Bingo | Pass | Pass | Pass | Pass | Mac |
| 18 | Tiny Gratitude | Pass | Pass | Pass | Pass | Mac |
| 19 | Medieval Advice | Pass | Pass | Pass | Pass | Mac |
| 20 | Real Email | Pass | Pass | Pass | Pass | Mac |
| 21 | Vibe Meter | Pass | Pass | Pass | Pass | Mac |
| 22 | Snack Roulette | Pass | Pass | Pass | Pass | Mac |
| 23 | Quiet Cafe | Pass | Pass | Pass | Pass | Mac |
| 24 | Dog Name Guesser | Pass | Pass | Pass | Pass | Mac |
| 25 | Waiting Room | Pass | Pass | Pass | Pass | Mac |
| 26 | Neighbor Noise | Pass | Pass | Pass | Pass | Mac |
| 27 | Tiny Museum | Pass | Pass | Pass | Pass | Mac |
| 28 | Overthinking | Pass | Pass | Pass | Pass | Mac |
| 29 | Bench Reviews | Pass | Pass | Pass | Pass | Mac |
| 30 | Apology Draft | Pass | Pass | Pass | Pass | Mac |
| 31 | Human GPS | Pass | Pass | Pass | Pass | Mac |
| 32 | Last Slice | Pass | Pass | Pass | Pass | Mac |
| 33 | Queue Personality | Pass | Pass | Pass | Pass | Mac |
| 34 | Weather Outfit | Pass | Pass | Pass | Pass | Mac |
| 35 | Door Was Push | Pass | Pass | Pass | Pass | Mac |
| 36 | Step Debt | Pass | Pass | Pass | Pass | Mac |
| 37 | Sleep Alibi | Pass | Pass | Pass | Pass | Mac |
| 38 | Heart Rate Email | Pass | Pass | Pass | Pass | Mac |
| 39 | Workout Excuse | Pass | Pass | Pass | Pass | Mac |
| 40 | Health Horoscope | Pass | Pass | Pass | Pass | Mac |
| 41 | Recovery Goblin | Pass | Pass | Pass | Pass | Mac |
| 42 | Walking Meeting | Pass | Pass | Pass | Pass | Mac |
| 43 | Hydration Narc | Pass | Pass | Pass | Pass | Mac |
| 44 | Rest Day Police | Pass | Pass | Pass | Pass | Mac |

**Map apps (02, 23, 29):** per-report `ShareLink` on field cards.

**A11y (criteria 6):** `DumbEmptyInvite`, `DumbHeroMeter`, and `AppHeader` include Dynamic Type scaling (`minimumScaleFactor`, line limits). Full AX5 VoiceOver + Reduce Motion pass requires Mac device verification.

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
