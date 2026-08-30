# Top 10 viral UX audit

Date: 28 August 2026  
Device: iPhone 16e simulator, iOS 26.2  
Standard: understandable in one second, filmable payoff, real repeat use, and an
honest local or native capability.

## Verdict

The visual system is now distinctive enough to launch: oversized headlines,
warm paper backgrounds, one loud department color, absurd civil-service copy,
and a different mascot for every app. The flagship roots now have bespoke
interaction geometry as well: camera stage, scanner, decision grid, filing
desk, tone chips, oracle desk, and board-first game screen. The shared kit is
still engineering infrastructure, not the identity of each product.

The launch ten below all build and run. Ten focused end-to-end UI tests pass
with zero failures and zero skips across these ten apps.

## Ranked release ten

| Rank | App | Viral hook | Retention loop | UX verdict |
|---:|---|---|---|---|
| 1 | Dog Name Guesser | Point the app at any dog and argue with the name | New dog/photo, local Vision labels, adjustable naming persona | Lead pilot. The first content block is now a camera evidence stage with an optional local Vision finding. |
| 2 | Pigeon or Seagull? | Street-level species argument plus lunch theft | New bird/photo, on-device Vision, manual comedy fallback | Best instant interaction. The scanner frame makes the photo payoff legible before the manual checklist. |
| 3 | The Door Was Push | Physical embarrassment with a perfect mascot reaction | Private incident log, attempts, signage pattern, correction and deletion | Strongest tactile screen: type the place, tap the direction, file the witness report. |
| 4 | Receipt Emotional Damage | A screenshotable emotional invoice | Real cost-per-use arithmetic, private ledger, reminders and deletion | The first content block is now the evidence form; filing, receipt, explanation, and ledger follow in that order. |
| 5 | Meeting Bingo for One | Viewers instantly recognize every square | Randomized board, persistent marks, completed-game count | Best game screen. No onboarding needed; the board is the tutorial. |
| 6 | Sock Tribunal | A real missing sock becomes a court case | Case aging, evidence, reminders, reunion/unsolved outcomes | The docket now opens on the filing desk; rules and totals are supporting context after the useful action. |
| 7 | Apology Draft Generator | Followers submit tiny crimes | On-device generation on supported hardware, local fallback, copyable drafts | Direct tone chips make the composer feel like a toy, and the action label mirrors the chosen voice. |
| 8 | Plant Court | A plant files a case against its owner | Private care docket, watering history, due dates, reminders | The care editor now arrives before rules and totals, so the user can record a real plant immediately. |
| 9 | Medieval Peasant Advice | Modern problem, wildly unqualified medieval answer | On-device generation on supported hardware, deterministic local fallback | The village desk turns the prompt into a character moment while keeping the safety boundary beside it. |
| 10 | Laundry Mountain | Turn a pile into an expedition | Multi-load stages, editable timers, reminders and persistent progress | The batch plan is now the first task; the expedition ticket, rules, totals, and queue follow the filing path. |

## Mean findings and fixes

- Dog Name Guesser and Pigeon or Seagull presented their photo pickers like blue
  headings. They now open on dedicated camera/scanner stages with obvious
  library and camera actions, target framing, accessibility identifiers, and
  privacy hints.
- Receipt Damage, Sock Tribunal, Plant Court, and Laundry Mountain previously
  made users pass rules and totals before the useful action. Their roots now
  lead with evidence, filing, or planning and push explanation below the first
  decision.
- The Door Was Push previously had the right content but a long vertical list;
  its push/pull evidence is now a large visual choice grid while the original
  identifiers and slider details remain intact.
- Apology Draft Generator and Medieval Advice previously shared a generic
  input → button rhythm; direct tone chips and the “village desk” now make the
  two generative products feel like different toys.
- Recovery Goblin is lovable but not ready for this ten. Two sliders and a one-line
  answer are a social filter, not a durable app. It returns only after it gains a
  recovery plan, history, reminders, and a meaningful next-day loop.
- The shared family resemblance is strong, but future passes should make the
  interaction geometry more unique—not merely swap colors and mascots. Meeting
  Bingo and Door Was Push are the benchmark because their core screen cannot be
  mistaken for another app.

## Verification evidence

Fresh native simulator results after the geometry pass:

- `VisionComedyUITests`: 2 passed — Dog Name Guesser and Pigeon or Seagull
- `PurchaseLedgerUITests`: 1 passed — Receipt Emotional Damage
- `DoorIncidentLogUITests`: 1 passed — The Door Was Push
- `MeetingBingoUITests`: 1 passed — Meeting Bingo for One
- `SockDocketUITests`: 1 passed — Sock Tribunal
- `PlantCareUITests`: 1 passed — Plant Court
- `LaundryQueueUITests`: 1 passed — Laundry Mountain
- `GenerativeAppsUITests`: 2 passed — Apology Draft and Medieval Peasant Advice

Total: 10 passed, 0 failed, 0 skipped. Result bundles are in `build/Results/`;
fresh launch captures for all ten are in `build/QA/`.

## TestFlight decision

The first audited internal lane now includes Do Not Text Them Build 3, Dog Name
Guesser Build 6, Step Debt Build 1, Sleep Alibi Build 1, and Workout Excuse
Build 1. Project generation reads persistent build numbers from
`config/build-numbers.json`; App24's next build must therefore be greater than 6.
The other top-ten apps should enter internal TestFlight after their
individual App Store Connect records exist. Public App Store submissions should
still be staggered to reduce minimum-functionality/spam review risk.
