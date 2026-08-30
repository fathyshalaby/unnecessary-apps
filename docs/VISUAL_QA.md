# Visual QA — Unnecessary Apps Corp

Date: 30 August 2026  
Scope: shared SwiftUI system, representative simulator captures, and all 44 active app targets by static UI/behavior review.

## Latest simulator evidence — 28 August 2026

### Minimal-modern pass

- The complete simulator build passed for all 44 active app targets plus the UI-test
  target after the shared redesign. The all-target build completed with exit 0;
  Xcode emitted only its normal “no AppIntents.framework dependency” notices.
- App23 Quiet Café, App02 Bathroom Map, and App29 Bench Reviews now use a
  compact 48pt brand header, a 360pt map-first surface, 44pt map controls, a
  single primary action, and a quiet evidence ledger below the map. Fresh
  369×800 captures show no black bands or clipped content.
- App17 Meeting Bingo keeps its board as the first useful surface and now sits
  on the same calmer canvas/card hierarchy. The health lane keeps Apple Health
  optional, read-only, and visibly separate from manual fallbacks; no app
  presents itself as a diagnostic tool.
- The shared `DumbShell`, `DumbAction`, `DumbCard`, `DumbCharacterStage`, and
  `DumbField` changes cover 41 shell-based apps; the three map apps have their
  own map-specific composition rather than being forced into that shell.

- App24 Dog Name Guesser built and launched through XcodeBuildMCP on the iPhone
  16e Simulator in 18.5 seconds with no build warnings or errors.
- The fresh 369×800 phone capture shows the evidence task and `Library` /
  `Camera` actions in the first useful viewport, with no black letterboxing.
- `snapshot_ui` still reports one root element and zero likely interaction
  targets after relaunch. The app source contains explicit accessibility labels
  and identifiers, and the native UI test suite covers this evidence flow, so
  this is currently an MCP snapshot/parser verification item—not evidence to
  remove or weaken the app's accessibility semantics.

The previous black-band P0 is cleared for this simulator path but remains a
device/clean-simulator regression check for the collection before broad release.

After a clean iPhone 16e Simulator restart, the complete `MapAppsUITests`
interaction suite passed on 28 August 2026: 5 tests passed, 0 failed, 0
skipped on iOS 26.2. The suite covers save, search, persistence, and clear
flows across the Bathroom Map, Quiet Café Index, and Local Bench Reviews. The
earlier `NSMachErrorDomain -308 (ipc/mig) server died` was confirmed as a
recoverable CoreSimulator runner condition rather than an app behavior result.

The full current-binary acceptance suite also passed on the same iPhone 16e
Simulator: 47 tests passed, 0 failed, and 0 skipped. It covers the local
create/edit/reset/erase journeys across all 44 active app targets. The final
all-target unsigned simulator build passed as well. HealthKit’s App39 test
uses an explicit test-only manual-fallback launch flag so simulator evidence
does not depend on a stale system authorization sheet; production still keeps
the real read-only HealthKit path.

## Verdict

The visual direction is now recognizable and ownable: warm paper canvas, candy-color accents, rounded type, mascot art, restrained shadows, and a deliberately unserious “Nonsense Dept.” voice. The new shared shell is much closer to the Duolingo / Dumb Ways to Die energy without making the joke compete with the task.

The final Apple-native pass keeps that personality inside iOS conventions:
SwiftUI-native controls remain the interaction surface, user-facing headline
readouts use Dynamic Type-aware SF styles, semantic adaptive colors cover light
and dark appearance, and app-specific animations now honor Reduce Motion. The
three map apps remain map-first and the photo apps remain photo-first; native
composition does not require flattening every app into the same layout.

The first viewport now has a clear job in every lane: input/camera/map/board first, one obvious action second, result or saved evidence third. The remaining release risk is verification breadth—not a missing visual direction: large-text, dark-mode, permission-denied, and physical-device captures still need to be run.

## Fixed in this pass

- Replaced the fixed 42pt hero title with a Dynamic Type-aware rounded large-title style.
- Reduced hero padding and mascot scale so the first useful action arrives sooner.
- Removed pressed-state layout movement; buttons now scale and fade without shifting their bounds.
- Added reduced-motion handling to the shared press style.
- Added visible labels to the shared text field and preserved multiline fields.
- Standardized the remaining native text fields and sliders through `DumbField` and `DumbSlider`.
- Standardized the two rogue app-specific buttons: meeting bingo tiles and the door-pull action.
- Added a 44pt minimum target to “Delete evidence.”
- Fixed a real behavior bug in Do Not Text Them: deleting evidence now invalidates the running countdown so it cannot later overwrite the user’s “court adjourned” result.
- Added VoiceOver labels/hints, decorative-icon hiding, visible disabled states, result-card pulse feedback, and light haptics for primary actions.
- Added adaptive light/dark surface, text, accent, and button-ink tokens instead of relying on a light-only white-card system.
- Added lightweight local persistence to gratitude, museum, bench-review, and daily hydration flows; hydration resets at the next calendar day.
- Fixed the receipt reminder’s notification-consent copy so enabling the
  switch always explains that permission is requested only when filing.
- Added an explicit manual fallback test boundary for the HealthKit workout
  flow, keeping simulator acceptance deterministic without weakening the
  production integration.
- Hardened cross-app acceptance around asynchronous SwiftUI updates,
  accessibility-combined result cards, scroll-position changes, and catalog
  deletion state.
- Replaced ad-hoc screen accent colors with the shared palette so the collection reads as one product.
- Kept the implementation native and dependency-free; the shared `DumbKit` library remains the single styling surface.

## Findings — ranked harshly

### P0 — unexplained black letterboxing — cleared for current simulator path

Fresh captures of Apps 02, 17, 23, 24, and 29 are full-height 369×800 phone screens with no black bands. The earlier capture was simulator presentation state. Recheck once on a clean boot and a real iPhone before release, but it is no longer blocking the design pass.

### P1 — the hero was trying to be the whole product — fixed in the shared pass

The old hero used too much vertical real estate before the user could act. The shared hero is now a compact title block with a small mascot, and the representative captures keep the useful surface above the fold. Long titles still need Dynamic Type review.

### P1 — custom map apps used to feel like a second design system — fixed

Apps 02, 23, and 29 now share the collection’s spacing and hit-target tokens while preserving their useful difference: the map remains the dominant surface, the center marker explains the action, and saved reviews/report cards use quieter borders and shadows.

### P1 — 44 active apps, one interaction language

The collection previously had a branded shell but unbranded native controls inside it. That read as a template pasted over prototypes. Shared fields, sliders, press feedback, labels, and action styling now cover the collection. The remaining intentionally raw surfaces are multiline editors, which still need a final clean card treatment on-device.

### P1 — “dumb” must not mean confusing

The jokes are strong when the action is obvious and the result is immediate. They fail when the user has to infer what a slider means, whether a button is disabled, or whether a result is saved. Every app should answer three questions on first screen: what am I changing, what do I tap, and what do I get back?

### P1 — health data must stay bounded and legible

The health lane now separates read-only Apple Health context from user-entered
fallbacks. Step Debt calculates its target deterministically, routes through
MapKit only after an explicit request, and limits Foundation Models to joke
copy. The remaining health apps keep their primary self-report or ledger flow
usable when permission is denied or no data exists.

### P2 — persistence is intentionally selective

The journal-shaped repeat-use apps now retain their latest useful record locally, and hydration rolls over by day. The rest remain intentionally disposable one-session toys; adding a database to every joke would make the collection heavier without making it better.

### P2 — dark and accessibility states still need capture proof

The palette and interaction code now have adaptive dark tokens, visible disabled states, VoiceOver labels, reduced-motion handling, and Dynamic Type-aware titles. They still need screenshots and tap-through verification in dark appearance and the largest text size once CoreSimulator is healthy.

### P2 — stored store screenshots need a clean launch

The archived QA screenshots are useful for reviewing the app surface, but their
status bars retain the simulator's previous-app back affordance (for example,
`App44RestDayPo…`) and some capture predate the latest capability upgrades:
App02 does not show its map-first surface, App24 does not show its Photos/Camera
entry, and App36 still says “Manual entry only” despite the current optional
read-only Apple Health context. This is asset drift, not current app behavior.
Regenerate the submission assets from a clean simulator launch or a physical
iPhone before using them in App Store Connect; the preparation script now
covers exactly 44 active apps and no longer includes retired App45.

## Ship gate

Before TestFlight: use a clean simulator/device, rebuild at least Apps 01, 03, 11, 20, and 36, capture light/dark and the largest accessibility text size, tap every primary action, test keyboard dismissal and disabled states, then repeat the same smoke pass on a physical iPhone. The map interaction suite is green on iPhone 16e Simulator; repeat it on the final release destination as part of the device smoke pass.
