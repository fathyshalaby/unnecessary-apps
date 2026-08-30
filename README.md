# Unnecessary Apps Corp

Forty-four tiny apps for problems nobody officially has, but everybody understands.

## Open in Xcode

Open UnnecessaryApps.xcodeproj in Xcode 26.2 or newer. It contains one iOS application target and scheme per numbered folder, plus the shared DumbKit library. Choose any App01...App44 scheme and run it on an iPhone or installed simulator.

The project is generated deterministically by tools/generate_xcode_project.py; rerun that script after adding or renaming app source files.

## Collection

The folders are ordered by likely shareability and build simplicity:

1–10: `01-chair-finder`, `02-public-bathroom-quality-map`, `03-do-not-text-them`, `04-social-battery-receipt`, `05-fridge-witness`, `06-receipt-emotional-damage`, `07-sock-tribunal`, `08-plant-court`, `09-laundry-mountain`, `10-what-was-i-doing`

11–20: `11-am-i-early`, `12-pigeon-or-seagull`, `13-toilet-timer`, `14-one-more-episode`, `15-can-i-wear-this-again`, `16-microwave-sommelier`, `17-meeting-bingo-for-one`, `18-tiny-gratitude`, `19-medieval-peasant-advice`, `20-is-this-a-real-email`

21–30: `21-the-vibe-meter`, `22-snack-roulette`, `23-quiet-cafe-index`, `24-dog-name-guesser`, `25-waiting-room-simulator`, `26-neighbor-noise-translator`, `27-tiny-personal-museum`, `28-overthinking-evidence-board`, `29-local-bench-reviews`, `30-apology-draft-generator`

31–35: `31-human-gps`, `32-the-last-slice`, `33-queue-personality-test`, `34-weather-outfit-excuse`, `35-the-door-was-push`

36–44: `36-step-debt`, `37-sleep-alibi`, `38-heart-rate-during-email`, `39-workout-excuse-detector`, `40-health-data-horoscope`, `41-the-recovery-goblin`, `42-walking-meeting-escape-plan`, `43-hydration-narc`, `44-rest-day-police`

Every app is intentionally local-first, silly, and narrow. No accounts, servers, analytics, ads, or payments are required for the first version.

The current security posture, applied fixes, release gates, and safe multimodal AI architecture are documented in `SECURITY.md`. Cloud AI must be reached through a first-party backend; provider keys must never ship in an app binary.

The current visual direction is minimal-modern with character: one obvious action,
an immediate useful surface, a small mascot with a job, rounded display
typography, controlled accents, quiet depth, and one playful result payoff. The
native design rules live in `design-system/unnecessary-apps/MASTER.md`; the
research-to-tool mapping is in `docs/UX_UI_TOOLCHAIN.md`, and the latest visual
evidence is in `docs/VISUAL_QA.md`.

The reusable UI library is the local `shared/DumbKit.swift` module. It owns the hero, card, action, result, field, and slider patterns; no third-party UI dependency is needed.

Package.swift also exposes all 44 executable products for local macOS SwiftPM compilation.

Each folder contains standalone SwiftUI source that can be dropped into an iOS App target in Xcode. The apps in waves 2–5 use the small helpers in `shared/` for consistent card and button styling.

## Brand and design assets

The parent logo and mascot are in `assets/brand/`. Each app has a generated text-free mascot mark in `assets/app-icons/`, plus an Xcode-ready `Assets.xcassets` containing `AppIcon` and `AppMascot`. See `docs/DESIGN_REVIEW.md` for the visual rationale, release-candidate ranking, and public-release guardrails.

## TestFlight pilot

Release preparation lives in `release/`. Start with `release/TESTFLIGHT_CHECKLIST.md`; the first pilot is App24 Dog Name Guesser, staged for internal TestFlight before the remaining local-first wave. See `docs/INFRASTRUCTURE_AUDIT.md` for the service and permission plan, and `docs/NOTIFICATION_STRATEGY.md` for the contextual, opt-in notification standard shared across the collection.

## Creator series

The app-by-app creator evaluation is in `docs/APP_EVALUATION.md`, the dated 15-week calendar is in `docs/SOCIAL_SERIES_PLAN.md`, and the trailer plus episode scripts are in `docs/SOCIAL_SCRIPTS_SEASON_1.md`. The public series and recurring hook are **Unnecessary Apps**, produced by **Unnecessary Apps Corp**.

The executable launch pack is in `social/`: import its launch-week calendar, use the capture manifest for filming, and paste the prepared platform copy from `social/launch-week/LAUNCH_WEEK.md`.
