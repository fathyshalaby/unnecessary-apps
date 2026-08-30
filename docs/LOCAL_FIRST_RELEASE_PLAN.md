# Local-First Release Plan

Date: 28 August 2026

## Product rule

An app is not considered implemented because it launches or changes a result label. A release candidate must have:

1. A complete primary loop with useful input, output, reset, and error handling.
2. Local persistence for user-created history, counters, or preferences when losing them would be surprising.
3. Honest privacy copy and no implied data source that is not actually connected.
4. Background and relaunch behavior appropriate to the feature.
5. Accessibility identifiers on the primary flow.
6. A simulator acceptance pass covering the real user journey.

## Audit result

At the start of this pass, most of the 44 active compilable targets were prototypes.
Many now have honest local/manual loops, but manual or seeded behavior is not
automatically a release candidate. The canonical no-dummy release order is in
release/RELEASE_ORDER.md; native Vision, HealthKit, PhotosPicker, and
Foundation Models are admitted only where they are actually implemented. The
release generator also includes a required-reason privacy manifest for
targets that use app-private UserDefaults.

## Local-only priority

| Priority | App | Why it should ship early | End-to-end work |
| ---: | --- | --- | --- |
| 1 | Do Not Text Them | Strong utility, social hook, no account or network | Background-safe deadline countdown, optional generic local completion alert, private in-memory draft, persistent rescue counters, complete deletion flow |
| 2 | What Was I Doing? | Tiny interruption journal with useful pattern evidence | Persist timestamped context categories and optional mission notes, summarize the most common context, and support individual, today-only, and complete deletion |
| 3 | Meeting Bingo for One | Real repeatable gameplay | Full bingo board, randomized cards, persisted active game, win state, reset |
| 4 | Hydration Narc | Useful manual daily tracker with no permission burden | User-chosen serving goal, quick log and undo, report persistence, tested day rollover into a seven-day ledger, and confirmed today-only reset |
| 5 | Is This a Real Email? | Useful local text analysis and strong office hook | Exact phrase analysis, deterministic clarity score, action/deadline signals, concrete surgery plan |
| 6 | Tiny Gratitude | Small journal with no infrastructure | Categorized dated entries, today/total/day summaries, browseable bounded archive, resurfacing, individual deletion, and confirmed erase-all |
| 7 | Snack Roulette | Clear local decision utility | Saved pantry list, validation, non-repeating spins, history |
| 8 | Apology Draft Generator | Private generative writing with a deterministic fallback | Apple Foundation Models when available, tone controls, validation, clipboard copy, reset |

## Wave 1 implementation status

The following eight targets now have real local product loops rather than placeholder result labels:

| App | Implemented behavior | Evidence | Remaining sign-off |
| --- | --- | --- | --- |
| Do Not Text Them | Background-safe deadline cool-off, optional generic local completion alert, private in-memory draft, persistent counters, delete flow | Simulator build + passing UI test + unsigned Release archive | Physical-device notification/background smoke pass, light/dark/large-text pass, and Apple signing |
| What Was I Doing? | Timestamped context-and-note archive, today/total counts, most-common context, relaunch persistence, individual deletion, erase-today, and confirmed erase-all | Focused Simulator UI journey + visual QA + unsigned Release archive | Apple signing and large-text/dark-mode smoke pass |
| Meeting Bingo for One | Randomized 3×3 board, free space, all eight winning lines, once-per-board win invariant, persisted board/marks/win state/statistics, confirmed complete erasure | Focused complete-game Simulator journey + visual QA + unsigned Release archive | Apple signing and large-text/dark-mode smoke pass |
| Hydration Narc | Manual serving log, user-chosen 1–16 goal, one-tap increment/undo, report persistence, automatic rollover, seven-day summaries, confirmed today-only reset | Focused two-day Simulator UI journey + visual QA + unsigned Release archive | Apple signing and large-text/dark-mode smoke pass |
| Tiny Gratitude | Categorized local journal, today/total/day summary, five-entry preview plus full browsing, 100-entry cap, random resurfacing, individual deletion, and confirmed erase-all | Focused Simulator UI journey + visual QA + unsigned Release archive | Apple signing and large-text/dark-mode smoke pass |
| Snack Roulette | Empty user-owned pantry, trimmed/case-insensitive deduplication, guaranteed immediate-repeat avoidance when possible, browseable 20-spin history, granular deletion, confirmed pantry-plus-history erasure | Focused Simulator pantry journey + visual QA + unsigned Release archive | Apple signing and large-text/dark-mode smoke pass |
| Is This a Real Email? | Exact-token fog analysis, deterministic clarity score, action/deadline signals, concrete surgery plan, 5,000-character cap, no email persistence | Focused Simulator UI journey + visual QA + unsigned Release archive | Apple signing and large-text/dark-mode smoke pass |
| Apology Draft Generator | Validated input, Apple Foundation Models when available, deterministic tone fallback, clipboard copy, reset | Simulator build + settled launch screen | Direct typing/tone/generate/copy test |

All eight have no backend, account, analytics, ads, or network permission.
App03, App10, App18, and App20 now have focused passing XCTest UI flows and
unsigned Release archives. The other four remain pending their direct interactive
acceptance passes.

## Wave 2 implementation status

Six additional offline targets now have real persisted loops and settled simulator screens:

| App | Implemented behavior | Remaining sign-off |
| --- | --- | --- |
| Social Battery Receipt | Optional event context, exact signed before/after energy change, duration and people context, drain/recharge/break-even paths, 30-record private history, event/time/average summaries, granular deletion, current reset, and confirmed complete erasure | Focused Simulator journey, visual QA, and unsigned Release archive complete; Apple signing and large-text/dark-mode smoke pass remain |
| Fridge Witness | Zero-seed user-owned inventory, quantity and optional use-by reminders, case-insensitive merge, item/unit/attention summaries, truthful overdue/due-soon interrogation, use-one decrement, row removal, and confirmed complete erasure | Focused Simulator journey, visual QA, and unsigned Release archive complete; Apple signing, physical-device notification sign-off, and large-text/dark-mode smoke pass remain |
| Receipt Emotional Damage | Exact amount/category/intended-use inputs, published cost-per-use formula, 50-entry private ledger, planned/impulse summaries, granular deletion/reset/erase, and optional one-shot local review reminders | Focused Simulator journey, visual QA, and unsigned Release archive complete; Apple signing and physical-device notification-permission smoke pass remain |
| Sock Tribunal | Zero-seed 75-case private docket, exact missing-since dates, color/pattern/location evidence, open/reunited/unsolved states, reopening, summaries, deletion/erase controls, and optional quiet-hours-aware one-shot rechecks | Focused Simulator journey, visual QA, and unsigned Release archive complete; Apple signing and physical-device notification-permission smoke pass remain |
| Plant Court | Zero-seed 50-plant private care docket, transparent last-watered + user-interval arithmetic, user condition observation, due-first ordering, 50-entry-per-plant watering history, editing, “Watered now,” deletion/erase controls, and optional quiet-hours-aware care reminders | Focused Simulator journey, visual QA, and unsigned Release archive complete; Apple signing and physical-device notification-permission smoke pass remain |
| Laundry Mountain | Zero-seed 50-batch private queue, five explicit manual stages, multi-load completion, active/remaining/finished summaries, editable user wash/dry expectations, stage correction, reopening, deletion/erase controls, and optional quiet-hours-aware stage reminders | Focused Simulator journey, visual QA, and unsigned Release archive complete; Apple signing and physical-device notification-permission smoke pass remain |

Wave 2 also has no backend, account, analytics, ads, or network permission. Plant Court is explicitly manual and makes no sensor, camera, HealthKit, weather, identification, or horticultural-advice claim.

## Wave 3 implementation status

Six more local-only targets now have persisted inputs/results, reset flows, and settled simulator screens:

| App | Implemented behavior | Remaining sign-off |
| --- | --- | --- |
| Am I Early? | Persisted signed offset and optional occasion, five transparent verdict levels, 30-record private history, filed/not-late/late summaries, full browsing, granular deletion, current reset, confirmed complete erasure | Focused early/late Simulator journey + visual QA + unsigned Release archive; Apple signing and large-text/dark-mode smoke pass remain |
| Toilet Timer | Relaunch-safe elapsed timer, optional 5/10/15/20-minute local notifications, Lock Screen/Dynamic Island Live Activity, independently actionable manual estimate, local assessment, 20-session private history, granular deletion, current-session reset, and confirmed history erasure | Focused lifecycle, notification, and Live Activity Simulator test + visual QA + unsigned Release archive; Apple distribution signing and physical-device smoke pass remain |
| One More Episode? | Exact minute-based watch forecast from 1–8 episodes, 15–120 minute runtime, and user-chosen 4–12 hour sleep budget; published non-medical assumption, optional show name, 20-record private history, granular deletion, current reset, and confirmed complete erasure | Focused boundary-value Simulator journey + visual QA + unsigned Release archive; Apple signing and large-text/dark-mode smoke pass remain |
| Can I Wear This Again? | User-defined maximum wears, completed-wear count, explicit odor/stain/sweaty-wear evidence, separate social-repeat context, 30-record private ruling history, approved/laundry summary, granular deletion, current reset, and confirmed complete erasure | Focused approved/limit/condition Simulator journey + visual QA + unsigned Release archive; Apple signing and large-text/dark-mode smoke pass remain |
| Microwave Sommelier | Published proportional wattage formula, explicit package minutes/seconds and source/target wattages, five-second rounding, 80% first checkpoint, 20-record private conversion history, granular deletion, current reset, and confirmed complete erasure | Focused 800 W/500 W boundary conversion journey + visual QA + unsigned Release archive; Apple signing and large-text/dark-mode smoke pass remain |
| Medieval Peasant Advice | Bounded persisted question, Apple Foundation Models when available, deterministic fallback, empty handling, reset | Direct typing/advice/reset tap-through |

Wave 3 does not connect to streaming, appliances, sensors, or a cloud AI
service. Medieval Advice is the deliberate on-device Foundation Models
exception and states its availability/fallback boundary in the UI and README.

## Wave 4 implementation status

Six more local-only targets now have complete manual inputs, deterministic outputs, persisted state, reset flows, and settled simulator screens:

| App | Implemented behavior | Remaining sign-off |
| --- | --- | --- |
| The Vibe Meter | Persisted room-vibe inputs, visible score, deterministic ruling, reset | Direct toggle/measurement/reset tap-through |
| Waiting Room Simulator | Persisted wait duration, five-minute extension control, local forecast, reset | Direct slider/extension/reset tap-through |
| Overthinking Evidence Board | Persisted structured draft, supporting/counter-evidence, alternative explanation, small next step, transparent non-diagnostic status, bounded private case archive, granular deletion | Focused Simulator UI journey + visual QA + unsigned Release archive; Apple signing and large-text/dark-mode smoke pass remain |
| Human GPS | Persisted manual landmark, deterministic walking directions, reset | Direct typing/directions/reset tap-through |
| The Last Slice | Zero-seed 50-ruling private fairness ledger, 2–20-person trimmed/deduplicated roster, published fewest-prior-awards selection, tie-only local randomness, pass/all-pass handling, relaunch-safe active ruling, exact summaries, granular deletion, and confirmed erasure | Focused Simulator fairness journey, visual QA, and unsigned Release archive complete; Apple signing and large-text/dark-mode smoke pass remain |
| Queue Personality Test | Zero-seed 50-session private wait log, named active queue, relaunch-safe elapsed timer, published fallback/observed-throughput ETA, exact served/joined/correction actions, reached-front/left outcomes, summaries, deletion/erase controls, and optional quiet-hours-aware estimated-turn checkpoint | Focused Simulator journey, visual QA, and unsigned Release archive complete; Apple signing, deep-link, and physical-device notification-permission smoke pass remain |

Wave 4 is deliberately honest about its boundaries: it uses no location, camera, contacts, network, account, analytics, ads, or external AI service. Human GPS is a manual joke, not a location-services feature.

## Wave 5 implementation status

Eight more offline targets now have persisted inputs/results, complete reset flows, and settled simulator screens:

| App | Implemented behavior | Remaining sign-off |
| --- | --- | --- |
| Weather Outfit Excuse | Persisted outfit/temperature inputs, validation, local defense generation, reset | Direct typing/temperature/generation tap-through |
| The Door Was Push | Zero-seed 75-case private door log with actual place, three mistake directions, 1–8 wrong attempts, 1–5 self-reported sign clarity, optional note, exact summaries, most-common pattern, correction without duplication, granular deletion, and confirmed erasure | Focused Simulator persistence/edit/erase journey, visual QA, and unsigned Release archive complete; Apple signing and large-text/dark-mode smoke pass remain |
| Step Debt | Optional read-only Apple Health step count, manual fallback, fictional invoice, reset | Physical-device successful-read/denial smoke pass |
| Sleep Alibi | Optional read-only Apple Health sleep samples, manual fallback, deterministic alibi, reset | Physical-device successful-read/denial smoke pass |
| Workout Excuse Detector | Optional read-only Apple Health workout durations, manual fallback, local audit, empty handling, reset | Physical-device successful-read/denial smoke pass |
| The Recovery Goblin | Persisted tiredness/soreness check-in, local ruling, reset | Direct sliders/ruling/reset tap-through |
| Walking Meeting Escape Plan | Persisted duration, deterministic exit plan, reset | Direct slider/plan/reset tap-through |
| Rest Day Police | Persisted manual training streak, fictional citation, reset | Direct slider/citation/reset tap-through |

Wave 5 does not connect to WeatherKit, workout services, calendars, location, accounts, analytics, ads, or a network. Step Debt, Sleep Alibi, and Workout Excuse Detector are the explicit read-only HealthKit exemplars; each keeps a manual fallback and visible permission boundary. The remaining manual boundaries are visible in the UI where a user might otherwise infer a real data source.

## Final local/manual implementation status

The remaining eleven targets now have honest local loops and current simulator/device build evidence:

| App | Current shipped behavior | Future capability, if desired |
| --- | --- | --- |
| Chair Finder | User-created private chair observations, multi-factor ranking, relaunch persistence, individual deletion, and confirmed clear-all | Optional MapKit only if users later ask for shared place discovery |
| Public Bathroom Quality Map | Apple MapKit restroom search, manual map-pin fallback, optional When In Use recentering, and a persistent private multi-factor report ledger | Optional moderated public/community reports only if users ask for them |
| Pigeon or Seagull | PhotosPicker plus on-device Vision labels with manual checklist fallback; simulator capability limitation is labeled | Optional species-specific model refinement; no cloud upload |
| Quiet Café Index | Apple MapKit café search, manual map-pin fallback, optional When In Use recentering, and a persistent private multi-factor rating ledger | Optional public/community layer only if users ask for it |
| Dog Name Guesser | Optional PhotosPicker image and on-device Vision labels/name proposal plus manual traits; simulator capability limitation is labeled | Optional breed refinement with a custom on-device model; no cloud upload |
| Neighbor Noise Translator | Two-second local microphone level measurement with typed-description fallback | Physical-device microphone permission and audio-level acceptance pass |
| Tiny Personal Museum | Up to 30 private exhibits with stories, placards, optional protected photos, relaunch persistence, individual deletion, and confirmed complete erasure | Optional opt-in cross-device sync only if users ask for it |
| Local Bench Reviews | Apple MapKit, map-center pinning, optional When In Use recentering, and a persistent private bench ledger | Optional public/community layer only if users ask for it |
| Heart Rate During Email | Manual BPM drama log | Explicit HealthKit authorization and privacy review |
| Health Data Horoscope | Manual entertainment numbers | Optional HealthKit read-only import |

These remain local/manual or capability-limited products; they are not all
first-wave submission candidates. The future-capability column is deliberately
not represented as connected functionality unless the current behavior column
says it is implemented.

## Deferred until real capabilities exist

- Live background location, WeatherKit, and remote AI are future expansions only.
  Dog Name Guesser and Pigeon or Seagull offer user-selected PhotosPicker
  input and on-device Vision labels without upload; Step Debt offers optional
  read-only HealthKit steps; Medieval Advice offers optional on-device
  Foundation Models; Public Bathroom Quality Map, Quiet Café Index, and Local
  Bench Reviews offer Apple MapKit with optional foreground recentering. Each
  keeps a local fallback and visible boundary.

## Current release wave

The first no-dummy release lane is the curated set in
release/RELEASE_ORDER.md, currently led by Is This a Real Email?, Do Not Text
Them, What Was I Doing?, Tiny Gratitude, Overthinking Evidence Board,
Hydration Narc, Toilet Timer, Tiny Personal Museum, Step Debt, Dog Name
Guesser, Pigeon or Seagull?, Bad Advice from a Peasant, and Apology Draft
Generator. The remaining apps stay in later, AI/medical-hold, or
external-information lanes until their missing capability exists. Neighbor
Noise Translator is also locally functional but remains behind the first
writing apps until its physical-device microphone permission smoke pass.

Current functional acceptance evidence (28 August 2026): the full serialized
UI-test scheme exercised 44 active app targets through 47 real journeys on an iPhone
16e Simulator running iOS 26.2 (build 23C54). Result: 47 passed, 0 failed, and
0 skipped. The result bundle is
`build/DerivedData/PilotMCP/Logs/Test/Test-App03DoNotTextThemUITests-2026.08.28_23-31-02-+0200.xcresult`.
The final all-target unsigned simulator build also passed with exit 0. The
remaining release work is physical-device permission/appearance review,
Apple signing, and TestFlight distribution—not missing local acceptance
coverage.

Packaging evidence (29 August 2026): the current source was rebuilt into 44
unsigned Release archives and `tools/verify_local_archives.py` verified every
bundle ID, archived version/build value, and non-exempt-encryption flag against
the store manifest. A separate current signed Release sweep produced all 44
development-signed archives with provisioning profiles for team
`2CGZC35S8K`; strict deep-signature verification passed for every archive.
This validates the local signing lane only—no App Store Connect upload was
performed.

## Submission gate

Before TestFlight:

- Complete the interactive simulator journey.
- Test Reduce Motion, dark mode, and large Dynamic Type.
- Add product name, final bundle identifier, age rating, screenshots, and App Store copy; the public support and privacy URLs are now live.
- Archive with the real Apple development team and validate the archive.
