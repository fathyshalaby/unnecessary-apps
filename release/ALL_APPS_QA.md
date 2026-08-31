# All apps — Mac launch checklist

Complete verification for all **44 active apps** before App Store submission. Run everything on your Mac after merging the PR stack.

## One-command pipeline

```bash
# 1. Build all 44 targets + run 47 UI journeys
zsh tools/run_all_apps_mac.sh

# 2. Capture fresh App Store screenshots (1260×2736)
zsh tools/capture_all_apps_screenshots.sh

# 3. Record demo videos (interactive, all 44)
zsh tools/record_all_apps_demos.sh
```

## Repo-only checks (no Xcode)

```bash
python3 tools/generate_app_manifest.py
python3 tools/audit_launch_readiness.py
python3 tools/validate_store_metadata.py
python3 tools/generate_xcode_project.py
python3 tools/generate_demo_scripts.py
```

## What each step does

| Step | Script | Output |
|------|--------|--------|
| Build + test | `run_all_apps_mac.sh` | Builds via `App03DoNotTextThemUITests` scheme; runs 47 UI tests covering all 44 apps |
| Screenshots | `capture_all_apps_screenshots.sh` | `release/screenshots/iphone-6.9/App01.png` … `App44.png` |
| Demo videos | `record_all_apps_demos.sh` | `release/demos/all-apps/01-slug.mp4` … `44-slug.mp4` |

## Focused subsets

| Cohort | Script |
|--------|--------|
| First 10 release lane | `zsh tools/run_first_wave_mac.sh` |
| First 10 screenshots | `zsh tools/capture_first_wave_screenshots.sh` |
| First 10 demos | `zsh tools/record_first_wave_demos.sh` |

See `release/FIRST_WAVE_QA.md` for the launch-lane order.

## App manifest

`config/app-manifest.json` is the canonical list (scheme, bundle ID, folder, hold status, review notes). Regenerate after metadata changes:

```bash
python3 tools/generate_app_manifest.py
```

## Demo script reference

Auto-generated from App Store review notes:

```bash
python3 tools/generate_demo_scripts.py
# -> release/ALL_APPS_DEMO_SCRIPTS.md
```

## App Store Connect (per app)

1. Copy fields from `release/app-store-metadata.json`.
2. Set privacy labels from `release/APP_PRIVACY_MATRIX.md`.
3. Upload screenshots from `release/screenshots/iphone-6.9/`.
4. Optional: attach demo clips for social / preview use.

## Release cohorts

| Cohort | Apps | Notes |
|--------|------|-------|
| First wave | 10 apps | See `release/RELEASE_ORDER.md` lane 1 |
| Full collection | 44 apps | All pass repo audit |
| HOLD | 38, 40 | Documented and testable; exclude from first public season |

## Physical device (after simulator green)

Priority hardware checks per `release/TESTFLIGHT_CHECKLIST.md`:

- **Camera / Vision:** 12, 24, 27
- **HealthKit:** 36, 37, 39, 40, 41, 43, 44
- **Location / Maps:** 02, 23, 29, 36
- **Microphone:** 26
- **Notifications + Live Activity:** 13, 33, 42
- **Apple Foundation Models:** 19, 30

## Regenerate from existing QA PNGs (legacy)

If you already have fresh captures in `docs/screenshots/`:

```bash
zsh tools/prepare_store_screenshots.sh
```

Prefer `capture_all_apps_screenshots.sh` for a clean simulator launch without status-bar back labels.
