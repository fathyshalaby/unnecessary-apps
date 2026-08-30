# Release order and readiness

This is the operational order for the local-first series. The first lane is
now restricted to apps with a real local capability or a real native-device
integration. Manual-only, seeded-data, and “AI-themed” apps stay out until
their missing capability exists. Signing and upload are still a shared
Apple-account step.

## First release lane

| Order | App | Why first | Current boundary |
|---:|---|---|---|
| 1 | Is This a Real Email? | Useful workplace tool with a clear social hook | Exact local phrase matching, transparent clarity score, action/deadline signals, and editing plan; no inbox access, AI, retention, or upload |
| 2 | Do Not Text Them | Real background-safe cooldown for an impulse message | Deadline-based ten-second intervention; optional generic completion notification; draft never sends or saves; local counters only |
| 3 | What Was I Doing? | A small, genuinely useful context-memory tool | Local category-and-note archive, pattern summary, relaunch persistence, granular deletion, and no cloud sync |
| 4 | Tiny Gratitude | Real private micro-journal, not a fake wellness claim | Categorized local archive, useful day counts, resurfacing, granular deletion, and no therapy, account, or network |
| 5 | Overthinking Evidence Board | Real structured reflection workflow | Local five-part board, transparent evidence status, private case archive, and explicit no-therapy/no-truth-assessment boundary |
| 6 | Hydration Narc | Real repeatable local daily log | User-chosen serving target, one-tap log/undo, seven-day summaries, optional read-only Apple Health water total, confirmed reset, and no medical guidance |
| 7 | Toilet Timer | Real elapsed-time experience | Relaunch-safe elapsed timer, optional local milestone notifications, Live Activity, actionable manual fallback, and private session history |
| 8 | Meeting Bingo for One | Complete repeatable game with an instant social hook | Offline randomized board, persistent marks and once-per-board wins, local statistics, and complete erasure |
| 9 | Snack Roulette | Tiny decision utility with a repeatable social hook | User-owned pantry, validated local randomness, non-repeating picks, complete history controls, and no shopping integration |
| 10 | Am I Early? | Useful private punctuality pattern log | Signed arrival offsets, five-level verdicts, not-late/late summaries, complete history controls, and no calendar access |
| 11 | One More Episode? | Honest tiny planning utility with a recognizable streaming hook | Exact watch-time arithmetic against a user-chosen sleep budget, explicit non-medical assumption, private forecast history, and no streaming or sleep access |
| 12 | Can I Wear This Again? | Useful personal-rule wardrobe log with a silly compliance-office hook | User-defined wear limit, explicit condition evidence, repeat context, private ruling history, and no fake camera or sensor inspection |
| 13 | Microwave Sommelier | Real offline wattage converter wearing a ridiculous culinary costume | Published proportional formula, exact source/target values, conservative check point, private conversion history, and no appliance control or safety claim |
| 14 | Social Battery Receipt | Repeatable private reflection log with a strong shareable receipt hook | Exact user-reported energy change, honest event context, drain/recharge paths, useful summaries, complete history controls, and no diagnosis or prediction |
| 15 | Fridge Witness | Useful local inventory hidden inside a detective interrogation bit | Zero seeded fiction, user-entered quantities and reminder dates, urgency summaries, merge/decrement/removal controls, and explicit no-safety-verdict boundary |
| 16 | Receipt Emotional Damage | Real private purchase-reflection ledger with a shareable receipt hook | Published cost-per-intended-use formula, exact local history, optional one-shot review reminders, complete controls, and no bank or financial-advice claim |
| 17 | Sock Tribunal | Real private missing-item workflow with a distinctive courtroom hook | Zero seeded fiction, exact missing dates, evidence fields, open/reunited/unsolved states, reminders, complete archive controls, and no automatic closure |
| 18 | Plant Court | Real private plant-care journal with a shareable judicial hook | Zero seeded fiction, user-defined care arithmetic, watering history, editing, due-first ordering, reminders, and no diagnosis or horticultural-advice claim |
| 19 | Laundry Mountain | Real private multi-load workflow with a visual expedition hook | Zero seeded fiction, five manual stages, exact load progress, editable user timers, stage correction/reopening, reminders, and no appliance-control claim |
| 20 | Queue Personality Test | Real private wait tracker disguised as an absurd personality test | Zero seeded fiction, relaunch-safe elapsed time, transparent observed-throughput ETA, queue corrections, outcome history, optional one-shot checkpoint, and no venue/location claim |
| 21 | The Last Slice | Real local fairness rotation with an instant group/social hook | Zero seeded people, fewest-prior-awards selection, tie-only local randomness, candidate passing, relaunch persistence, exact ruling history, and no Contacts claim |
| 22 | The Door Was Push | Real private observation log with an unusually strong visual hook | Zero seeded fiction, self-reported place/direction/attempts/sign clarity, exact pattern summaries, correction without duplication, full history controls, and no sensor/location claim |
| 23 | Tiny Personal Museum | Real private photo-and-story catalog | User-selected or newly captured photo stored in the protected app container; no upload or publishing |
| 24 | Step Debt | Native device data with an honest fallback | Optional read-only Apple Health steps, transparent recent-baseline target, user-requested walking route with Apple Maps handoff, bounded on-device joke layer, manual fallback, and no upload or medical advice |
| 25 | Dog Name Guesser | Strongest social/video hook | PhotosPicker or camera capture plus on-device Vision labels; no upload or pet database |
| 26 | Pigeon or Seagull? | Same cheap native-vision pattern with a stronger absurdist hook | PhotosPicker or camera capture plus on-device Vision labels; manual checklist fallback; no upload |
| 27 | Bad Advice from a Peasant | First genuinely generative text app without cloud infrastructure | Apple Foundation Models on supported iOS 26 devices; deterministic local fallback; no cloud upload |
| 28 | Apology Draft Generator | A second genuinely generative, private writing tool | Apple Foundation Models on supported iOS 26 devices; local tone fallback; drafts never send |
| 29 | Neighbor Noise Translator | Real local microphone measurement with a no-permission fallback | Two-second in-memory audio level; microphone permission required only for listening; typed descriptions always work |
| 30 | Local Bench Reviews | Real private place journal with a native map | Apple MapKit plus optional When In Use recentering; saved coordinates and reviews stay on-device; no public feed |
| 31 | Quiet Café Index | Real venue discovery plus a private usefulness journal | Apple MapKit café search, manual map-pin fallback, optional When In Use recentering, and on-device ratings |
| 32 | Public Bathroom Quality Map | Real facility discovery plus private field reports | Apple MapKit restroom search, manual pin fallback, optional When In Use recentering, and explicit verify-on-arrival boundaries |

## Later local wave

Human GPS and the
other local journals remain functional but intentionally manual. Sleep Alibi,
Workout Excuse Detector, Health Data Horoscope, Recovery Goblin, Hydration Narc,
and Rest Day Police now have optional read-only HealthKit paths, but stay in
this later local wave until their physical-device permission and no-data states
are signed off. The remaining apps need a real native input, sensor, or stronger
user workflow before they pass the no-dummy gate.

## AI and medical hold

Bad Advice from a Peasant and Apology Draft Generator now use Apple Foundation
Models when available and keep deterministic fallbacks.

Heart Rate During Email and Health Data Horoscope also stay out of the first
public season. Health language increases App Review, trust, and wording risk;
they should not gain HealthKit, image upload, or medical interpretation without
a separate privacy and safety design.

## External-information lane

Human GPS and Weather Outfit Excuse are not first-wave apps because they need
real location or weather data to deliver their implied live-data value. Chair
Finder is now a truthful local-first observation tool: users create the chair
shortlist themselves, so it no longer ships seeded fiction or requires an API.

## Evidence

- Current result: 47 passed, 0 failed, 0 skipped in the full serialized
  simulator UI suite on iPhone 16e Simulator, iOS 26.2. The 47 journeys cover
  all 44 active app targets, including persistence, reset/erase, map, camera/photo,
  HealthKit fallback, and on-device generation boundaries where applicable.
- Final all-target unsigned simulator build passed with exit 0 after the
  current acceptance fixes.
- Post-upgrade spot checks: App13 proved relaunch-safe elapsed timing across a real
  Home/app-activation lifecycle, its local milestone notifications, Live Activity,
  manual path, persistence, and deletion; App20
  passed foggy/clear/no-retention UI acceptance and archived cleanly, App27
  persisted and deleted a two-exhibit catalog, and App36
  calculated from the manual fallback while HealthKit access was unavailable
  in the simulator.
- Distribution preparation: 44 active unsigned Release archives verified against the
  Xcode bundle IDs, plus a separate 44-archive development-signing sweep with
  strict deep-signature and provisioning-profile verification.
- Store preparation: 44 validated metadata entries and 44 active screenshot
  assets, plus live public support/privacy URLs. The retired App45 screenshot
  is stored under `retired/45-lab-report-translator/` and is outside the
  release directory.
- External prerequisites: Apple Developer team/provisioning, internal testers,
  and physical-device permission smoke passes.
