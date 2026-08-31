# Custom app design direction

The collection does **not** need every app inside the same `DumbShell` template. Shared **controls** (fields, buttons, cards, motion) stay in DumbKit; each app owns its **layout** and visual hierarchy.

## The template problem

**31 of 44 apps** still use `DumbShell`, which forces the same structure:

1. Cream canvas background  
2. Large hero block: eyebrow → mascot → `.largeTitle` → subtitle → department label  
3. Scroll stack of `DumbCard` + `DumbAction` + `DumbResult`  
4. Same entrance animation on every launch  

That reads as one product with 44 skins, not 44 tiny apps. `DumbExperienceStyle` tweaks corner radii and labels but cannot fix the shared hero composition.

## What already works without the template

| App | Layout model |
|-----|----------------|
| **02 Bathroom Map**, **23 Quiet Café**, **29 Bench Reviews** | Map-first: compact `brandHeader` + full-width map + desk sheet. No `DumbShell`. |
| **03 Do Not Text Them** | Intervention-first: red wash + draft editor hero, no oversized title block. |
| **17 Meeting Bingo** | Game-first: thin toolbar + board grid dominates the screen. |
| **20 Real Email?** | Workbench: editor-first + sticky autopsy CTA in bottom bar. |
| **10 What Was I Doing?** | Ledger: context picker + sticky “I forgot why” action. |
| **18 Tiny Gratitude** | Ledger: kind picker + sticky archive CTA. |
| **28 Overthinking Board** | Workbench: evidence sections + sticky conclusion CTA. |
| **43 Hydration Narc** | Meter: progress ring + sticky “Log one serving”. |
| **13 Toilet Timer** | Intervention: large timer readout + sticky start/stop. |
| **22 Snack Roulette** | Game: result prominent + sticky spin button. |
| **11 Am I Early?** | Meter: punctuality summary + sticky verdict CTA. |

**First wave (10 apps) is fully off `DumbShell`.** These are the reference pattern for the rest of the collection.

## Keep vs drop

| Keep (shared kit) | Drop or avoid (per app) |
|-------------------|-------------------------|
| `DumbField`, `DumbAction`, `DumbCard`, `DumbResult` | Mandatory `DumbShell` hero on every screen |
| `CorpPalette` accents (or app-local palette overrides) | Identical scroll + card stack for every flow |
| `DumbMotion`, `DumbCharacterStage`, accessibility IDs | Same `.largeTitle` + mascot header on tools, games, and maps |
| `AppCanvas`, `AppHeader` | Copy-pasting another app's layout wholesale |

`DumbShell` remains available for quick utility screens but is **optional**, not default.

## New layout primitives

### `AppCanvas`

Scroll + canvas background + optional sticky bottom bar + experience environment. **No hero template.**

```swift
AppCanvas(accent: CorpPalette.parkGreen, experience: .workbench) {
    AppHeader(eyebrow: "...", title: "...", accent: accent)
    // app-specific content
}
```

### `AppHeader`

Compact title row (matches map apps): small eyebrow, `title3` title, optional subtitle, optional mascot.

## Layout archetypes (assign one per app)

| Archetype | Best for | Examples |
|-----------|----------|----------|
| **Map-first** | Location journals | 02, 23, 29 |
| **Game board** | Grids, timers, taps | 17, 22, 33 |
| **Editor / workbench** | Paste, type, generate | 20, 30, 28 |
| **Intervention** | Single urgent action | 03, 13 |
| **Camera / capture** | Photo + result | 12, 24, 27 |
| **Ledger** | Lists + stats | 04, 06, 10, 18 |
| **Meter / dial** | Sliders, scores | 11, 21, 39 |

Do not assign the same archetype + hero joke twice in one release wave.

## Migration order

1. ~~**First wave (10)**~~ — **done** (all 10 off `DumbShell`)  
2. **Map + camera cluster (02, 12, 23, 24, 27, 29)** — already non-template or capture-heavy  
3. **Games + timers (13, 22, 25, 33)** — board/timer should own the screen  
4. **Remaining utility shells** — replace `DumbShell` with `AppCanvas` + archetype layout  

Track progress in code: grep for `DumbShell(` per folder.

## Accessibility guardrails (unchanged)

- Preserve existing `accessibilityIdentifier`s when refactoring layout (UI tests depend on them).  
- Keep 44pt tap targets and Reduce Motion paths.  
- Color + icon + text for status — never color alone.

## Mac verification after layout changes

```bash
zsh tools/run_all_apps_mac.sh
zsh tools/capture_all_apps_screenshots.sh
```

Screenshots should show **different compositions**, not just different accent colors.
