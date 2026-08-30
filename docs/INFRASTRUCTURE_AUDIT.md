# Infrastructure audit

Date: 2026-08-30  
Scope: all 44 active Unnecessary Apps targets, local release assets, App Store Connect pilot, and external-service readiness.

## Executive result

The collection is currently a healthy local-first product set. All 44 active targets
have an implemented local loop, and the current shared UI test suite passed
47/47 journeys on an iPhone 16e simulator running iOS 26.2. No active app currently
needs Supabase just to work.

The highest-value infrastructure change completed in this pass is the audited
five-app beta lane. Dog Name Guesser now has an optional PhotosPicker flow and
on-device Vision classification; the chosen photo is processed in memory only.
Do Not Text Them has a background-safe deadline and optional generic local
notification. Step Debt, Sleep Alibi, and Workout Excuse have optional
read-only HealthKit imports with explicit manual fallbacks. App Store Connect
shows Build 6, 3, 1, 1, and 1 respectively as `Ready to Submit`. Four new
internal groups each show the owner tester and one build; Dog Name Guesser
retains its existing pilot group with the owner tester and prior build history,
while its external group has Build 6 assigned. Physical-device acceptance and
smoke testing remain open.

## Verified project state

- Xcode project: 44 active app targets plus the shared UI-test target.
- Current full-simulator UI suite: 47 passed, 0 failed, 0 skipped on iPhone 16e Simulator, iOS 26.2 (build 23C54). The 47 journeys cover all 44 active app targets, with extra coverage for the three map apps.
- Final active-target unsigned simulator build: passed with exit 0 across the 44 app targets and shared UI-test target.
- Current unsigned Release archive sweep: 44 active archives rebuilt from current
  source and verified against the store metadata manifest. App03’s archived
  build 3 and App24’s archived build 4 are recorded correctly rather than
  being forced to build 1.
- Current signing sweep: all 44 current Release archives have development
  provisioning profiles for Team ID `2CGZC35S8K`; `codesign --verify
  --deep --strict` passed for every archive and no upload was performed.
- App Store screenshot references: 44 iPhone 6.9-inch assets for the active
  targets; clean simulator/device recapture is still required before Store
  submission because the current references include simulator chrome and
  pre-upgrade surfaces.
- Store metadata: 44 entries validate with live public support/privacy URLs.
- App-private persistence: 43 targets use `@AppStorage` or `UserDefaults`.
- Required-reason privacy manifests: all 43 persistence-using targets now have a manifest (39 use the shared manifest and 4 keep app-specific manifests).
- All 44 active app targets package a privacy manifest. App20 uses the shared
  no-required-reason/no-tracking manifest, while App30 keeps an explicit
  no-tracking/no-collected-data manifest despite neither app using a
  required-reason API.
- App display names: generated from the store metadata instead of raw target names.
- App24 TestFlight record: `Unnecessary: Dog Name Guesser`, ASC ID `6805446694`; Build 6 was uploaded on 29 August 2026 and is live in TestFlight as `Ready to Submit`.
- Audited beta records: Do Not Text Them `6805352462` Build 3; Step Debt `6806534240` Build 1; Sleep Alibi `6806534690` Build 1; Workout Excuse `6806534987` Build 1. All are `Ready to Submit` in App Store Connect.
- No Supabase, Firebase, analytics, third-party network SDK, or cloud account layer is currently in the project. Public Bathroom Quality Map and Quiet Café Index use Apple MapKit search; both and Local Bench Reviews use optional foreground location only. Step Debt, Sleep Alibi, Workout Excuse Detector, Health Data Horoscope, Recovery Goblin, Hydration Narc, and Rest Day Police are read-only HealthKit integrations; Step Debt also has a user-requested walking route. No health data is written back or uploaded.
- The connected Supabase account has one existing healthy project named `Specky` in `eu-west-3`; it is not wired to this repository and should not be reused for Unnecessary Apps without an explicit product decision.

## Infrastructure lanes

### Ship locally first

These apps are useful without accounts, a backend, or device permissions:

- 01 Chair Finder
- 03 Do Not Text Them
- 04 Social Battery Receipt
- 05 Fridge Witness
- 06 Receipt Emotional Damage
- 07 Sock Tribunal
- 08 Plant Court
- 09 Laundry Mountain
- 10 What Was I Doing?
- 11 Am I Early?
- 12 Pigeon or Seagull?
- 13 Toilet Timer
- 14 One More Episode
- 15 Can I Wear This Again?
- 16 Microwave Sommelier
- 17 Meeting Bingo for One
- 18 Tiny Gratitude
- 19 Bad Advice from a Peasant
- 20 Is This a Real Email?
- 21 The Vibe Meter
- 22 Snack Roulette
- 25 Waiting Room Simulator
- 26 Neighbor Noise Translator
- 27 Tiny Personal Museum
- 28 Overthinking Evidence Board
- 30 Apology Draft Generator
- 32 The Last Slice
- 33 Queue Personality Test
- 34 Weather Outfit Excuse
- 35 The Door Was Push

These are the best candidates for rapid social episodes because their joke is complete on one device and their privacy story is simple.

### Native-device upgrades, no Supabase required

- 24 Dog Name Guesser — PhotosPicker and on-device Vision are implemented; uploaded Build 6 is ready for the physical-device smoke pass.
- 02 Public Bathroom Quality Map — Apple MapKit restroom search, manual map-center pinning, optional When In Use recentering, and a persistent private report ledger are implemented. Focused fallback/search UI tests, visual QA, and an unsigned Release archive pass; physical permission and human search-quality review remain.
- 23 Quiet Café Index — Apple MapKit café search, manual map-center pinning, optional When In Use recentering, and a persistent private rating ledger are implemented. Focused fallback/search UI tests, visual QA, and an unsigned Release archive pass; physical permission review remains.
- 29 Local Bench Reviews — Apple MapKit, map-center pinning, optional When In Use recentering, and a persistent private review ledger are implemented. Focused create/relaunch/clear UI testing, visual QA, and an unsigned Release archive pass; physical permission review remains.
- 36 Step Debt — optional HealthKit step-count read, recent-baseline smart target, and user-requested MapKit walking route; retain manual fallback and complete the physical-device permission/location/no-data smoke pass.
- 37 Sleep Alibi — optional read-only HealthKit sleep read implemented; retain manual fallback and complete the physical-device permission/no-data smoke pass.
- 39 Workout Excuse Detector — optional read-only HealthKit workout-duration read implemented; retain manual fallback and complete the physical-device permission/no-data smoke pass.
- 40 Health Data Horoscope — optional read-only HealthKit steps/sleep read implemented; retain manual inputs and entertainment boundary.
- 41 The Recovery Goblin — optional read-only HealthKit workout context implemented; self-reported signals remain primary and no recovery score is calculated.
- 42 Walking Meeting Escape Plan — optional motion/activity signal; no location needed.
- 43 Hydration Narc — optional read-only HealthKit water total implemented as a separate ledger; retain the user-defined manual serving ledger.
- 44 Rest Day Police — optional read-only HealthKit workout streak implemented; retain the current local satire and manual fallback.

The missing work for this lane is capability-specific: entitlements, purpose strings, a permission explanation screen, denial/offline states, and physical-device smoke tests. It should be added one app at a time, not as a shared blanket permission.

### Apple-native services, still no Supabase

- 01 Chair Finder is intentionally observation-led and local; it does not need
  MapKit or location to rank chairs the user can actually see. Apps 02, 23, and
  29 provide the collection's private MapKit workflows.
- 31 Human GPS could use Core Location, but precise location is a meaningful privacy cost and is not needed for the joke.
- 34 Weather Outfit Excuse could use WeatherKit, but the manual version is currently safer and cheaper to operate.
- 12 Pigeon or Seagull? uses on-device Vision plus PhotosPicker. Tiny Personal Museum uses PhotosPicker for a protected local multi-exhibit catalog and deliberately performs no image analysis.

These should remain local/manual until an audience proves the live-data feature is worth the permission and review burden.

### Supabase-worthy apps

Create a Supabase project only when one of these becomes a real shared product:

- 02 Public Bathroom Quality Map — user-submitted reports, coarse venue areas, moderation, RLS, and abuse controls.
- 23 Quiet Café Index — shared café records and community ratings, with moderation and venue-level rather than precise user location.
- 29 Local Bench Reviews — the strongest first Supabase candidate: public bench records and reviews without storing a user’s exact location.
- 32 The Last Slice — short-lived multiplayer rooms; Supabase Realtime plus anonymous session IDs and expiry cleanup.
- 27 Tiny Personal Museum — optional cross-device image storage and metadata; Storage + Postgres + strict per-user RLS.
- 18 Tiny Gratitude — optional account-based cross-device sync, only if users ask for it.

For the AI-flavored apps, a backend function may proxy a model key, but that is an API-key boundary, not a database requirement. Keep the provider behind a server-side function and never put a provider secret in the iOS binary. A small edge function can be Supabase Edge Functions, Cloudflare Workers, or Vercel Functions; choose after the first AI app and model are selected.

### Hold for product and review decisions

- 38 Heart Rate During Email — remains manual-only by design; the product explicitly avoids heart-rate monitoring and interpretation.
- 40 Health Data Horoscope — HealthKit is implemented as an optional read-only input, but entertainment-only wording must remain explicit.

## What is still missing for a genuinely public release

1. Accept the internal invitations on the intended Apple ID. The five audited
   pilot apps have one owner tester in their internal groups, and that same
   tester is attached to each corresponding external group; Dog Name Guesser’s
   external group is assigned Build 6. No email is written into this repository.
2. Run one physical-device smoke pass for the current Dog Name Guesser build,
   especially PhotosPicker denial/cancellation and a non-dog image.
3. Complete physical-device permission/denial/no-data smoke passes for all seven HealthKit apps, plus Step Debt’s location denial and Apple Maps handoff.
4. Complete physical-device location grant/denial smoke passes for Public Bathroom Quality Map, Quiet Café Index, and Local Bench Reviews. Simulator search/fallback and saved-record journeys now pass.
5. Decide whether the first shared-data product is a public expansion of Local Bench Reviews, Quiet Café Index, or The Last Slice. That choice determines the Supabase schema and RLS policy.
6. Set up crash monitoring only after the first public beta; none is needed for the current internal pilot.

## Recommendation

Do not create Supabase yet. Use the five-app internal beta lane first, complete
physical-device sign-off for the photo, notification, and HealthKit paths, and
use feedback to choose one shared-data app. The next backend slice should be a
deliberately small Supabase proof of concept for Local Bench Reviews only if
the audience asks for public/community data.
