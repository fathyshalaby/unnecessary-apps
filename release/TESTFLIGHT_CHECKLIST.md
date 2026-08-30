# TestFlight readiness

This checklist covers the 44 active apps.

## Current release status — 2026-08-30

- All 44 active apps have a valid processed TestFlight build.
- Every build is assigned to its app-specific `Unnecessary Apps Friends`
  external group, and each group has a public invitation link.
- Every current external build is submitted to Apple for Beta App Review and
  awaits Apple's decision. This is the only immediate publishing gate.
- After approval, add the owner beta tester to each external group and use the
  public hub: https://fathyshalaby.github.io/unnecessary-apps/testflight.html

The retired Lab Report Translator is excluded from this release.

## Earlier pilot history

Five apps had earlier pilot builds; their latest valid builds are now part of
the collection-wide external-review submission:

| App Store Connect record | Scheme | Build | Current state |
|---|---|---:|---|
| `6805352462` — Do Not Text Them | `App03DoNotTextThem` | 3 | Submitted for external beta review |
| `6805446694` — Dog Name Guesser | `App24DogNameGuesser` | 6 | Submitted for external beta review |
| `6806534240` — Step Debt | `App36StepDebt` | 1 | Submitted for external beta review |
| `6806534690` — Sleep Alibi | `App37SleepAlibi` | 1 | Submitted for external beta review |
| `6806534987` — Workout Excuse | `App39WorkoutExcuse` | 1 | Submitted for external beta review |

Tester invitations are App Store Connect/Apple ID actions and are intentionally
not stored in this repository. The 44 external groups and public links are
provisioned in [TESTFLIGHT_INVITE_LINKS.md](TESTFLIGHT_INVITE_LINKS.md). They
become installable after Apple approves the corresponding external beta build.
The public hub contains all 44 unique Apple links:
https://fathyshalaby.github.io/unnecessary-apps/testflight.html

Beta App Review contacts, descriptions, and feedback emails are synchronized
in App Store Connect. Contact details remain only in App Store Connect.

## What is ready

- All 44 active app schemes are present in `UnnecessaryApps.xcodeproj`.
- The project sets `ITSAppUsesNonExemptEncryption` to `NO`.
- The shared SwiftUI layer and all app sources pass the current static checks.
- App icons and mascot assets are present for the collection.
- App24 has a verified UI flow covering trait entry, dog-name presentation, and reset.
- The shared UI-test scheme now covers one real end-to-end acceptance flow for every local/manual app; the current iPhone 16e simulator run passed 47/47 journeys with 0 failures and 0 skips.
- Store copy for all 44 active apps is validated in `release/app-store-metadata.json`; the draft privacy matrix is in `release/APP_PRIVACY_MATRIX.md`.
- App Store Connect’s editable app-info localization is synced for all 44
  records: prefixed titles, subtitles, and the hosted privacy URL are present.
- All 44 App Store Connect app records exist, and every app has an external
  TestFlight group with a public invitation link.
- The App Store Connect API key and four refreshed HealthKit distribution
  profiles are stored outside the repository; the local keychain exposes a
  valid team distribution identity.
- The release lane intentionally keeps App Store Connect credentials outside the repository.

## What remains

1. **Apple:** finish Beta App Review for each submitted build. Until approval,
   App Store Connect correctly rejects external-tester membership.
2. **Us, after approval:** add the owner beta tester to all 44 external groups
   and verify every public link opens the right TestFlight page.
3. **You, on iPhone:** smoke-test Dog Name Guesser (camera/photo picker),
   Toilet Timer (notifications and Live Activity), Quiet Cafe Index
   (location/map), Step Debt (HealthKit + route), and Health Data Horoscope
   (HealthKit), then expand to the top ten.
4. **Before public App Store release:** capture polished marketing screenshots;
   test dark appearance, large Dynamic Type, Reduce Motion, and
   permission-denial paths on physical hardware; generate Xcode's Privacy
   Report from the exact signed archive; and choose a smaller public launch
   cohort rather than releasing all 44 at once.

The full shared UI test scheme passed 47/47 journeys on the iPhone 16e
simulator. Physical-device checks remain essential for camera, notifications,
location, HealthKit, and Live Activities.

## Release command reference

The release helper remains available for future updates. Each new build must
receive a new build number, be uploaded, assigned to its app's external group,
and submitted for Beta App Review before external testers can install it. The
helper keeps credentials outside the repository and does not commit source
changes.

## Easiest first deployment through Xcode

For the pilot, the Xcode UI is the least fragile path:

1. Open `UnnecessaryApps.xcodeproj` and select the `App24DogNameGuesser` scheme.
2. In **Signing & Capabilities**, choose the Apple Developer team and leave automatic signing enabled.
3. Choose **Any iOS Device ( arm64 )** or a generic iOS device destination.
4. Choose **Product > Archive**.
5. In Organizer, select the new archive and choose **Distribute App > TestFlight & App Store > Upload**.
6. After App Store Connect finishes processing the build, open the app’s **TestFlight** tab and confirm the internal/external group assignments. The five pilot memberships and build assignments are already verified through the API.

Use the command-line lane above for the repeatable release. Xcode Organizer
remains a valid fallback if a target needs interactive signing repair.

## Lead pilot What to Test

> Adjust fluff and seriousness, enter “Biscuit,” present the name, and reset the accusation. Then choose one dog photo and one non-dog photo in PhotosPicker. Confirm the local Vision finding, cancellation path, and manual path work in light/dark appearance, Reduce Motion, and large Dynamic Type. No camera permission, login, or network prompt should appear.

The repeatable UI-test command is:

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
xcodebuild test \
  -project UnnecessaryApps.xcodeproj \
  -scheme App03DoNotTextThemUITests \
  -destination 'platform=iOS Simulator,id=0916A2F7-ED60-44B8-8158-DC34E0F10C84'
```

The full shared UI test scheme passed on the iPhone 16e Simulator (iOS 26.2):
47 tests passed, 0 failed, and 0 skipped. The Dog Name Guesser case passed as
part of that run. When running from a restricted shell, use Xcode-level access
so CoreSimulator can reach its user Library logs.

## Guardrails

- Upload all 44 apps, but use bounded batches and verify processing between
  batches so one signing or metadata failure does not hide the rest.
- Do not commit API keys, `.p8` files, archives, exported IPAs, or distribution logs.
- Do not treat the simulator viewport issue as resolved until it is reproduced on a clean simulator or physical iPhone.
