# Screenshot assets

Fresh captures: run on Mac after merging the launch-readiness PR stack:

```bash
zsh tools/capture_all_apps_screenshots.sh
```

Output: `release/screenshots/iphone-6.9/App01.png` … `App44.png` at 1260×2736.

For the first ten release-lane apps only:

```bash
zsh tools/capture_first_wave_screenshots.sh
```

See `release/ALL_APPS_QA.md` and `release/FIRST_WAVE_SCREENSHOTS.md`.

---

The folder release/screenshots/iphone-6.9/ may contain one exact-size portrait
in-app capture for each of the 44 active local/manual apps. They are derived from the
verified simulator QA captures and prepared at 1260x2736 for Apple's 6.9-inch
iPhone slot.

These are functional product screenshots, not finished marketing treatments,
and the current set is not submission-ready. The QA captures retain the
simulator's previous-app back affordance in the status bar, and some were made
before the latest capability upgrades: App02 does not show the map-first
surface, App24 does not show the Photos/Camera entry, and App36 still says
“Manual entry only” even though the current app has optional read-only Apple
Health context. Before submission, capture each app from a clean simulator
launch (or a physical device) so no previous-app label is present and the
screenshots match the current build; then review the first three images for
each listing, add captions only if they improve clarity, confirm that no
private sample text is visible, and recreate any additional device-size slots
required by App Store Connect.

Regenerate from legacy QA PNGs in docs/screenshots/ with:

    zsh tools/prepare_store_screenshots.sh
