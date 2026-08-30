# Unnecessary Apps — Native iOS Design System

> This is the product design source of truth for the 44-app active SwiftUI collection.
> Page-specific rules may live in `design-system/unnecessary-apps/pages/` and
> override this file only where the app genuinely needs a different interaction
> model.

**Project:** Unnecessary Apps  
**Platform:** Native iOS / SwiftUI  
**Audience:** People who want a useful tiny tool, a quick laugh, or both  
**Design dials:** Variance 8/10 (distinct tiny worlds) · Motion 7/10 (delight with restraint) · Density 4/10 (room to breathe)

## North star

Each app is a polished little toy with a job:

1. The person understands the premise in one glance.
2. One obvious primary action gets them to the useful bit.
3. The result has a readable explanation and one memorable payoff.
4. The character, prop, soundless motion, or verdict makes it worth sharing.

The collection shares a grammar, not a template. The parent brand is recognizable
through spacing, tone, accessibility, and motion; every app owns its accent,
mascot, hero composition, vocabulary, and result mechanic.

## Reference translation

These supplied references are directional input, translated into native SwiftUI
patterns rather than copied as web CSS:

- [Essential skills to become a successful mobile app developer](https://medium.com/@nareshintern.infasta/essential-skills-to-become-a-successful-mobile-app-developer-812f4a49da83)
  reinforces native platform fluency, maintainable architecture, testing, and
  version-control discipline.
- [Mobile App UI Design](https://github.com/ceorkm/mobile-app-ui-design) supplies
  the context → structure → visual → emotion → polish sequence, the 60/30/10
  color balance, 8-point rhythm, thumb-zone thinking, and peak-end payoff.
- [Mobile App UX Best Practices](https://mcpmarket.com/tools/skills/mobile-app-ux-best-practices)
  reinforces 44pt-or-larger targets, progressive disclosure, clear loading and
  empty states, inline validation, haptics used sparingly, and accessibility.
- [9 must-have skills for Codex in 2026](https://medium.com/@unicodeveloper/9-must-have-skills-for-codex-in-2026-b5124b375eec)
  is treated as a third-party workflow prompt: use planning, code review,
  security, and verification habits, but do not install arbitrary tools or trust
  unverified service claims without a concrete project need.

The UI Pro Max search was also run against the SwiftUI stack. Its useful native
matches were explicit `ProgressView` loading states and descriptive
`accessibilityLabel` values; broad web-style recommendations are not imported
into this native project.

## Architecture: three layers

Keep the design system easy to evolve:

1. **Primitive tokens** — palette, spacing, type, radii, icon sizes, motion.
2. **Semantic tokens** — canvas, surface, ink, muted ink, accent, action, result,
   warning, and success roles.
3. **Components** — `DumbShell`, `DumbAction`, `DumbCard`, `DumbResult`,
   `DumbField`, `DumbCameraPicker`, and app-specific compositions.

Use `shared/Palette.swift` and `shared/DumbKit.swift` as implementation homes.
Views should consume semantic tokens and shared components rather than introduce
raw hex values, one-off shadows, or unrelated typography.

## Visual tokens

### Color

The current semantic palette is defined in `CorpPalette`:

| Semantic role | SwiftUI token | Use |
| --- | --- | --- |
| Canvas | `CorpPalette.canvas` | Screen background |
| Surface | `CorpPalette.surface` | Cards, sheets, result panels |
| Ink | `CorpPalette.ink` | Primary text and high-value marks |
| Muted ink | `CorpPalette.mutedInk` | Supporting copy and metadata |
| Sunshine | `CorpPalette.sunshine` | Optimistic highlights |
| Coral | `CorpPalette.coral` | Warm primary actions and reactions |
| Sky | `CorpPalette.sky` | Friendly information |
| Violet | `CorpPalette.violet` | Weirdness, imagination, oracle moments |
| Park green | `CorpPalette.parkGreen` | Outdoors and positive status |
| Bathroom blue | `CorpPalette.bathroomBlue` | Map and civic utility |
| Emergency red | `CorpPalette.emergencyRed` | Warnings only |
| Receipt cream | `CorpPalette.receiptCream` | Paper/receipt worlds |
| Evidence mint | `CorpPalette.evidenceMint` | Confirmed evidence and success |

Target a 60/30/10 balance: canvas/background first, surfaces and ink second,
accent and reaction color last. Color never carries meaning alone; pair status
with text, icon, shape, or a change in content. Check contrast in both light and
dark mode instead of assuming the adaptive palette is automatically safe.

### Typography

Use Apple system typography so text remains localizable, sharp, and compatible
with Dynamic Type:

- **Default display:** `.system(..., design: .rounded).weight(.black)` for
  playful utility and game worlds.
- **Editorial display:** `.system(..., design: .serif).weight(.black)` for
  receipts, courtrooms, and oracles.
- **Body:** system `.body` / `.subheadline` with `.medium` or `.semibold` only
  where hierarchy requires it.
- **Eyebrow:** `.caption.weight(.black)` with restrained tracking; never use an
  eyebrow as the only explanation of an action.

One screen should use one primary type personality and no more than four size
levels. All text must survive larger Dynamic Type without clipping, disappearing,
or turning the primary action into an afterthought.

### Spacing and layout

Use an 8-point rhythm with a 4-point micro step:

| Token | Value | Use |
| --- | ---: | --- |
| `micro` | 4pt | Icon-to-label optical adjustment |
| `xs` | 8pt | Inline gaps and compact rows |
| `sm` | 12pt | Control internals |
| `md` | 16pt | Standard card and screen padding |
| `lg` | 24pt | Section separation |
| `xl` | 32pt | Hero and result separation |
| `xxl` | 48pt | Major breathing room |

Keep the primary action in the comfortable thumb zone, respect safe areas, and
give scroll content enough bottom inset that the home indicator or a fixed CTA
never hides the result. Use `GeometryReader` only when the layout truly depends
on available space; prefer predictable stacks and flexible frames.

### Shape, depth, and icons

- Use the experience-style radii already encoded by `DumbExperienceStyle` so a
  receipt can feel printed, a courtroom can feel formal, and a game can feel
  bouncy without recoloring a generic card.
- Use soft depth only to establish surface hierarchy. Avoid floating every item.
- Use SF Symbols for structural icons. No emoji as navigation, status, or action
  icons. Decorative symbols beside visible text are hidden from VoiceOver; icon-
  only controls receive a descriptive accessibility label.
- The visible glyph may be 17–28pt, but its tappable control is at least 44×44pt.
- Keep icon families, weights, and alignment consistent within each screen.

## UX contract for every app

### First glance

- State the premise in plain language.
- Show the useful surface first: map for map apps, camera/photo choice for image
  apps, input for generators, and the game board for games.
- Show one primary action with a verb that says what will happen.
- Keep secondary history, explanation, and settings below the first payoff unless
  they are required to complete the task.

### Interaction

- Use native `Button`, `TextField`, `Picker`, `Toggle`, `Map`, and sheet controls
  with correct semantics.
- Provide immediate pressed feedback without shifting surrounding layout.
- Prefer `@State` for local interaction, `@Binding` for parent-owned values, and
  explicit dependency injection for feature services.
- Use `.sheet(item:)` for selected models and one source of truth for mutually
  exclusive presentation states.
- Use progressive disclosure: ask for the minimum input first, reveal advanced
  controls only after the person has a reason to need them.

### State design

Every asynchronous or permission-sensitive action has an intentional state:

| State | Required behavior |
| --- | --- |
| Ready | The next action is obvious and enabled |
| Loading | Show `ProgressView` plus a human explanation; never show an empty hole |
| Empty | Say what is missing and offer the next useful action |
| Error | Preserve input, explain recovery, and offer retry or a non-network path |
| Permission | Explain why before requesting; ask at the point of need |
| Success | Show the result, explain it, and give the app’s signature payoff |
| Reduced motion | Keep the same information and outcome with motion removed |

Never make people understand words such as “backend”, “cloud”, “fallback”, or
“local-first” to use the app. Technical implementation details belong in
developer documentation, not user-facing copy.

### Special surfaces

- **Maps:** map is the dominant surface; useful pins or the first empty state
  appear before filters and explanation. Request location only after the person
  taps the location action.
- **Camera/photo:** explain the evidence task, then offer `Photo Library` and
  `Take Photo` together. Request camera access only after `Take Photo` is chosen.
- **Health-adjacent:** label the product as reflection, journaling, or translation;
  never diagnose, prescribe, or imply clinical validation. Show the source and
  limitations of any interpretation.
- **Generative/AI:** state what the model can and cannot do, preserve user input,
  show a retry path, and do not send sensitive material without a clear opt-in.

## Motion system

Motion is a punchline amplifier, not wallpaper. The shared tokens are:

| Token | Existing implementation | Use |
| --- | --- | --- |
| `DumbMotion.quick` | spring `0.22 / 0.78` | Presses, counters, repeated actions |
| `DumbMotion.playful` | spring `0.38 / 0.64` | Mascot reaction and major selection |
| `DumbMotion.settle` | spring `0.46 / 0.84` | Returning the scene to rest |

Rules:

- One principal reaction per interaction: bounce, shake, or stamp.
- Prefer opacity and transforms; do not animate layout dimensions, padding, or
  positions in a way that makes surrounding content jump.
- High-frequency actions stay fast and quiet. Save longer playful motion for a
  result or reveal.
- Never use a continuous decorative loop unless it has a pause/stop alternative.
- Read `accessibilityReduceMotion`; when enabled, render the final state directly.
- Avoid large zooms, spins, parallax, and motion that makes the person track the
  whole screen.
- Test a reaction repeatedly. If it is annoying on the tenth use, it is wrong.

## Tiny-world lanes

The experience style is a design decision, not merely a color choice:

| Lane | Visual grammar | Signature payoff |
| --- | --- | --- |
| `dossier` | Case file, stamps, clipped evidence | Official finding |
| `receipt` | Paper, ruled lines, itemized numbers | Damage total or absurd subtotal |
| `courtroom` | Formal serif, exhibits, ruling card | Verdict with a decisive stamp |
| `camera` | Field evidence, camera framing, image-led hero | Identification and confidence |
| `journal` | Private notes, handwritten-feeling rhythm | One honest observation |
| `gallery` | Curated object wall, label cards | Tiny museum placard |
| `game` | Big board, fast feedback, celebratory result | Score, streak, or winner |
| `timer` | Clear clock/dial, calm urgency | Time report or intervention |
| `meter` | One large gauge, threshold copy | Measurement with a verdict |
| `route` | Map/line/path, location context | Escape route or next stop |
| `wellness` | Gentle surfaces, supportive language | Reflection, not diagnosis |
| `oracle` | Editorial type, symbols, deliberate reveal | Questionable wisdom |
| `workbench` | Practical controls, object-first utility | Workshop recommendation |
| `map` | Map-first canvas, visible pins, compact overlays | Field report |

No release wave should repeat the same hero composition and result mechanic for
every app. Reuse the lane’s primitives, then change the subject, action, voice,
and payoff.

## Accessibility and quality gates

Before an app is called release-ready, verify:

- 44×44pt minimum hit areas and visible pressed/disabled states.
- Descriptive labels, correct focus order, and no meaning conveyed by color alone.
- Light mode, dark mode, VoiceOver, Reduce Motion, and the largest practical
  Dynamic Type size.
- iPhone SE/small phone, standard phone, large phone, tablet, portrait, and
  landscape; no content behind safe areas or fixed controls.
- Ready, loading, empty, error, permission-denied, and success paths.
- Camera and location denial paths; Simulator-friendly alternatives where a
  physical sensor is unavailable.
- No unnecessary permissions, network calls, or sensitive persistence.
- A clean Xcode build, focused native UI tests, and a screenshot-based visual
  check before TestFlight.

## Forbidden shortcuts

- Do not ship the generated web/CSS template as if it were native iOS UI.
- Do not use a single recolored screen shell for all 44 apps.
- Do not use emoji as structural icons or tiny unlabeled icon-only controls.
- Do not hide the useful result below a marketing hero, onboarding wall, or
  settings screen.
- Do not request camera, location, contacts, health, notifications, or network
  access before the person takes an action that needs it.
- Do not let a mascot replace an accessible label or a clear explanation.
- Do not add AI, remote APIs, or accounts when a deterministic on-device feature
  gives the same user value.

## Delivery checklist

- [ ] App-specific lane, accent, mascot, vocabulary, and payoff are documented.
- [ ] One primary action is visible in the first useful viewport.
- [ ] Shared semantic tokens are used; no raw per-screen color hacks.
- [ ] Loading/empty/error/permission/success states are intentional.
- [ ] All interactive controls are native, labeled, and at least 44pt.
- [ ] Reduce Motion, Dynamic Type, dark mode, VoiceOver, and safe areas pass.
- [ ] The app was inspected on the simulator and tested with a clean build.
- [ ] Any external service has a documented key, privacy boundary, failure path,
      and cost owner before it is enabled.
