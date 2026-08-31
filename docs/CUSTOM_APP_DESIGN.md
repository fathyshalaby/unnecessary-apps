# Custom app design direction

The collection does **not** need every app inside the same `DumbShell` template. Shared **controls** (fields, buttons, cards, motion) stay in DumbKit; each app owns its **layout** and visual hierarchy.

## Status: all 44 apps off `DumbShell`

Every shipping app now uses **`AppCanvas` + `AppHeader`**, a **map-first custom layout**, or an **intervention/game custom shell**. The shared hero template (eyebrow → mascot → `.largeTitle` → subtitle) is gone from the release collection.

| Layout family | Apps |
|---------------|------|
| **Map-first** (custom) | 02, 23, 29 |
| **Intervention / custom shell** | 03, 17 |
| **AppCanvas + sticky bottom CTA** | All other 39 apps |

## Premium layout principles

1. **Compact header** — `AppHeader` with `title3`, optional mascot; camera apps hide mascot so the viewport dominates.
2. **Content-first** — editors, meters, galleries, and game boards lead; jokes live in copy, not oversized chrome.
3. **Sticky primary action** — main `DumbAction` (+ often `DumbResult`) in `AppCanvas` bottom bar so thumbs reach the one job.
4. **Accent wash** — `AppCanvas` applies a subtle top gradient from each app's accent color.
5. **Archetype-specific hero** — large timer readouts (13), live vibe gauge (21), photo viewport (12), game grid (17), map sheet (02).

## Keep vs drop

| Keep (shared kit) | Drop or avoid (per app) |
|-------------------|-------------------------|
| `DumbField`, `DumbAction`, `DumbCard`, `DumbResult` | Mandatory `DumbShell` hero on every screen |
| `CorpPalette` accents (or app-local palette overrides) | Identical scroll + card stack for every flow |
| `DumbMotion`, accessibility IDs | Same `.largeTitle` + mascot header on tools, games, and maps |
| `AppCanvas`, `AppHeader` | Copy-pasting another app's layout wholesale |

`DumbShell` remains in DumbKit for legacy/prototyping but is **not used** in the 44-app collection.

## Layout primitives

### `AppCanvas`

Scroll + accent gradient wash + optional sticky bottom bar + experience environment. **No hero template.**

```swift
AppCanvas(accent: CorpPalette.parkGreen, experience: .workbench) {
    AppHeader(eyebrow: "...", title: "...", accent: accent)
    // app-specific content
} bottomBar: {
    DumbAction(title: "...", accent: accent, systemImage: "...", action: perform)
    DumbResult(text: result, accent: accent, systemImage: "...")
}
```

### `AppHeader`

Compact title row: small eyebrow, `title3` title, optional subtitle, optional mascot (`showsMascot: false` for camera-first apps).

## Layout archetypes (one per app)

| Archetype | Best for | Examples |
|-----------|----------|----------|
| **Map-first** | Location journals | 02, 23, 29 |
| **Game board** | Grids, timers, taps | 17, 22, 32, 33 |
| **Editor / workbench** | Paste, type, generate | 20, 30, 28, 31 |
| **Intervention** | Single urgent action | 03, 13 |
| **Camera / capture** | Photo + result | 12, 24, 27 |
| **Ledger** | Lists + stats | 04, 06, 07, 08, 10, 18, 35 |
| **Meter / dial** | Sliders, scores | 11, 14, 21, 25, 36, 37, 39, 40, 41, 44 |

## Accessibility guardrails

- Preserve existing `accessibilityIdentifier`s when refactoring layout (UI tests depend on them).
- Keep 44pt tap targets and Reduce Motion paths.
- Color + icon + text for status — never color alone.

## Mac verification after layout changes

```bash
zsh tools/run_all_apps_mac.sh
zsh tools/capture_all_apps_screenshots.sh
```

Screenshots should show **different compositions**, not just different accent colors.

## Migration tooling

`tools/migrate_dumb_shell.py` — mechanical `DumbShell` → `AppCanvas` converter (used for the bulk migration). Hand-tune camera, game, and museum layouts after running.
