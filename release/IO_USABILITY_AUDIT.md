# Input / Output Usability Audit — All 44 Apps

Audit focus: how each app **collects input**, **validates** it, and **presents output** — including sticky vs scroll placement and stale-result behavior.

**Status: all 44 apps rated Good** after the full I/O pass (Aug 2026).

## Shared patterns

| Pattern | Apps | Input → Output flow |
|---------|------|---------------------|
| **Sticky action + result** | Most AppCanvas apps | Form in scroll; primary CTA + verdict in bottom bar |
| **Sticky action only** | 04, 06, 27 | Result/receipt/placard in scroll; print/issue action sticky |
| **Live preview** | 11, 14, 16, 21, 25, 36 | Sliders/dials update before tap |
| **Map + sheet** | 02, 23, 29 | Map tap → bottom sheet form → report cards |
| **Session swap** | 03, 13, 32, 33, 42 | Bottom bar changes during active timer/walk/tribunal/queue |
| **Incremental ledger** | 10, 18, 43 | Each action appends; result confirms last action |
| **Ledger + pinned ruling** | 07, 08, 09, 35 | Latest court order/report card above archive |

## I/O quality rules (collection-wide)

1. **Primary action is sticky** — thumb-reachable via `AppCanvas` bottom bar or `safeAreaInset`.
2. **Output invalidates on input change** — editing after a generated result shows “run again” copy, not a stale verdict.
3. **Session apps swap the bottom bar** — start/stop, pass/award, finish/end, person served/reached front.
4. **Results visible without hunting** — spin/game results in bottom bar; ledger rulings above history.
5. **Constraints preserved** — `DumbField` max lengths, empty-state hints, 44pt targets, `accessibilityIdentifier`s.

## Full app table

| # | App | Input | Output | Placement |
|---|-----|-------|--------|-----------|
| 01 | Chair Finder | Sliders + add chair | Rank verdict | Sticky; invalidates on edit |
| 02 | Bathroom Map | Map tap + sheet | Report cards | Map ledger |
| 03 | Do Not Text Them | TextEditor draft | Countdown + status | Sticky intervention bar |
| 04 | Social Battery | Sliders + event | Receipt paper | Scroll + sticky print |
| 05 | Fridge Witness | Item fields | Witness statement | Sticky action + result |
| 06 | Receipt Damage | Purchase fields | Damage receipt | Scroll + sticky issue |
| 07 | Sock Tribunal | Case filing | Court order | Order card above docket |
| 08 | Plant Court | Plant filing | Care order | Order card above docket |
| 09 | Laundry Mountain | Batch editor | Expedition ticket | Ticket above queue |
| 10 | What Was I Doing | Context + note | Log entry | Scroll + sticky forgot |
| 11 | Am I Early | Occasion + minutes | Meter + verdict | Sticky bottom |
| 12 | Pigeon/Seagull | Photo + toggles | Bird ruling | Sticky bottom |
| 13 | Toilet Timer | Mode + manual min | Live timer | Sticky start/stop |
| 14 | One More Episode | Episode sliders | Sleep forecast | Sticky + scroll receipt |
| 15 | Wear Again | Wear toggles | Closet ruling | Sticky bottom |
| 16 | Microwave | Time/wattage | Converted time | Sticky; live invalidation |
| 17 | Meeting Bingo | Tap grid | Bingo line | In-grid result |
| 18 | Tiny Gratitude | Entry + kind | Archive confirm | Sticky bottom |
| 19 | Medieval Advice | Question | Peasant answer | Sticky; invalidates |
| 20 | Real Email | Paste editor | Fog autopsy | Scroll + sticky autopsy |
| 21 | Vibe Meter | Sliders | Live gauge + text | Sticky; invalidates |
| 22 | Snack Roulette | Pantry list | Spin result | Sticky result + spin |
| 23 | Quiet Cafe | Map + search | Review cards | Map sheet |
| 24 | Dog Name Guesser | Photo + sliders | Name verdict | Sticky; invalidates |
| 25 | Waiting Room | Minutes slider | Live dial + quip | Sticky; live update |
| 26 | Neighbor Noise | Mic + description | Translation | Sticky; invalidates |
| 27 | Tiny Museum | Photo + story | Placard | Scroll + sticky open |
| 28 | Overthinking | Evidence fields | Conclusion | Sticky bottom |
| 29 | Bench Reviews | Map pin + sheet | Review cards | Map sheet |
| 30 | Apology Draft | Crime + tone | Draft letter | Sticky; invalidates |
| 31 | Human GPS | Landmark | Directions | Sticky; invalidates |
| 32 | Last Slice | People roster | Tribunal ruling | Sticky pass/award during session |
| 33 | Queue Personality | Queue params | Personality ticket | Sticky served/front/leave during session |
| 34 | Weather Outfit | Outfit + temp | Excuse | Sticky; invalidates |
| 35 | Door Was Push | Incident form | Report | Report above history |
| 36 | Step Debt | Steps/goal/health | Invoice joke | Sticky; invalidates |
| 37 | Sleep Alibi | Hours + health | Alibi doc | Sticky; invalidates |
| 38 | Heart Rate Email | Subject + BPM | Drama score | Sticky bottom |
| 39 | Workout Excuse | Excuse + minutes | Verdict | Sticky; invalidates |
| 40 | Health Horoscope | Manual/health | Oracle | Sticky; invalidates |
| 41 | Recovery Goblin | Tired/sore sliders | Goblin reply | Sticky; invalidates |
| 42 | Walking Meeting | Plan / checkpoints | Live timer + brief | Session sticky finish/end |
| 43 | Hydration Narc | Goal + log tap | Progress ring | Incremental ledger |
| 44 | Rest Day Police | Streak slider | Citation | Sticky; invalidates |

## Mac verification

```bash
zsh tools/run_all_apps_mac.sh
zsh tools/capture_all_apps_screenshots.sh
```

## Changelog

- **Pass 1** — Fixed compile corruption (05, 30), sticky intervention (03), walking session bar (42), step debt invalidation (36).
- **Pass 2** — Stale-output invalidation for all remaining generator/meter apps; snack result to bottom bar; tribunal and queue session bars (32, 33).
