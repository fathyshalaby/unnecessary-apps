# Input / Output Usability Audit — All 44 Apps

Audit focus: how each app **collects input**, **validates** it, and **presents output** — including sticky vs scroll placement and stale-result behavior.

## Shared patterns

| Pattern | Apps | Input → Output flow |
|---------|------|---------------------|
| **Sticky action + result** | Most AppCanvas apps | Form in scroll; primary CTA + verdict in bottom bar |
| **Sticky action only** | 04, 06, 27, social/receipt ledgers | Result stays in scroll (receipt paper, placard) |
| **Live preview** | 11, 14, 16, 21, 25, 36 (progress card) | Sliders/dials update before tap |
| **Map + sheet** | 02, 23, 29 | Map tap → bottom sheet form → report cards |
| **Session swap** | 13, 03*, 42* | Bottom bar changes during active timer/walk |
| **Incremental ledger** | 10, 18, 43 | Each action appends; result confirms last action |

\* Fixed in usability pass (03 sticky intervention, 42 sticky finish/end).

## Severity summary

| Rating | Count | Meaning |
|--------|-------|---------|
| **Good** | 20 | Clear I/O, sticky primary action, invalidates stale output |
| **Minor** | 19 | Works but result below fold, or stale text until re-run |
| **Fixed this pass** | 5 | Compile blockers or critical UX gaps |

---

## Fixed this pass

| App | Issue | Fix |
|-----|-------|-----|
| **05** Fridge Witness | Migration syntax corruption | Restored action + result bottom bar |
| **30** Apology Draft | Migration syntax corruption | Restored layout; invalidate draft on crime/tone change |
| **03** Do Not Text Them | Primary action buried in scroll | Sticky cool-off CTA + status in bottom inset |
| **42** Walking Meeting | Finish/End early below fold during walk | Session bottom bar swaps to Finish / End early |
| **36** Step Debt | Stale invoice after step/goal edits | Invalidate sticky result when inputs change |

Additional stale-output fixes: **19**, **21**, **34**.

---

## Full app table

| # | App | Input | Output | Placement | Rating |
|---|-----|-------|--------|-----------|--------|
| 01 | Chair Finder | Sliders, name field, add chair | Rank verdict | Sticky bottom | Minor — stale verdict on slider edit; add chair also in card |
| 02 | Bathroom Map | Map tap, sheet sliders | Report cards | Scroll ledger | Good |
| 03 | Do Not Text Them | TextEditor draft | Countdown + status | Sticky bottom | Good (fixed) |
| 04 | Social Battery | Sliders, event name | Receipt paper | Scroll + sticky print | Good |
| 05 | Fridge Witness | Item name, qty, use-by | Witness statement | Sticky bottom | Good (fixed) |
| 06 | Receipt Damage | Purchase fields | Damage receipt | Scroll + sticky issue | Good |
| 07 | Sock Tribunal | Case filing form | Court order | Scroll | Minor — latest order below history |
| 08 | Plant Court | Plant care form | Court order | Scroll | Minor |
| 09 | Laundry Mountain | Batch editor | Expedition ticket | Scroll | Minor |
| 10 | What Was I Doing | Context + note | Log entry | Scroll + sticky forgot | Minor — journal pattern OK |
| 11 | Am I Early | Occasion + minutes | Meter + verdict | Sticky bottom | Good |
| 12 | Pigeon/Seagull | Photo + toggles | Bird ruling | Sticky bottom | Good |
| 13 | Toilet Timer | Mode + manual min | Live timer | Sticky start/stop | Good |
| 14 | One More Episode | Episode sliders | Sleep forecast | Sticky + scroll receipt | Good |
| 15 | Wear Again | Wear toggles | Closet ruling | Sticky bottom | Good |
| 16 | Microwave | Time/wattage | Converted time | Sticky bottom | Good — live invalidation |
| 17 | Meeting Bingo | Tap grid cells | Bingo line | In-grid result | Good |
| 18 | Tiny Gratitude | Entry + kind | Archive confirm | Sticky bottom | Good |
| 19 | Medieval Advice | Question field | Peasant answer | Sticky bottom | Good (fixed invalidation) |
| 20 | Real Email | Paste editor | Fog autopsy | Scroll metrics + sticky autopsy | Good |
| 21 | Vibe Meter | Plant/lamp sliders | Live gauge + text | Sticky bottom | Good (fixed text invalidation) |
| 22 | Snack Roulette | Comma snacks | Spin result | Scroll + sticky spin | Minor — result mid-scroll |
| 23 | Quiet Cafe | Map + search | Review cards | Map sheet | Good |
| 24 | Dog Name Guesser | Photo + guess | Name verdict | Sticky bottom | Minor — stale on slider edit |
| 25 | Waiting Room | Minutes slider | Live dial + quip | Sticky bottom | Good — live update |
| 26 | Neighbor Noise | Description + mic | Translation | Sticky bottom | Minor — stale on edit |
| 27 | Tiny Museum | Photo + story | Placard | Scroll + sticky open | Minor — photo optional |
| 28 | Overthinking | Evidence fields | Conclusion | Sticky bottom | Good |
| 29 | Bench Reviews | Map pin + sheet | Review cards | Map sheet | Good |
| 30 | Apology Draft | Crime + tone | Draft letter | Sticky bottom | Good (fixed) |
| 31 | Human GPS | Landmark field | Directions | Sticky bottom | Minor — stale directions |
| 32 | Last Slice | People roster | Tribunal ruling | Scroll | Minor — session taps in scroll |
| 33 | Queue Personality | Queue params | Personality ticket | Scroll + sticky start | Minor — active queue in scroll |
| 34 | Weather Outfit | Outfit + temp | Excuse | Sticky bottom | Good (fixed invalidation) |
| 35 | Door Was Push | Incident form | Report | Scroll + sticky file | Minor — report below history |
| 36 | Step Debt | Steps/goal/health | Invoice joke | Sticky bottom | Good (fixed) |
| 37 | Sleep Alibi | Hours + health | Alibi doc | Sticky bottom | Minor — stale alibi |
| 38 | Heart Rate Email | Subject + BPM | Drama score | Sticky bottom | Good |
| 39 | Workout Excuse | Excuse + minutes | Verdict | Sticky bottom | Minor — stale verdict |
| 40 | Health Horoscope | Manual/health stats | Oracle | Sticky bottom | Minor — stale oracle |
| 41 | Recovery Goblin | Tired/sore sliders | Goblin reply | Sticky bottom | Minor — stale reply |
| 42 | Walking Meeting | Plan fields / checkpoints | Live timer + brief | Session sticky bar | Good (fixed) |
| 43 | Hydration Narc | Goal slider + log tap | Progress ring | Scroll + sticky log | Minor — incremental OK |
| 44 | Rest Day Police | Streak slider | Citation | Sticky bottom | Minor — stale citation |

---

## Cross-cutting recommendations

1. **Stale output** — When inputs change after a generated result, call `invalidate*()` (pattern in 04, 06, 14, 15, 16, 28, 30). Remaining: 01, 24, 26, 31, 37, 39–41, 44.
2. **Session apps** — Swap bottom bar when a session is active (13, 03, 42 are reference).
3. **Ledger apps** — Courtroom/receipt outputs intentionally live in scroll below history; consider pinning “latest ruling” card above archive.
4. **Mac verification** — Run `zsh tools/run_all_apps_mac.sh` after I/O changes; UI tests depend on preserved `accessibilityIdentifier`s.

---

## Input constraints (collection-wide)

- **DumbField** — max length, keyboard Done, trim on submit
- **Sliders** — labeled ranges, 44pt targets
- **Photo apps** — PhotosPicker + camera sheet; device banner when unavailable
- **Health apps** — Manual fallback always available; HealthKit optional
- **Map apps** — Crosshair + sheet; no live GPS required for core flow
