# First wave QA — release lane apps 1–10

Operational checklist for the first App Store cohort. Merge the launch-readiness PR stack on Mac before running these steps.

## Apps in order

| # | Folder | Bundle ID suffix | Device QA focus |
|---|--------|------------------|-----------------|
| 1 | `20-is-this-a-real-email` | `app20realemail` | Paste sample email, autopsy, clear |
| 2 | `03-do-not-text-them` | `app03donottextthem` | 10s cool-off, background, optional notification |
| 3 | `10-what-was-i-doing` | `app10whatwasidoing` | Log incidents, relaunch, erase |
| 4 | `18-tiny-gratitude` | `app18tinygratitude` | Archive, resurfacing, erase |
| 5 | `28-overthinking-evidence-board` | `app28overthinkingboard` | Five-field board, archive, share extension |
| 6 | `43-hydration-narc` | `app43hydrationnarc` | Log/undo, optional HealthKit, optional nudge |
| 7 | `13-toilet-timer` | `app13toilettimer` | Background timer, Live Activity, milestones |
| 8 | `17-meeting-bingo-for-one` | `app17meetingbingo` | Win-once bingo, relaunch, erase |
| 9 | `22-snack-roulette` | `app22snackroulette` | Pantry dedup, no-immediate-repeat spin |
| 10 | `11-am-i-early` | `app11amiearly` | Default 12 min early, late slider, history |

## Automated checks (repo)

```bash
python3 tools/audit_first_wave.py
python3 tools/validate_store_metadata.py
python3 tools/generate_xcode_project.py
```

## Mac build + UI tests

```bash
chmod +x tools/run_first_wave_mac.sh
zsh tools/run_first_wave_mac.sh
```

Runs repo audits, builds all ten app targets, then executes the `FirstWaveUITests` scheme (10 journeys).

## Screenshots

See `release/FIRST_WAVE_SCREENSHOTS.md`. Capture on Mac:

```bash
chmod +x tools/capture_first_wave_screenshots.sh
zsh tools/capture_first_wave_screenshots.sh
```

## Demo videos

See `release/FIRST_WAVE_DEMO_SCRIPTS.md`. Record on Mac:

```bash
chmod +x tools/record_first_wave_demos.sh
zsh tools/record_first_wave_demos.sh
```

## Simulator UI suite (manual alternative)

The serialized UI suite in `tests/App03DoNotTextThemUITests.swift` includes journeys for all ten apps (by bundle ID). On Mac:

```bash
xcodebuild test \
  -project UnnecessaryApps.xcodeproj \
  -scheme UnnecessaryAppsUITests \
  -destination 'platform=iOS Simulator,name=iPhone 16e,OS=latest'
```

## App Store Connect per app

1. Copy name, subtitle, description, keywords from `release/app-store-metadata.json`.
2. Paste matching review notes (button labels now align with UI).
3. Set privacy labels per `release/APP_PRIVACY_MATRIX.md` (App 43 declares optional HealthKit read + local notifications).
4. Capture 6.7" and 6.1" screenshots after final build.

## Out of first wave

Apps 38 and 40 remain on **HOLD**. Do not include them in this cohort.
