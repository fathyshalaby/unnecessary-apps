# Design Review

## Direction

Each app should feel like its own tiny product — not a recolored form. Shared **controls** live in DumbKit; **layout** is per app. See [docs/CUSTOM_APP_DESIGN.md](../docs/CUSTOM_APP_DESIGN.md) and [release/CUSTOMER_UX_SCORECARD.md](../release/CUSTOMER_UX_SCORECARD.md).

The playful system still applies: warm canvas, ink-black type, accent colors, mascots with a job, and one obvious primary action. Map apps (02, 23, 29), Meeting Bingo, and Do Not Text Them break the old hero template.

The parent brand is the **Unnecessary Apps Corp** civic seal: a chair, laurel, tiny pigeon, and red flag. Each app gets its own deadpan mascot mark.

## What is working

- All **44 shipping apps** use custom layouts (`AppCanvas`, map-first, intervention, or game board) — no mandatory `DumbShell`.
- Shared interest primitives: `DumbEmptyInvite`, `DumbShareVerdict`, `DumbHeroMeter`, `DumbBoundaryChip`, lane-tuned haptics.
- First-lane apps have distinct first-viewport geometry (spin wheel, pinboard columns, fog preview, hero timer dial, share receipts).
- I/O usability pass complete — sticky actions, stale invalidation, session bars ([release/IO_USABILITY_AUDIT.md](../release/IO_USABILITY_AUDIT.md)).

## Asset system

- Parent logo: `assets/brand/unnecessary-apps-corp-logo.png`
- Parent mascot: `assets/brand/unnecessary-apps-corp-mascot.png`
- Per-app source marks: `assets/app-icons/`
- Per-app Xcode assets: each numbered folder contains `Assets.xcassets/AppIcon.appiconset` and `AppMascot.imageset`.

## Product review notes

Strong first-release candidates:

1. **Chair Finder** — instantly legible, highly shareable, visually representative of the brand.
2. **Public Bathroom Quality Map** — practical enough to earn repeat use while remaining absurd.
3. **Do Not Text Them** — universal emotional trigger with a clean one-action interaction.
4. **Receipt Emotional Damage** — screenshot-able result with share export.

For TestFlight, stagger releases rather than shipping all 44 at once.

## Guardrails before public release

- Keep color paired with labels, icons, or text so status is never color-only.
- Preserve Dynamic Type and VoiceOver labels when replacing placeholder controls with richer mascot treatments.
- Keep health-adjacent apps framed as journaling, reflection, or translation; they must not diagnose, prescribe, or imply clinical validation.
- Avoid real location, contacts, health, or notification permissions until a specific app has a user-tested reason to request them.
- Keep mascots as optional personality, not as the only source of meaning.

## Next design pass

- Mac screenshot pass at AX5 Dynamic Type for first-lane apps.
- App Store frames: premise → action → payoff (see scorecard checklist).
- HOLD apps (38, 40) and Recovery Goblin stay out of public cohort until retention loops are signed off.
