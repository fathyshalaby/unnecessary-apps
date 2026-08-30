# Verification

The current release scope contains 44 active numbered apps and a shared DumbKit
SwiftUI component library. App45, Lab Report Translator, is retired under
`retired/45-lab-report-translator/` and is not part of the Xcode project or
TestFlight release.

## Current active release verification — 2026-08-30

The audited five-app pilot lane is uploaded and shows `Ready to Submit` in App
Store Connect. The builds are assigned to the collection’s external groups,
but Apple’s first external beta-review submission is still pending required
review information; they are not yet publicly installable:

- Do Not Text Them — ASC `6805352462`, Build 3
- Dog Name Guesser — ASC `6805446694`, Build 6
- Step Debt — ASC `6806534240`, Build 1
- Sleep Alibi — ASC `6806534690`, Build 1
- Workout Excuse — ASC `6806534987`, Build 1

The physical-iPhone invitation acceptance, installation, and smoke testing
remain open. No custom analytics SDK or cloud backend was added.

The owner’s existing TestFlight tester records are attached to both the
internal pilot groups and the five corresponding `Unnecessary Apps Friends`
external groups. Installation from the external links still waits for Apple’s
first external beta-review approval.

The current source includes background-safe Do Not Text Them deadlines with
optional generic local notifications, on-device dog-photo suggestions, and
HealthKit read-only imports with explicit manual fallbacks. The generated
project compiles all 47 targets, and a fresh unsigned Release archive sweep
verifies all 44 active products against the manifest. The public collection hub
is https://fathyshalaby.github.io/unnecessary-apps/testflight.html.

Current release evidence:

- `python3 tools/validate_store_metadata.py release/app-store-metadata.json`
  validates all 44 metadata entries.
- `python3 tools/verify_local_archives.py . build/final-local-archives-20260830d`
  verifies all 44 unsigned Release archives, including bundle IDs, build
  values, and non-exempt encryption.
- App Store Connect has 44 app records, 44 `Unnecessary Apps Friends` external
  groups, and 44 public links; five groups have a `VALID` build assigned and 39
  await signed upload.
- App Store Connect app-info localization metadata is synced for all 44
  records: every editable Store title uses the `Unnecessary:` convention,
  every subtitle is present, and every privacy URL points to the hosted policy.
- The Apple-native UX gate covers native SwiftUI controls, Dynamic Type,
  adaptive light/dark colors, Reduce Motion, accessible labels, and
  permission-denial fallbacks. The latest hard-coded white receipt surface was
  replaced with an adaptive token.
- Signed distribution still requires an unlocked Mac/keychain. External beta
  review also requires the reviewer contact fields, including an international
  phone number; those values are intentionally not stored here.

## Historical verification log

The records below preserve earlier 45-app development and simulator evidence.
They are historical context, not the current release count or TestFlight
status.

Verified on 2026-08-24 with Xcode 26.2 (17C52):

- swift package describe --type json: 46 products/targets, including 45 executables.
- swift build: all 45 SwiftPM products compile successfully on macOS.
- xcodebuild -list -project UnnecessaryApps.xcodeproj: project parses and exposes 45 iOS app schemes plus DumbKit.
- Each of the 45 iOS schemes was built against iphoneos26.2 with CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO; all 45 passed.
- The build produced 45 Debug-iphoneos/*.app bundles.

Simulator smoke test completed on 2026-08-25 using iPhone 17 Pro (iOS 26.2, UDID 06C46F13-B37E-4254-8DBA-785C8DE15A4A): App01ChairFinder built for iphonesimulator, installed, launched, and rendered a screenshot successfully.

Design asset verification completed on 2026-08-25: all 45 app folders contain an Xcode `Assets.xcassets` with AppIcon and AppMascot sets; the complete AppIcon size set compiles cleanly; and all 45 simulator asset catalogs were generated successfully with `xcodebuild -alltargets`.

The final App01 simulator build was rebuilt after the complete icon catalog was installed and launched successfully. The generated app bundle contains the compiled `Assets.car` resource.

App11AmIEarly was rebuilt and launched on the same simulator after the shared `DumbShell` gained its per-app mascot header; the mascot rendered above the title as intended.

Final collection-wide simulator compile completed after the mascot and release metadata changes; 45 `Assets.car` outputs were produced.

Playful UI redesign verification completed on 2026-08-25: the shared shell now uses rounded display typography, mascot-led hero cards, soft-depth surfaces, chunky primary actions, press feedback, and compact result cards. Apps 01–10 were migrated to the same composition, and the final all-target simulator compile completed without Swift compiler errors.

Ponytail refactor verification completed on 2026-08-25: repeated fields and sliders now use shared `DumbKit` primitives; no new UI dependency was added; `swift build -q` passes; and the App06 iOS simulator target builds successfully.

XcodeBuildMCP still needs the full Xcode developer directory selected system-wide; the current shell can run simulator commands with DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer.

The first version intentionally uses seeded data and in-memory state. No app sends messages, uses real location, contacts servers, or requests sensitive permissions. The lab translator explicitly avoids diagnosis and treatment recommendations.

Visual QA pass completed on 2026-08-25: all 45 app folders still use the shared shell; all app text inputs now use visible-label `DumbField` or an explicitly labeled multiline editor; all app sliders now use `DumbSlider`; all primary actions use `DumbAction`; and fixed-size font usage was removed. All 45 app source groups pass iOS 17 type-checking against the iPhoneOS 26.2 SDK, and every Swift file passes parse checking.

The simulator service became unavailable during an earlier post-refactor recapture (`CoreSimulatorService connection invalid` / `simdiskimaged` unavailable). That was recovered using the installed Xcode developer directory and a clean iPhone 17 Pro simulator boot; the earlier black-band/windowed presentation was addressed by the generated launch-screen settings.

See [docs/VISUAL_QA.md](docs/VISUAL_QA.md) for the ranked design and interaction findings.

Follow-up fixes completed after the visual QA report: adaptive light/dark palette tokens and button foregrounds, VoiceOver labels/hints and decorative-image hiding, visible disabled button states, reduced-motion-safe result feedback, primary-action haptics, selective `@AppStorage` persistence for repeat-use apps, and shared palette accents across all app targets. The full 45-target iOS source type-check and Swift parse sweep passed again after these changes.

The XcodeBuildMCP bridge still cannot resolve `simctl` while the system developer directory remains set to CommandLineTools, but direct shell commands work with `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`. Computer Use did not return a usable simulator accessibility state during this pass, so direct tap-through remains an explicit open gate.

Local-first wave verification completed on 2026-08-26:

- 148 Swift files passed `xcrun swiftc -parse`.
- All forty-five local/manual targets passed an iPhoneOS device-SDK build with signing disabled.
- All forty-five targets passed an iPhone simulator build, installed, launched, and rendered a settled screenshot on iPhone 17 Pro (iOS 26.2).
- Static scanning found no URLSession or analytics dependency in the app targets. App02 Bathroom Quality Map, App23 Quiet Café Index, and App29 Local Bench Reviews intentionally use MapKit plus optional foreground Core Location; App36 Step Debt, App37 Sleep Alibi, and App39 Workout Excuse Detector intentionally import HealthKit for optional read-only native data. Each integration has a manual fallback and a per-target purpose string where required.
- QA screenshots for all forty-five targets are stored in `docs/screenshots/` and the remaining interactive acceptance cases are documented in `docs/LOCAL_FIRST_RELEASE_PLAN.md`.

Archive verification on 2026-08-26: the App03 Release archive stages successfully when signing is disabled, including the shared DumbKit module. A signed archive is still blocked by missing Xcode account credentials and a missing provisioning profile for `corp.unecessary.app03donottextthem`; this is an Apple Developer setup issue, not a source/build failure.

Pilot interaction coverage verified on 2026-08-26: `App03DoNotTextThemUITests/testDraftInterventionDeleteAndPersistence()` passed on iPhone 17 Pro (iOS 26.2) in 32.99 seconds, with 1 passed test and 0 failures. It exercises draft entry, the ten-second intervention, deletion, relaunch, and persisted rescue counters. The same test passed again in dark appearance with `accessibility-extra-extra-extra-large` Dynamic Type. The pilot app exposes deterministic UI-test reset state only when launched with `-uiTestReset`; normal launches are unchanged. The UI-test Swift source passes parse checking and iOS Simulator SDK type-checking with XCTest, the Xcode project exposes all 45 app schemes plus `App03DoNotTextThemUITests`, and both scheme files pass XML parsing.

The first runtime failures were caused by running Xcode inside the restricted shell, which prevented CoreSimulator from opening its user Library logs. Re-running with Xcode-level access restored the simulator and produced the passing result bundle at `/tmp/UnnecessaryAppsPilotUITestEscalated.xcresult`.

Current archive verification: the App03 Release archive stages successfully with signing disabled at `/tmp/UnnecessaryAppsPilotUnsignedEscalated.xcarchive`; its bundle identifier is `corp.unecessary.app03donottextthem`, marketing version `1.0`, and build `1`. The signed archive is still blocked only by Apple setup: Xcode reports `No Accounts` and no provisioning profile for the pilot bundle ID.

The final repeatable unsigned Release archive also passed from the external project drive at `build/ReleaseArchive/App03Unsigned.xcarchive` with the same bundle identifier, marketing version `1.0`, and build `1`. The remaining archive step is signing/export with the Apple Developer team and provisioning profile.

Full local-first interaction acceptance completed on 2026-08-26: the dedicated XCTest target exercised one real end-to-end flow for each of all 45 apps on a clean iPhone 17 Pro simulator (iOS 26.2, UDID `0916A2F7-ED60-44B8-8158-DC34E0F10C84`). The result was 45 passed, 0 failed, and 0 skipped in 489.620 seconds. The result bundle is stored at `build/FullUITest/Full.xcresult`. This closes the functional simulator gate for the local/manual release set; Apple signing, App Store metadata, and TestFlight upload remain separate release steps. The App 11 test now uses its actual product bundle identifier, `corp.unecessary.app11amiearly`.

Release archive sweep completed on 2026-08-26: all 45 app schemes staged unsigned Release archives for a generic iOS device. The archive verifier checked 45 archive products against the metadata manifest: bundle IDs match, marketing version is 1.0, build is 1, and the non-exempt-encryption flag is false. Archives and the TSV manifest are stored under build/local-archives/.

App Store submission preparation completed on 2026-08-26: release/app-store-metadata.json contains validated title, subtitle, promotional text, keyword, category, description, review-note, privacy-boundary, bundle-ID, and release-priority fields for all 45 apps. The metadata validator checks Apple character/byte limits and the exact Xcode bundle-ID set. The privacy matrix and support/privacy drafts are in release/APP_PRIVACY_MATRIX.md, release/SUPPORT.md, and release/PRIVACY_POLICY.md; the support and privacy URLs still need to be publicly hosted before App Store submission.

Screenshot preparation completed on 2026-08-26: one exact 1260x2736 portrait in-app PNG was generated for each app under release/screenshots/iphone-6.9/. These are functional captures derived from the verified QA screenshots; final marketing captions, sample-text review, and any additional device-size slots remain App Store Connect work.

Signing state rechecked on 2026-08-26: the Apple Account is now signed into Xcode and the project resolves development team `2CGZC35S8K` for App03 (and all 45 app targets). A signed archive retry reaches provisioning but fails because Apple reports a pending Program License Agreement and no profile for `corp.unecessary.app03donottextthem` until that agreement is accepted.

Xcode UI confirmation on 2026-08-26: Xcode Settings > Apple Accounts now shows `Fathy Shalaby (fathy.mshalaby@gmail.com)`. The owner must accept Apple’s current Developer Program License Agreement in the developer account; an automation agent must not accept a legal agreement on the owner’s behalf.

Lead-pilot signing and upload verification completed on 2026-08-26:

- Release priority was moved to Dog Name Guesser, followed by the local/native health lane: Step Debt, Sleep Alibi, and Workout Excuse Detector are the implemented HealthKit exemplars; The Recovery Goblin, Hydration Narc, and Rest Day Police remain manual or deferred. Medical-interpretation candidates remain on hold.
- All 225 AppIcon PNGs were re-exported as opaque RGB PNGs with no alpha channel; Apple’s large-icon validation requirement is now covered by the checked-in `tools/flatten_app_icons.swift` utility.
- `App24DogNameGuesser` archived successfully with signing at `build/SignedPilot/App24Signed.xcarchive`.
- Distribution export succeeded at `build/SignedPilot/App24Exported/App24DogNameGuesser.ipa`.
- App Store Connect record `6805446694` was created for `corp.unecessary.app24dognameguesser` as `Unnecessary: Dog Name Guesser`.
- The corrected build 1 upload succeeded through Xcode and App Store Connect reported that the package is processing. At the last UI check, TestFlight had not yet surfaced the processed build; this is an external processing wait, not a local build failure.
- App03 remains a signed/exported technical pilot, but it was not uploaded after the release-priority pivot.

Latest infrastructure follow-up on 2026-08-26 supersedes the earlier App24 processing note above:

- App24 now includes optional PhotosPicker selection and on-device Vision classification; no photo upload, persistence, account, or camera permission was added.
- The updated source passed an iPhoneOS 26.2 build with signing disabled.
- A signed App24 archive was produced at `build/SignedPilot/App24SignedBuild2.xcarchive`; its marketing version is 1.0, build number is 2, display name is `Dog Name Guesser`, and `ITSAppUsesNonExemptEncryption` is false.
- The build 2 distribution upload succeeded. Computer Use verified App Store Connect status `Ready to Submit`; the internal group contains 2 builds and 0 testers.
- A post-change full UI-suite rerun was attempted but could not complete because the existing simulator ran out of storage while installing app bundles (`NSPOSIXErrorDomain 28`). The prior clean-simulator result remains 45 passed; the current blocker is simulator capacity, not an app assertion failure.
- The infrastructure classification and remaining setup checklist are documented in `docs/INFRASTRUCTURE_AUDIT.md`.

Post-build-2 source verification on 2026-08-26:

- App24 and App12 now decode PhotosPicker data through ImageIO before invoking Vision, retain the selected image when the simulator lacks the classifier runtime, and label that limitation instead of presenting a generic read failure.
- The iPhone Air simulator confirmed the photo-picker flow, selected-image preview, and manual fallback. Vision itself reported `Failed to create espresso context` on this simulator, so physical-device Vision acceptance remains required before TestFlight build 3.
- Current unsigned Release archives for App12 and App24 were rebuilt after this fix at `build/LocalWave/App12.xcarchive` and `build/LocalWave/App24.xcarchive`.
- A signed App24 build 3 archive and App Store export were then produced locally at `build/SignedPilot/App24SignedBuild3.xcarchive` and `build/SignedPilot/App24Build3Export/App24DogNameGuesser.ipa`; the exported bundle is version 1.0, build 3, with non-exempt encryption set to false. It has not been uploaded.

Workout Excuse Detector HealthKit verification completed on 2026-08-26:

- App39 now requests only read access to Apple Health workout samples, sums today’s workout durations in memory, writes nothing back, uploads nothing, and retains its manual movement fallback.
- The regenerated Xcode target contains `config/App39WorkoutExcuse.entitlements` and the matching `NSHealthShareUsageDescription`.
- The iPhone 16e simulator verified the unavailable/denied HealthKit state, manual 12-minute audit, and reset flow.
- `testWorkoutExcuseDetectsAndResets()` passed with 1 test, 0 failures, and 0 skips on iPhone 16e (iOS 26.2).
- The current unsigned Release archive is `build/LocalWave/App39HealthKit.xcarchive`; its bundle identifier is `corp.unecessary.app39workoutexcuse`, version is 1.0 (1), and non-exempt encryption is false.
- A successful Apple Health read still requires the physical-device smoke pass before App39 moves into the first release lane.
# Public support and privacy site — 26 August 2026

- Public repository: https://github.com/fathyshalaby/unnecessary-apps
- Public site: https://fathyshalaby.github.io/unnecessary-apps/
- Privacy URL: https://fathyshalaby.github.io/unnecessary-apps/privacy.html
- Support URL: https://fathyshalaby.github.io/unnecessary-apps/support.html
- GitHub Pages build `32987531919` completed successfully.
- The index, privacy, and support endpoints each returned HTTP 200 after the
  deployment.
- The deployed privacy copy explicitly covers the optional PhotosPicker/Vision,
  two-second microphone-level, read-only HealthKit, and Apple Foundation Models
  paths without claiming cloud collection.
- `python3 tools/validate_store_metadata.py` validated all 45 App Store metadata
  entries after replacing the public URL placeholders.
- `git diff --check` passed.

# App29 Local Bench Reviews MapKit upgrade — 26 August 2026

- Replaced the single fictional form with a real Apple MapKit workflow:
  map-center pinning, optional foreground location recentering, an item-driven
  review editor, comfort/shade/view ratings, pigeon status, bounded notes,
  local history, markers, individual deletion, and confirmed clear-all.
- Generated bundle ID: `corp.unecessary.app29benchreviews`.
- Generated purpose string: `Local Bench Reviews uses your location only when
  you ask it to center the map near you. Reviews and coordinates stay on this
  device.`
- Warning-free Debug simulator build passed on iPhone 16e, iOS 26.2.
- The exact Debug product installed and launched. A settled simulator screenshot
  at `docs/screenshots/app29-map-verified.png` confirms the branded map-first
  screen, loaded Apple map, optional-location copy, primary review action, and
  empty ledger state.
- `testBenchReviewSavesPersistsAndClears()` passed on iPhone 16e, iOS 26.2. It
  exercised manual map-center review creation, local save, relaunch
  persistence, and confirmed clear-all.
- The focused map suite found and fixed a VoiceOver/UI-automation identifier
  collision between the Map container and its overlay controls. The current
  primary action is exposed independently.
- The current unsigned Release archive is
  `build/LocalWave/App29MapKitFinal.xcarchive`. Its bundle identifier and
  location purpose string match the generated target, and its embedded
  `Info.plist` and `PrivacyInfo.xcprivacy` both pass `plutil -lint`.
- All 45 App Store metadata entries validate, `git diff --check` passes, and no
  stale App29 “no map/location” release claim remains.
- Public policy revision `c4342de` deployed in successful GitHub Pages run
  `32989750050`; the deployed privacy and support URLs returned HTTP 200 and
  include the MapKit/location boundary.

# App23 Quiet Café Index MapKit upgrade — 26 August 2026

- Replaced the manual single-result prototype with Apple MapKit café search,
  visible-region searching, a no-search/no-location map-pin fallback, optional
  foreground recentering, and a persistent private rating ledger.
- Each local report records a real or manually named place, coordinate,
  quietness, seating, outlet odds, solo-friendliness, visit period, and a
  bounded optional note. It supports map markers, relaunch persistence,
  individual deletion, and confirmed clear-all.
- Generated purpose string: `Quiet Café Index uses your location only when you
  ask it to center the café map near you. Private ratings and coordinates stay
  on this device.`
- The production source and DumbKit dependency pass a strict direct Swift 5
  type-check against the arm64 iOS 17 Simulator SDK and a warning-free Debug
  Xcode build on iPhone 16e, iOS 26.2.
- `testQuietCafeSavesPersistsAndClearsWithoutLocation()` passed and covered the
  deterministic map-pin create/save/relaunch/clear path.
- `testQuietCafeSearchReachesAUsefulOutcome()` passed against Apple Maps. It
  requires search to terminate with results, a truthful no-results state, or a
  clearly usable manual fallback instead of assuming fixed third-party venue
  data.
- Visual QA passed with the settled capture at
  `docs/screenshots/app23-map-verified.png`; the map, controls, privacy copy,
  mascot, and empty state render without clipping on iPhone 16e.
- The current unsigned Release archive is
  `build/LocalWave/App23MapKitFinal.xcarchive`. Its bundle identifier and
  location purpose string match the generated target, and its embedded
  `Info.plist` and `PrivacyInfo.xcprivacy` both pass `plutil -lint`.
- All 45 metadata records validate, `git diff --check` passes, and public policy
  revision `03e6186` deployed successfully with HTTP 200 verification.
- Real-device location grant/denial remains a physical-device acceptance gate;
  location is optional and the no-permission path is simulator-verified.

# App02 Public Bathroom Quality Map upgrade — 26 August 2026

- Removed all fictional seeded bathrooms and replaced them with Apple MapKit
  natural-language restroom search, possible-result labeling, manual map-pin
  fallback, optional foreground recentering, and persistent private reports.
- Each local report records coordinate, cleanliness, privacy, supplies, queue,
  changing-table observation, and a bounded optional note. The UI explicitly
  requires users to verify access, hours, conditions, and accessibility on
  arrival and does not present itself as an emergency service.
- Generated purpose string: `Bathroom Quality Map uses your location only when
  you ask it to center the restroom map near you. Private reports and
  coordinates stay on this device.`
- The production source and DumbKit dependency pass a strict direct Swift 5
  type-check against the arm64 iOS 17 Simulator SDK and a warning-free Debug
  Xcode build on iPhone 16e, iOS 26.2.
- `testBathroomMapSavesPersistsAndClearsWithoutLocation()` passed and covered
  the deterministic map-pin create/save/relaunch/clear path.
- `testBathroomMapSearchReachesAUsefulOutcome()` passed against Apple Maps. It
  requires search to terminate with results, a truthful no-results state, or a
  clearly usable manual fallback instead of assuming fixed third-party venue
  data.
- Visual QA passed with the settled capture at
  `docs/screenshots/app02-map-verified.png`; the safety warning, map controls,
  privacy copy, mascot, and empty state render without clipping on iPhone 16e.
- The current unsigned Release archive is
  `build/LocalWave/App02MapKitFinal.xcarchive`. Its bundle identifier and
  location purpose string match the generated target, and its embedded
  `Info.plist` and `PrivacyInfo.xcprivacy` both pass `plutil -lint`.
- All 45 metadata records validate, `git diff --check` passes, and no stale
  fictional/no-map claim remains in current release, product-plan, evaluation,
  or social-script documentation.
- Public policy revision `41a95fe` deployed in successful GitHub Pages run
  `33011001334`; the deployed privacy and support URLs returned HTTP 200 and
  include the Public Bathroom MapKit/location boundary.
- Real-device location grant/denial and human review of restroom result quality
  remain physical-device acceptance gates; location is optional and the
  no-permission path is simulator-verified.

Focused MapKit verification used the generated `MapAppsUITests` shared scheme,
which builds only the three map apps and the UI-test runner. DerivedData was
kept on the external project drive to avoid the system-disk exhaustion that
cancelled the earlier all-target attempt. The core result bundle at
`build/TestResults/MapAppsFocused3.xcresult` reports 3 passed and 0 failed; the
live-search result bundle at `build/TestResults/MapAppsSearch2.xcresult`
reports 2 passed and 0 failed.

# On-device generative apps hardening — 27 August 2026

- App19 Bad Advice from a Medieval Peasant and App30 Apology Draft Generator
  use Apple Foundation Models only when the system model reports available.
  Both retain deterministic, private local fallbacks and make no cloud request.
- A stricter focused UI run exposed that the Simulator can report the model
  available while generation remains slow enough to strand the primary action.
  Both apps now enforce a 12-second UX deadline, immediately return their local
  fallback at that deadline, and ignore any stale late model response by
  generation ID. Reset also invalidates in-flight work.
- Result and model-status regions now expose stable combined accessibility
  elements so VoiceOver and UI automation can distinguish output, engine path,
  and reset state.
- App19 and App30 pass direct Swift 5 type-checking with complete concurrency
  warnings enabled against the arm64 iOS 17 Simulator SDK. Store metadata and
  `git diff --check` also pass.
- `GenerativeAppsUITests` now selects only the two intended XCTest methods and
  builds only App19, App30, and the UI-test runner. Automated tests pass a
  launch argument that forces the deterministic local fallback, avoiding an
  unrelated Simulator model-asset download while still exercising input,
  generation, copy/reset, accessibility output, and fallback disclosure.
- `build/TestResults/GenerativeAppsVerified.xcresult` reports 2 passed and 0
  failed on the iPhone 16e iOS 26.2 Simulator. The tests assert the changing
  accessibility value rather than the stable “Official result” label, closing
  an earlier false-positive gap.
- Current unsigned Release archives are
  `build/LocalWave/App19MedievalAdviceFinal.xcarchive` and
  `build/LocalWave/App30ApologyDraftFinal.xcarchive`. Both package the expected
  bundle ID, version 1.0 build 1, executable, and a valid no-tracking privacy
  manifest. App30 received an explicit empty/no-tracking manifest after the
  first archive audit found it absent.
- The real Apple Foundation Models path remains a physical supported-device
  acceptance gate. Production still attempts it first, enforces the 12-second
  deadline, and falls back locally without a network dependency.

# App01 Chair Finder local-first replacement — 27 August 2026

- Removed the three hard-coded fictional chair candidates and all implied
  nearby-place discovery.
- The current app accepts up to 20 user-observed chairs with a nickname,
  comfort, shade, pigeon risk, and optional bounded field note. It computes a
  transparent local SIT score, ranks only those observations, persists the
  shortlist and verdict across relaunches, supports individual deletion, and
  provides confirmed clear-all.
- Store metadata, the app README, release order, evaluation, and launch scripts
  now describe the user-created workflow instead of seeded fiction.
- App01 passes direct Swift 5 type-checking with complete concurrency warnings
  enabled against the arm64 iOS 17 Simulator SDK. All 45 metadata records and
  git diff --check pass.
- testChairFinderInspectsAndResets() now covers two real user-created
  candidates, ranking, relaunch persistence, and confirmed clear-all. The
  generated ChairFinderUITests scheme selects only that method and builds App01
  plus the UI-test runner.
- `build/TestResults/ChairFinderPostFix.xcresult` reports 1 passed and 0 failed
  on iPhone 16e. Visual evidence is
  `docs/screenshots/app01-chair-finder-verified.png`; the empty-state hierarchy,
  mascot, first form field, and private count render without clipping.
- `build/LocalWave/App01ChairFinderFinal.xcarchive` is the current unsigned
  Release archive. Its packaged bundle ID is
  `corp.unecessary.app01chairfinder`, version 1.0 build 1; its executable and
  valid no-tracking privacy manifest are present.

# App27 Tiny Personal Museum collection upgrade — 27 August 2026

- Replaced the single overwriting exhibit with a private catalog of up to 30
  exhibits. Every item stores a bounded title and curator story, generated
  placard, creation time, and optional protected photo.
- User-selected photos are resized to a maximum 1,600-point side, re-encoded as
  JPEG to discard source metadata, and written with complete file protection.
  Nothing is uploaded, published, analyzed, or synced.
- Catalog and photo writes are transactional: a failed catalog save removes a
  newly written orphan image, and individual deletion saves the new catalog
  before removing its photo. Complete erasure reports a failure instead of
  falsely presenting an empty museum.
- The UI supports relaunch persistence, individual deaccession, draft reset,
  confirmed complete erasure, truthful empty/error states, and stable
  accessibility identifiers.
- App27 passes direct Swift 5 type-checking with complete concurrency warnings
  enabled against the arm64 iOS 17 Simulator SDK. Metadata validation and
  git diff --check pass.
- testTinyMuseumOpensAndResets() now covers two exhibits, relaunch persistence,
  individual deletion, and confirmed complete erasure. The generated
  TinyMuseumUITests scheme selects only that method and builds App27 plus its
  test runner.
- `build/TestResults/TinyMuseumVerified.xcresult` reports 1 passed and 0 failed
  on iPhone 16e. Visual evidence is
  `docs/screenshots/app27-tiny-museum-verified.png`; its purple museum identity,
  mascot, protected-files status, empty catalog, and curator desk render cleanly.
- `build/LocalWave/App27TinyMuseumFinal.xcarchive` is the current unsigned
  Release archive. Its packaged bundle ID is
  `corp.unecessary.app27tinymuseum`, version 1.0 build 1; its executable and
  valid no-tracking privacy manifest are present.
- Selecting, cancelling, and saving a real photo remains a physical-device or
  interactive PhotosPicker acceptance gate. The text-only catalog lifecycle is
  Simulator-verified and the production photo pipeline is present in the
  archived build.

# App20 Real Email local clarity audit — 27 August 2026

- Replaced raw substring counting with exact token/phrase matching, so text
  such as “adjust” no longer falsely counts as the fog marker “just.”
- The app now reports word, sentence, paragraph, and average-sentence metrics;
  exact matched phrases and counts; explicit ask/deadline signals; a published
  deterministic 0–100 clarity score; and a concrete local surgery plan.
- Editing evidence invalidates stale analysis immediately. Pasted text and
  results remain in `@State`, are never persisted or uploaded, and start empty
  after relaunch.
- `RealEmailUITests` selects only `testRealEmailAnalyzesAndClears()` and builds
  only App20 plus the UI-test runner. The test proves a three-marker foggy case
  scores 79, clear/reset behavior, `adjust` does not match `just` and scores
  100, and relaunch retains neither evidence nor metrics.
- `build/TestResults/RealEmailFocused4.xcresult` reports 1 passed and 0 failed
  on iPhone 16e iOS 26.2. Visual evidence is
  `docs/screenshots/app20-real-email-verified.png`.
- `build/LocalWave/App20RealEmailFinal.xcarchive` is the current unsigned
  Release archive. Its packaged ID is `corp.unecessary.app20realemail`, version
  1.0 build 1; the executable and canonical no-tracking
  `PrivacyInfo.xcprivacy` are present and parse successfully.

# App10 What Was I Doing context-memory upgrade — 27 August 2026

- Replaced the timestamp-only tap counter with a bounded private archive of up
  to 100 incidents. Each incident records a context category, timestamp, and
  optional 120-character last-known mission.
- The dashboard now reports today’s total and the most common interruption
  context. The recent ledger supports individual deletion, while a confirmed
  evidence menu can erase today or the complete local archive.
- Existing timestamp-only JSON records migrate without data loss as
  “Unspecified” incidents with an empty note.
- `MemoryLogUITests` selects only
  `testWhatWasIDoingRecordsAndPersists()`. The test creates two named incidents,
  proves both survive relaunch, deletes one, and confirms complete erasure. A
  first run exposed an accessibility-refresh race after deletion; the final
  test waits for the observable SwiftUI state transition.
- `build/TestResults/MemoryLogFocused2.xcresult` reports 1 passed and 0 failed
  on iPhone 16e iOS 26.2. Visual evidence is
  `docs/screenshots/app10-memory-log-verified.jpg`; the lavender memory-services
  identity, empty dashboard, context menu, note field, and primary action
  render without clipping in the launch viewport.
- `build/LocalWave/App10WhatWasIDoingFinal.xcarchive` is the current unsigned
  Release archive. Its packaged ID is
  `corp.unecessary.app10whatwasidoing`, version 1.0 build 1; the executable and
  canonical no-tracking privacy manifest are present. The manifest declares
  the required `CA92.1` reason for app-private UserDefaults persistence.

# App18 Tiny Gratitude journal upgrade — 27 August 2026

- Added five useful tiny-win categories, today/total/unique-day summaries, a
  five-item recent view with complete-history browsing, random resurfacing,
  individual deletion, and confirmed full-archive erasure.
- Existing journal JSON migrates without loss into the categorized format as
  “Unsorted tiny win.” New entries remain capped at 180 characters and the
  local archive remains capped at 100 records.
- `GratitudeUITests` selects only
  `testTinyGratitudeArchivesAndClears()`. The test creates two named entries,
  verifies summary counts and visible history, proves relaunch persistence,
  deletes one entry, and confirms full erasure.
- `build/TestResults/GratitudeFocused2.xcresult` reports 1 passed and 0 failed
  on iPhone 16e iOS 26.2. Visual evidence is
  `docs/screenshots/app18-tiny-gratitude-verified.jpg`; the blue identity,
  mascot, three-metric dashboard, categorized editor, disabled empty action,
  and result card render cleanly without clipping.
- `build/LocalWave/App18TinyGratitudeFinal.xcarchive` is the current unsigned
  Release archive. Its packaged ID is `corp.unecessary.app18tinygratitude`,
  version 1.0 build 1; the executable and canonical no-tracking privacy
  manifest are present. The manifest includes the `CA92.1` required reason for
  app-private UserDefaults persistence.

# App28 Overthinking Evidence Board safety and workflow upgrade — 27 August 2026

- Replaced the one-sided counter-evidence prompt and unconditional reassuring
  verdict with a five-part board: worry, supporting evidence, counter-evidence,
  alternative explanation, and one small next step.
- The deterministic result transparently reports “Case unproven,” “Case
  weakened,” “Counter-evidence missing,” or “Evidence mixed” based only on
  whether the user supplied each evidence side. It explicitly does not claim
  truth, safety, diagnosis, or treatment authority.
- Current draft fields continue to persist locally. Completed boards now create
  a separate bounded archive of up to 50 private case files with recent/full
  browsing, duplicate suppression, individual deletion, and confirmed
  erase-all. Clearing the draft does not silently erase the archive.
- `OverthinkingUITests` selects only
  `testOverthinkingBoardReachesAndClearsConclusion()`. The test fills all five
  sections, verifies the mixed-evidence status and next step, proves draft and
  archive persistence across relaunch, deletes the case, and clears the draft.
- `build/TestResults/OverthinkingFocused.xcresult` reports 1 passed and 0
  failed on iPhone 16e iOS 26.2. Visual evidence is
  `docs/screenshots/app28-overthinking-verified.jpg`; the red investigation
  identity, mascot, safety boundary, and structured board render cleanly.
- `build/LocalWave/App28OverthinkingBoardFinal.xcarchive` is the current
  unsigned Release archive. Its packaged ID is
  `corp.unecessary.app28overthinkingboard`, version 1.0 build 1; the executable
  and canonical no-tracking privacy manifest with the app-private UserDefaults
  `CA92.1` reason are present and parse successfully.

# App43 Hydration Narc configurable local ledger — 27 August 2026

- Removed the implied universal eight-glass recommendation. The user now
  chooses a personal 1–16 serving reminder goal, and the UI explicitly says a
  serving is user-defined and the target is not medical advice.
- Added one-step undo, a 24-serving safety cap for accidental tapping, persisted
  same-day state, confirmed today-only reset, and a bounded seven-day local
  ledger populated automatically at calendar rollover.
- The initial visual pass found the primary action compressed into an
  unacceptable four-line button beside Undo. The final layout restores the
  full-width primary action and keeps Undo visually secondary.
- `HydrationUITests` selects only `testHydrationNarcLogsAndResets()`. With an
  explicit UI-test-only day override, the test logs and undoes servings, proves
  same-day relaunch persistence, advances from 2099-01-02 to 2099-01-03,
  verifies the prior summary and fresh zero count, and confirms resetting today
  preserves yesterday.
- `build/TestResults/HydrationFocused3.xcresult` reports 1 passed and 0 failed
  on iPhone 16e iOS 26.2. Visual evidence is
  `docs/screenshots/app43-hydration-verified.jpg`; the blue bottle-oversight
  identity, mascot, safety boundary, progress ring, goal slider, and corrected
  action hierarchy render cleanly.
- `build/LocalWave/App43HydrationNarcFinal.xcarchive` is the current unsigned
  Release archive. Its packaged ID is `corp.unecessary.app43hydrationnarc`,
  version 1.0 build 1; the executable and canonical no-tracking privacy
  manifest with the app-private UserDefaults `CA92.1` reason are present and
  parse successfully.

# App13 Toilet Timer background timer + Live Activity — 29 August 2026

- Replaced foreground interval accumulation with one persisted wall-clock start
  date. Home, lock, suspension, termination, and relaunch now preserve the real
  elapsed duration instead of pausing or losing the active session.
- Added exact local milestone notifications for 5, 10, 15, and 20 minutes.
  Starting a new session replaces stale timer alerts; stop and reset cancel the
  current session's remaining alerts.
- Added a real WidgetKit/ActivityKit extension with Lock Screen and Dynamic
  Island expanded, compact, and minimal presentations. The app and extension
  share `BathroomTimerAttributes`; no fake in-app island is used.
- Fixed the nonfunctional manual fallback: the 1–60 minute estimate now has an
  independent assessment action rather than requiring an impossible live-timer
  stop path.
- Added a bounded 20-session private history that distinguishes measured and
  estimated sessions, persists across relaunch, supports individual deletion,
  and requires confirmation before complete erasure. Current-session reset no
  longer silently removes history.
- `ToiletTimerUITests` selects only
  `testToiletTimerAssessesAndResets()`. The test advances a real live timer,
  presses Home and proves those seconds were counted, terminates and relaunches
  the process while running and proves the clock continued, then stops,
  assesses, verifies history, deletes the live record, files a manual estimate,
  and confirms complete history erasure.
- `build/TestResults/ToiletTimerLiveActivityBuild2.xcresult` reports 1 passed
  and 0 failed on iPhone 16e iOS 26.2. Visual evidence is
  `docs/screenshots/app13-toilet-timer-live.png`; the screenshot was captured
  after the same session continued to 49 minutes while simulator work happened
  elsewhere.
- `build/LocalWave/App13ToiletTimerLiveActivityBuild2.xcarchive` is the current
  unsigned Release archive. Its packaged app is version 1.0 build 2 with
  `NSSupportsLiveActivities = true`; the embedded build-2 extension has bundle
  ID `corp.unecessary.app13toilettimer.liveactivity` and the validated
  `com.apple.widgetkit-extension` extension point.

# App17 Meeting Bingo complete-game invariant — 27 August 2026

- Preserved the real randomized 3×3 board, center free space, eight-line bingo
  detection, and local board/mark persistence while fixing completed-game
  inflation: each dealt board can now increment statistics only once.
- The current-board-won flag persists independently, so breaking a winning line,
  relaunching, and rebuilding it cannot count the same meeting twice.
- Added confirmed complete local-data erasure for the active board, marks,
  once-per-board state, and completed-game count.
- `MeetingBingoUITests` selects only `testMeetingBingoMarksAndPersists()`. The
  test erases prior state, marks a complete row, verifies BINGO and one completed
  game, breaks and restores the line without double-counting, proves relaunch
  persistence, deals a fresh board with its free center, and confirms full
  erasure.
- `build/TestResults/MeetingBingoFocused.xcresult` reports 1 passed and 0 failed
  on iPhone 16e iOS 26.2. Visual evidence is
  `docs/screenshots/app17-meeting-bingo-verified.jpg`; the entire readable board,
  header statistics, free-space treatment, and corporate-navy identity fit
  cleanly in the launch viewport.
- `build/LocalWave/App17MeetingBingoFinal.xcarchive` is the current unsigned
  Release archive. Its packaged ID is `corp.unecessary.app17meetingbingo`,
  version 1.0 build 1; the executable and canonical no-tracking privacy
  manifest with the app-private UserDefaults `CA92.1` reason are present and
  parse successfully. App17 is now promoted from the later local wave into the
  first release lane.

# App22 Snack Roulette user-owned pantry upgrade — 27 August 2026

- Removed the fake default pantry so first launch contains no implied user data.
  Input is trimmed and case-insensitively deduplicated, and spinning is disabled
  until at least one valid option exists.
- Preserved random selection while verifying the immediate-repeat invariant:
  with at least two options, the previous pick is excluded from candidates.
- Exposed the complete bounded 20-spin history instead of hiding all but five,
  added individual deletion, and made confirmed complete erasure remove the
  pantry, latest ruling, and history together.
- A focused run exposed an obsolete editor-container accessibility identifier
  swallowing the validated option count. Removing it restored independent
  VoiceOver/test access to the editor and count.
- `SnackRouletteUITests` selects only `testSnackRouletteSpinsAndClears()`. The
  test proves case-insensitive deduplication, two-choice non-repetition, pantry
  and history persistence, individual deletion, and confirmed complete erasure.
- `build/TestResults/SnackRouletteFocused2.xcresult` reports 1 passed and 0
  failed on iPhone 16e iOS 26.2. Visual evidence is
  `docs/screenshots/app22-snack-roulette-verified.jpg`; the empty pantry, option
  count, disabled spin, result, empty history, mascot, and red identity render
  cleanly.
- `build/LocalWave/App22SnackRouletteFinal.xcarchive` is the current unsigned
  Release archive. Its packaged ID is `corp.unecessary.app22snackroulette`,
  version 1.0 build 1; the executable and canonical no-tracking privacy
  manifest with the app-private UserDefaults `CA92.1` reason are present and
  parse successfully. App22 is now in the first release lane.

# App11 Am I Early private punctuality log — 27 August 2026

- Replaced the one-shot slider result with a repeatable local arrival workflow:
  optional occasion, signed offset from 30 minutes late to 60 minutes early,
  five explicit verdict levels, and a bounded 30-record private history.
- Added filed/not-late/late summaries, recent/full-history browsing, individual
  record deletion, current-report reset that preserves history, stale-verdict
  invalidation after edits, and confirmed complete erasure.
- `PunctualityUITests` selects only `testAmIEarlyCalculatesAndResets()`. The test
  files a 12-minute-early Dentist arrival, adjusts the real slider to -30 and
  verifies the severe late verdict, checks balanced summary totals, proves
  relaunch persistence, deletes one record, resets current input, and confirms
  complete deletion.
- `build/TestResults/PunctualityFocused.xcresult` reports 1 passed and 0 failed
  on iPhone 16e iOS 26.2. Visual evidence is
  `docs/screenshots/app11-punctuality-verified.jpg`; the green identity, mascot,
  three-metric summary, signed-offset explanation, editor, primary action, and
  result card render cleanly.
- `build/LocalWave/App11AmIEarlyFinal.xcarchive` is the current unsigned Release
  archive. Its packaged ID is `corp.unecessary.app11amiearly`, version 1.0
  build 1; the executable and canonical no-tracking privacy manifest with the
  app-private UserDefaults `CA92.1` reason are present and parse successfully.
  App11 is now promoted to release wave 1 and the first release lane.

# App14 One More Episode exact forecast upgrade — 27 August 2026

- Replaced the old one-shot, approximate formula—which truncated a default
  45-minute episode to zero hours—with exact minute arithmetic. Users now set
  1–8 episodes, 15–120 minutes per episode, and their own 4–12 hour sleep
  budget, with an optional show name.
- Published the calculation boundary in the UI: every watch minute is
  subtracted from the budget the user chooses. The app does not infer bedtime,
  access sleep data, or claim to determine medical sleep needs.
- Added a bounded 20-record private forecast history, recent/full browsing,
  individual deletion, current-forecast reset that preserves history, stale
  result invalidation after input edits, and confirmed complete erasure.
- `EpisodeForecastUITests` selects only
  `testEpisodeForecastCalculatesAndResets()`. The test proves the default
  45-minute result leaves 7 hours 15 minutes, the eight-episode maximum equals
  six hours and leaves two hours, verifies relaunch persistence, deletes one
  record, resets current inputs, and confirms full data erasure.
- `build/TestResults/EpisodeForecastFocused.xcresult` reports 1 passed and 0
  failed on iPhone 16e iOS 26.2. Visual evidence is
  `docs/screenshots/app14-episode-forecast-verified.jpg`; the purple streaming
  identity, mascot, published assumption, and three-control editor render
  cleanly without collisions or clipped text.
- `build/LocalWave/App14OneMoreEpisodeFinal.xcarchive` is the current unsigned
  Release archive. Its packaged ID is
  `corp.unecessary.app14onemoreepisode`, version 1.0 build 1; the executable and
  canonical no-tracking privacy manifest with the app-private UserDefaults
  `CA92.1` reason are present and parse successfully. App14 is now promoted to
  release wave 1 and the first release lane.

# App15 Can I Wear This Again personal-rule ledger — 27 August 2026

- Removed the false implication that elapsed resting days make clothing clean.
  The app now publishes its boundary: time is only playful social-repeat
  context, while the care ruling uses a user-defined maximum-wear limit and
  condition evidence the user explicitly marks.
- Added completed wears since washing, a personal 1–10 wear limit, optional
  item name, and odor, visible-stain, and sweaty/intense-wear flags. The result
  shows exact projected-wear arithmetic and prioritizes marked condition flags.
- Added a bounded 30-record private ruling history, filed/approved/laundry
  summary, recent/full browsing, individual deletion, stale-ruling
  invalidation, current-evidence reset, and confirmed complete erasure.
- `ClosetRulingUITests` selects only
  `testClosetRulingAsksAndResets()`. The test proves an approved default second
  wear, a projected eleventh wear above a three-wear personal limit, and an
  odor-triggered laundry ruling; it then verifies summary counts, relaunch
  persistence, granular deletion, reset, and complete erasure.
- `build/TestResults/ClosetRulingFocused.xcresult` reports 1 passed and 0 failed
  on iPhone 16e iOS 26.2. Visual evidence is
  `docs/screenshots/app15-closet-ruling-verified.jpg`; the coral wardrobe-office
  identity, mascot, honesty card, three-metric summary, and editor render
  cleanly with a strong hierarchy.
- `build/LocalWave/App15CanIWearThisAgainFinal.xcarchive` is the current
  unsigned Release archive. Its packaged ID is
  `corp.unecessary.app15caniwearthisagain`, version 1.0 build 1; the executable
  and canonical no-tracking privacy manifest with the app-private UserDefaults
  `CA92.1` reason are present and parse successfully. App15 is now promoted to
  release wave 1 and the first release lane.

# App16 Microwave Sommelier exact wattage conversion — 27 August 2026

- Removed the hidden fixed assumption that every dish starts at four minutes
  and 800 W. Users now enter package minutes and seconds, package instruction
  wattage, actual microwave wattage, and an optional food label.
- Published and implemented the proportional conversion formula: package time
  × package wattage ÷ actual wattage, rounded to five seconds. Results expose
  exact source/target values and a separately calculated 80% first checkpoint.
- The UI explicitly limits the claim to timing conversion: the app cannot
  measure temperature, doneness, or food safety and does not control an
  appliance. Added a bounded 20-record private history, full browsing,
  individual deletion, current reset, stale-result invalidation, and confirmed
  complete erasure.
- `MicrowaveConversionUITests` selects only
  `testMicrowaveSommelierPairsAndResets()`. The test proves 4:00 at 1000 W
  converts to 5:00 at 800 W with a 4:00 checkpoint, then to 8:00 at 500 W with
  a 6:25 checkpoint; it also verifies persistence, deletion, reset, and erase.
- `build/TestResults/MicrowaveConversionFocused.xcresult` reports 1 passed and
  0 failed on iPhone 16e iOS 26.2. Visual evidence is
  `docs/screenshots/app16-microwave-conversion-verified.jpg`; the red culinary
  identity, wine-cellar microwave mascot, formula card, and package-label input
  order render cleanly without becoming a generic settings screen.
- `build/LocalWave/App16MicrowaveSommelierFinal.xcarchive` is the current
  unsigned Release archive. Its packaged ID is
  `corp.unecessary.app16microwavesommelier`, version 1.0 build 1; the executable
  and canonical no-tracking privacy manifest with the app-private UserDefaults
  `CA92.1` reason are present and parse successfully. App16 remains release
  wave 1 and is now aligned with the first release lane.

# App04 Social Battery Receipt honest event log — 27 August 2026

- Removed the arbitrary “damage” score that ignored duration and multiplied an
  energy drop by people. The app now records only user-supplied event context
  and the exact signed difference between before/after energy scores.
- Added an optional event name and explicit drain, recharge, and break-even
  paths. Duration and people remain visible context rather than pretending to
  be psychological predictors; the UI states that it does not diagnose or
  decide how much socializing is healthy.
- Added a bounded 30-receipt private archive, filed-event/total-time/average-
  change summary, recent/full browsing, individual deletion, stale-receipt
  invalidation, current reset, and confirmed complete erasure.
- `SocialBatteryUITests` selects only
  `testSocialBatteryPrintsAndResets()`. The final run proves a five-point drain
  over 60 minutes and a two-point recharge, then verifies relaunch persistence,
  individual deletion, current reset, and complete erasure. Earlier runs
  exposed offscreen XCTest interactions; the final test explicitly requires
  the real slider and action to be hittable before using them.
- `build/TestResults/SocialBatteryFocused3.xcresult` reports 1 passed and 0
  failed on iPhone 16e iOS 26.2. Visual evidence is
  `docs/screenshots/app04-social-battery-verified.jpg`; the purple receipt
  identity, mascot, no-fake-psychology boundary, metrics, and selected editor
  render cleanly with strong hierarchy.
- `build/LocalWave/App04SocialBatteryReceiptFinal.xcarchive` is the current
  unsigned Release archive. Its packaged ID is
  `corp.unecessary.app04socialbatteryreceipt`, version 1.0 build 1; the
  executable and canonical no-tracking privacy manifest with the app-private
  UserDefaults `CA92.1` reason are present and parse successfully. App04 remains
  release wave 1 and is now promoted into the first release lane.

# App05 Fridge Witness zero-seed inventory — 27 August 2026

- Removed the five fictional starter items and generic statement that ignored
  which evidence was selected. First launch is now truthfully empty and all
  inventory belongs to the user.
- Added item/container name, quantity, and optional manually entered use-by
  reminder. Matching case-insensitive names with the same reminder date merge
  into one row, with a 99-unit cap; the dashboard reports item types, total
  units, and reminders due within three days or already overdue.
- Interrogation now summarizes real inventory totals and reminder status. “Use
  one” decrements multi-unit rows, “Remove item” deletes a row, and confirmed
  erasure clears the complete local inventory. Every reminder surface states
  that dates do not determine freshness or food safety.
- `FridgeInventoryUITests` selects only
  `testFridgeWitnessInterrogatesAndClears()`. The final run proves the empty
  first-use state, filing, case-insensitive merge from one to two units,
  truthful reminder summary, relaunch persistence, decrement back to one,
  row removal, re-add, and confirmed total erasure. Three earlier runs exposed
  the nonlinear XCTest coordinate mapping near the quantity slider’s first
  step; the final test proves multi-unit behavior through the deterministic
  merge path instead of asserting an unreliable gesture coordinate.
- `build/TestResults/FridgeInventoryFocused4.xcresult` reports 1 passed and 0
  failed on iPhone 16e iOS 26.2. Visual evidence is
  `docs/screenshots/app05-fridge-inventory-verified.jpg`; the green detective
  identity, fridge mascot, user-entered-date boundary, empty metrics, and case-
  filing editor render cleanly without resembling a generic grocery list.
- `build/LocalWave/App05FridgeWitnessFinal.xcarchive` is the current unsigned
  Release archive. Its packaged ID is `corp.unecessary.app05fridgewitness`,
  version 1.0 build 1; the executable and canonical no-tracking privacy
  manifest with the app-private UserDefaults `CA92.1` reason are present and
  parse successfully. App05 remains release wave 1 and is now promoted into
  the first release lane.

# App06 Receipt Emotional Damage private purchase ledger — 27 August 2026

- Removed arbitrary €30/€100 spending thresholds and hard moral verdicts. The
  app now publishes and applies one exact calculation: purchase amount divided
  by user-entered intended uses, rounded to cents.
- Added purchase name, category, intended uses, user-labelled planned/impulse
  context, robust EUR parsing, a bounded 50-entry private ledger, count/amount/
  impulse summaries, recent/full browsing, individual deletion, current reset,
  and confirmed complete erasure.
- Added an optional 1–30 day one-shot local review reminder. Notification
  permission is requested only after the user files a reminded purchase;
  deleting an entry or erasing all data removes its pending and delivered
  notification identifiers. Filing still works when permission is denied.
- Replaced the generic result card with a custom animated receipt-paper invoice
  using monospaced type, barcode, red rule, perforation details, slight physical
  rotation, and a hard-edged shadow.
- `PurchaseLedgerUITests` selects only
  `testReceiptDamageReportsAndClears()`. The focused run proves comma-decimal
  parsing, exact €12.50 ÷ 10 = €1.25 arithmetic, planned and impulse entries,
  €25.00 summary totals, relaunch persistence, granular deletion, current reset,
  and confirmed complete erasure.
- `build/TestResults/PurchaseLedgerFocused6.xcresult` reports 1 passed and 0
  failed on iPhone 16e iOS 26.2. Visual evidence is
  `docs/screenshots/app06-purchase-ledger-verified.jpg`; the custom invoice,
  reminder control, hierarchy, and destructive actions render cleanly.
- `build/LocalWave/App06ReceiptEmotionalDamageFinal3.xcarchive` is the current
  unsigned Release archive. Its packaged ID is
  `corp.unecessary.app06receiptemotionaldamage`, version 1.0 build 1; the
  executable and canonical no-tracking privacy manifest with the app-private
  UserDefaults `CA92.1` reason are present and parse successfully. App06 remains
  release wave 1 and is now promoted into the first release lane.
- App06 now uses the same shared local notification coordinator as App07, with
  generic lock-screen copy, centralized cancellation, and 09:00–20:30 delivery
  adjustment. The post-migration focused run and Release archive are the
  `Focused6` and `Final3` artifacts listed above.

# App07 Sock Tribunal private case docket — 27 August 2026

- Removed the fictional prefilled “blue sock” and the synthetic case number
  derived from a slider. First launch is now truthfully empty.
- Added a real local case model with user-entered description, color, pattern,
  optional last-seen location, exact missing-since date, derived elapsed days,
  and explicit open, reunited, and closed-unsolved states. The court never
  closes a case automatically.
- Added a bounded 75-case private docket with active-first ordering, open/
  reunited/oldest summaries, relaunch persistence, reopening, individual
  deletion, reusable draft clearing, and confirmed complete erasure.
- Added the shared `DumbLocalNotifications` foundation and changed the Xcode
  generator to compile every shared Swift source automatically. App07 can attach
  one optional 1–14 day recheck to an open case, defers permission until filing,
  uses generic lock-screen copy, adjusts delivery into 09:00–20:30, and cancels
  reminders on resolution, deletion, eviction, or complete erasure.
- Replaced the generic result with a navy-and-gold court order, dashed document
  border, wax-seal treatment, monospaced docket labels, and compact case cards.
- `SockDocketUITests` selects only
  `testSockTribunalTracksAndResolvesCases()`. The final run proves empty first
  use, contextual notification opt-in without an early system prompt, filing,
  exact zero-day arithmetic, summary totals, relaunch persistence, reunion,
  reopening, unsolved closure, individual deletion, reuse, and total erasure.
- `build/TestResults/SockDocketFocused5.xcresult` reports 1 passed and 0 failed
  on iPhone 16e iOS 26.2. Visual evidence is
  `docs/screenshots/app07-sock-docket-hero.jpg` and
  `docs/screenshots/app07-sock-docket-verified.jpg`; the unique courtroom
  hierarchy, empty docket, filing controls, and court order render cleanly.
- `build/LocalWave/App07SockTribunalFinal.xcarchive` is the current unsigned
  Release archive. Its packaged ID is `corp.unecessary.app07socktribunal`,
  version 1.0 build 1; the executable and canonical no-tracking privacy manifest
  with the app-private UserDefaults `CA92.1` reason are present and parse
  successfully. App07 remains release wave 1 and is now promoted into the first
  release lane.

# App09 Laundry Mountain private load queue — 27 August 2026

- Removed the arbitrary height × 2 + days “threat score” and one-report reset.
  First launch is now truthfully empty.
- Added a bounded 50-batch private queue with name, category, user-estimated
  loads, editable wash/dry expectations, and explicit Dirty → Washing → Drying
  → Folding → Done stages. Nothing advances automatically.
- Folding completes exactly one load. Multi-load batches return to Dirty until
  all loads are finished; users can correct a stage, reopen one finished load,
  edit without duplication, delete one batch, or confirm complete erasure.
- Added active-batch, remaining-load, and finished-load summaries plus active-
  first queue ordering and relaunch persistence.
- Added optional one-shot Washing/Drying checkpoints through the shared local
  notification coordinator. Permission is deferred until a timed stage starts;
  generic copy, quiet hours, and stale-request cancellation are enforced.
- Replaced the generic result with a blue topographic expedition ticket, dashed
  trail border, five-stage icon route, and private load queue.
- `LaundryQueueUITests` selects only
  `testLaundryMountainTracksCompleteBatchLifecycle()`. The run proves truthful
  empty use, opt-in explanation, two-load filing, exact summaries, relaunch,
  all five stages twice, duration use, editing, completion, reopening,
  individual deletion, reuse, and total erasure.
- `build/TestResults/LaundryQueueFocused.xcresult` reports 1 passed and 0 failed
  on iPhone 16e iOS 26.2. Visual evidence is
  `docs/screenshots/app09-laundry-queue-hero.jpg` and
  `docs/screenshots/app09-laundry-queue-verified.jpg`.
- `build/LocalWave/App09LaundryMountainFinal.xcarchive` is the current unsigned
  Release archive. Its packaged ID is `corp.unecessary.app09laundrymountain`,
  version 1.0 build 1; executable and no-tracking/UserDefaults privacy-manifest
  checks pass. App09 remains release wave 1 and is now promoted into the first
  release lane.

# App08 Plant Court private care journal — 27 August 2026

- Removed the fictional prefilled plant, arbitrary neglect verdict, and
  single-record reset loop. First launch is now truthfully empty.
- Added a bounded 50-plant private docket with name, optional species and room,
  last-watered date, user-defined 1–30 day interval, user-reported 1–5
  condition, due-first ordering, due-now/plant/watering summaries, full editing,
  individual deletion, and confirmed complete erasure.
- Published the only care arithmetic: next check equals last-watered date plus
  the user's interval. The app does not identify plants, inspect soil, recommend
  water amounts, or provide horticultural advice.
- Added “Watered now” and a newest-50 watering history per plant. Saving edits
  updates rather than duplicates the record.
- Added optional one-shot local care reminders through the shared coordinator.
  Permission is deferred until saving, delivery uses generic lock-screen copy
  and 09:00–20:30 adjustment, and watering/edit/delete/erase operations
  reschedule or cancel the relevant request.
- `PlantCareUITests` selects only
  `testPlantCourtTracksWateringAndEdits()`. The focused run proves truthful empty
  use, reminder opt-in without an early system prompt, saving, published seven-
  day arithmetic, exact summaries, relaunch persistence, repeat watering,
  editing without duplication, individual deletion, reuse, and complete erase.
- `build/TestResults/PlantCareFocused.xcresult` reports 1 passed and 0 failed on
  iPhone 16e iOS 26.2. Visual evidence is
  `docs/screenshots/app08-plant-care-hero.jpg` and
  `docs/screenshots/app08-plant-care-verified.jpg`; the botanical-green care
  order and greenhouse docket render cleanly and distinctly from App07.
- `build/LocalWave/App08PlantCourtFinal.xcarchive` is the current unsigned
  Release archive. Its packaged ID is `corp.unecessary.app08plantcourt`,
  version 1.0 build 1; executable and no-tracking/UserDefaults privacy-manifest
  checks pass. App08 remains release wave 1 and is now promoted into the first
  release lane.

# App33 Queue Personality Test real wait tracker — 27 August 2026

- Removed the one-slider fictional archetype reveal. First launch now contains
  no active queue and no invented history.
- Added a bounded 50-session private wait log with a named live queue,
  relaunch-safe elapsed timer, starting position, observed service, joiner and
  correction actions, reached-front/left outcomes, average/longest summaries,
  individual deletion, and confirmed complete erasure.
- Published the estimate logic in the UI: before observed progress it uses
  people ahead × user fallback minutes per person; afterward it uses elapsed
  seconds ÷ people served × people still ahead. It explicitly claims no venue
  feed, reservation, location knowledge, or guarantee.
- Added an optional one-shot estimated-turn checkpoint through the shared local
  notification coordinator. Permission is deferred until a reminded queue
  starts; position changes reschedule it and finish/delete/erase cancels it.
- Replaced the generic result with a purple queue-observation ticket, live
  position trail, exact metric card, and private wait log.
- `QueueTrackerUITests` selects only
  `testQueueTrackerMeasuresProgressAndHistory()`. The final focused run proves
  truthful empty use, deferred reminder explanation, starting arithmetic,
  relaunch persistence, service/join/correction updates, both outcomes,
  individual deletion, reuse, and total erasure.
- `build/TestResults/QueueTrackerFocused3.xcresult` reports 1 passed and 0 failed
  on iPhone 16e iOS 26.2. Visual evidence is
  `docs/screenshots/app33-queue-tracker-hero.jpg` and
  `docs/screenshots/app33-queue-tracker-verified.jpg`.
- `build/LocalWave/App33QueuePersonalityFinal.xcarchive` is the current unsigned
  Release archive. Its packaged ID is `corp.unecessary.app33queuepersonality`,
  version 1.0 build 1; its arm64 executable and canonical no-tracking
  UserDefaults `CA92.1` privacy manifest pass strict inspection. App33 is now
  promoted to release wave 1 and order 20 in the first release lane.

# App32 The Last Slice fair allocation treaty — 27 August 2026

- Removed the fictional Alex/Sam/Me roster, unweighted random picker, and
  one-result reset loop. First launch now has no participants or ruling history.
- Added a 2–20-person trimmed and case-insensitively deduplicated roster, custom
  item, relaunch-safe active tribunal, candidate passes, all-pass outcome,
  bounded 50-ruling ledger, exact summaries, individual deletion, and confirmed
  complete erasure.
- Published and implemented the fairness invariant: select from the people with
  the fewest prior awards among the current eligible roster, then randomize only
  a tie. Passing removes only that candidate from the current round and does not
  count as an award.
- Deliberately added no notification permission or scheduling. This is a live
  group decision with no useful future checkpoint; a later push would be a
  retention nag rather than contextual value.
- Replaced the generic result with a red wax-seal tribunal, pizza diplomat
  mascot, participant standings, serif diplomatic communiqué, and private
  ruling ledger.
- `LastSliceFairnessUITests` selects only
  `testLastSliceRotatesFairlyAndPersistsHistory()`. The final focused run proves
  truthful empty use, exact roster parsing, relaunch persistence, pass-to-next,
  rotation away from the prior winner, append-only history, individual
  deletion, and total erasure.
- `build/TestResults/LastSliceFairnessFocused5.xcresult` reports 1 passed and 0
  failed on iPhone 16e iOS 26.2. Visual evidence is
  `docs/screenshots/app32-last-slice-hero.jpg` and
  `docs/screenshots/app32-last-slice-verified.jpg`.
- `build/LocalWave/App32LastSliceFinal.xcarchive` is the current unsigned
  Release archive. Its packaged ID is `corp.unecessary.app32lastslice`, version
  1.0 build 1; its arm64 executable and canonical no-tracking UserDefaults
  `CA92.1` privacy manifest pass strict inspection. App32 is now promoted to
  release wave 1 and order 21 in the first release lane.

# App35 The Door Was Push private incident log — 27 August 2026

- Removed the lifetime tap counter that let users manufacture fictional door
  failures by repeatedly pressing one button. First launch now contains no
  incident and no invented evidence.
- Added a bounded 75-case local log with actual door/place, pulled-PUSH,
  pushed-PULL, or tried-both direction, 1–8 wrong attempts, self-reported 1–5
  sign clarity, optional note, exact dates, and relaunch persistence.
- Added incident, attempt, and clear-sign totals plus the most-common mistake
  pattern. Every result is explicitly self-reported and makes no sensor,
  location, accessibility, architectural-quality, or diagnostic claim.
- Added full correction that updates rather than duplicates, individual
  deletion, and confirmed draft/history erasure. Door incidents are completed
  events, so the app deliberately requests no notification permission.
- Rebuilt the visual experience around an angry door witness, red incident-
  office intake, direction controls, a tiny PUSH-door case report, and private
  evidence log. Visual QA caught and fixed a shadow that duplicated ticket text.
- `DoorIncidentLogUITests` selects only
  `testDoorIncidentLogPersistsEditsAndErases()`. The final run proves truthful
  empty use, exact slider values and summaries, relaunch, correction without
  duplication, a second independent case, individual deletion, and total erase.
- `build/TestResults/DoorIncidentFocused6.xcresult` reports 1 passed and 0 failed
  on iPhone 16e iOS 26.2. Visual evidence is
  `docs/screenshots/app35-door-incident-hero.jpg` and
  `docs/screenshots/app35-door-incident-verified.jpg`.
- `build/LocalWave/App35DoorWasPushFinal.xcarchive` is the current unsigned
  Release archive. Its packaged ID is `corp.unecessary.app35doorwaspush`,
  version 1.0 build 1; its arm64 executable and canonical no-tracking
  UserDefaults `CA92.1` privacy manifest pass strict inspection. App35 is now
  promoted to release wave 1 and order 22 in the first release lane.
