# First wave screenshot guide

Capture fresh 6.9" (1260×2736) portraits for the ten launch apps. Stale QA shots in `docs/screenshots/` predate recent fixes — recapture from a clean simulator launch.

## Automated capture (Mac)

```bash
chmod +x tools/capture_first_wave_screenshots.sh
zsh tools/capture_first_wave_screenshots.sh
```

Output: `release/screenshots/first-wave/iphone-6.9/*.png`

## Manual hero frame per app

Set up the screen below **before** capturing so listing screenshots show the app at its best.

| App | Hero frame to capture |
|-----|----------------------|
| Real Email? | After autopsy: clarity score + fog terms visible |
| Do Not Text Them | Draft entered, **Start the cool-off** enabled (pre-timer) |
| What Was I Doing? | Two incidents logged, count visible |
| Tiny Gratitude | Two archived gratitudes + summary stats |
| Overthinking Board | Worry filled, evidence expanded, conclusion visible |
| Hydration Narc | Progress bar mid-goal after 2–3 logs |
| Toilet Timer | Live timer running (elapsed seconds visible) |
| Meeting Bingo | BINGO result on a marked row |
| Snack Roulette | Pantry set + latest spin result |
| Am I Early? | **Comfortably early** verdict for Dentist / 12 min |

## App Store Connect

1. Upload **3–5 screenshots** per app; lead with the hero frame above.
2. Add 6.1" slot if required — scale from 6.9" or recapture on iPhone 15 simulator.
3. Confirm no simulator status-bar back chevron (launch from home screen).
4. Confirm no real private data in any frame.

## Regenerate full 44-app set later

After first wave ships, refresh the full catalog:

```bash
zsh tools/prepare_store_screenshots.sh
```

Update `docs/screenshots/` sources first.
