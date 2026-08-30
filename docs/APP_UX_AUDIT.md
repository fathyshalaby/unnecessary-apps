# 44-app UI and UX audit

Date: 30 August 2026  
Scope: first-launch usefulness, primary interaction, information hierarchy, empty/loading/error/success behavior, motion, accessibility, and visual identity.

## Collection verdict

The apps are not allowed to look like 44 copies of one dashboard. Shared SwiftUI primitives are fine as engineering infrastructure; they are not the product identity. Each app needs its own interaction geometry, emotional payoff, mascot behavior, and reason to be opened again.

The current collection has three strengths: every premise is legible, the mascots create a memorable emotional hook, and most apps already produce a useful local result. The main weakness is repeated composition: a hero card, a stack of cards, one chunky action, and a result card. This audit treats that repetition as the primary design debt.

## Release-wide rules

- Put the useful action in the first viewport. Do not add a blocking splash to fast local apps.
- Use a short mascot entrance animation as the welcome moment; use a real loading state only for Vision, AI, location search, or work that can take longer than a tap.
- Give each app one primary action, one unmistakable result, and one recovery path when there is no data or a permission is denied.
- Keep every native control at least 44pt, preserve Dynamic Type and Reduce Motion, and hide decorative icons from VoiceOver.
- Use distinct interaction worlds: maps should be map-first, photo apps should be camera/photo-first, games should be play-first, journals should be entry-first, and timers should be timer-first.
- Make the benefit concrete in the first sentence: what the user can decide, record, find, translate, or laugh at after one tap.

## Apple-native final gate

Apple design language here means native behavior underneath the deliberately
weird art direction—not 44 copies of a stock Settings screen. Every app must
pass this gate before its build is assigned to an external TestFlight group:

- Prefer SwiftUI-native `NavigationStack`, `Button`, `TextField`, `Toggle`,
  `Picker`, `Slider`, sheets, alerts, and system keyboard behavior. Custom
  gesture surfaces are reserved for the map, board, and camera worlds, and
  still expose labeled controls for VoiceOver and UI tests.
- Keep interactive targets at least 44pt, use Dynamic Type-aware text and
  layout, support light and dark appearance with semantic/adaptive colors, and
  hide decorative artwork from assistive technologies.
- Treat Reduce Motion as a real preference: decorative mascot entrances,
  pressed states, result reveals, and map transitions must settle without
  animation when it is enabled. No essential information may be conveyed only
  by motion or color.
- Ask for permission at the moment of intent and explain the benefit first:
  PhotosPicker for photos, foreground location only for a map action, read-only
  HealthKit only after its value is clear, and notifications only when a user
  enables a reminder. Every denial/offline/no-data path keeps the core app
  useful.
- Hand off to Apple Maps or Health where that is the user’s natural next step;
  do not imitate a system dashboard, invent health measurements, or silently
  upload private photos, notes, location, or health data.
- Loading, empty, error, success, reset, and destructive actions need visible
  copy and a recoverable path. The joke can be loud; the action and consequence
  must remain obvious.

## Final static gate · 30 August 2026

- 44 active app folders were checked: 41 use the shared native primitives and
  three keep bespoke map-first roots (Bathroom Map, Quiet Café Index, and Local
  Bench Reviews).
- All app-specific result/list/map animations now branch on Reduce Motion, and
  the shared shell, press feedback, and result reveal do the same.
- The final adaptive-color scan removed the last hard-coded black/white UI
  surface from the active apps; Receipt Emotional Damage now uses its adaptive
  receipt-paper token in light and dark appearance.
- The last user-visible fixed-size micro-labels now use Dynamic Type-aware
  `caption2` styles; the remaining fixed-size marks are decorative map or
  diagram artwork and are hidden from assistive technology.
- The full generated Xcode project compiled 47 targets for the iOS Simulator;
  a fresh unsigned Release archive sweep verified 44 products against their
  bundle IDs, marketing versions, build numbers, and encryption flags.
- Store metadata validates for all 44 apps, and the App Store Connect lane has
  44 app records plus 44 external group/public-link records provisioned.
- The stored 6.9-inch screenshot set is a QA reference only: it includes
  previous-app simulator chrome and pre-upgrade captures for Apps 02, 24, and
  36. It must be regenerated from a clean launch before App Store submission.

Interactive dark-mode, largest-text, permission-denial, and physical-device
sign-off remain release checks, not reasons to pretend the simulator is a
device.

## App-by-app direction

| # | App | First useful benefit | Signature UI | UX direction / release note |
|---:|---|---|---|---|
| 01 | Chair Finder | Rank a chair the user can actually see | Field notebook with a visible comfort score | Keep the inspector mascot, but make “File this chair” the first move and move the ledger below the verdict. |
| 02 | Public Bathroom Quality Map | Find a nearby place to inspect | Map-first with a bottom search action | Keep the map dominant; location denial must explain how to pan and search manually. |
| 03 | Do Not Text Them | Start a cooling-off intervention | Large countdown and one emergency button | The timer is the screen; move the draft field into a later sheet so the user can act before writing. |
| 04 | Social Battery Receipt | See the emotional cost of a social event | Receipt with before/after totals | Lead with the result preview and make “print receipt” the payoff, not another form submit. |
| 05 | Fridge Witness | Turn food into an actionable inventory | Fridge shelves / evidence tags | Keep one-tap item filing and show “what needs attention next” above the full inventory. |
| 06 | Receipt Emotional Damage | See the real cost per use | Itemized receipt with a large damage total | The first screen should be the receipt preview; editing purchase details can stay below. |
| 07 | Sock Tribunal | Get a verdict on a missing sock | Court docket and verdict stamp | Use binary evidence choices before text fields; the ruling should be filmable in one tap. |
| 08 | Plant Court | Decide what a plant needs next | Plant witness stand with care buttons | Replace slider-first input with “watered / not watered / suspicious” quick actions, then show the case. |
| 09 | Laundry Mountain | Move a load to its next stage | Expedition board with a prominent current stage | Make the next stage the main CTA and reserve editing for a secondary action. |
| 10 | What Was I Doing? | Record a lapse in one tap | Memory log with a single “I forgot” action | Keep optional context collapsed until after the first record; the joke is the immediate loop. |
| 11 | Am I Early? | Get a punctuality verdict | Clock face / signed offset | Make the offset visually dominant and keep occasion optional; show the result without scrolling. |
| 12 | Pigeon or Seagull? | Classify the bird in front of the user | Camera/photo stage with a large species reveal | Camera and library remain adjacent; show loading while Vision examines a photo and explain failure nearby. |
| 13 | Toilet Timer | Know whether the stall visit has become a situation | Oversized stopwatch | Open directly on the timer; explanations and history should never outrank Start. |
| 14 | One More Episode? | See tomorrow’s sleep cost | Bedtime budget dial | Show the trade-off as a live sentence while sliders change; make the result a morning-shareable card. |
| 15 | Can I Wear This Again? | Get a clear wear-again ruling | Outfit inspection card | Start with three quick evidence buttons, then reveal the ruling; keep detailed history secondary. |
| 16 | Microwave Sommelier | Convert package timing to the current microwave | Split wattage conversion panel | Put “your microwave” first and use numeric keyboards; the converted time should update immediately. |
| 17 | Meeting Bingo for One | Play the meeting without setup | Full bingo board | The board is the tutorial; keep the header compact, animate only marked squares, and show the bingo payoff. |
| 18 | Tiny Gratitude | Save one small good thing | Daily note card | Start with the prompt and keyboard, not the archive; after saving, show a calm celebratory card. |
| 19 | Medieval Peasant Advice | Get a funny answer to a modern problem | Parchment prompt and oracle reveal | Prompt first, answer second; loading should feel like a tiny ceremony without blocking cancellation. |
| 20 | Is This a Real Email? | Spot foggy writing before sending | Inbox autopsy | Put paste/type input first and keep the analysis result scannable with concrete flags and a rewrite path. |
| 21 | The Vibe Meter | Produce a room score people can argue with | Radial meter with dial controls | Show the live score while adjusting; never hide the score below sliders. |
| 22 | Snack Roulette | Choose a snack without debating | Wheel / slot-machine result | Let users edit the snack list later; spin should be the first-view focal point. |
| 23 | Quiet Café Index | Judge a café from the map center | Map-first with quietness markers | Preserve map-first; make rating a focused sheet anchored to the selected location. |
| 24 | Dog Name Guesser | Invent a defensible dog name | Camera/photo stage and name reveal | Keep camera/library first, then make the name reveal feel like a title card rather than a form result. |
| 25 | Waiting Room Simulator | Spend five fake minutes in a controlled absurdity | Large queue clock | The current timer should be immediately tappable; place commentary under the clock and show the escalation as progress. |
| 26 | Neighbor Noise Translator | Turn a thud into a harmless category | Waveform plus category chips | Use a few large sound buttons before free text; add a safe “do not confront anyone” recovery note. |
| 27 | Tiny Personal Museum | Preserve the story of an ordinary object | Camera/photo-led exhibit builder | Camera/library first, story second, gallery third; open directly on “Add an exhibit.” |
| 28 | Overthinking Evidence Board | Reach a provisional conclusion | Corkboard evidence layout | Keep worry and evidence entry visible, but make the conclusion card the visual destination. |
| 29 | Local Bench Reviews | Review the bench at the map center | Map-first with bench pin and review sheet | Keep the map dominant and let the selected pin carry the review flow; do not front-load the ledger. |
| 30 | Apology Draft Generator | Get a reviewable apology draft | Composer and draft reveal | Put the tiny crime field first, show generation progress, and make copy/edit the immediate next action. |
| 31 | Human GPS | Give someone usable arrival instructions | Route cards with landmark steps | Ask for one landmark, then show the copyable instruction as a large result; keep extra nuance collapsed. |
| 32 | The Last Slice | Resolve a slice dispute | Fairness picker and ruling card | Start with the available slices / people, not a paragraph; show the ruling with a shareable receipt. |
| 33 | Queue Personality Test | Identify the kind of queue person you are | Choice cards with a progress rail | One question per screen or card, clear progress, and a celebratory result portrait. |
| 34 | Weather Outfit Excuse | Produce a defensible outfit excuse | Closet stack plus weather card | Make temperature entry fast and show the excuse in a copyable card; keep disclaimers short and visible. |
| 35 | The Door Was Push | Record the exact moment architecture won | Incident choice buttons and witness card | Make “Push or pull?” the hero interaction; the incident log comes after the verdict. |
| 36 | Step Debt | Turn real steps into a fictional invoice | Health-first balance, editable smart target, route card, and Apple Maps handoff | Make the current balance and next walk visible immediately; explain that Apple Health supplies steps, not a universal step goal. |
| 37 | Sleep Alibi | Generate a ridiculous excuse for being tired | Health evidence card, bedside reveal, and manual fallback | Ask for Apple Health only after the user sees the alibi value; show recent duration, not a fake sleep score. |
| 38 | Heart Rate During Email | Record inbox drama without implying medical insight | Manual event card and trend strip | Keep it explicitly self-reported and non-medical; never imply Health data unless the user opts into a real integration. |
| 39 | Workout Excuse Detector | Reframe a skipped workout kindly | Excuse-first case, optional HealthKit evidence, and supportive result | Let the user tell the story first; imported workout duration is evidence, not a performance score. |
| 40 | Health Data Horoscope | Turn a wellness check-in into entertainment | Entertainment boundary, optional HealthKit inputs, and cosmic reveal | Keep the disclaimer beside the result and make manual input equally usable. |
| 41 | The Recovery Goblin | Turn self-reported signals into a gentle fictional ruling | HealthKit context card, self-report sliders, and goblin result | Never calculate or imply recovery; the user’s own signals drive the joke and the fallback is always available. |
| 42 | Walking Meeting Escape Plan | Get a usable exit line quickly | Route / escape-plan cards | Ask for meeting length and urgency with large choices; show the line to say as the main result. |
| 43 | Hydration Narc | Log water in one tap and see today’s progress | Separate read-only HealthKit water card, progress ring, quick-add ledger, and optional reminder | Never silently merge milliliters with user-defined servings; quick-add remains the home action and reminders stay opt-in. |
| 44 | Rest Day Police | Get permission to rest | Optional HealthKit workout dossier, manual streak fallback, and citation card | Activity context must be transparent and the citation must remain supportive, not punitive. |

## Implemented experience layer

`DumbExperienceStyle` now infers a visual grammar from each app’s purpose. It changes hero geometry, background motif, mascot frame, card radius, action shape, result label, and department language. The current styles are dossier, receipt, courtroom, camera, journal, gallery, game, timer, meter, route, wellness, oracle, workbench, and map.

This is intentionally an implementation layer, not a mandate that every app must share a shell. The three map apps retain their custom map-first surfaces, and the three image-led apps retain their camera/photo workflows. Future flagship apps can opt out of the inferred style and own the entire root layout.

## Flagship geometry pass · 28 August 2026

The top-ten release candidates now have a second layer of differentiation: the
first useful interaction is intentionally different per product, even when the
apps reuse the same persistence and accessibility primitives.

- Dog Name Guesser opens on a camera evidence stage, then separates the name
  dials from the photo workflow.
- Pigeon or Seagull opens on a species scanner with a target frame, library and
  camera actions, and a separate manual checklist.
- The Door Was Push starts with the incident intake and a visual push/pull
  decision grid; the mascot witness and archive follow the filing action.
- Receipt Emotional Damage starts with purchase evidence and its action path;
  the receipt explanation and ledger no longer delay data entry.
- Sock Tribunal, Plant Court, and Laundry Mountain now start with their real
  filing/planning forms and move rules and totals below the primary action path.
- Apology Draft Generator replaces a menu with direct tone chips and updates
  the primary action label to the selected tone.
- Medieval Peasant Advice uses a small “village desk” prompt surface and keeps
  the safety boundary beside the input rather than burying it below the result.
- Meeting Bingo remains deliberately board-first: the board is the tutorial and
  the marked-square payoff is visible without a setup flow.

The launch evidence for all ten is captured in `build/QA/` on the iPhone 16e
simulator. This pass also added `dogEvidenceStage` and `birdScannerStage` UI
identifiers so the differentiated first screens are protected by tests.

## Loading and launch policy

No generic branded splash is added to every app. A splash would make a local joke feel slower and hide the benefit. The shared hero now gives the mascot a short, interruptible entrance animation. Real loading states belong only where there is actual work: Vision classification, AI generation, MapKit search, or a notification setup flow. Those states should preserve the input, explain what is happening, and offer recovery.

## Release gates

Before TestFlight, run each flagship in light mode, dark mode, Reduce Motion, and the largest Dynamic Type setting. Check the first useful action on a 375pt phone and landscape. Then verify physical camera, location denial, keyboard dismissal, and share/copy flows on an iPhone. A beautiful first frame is not enough if the result cannot be used.
