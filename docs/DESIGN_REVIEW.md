# Design Review

## Direction

Each app should feel like its own tiny product — not a recolored form. Shared **controls** live in DumbKit; **layout** is per app. See `docs/CUSTOM_APP_DESIGN.md` for the full migration plan.

The playful system still applies: warm canvas, ink-black type, accent colors, mascots with a job, and one obvious primary action. Map apps (02, 23, 29), Meeting Bingo, and Do Not Text Them already break the old `DumbShell` hero template.

The parent brand is the **Unnecessary Apps Corp** civic seal: a chair, laurel, tiny pigeon, and red flag. Each app gets its own deadpan mascot mark.

## What is working

- Oversized rounded headlines make every app understandable within one glance.
- A large mascot moment gives each app an immediate emotional hook.
- One chunky primary action creates a simple game-like loop.
- Soft-depth cards and small status pills keep the interface friendly rather than administrative.
- The deadpan corporate voice remains in short labels such as `NONSENSE DEPT.` and `OFFICIAL RESULT`.
- Apps 11–44 use shared DumbKit controls; **41 still use the optional `DumbShell` template** — migration to custom layouts is in progress (see `docs/CUSTOM_APP_DESIGN.md`).
- Map apps (02, 23, 29), Meeting Bingo, and Do Not Text Them use **custom layouts** without the hero template.

## Asset system

- Parent logo: `assets/brand/unnecessary-apps-corp-logo.png`
- Parent mascot: `assets/brand/unnecessary-apps-corp-mascot.png`
- Per-app source marks: `assets/app-icons/`
- Per-app Xcode assets: each numbered folder contains `Assets.xcassets/AppIcon.appiconset` and `AppMascot.imageset`.

The generated marks use one subject, one ridiculous prop, a heavy editorial outline, transparent background, and no readable text. The AppIcon copy is normalized to Apple’s full iPhone/iPad/App Store size set; the source artwork remains in `assets/app-icons` for future art direction.

## Product review notes

The strongest first-release candidates are:

1. **Chair Finder** — instantly legible, highly shareable, and visually representative of the brand.
2. **Public Bathroom Quality Map** — practical enough to earn repeat use while remaining absurd.
3. **Do Not Text Them** — a universal emotional trigger with a clean one-action interaction.
4. **Receipt Emotional Damage** — the most naturally screenshot-able result screen.

For the first TestFlight, release one flagship target rather than shipping all 44 at once. This gives us a clean signal on onboarding, icon recognition, retention, and which flavor of nonsense people actually share. App01 Chair Finder is the recommended pilot.

## Guardrails before public release

- Keep color paired with labels, icons, or text so status is never color-only.
- Preserve Dynamic Type and VoiceOver labels when replacing placeholder controls with richer mascot treatments.
- Keep health-adjacent apps framed as journaling, reflection, or translation; they must not diagnose, prescribe, or imply clinical validation.
- Avoid real location, contacts, health, or notification permissions until a specific app has a user-tested reason to request them.
- Keep mascots as optional personality, not as the only source of meaning.

## Next design pass

The refreshed shell and mascot badge are now implemented and verified on App11; Chair Finder is the flagship visual reference. The next worthwhile pass is focused polish on the first five release candidates: test the copy at larger Dynamic Type sizes, tighten the empty states, and add App Store screenshots that show the joke immediately.
