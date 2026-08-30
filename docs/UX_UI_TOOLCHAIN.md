# UX/UI toolchain for Unnecessary Apps

**Status:** active  
**Date:** 28 August 2026  
**Target:** 44 native SwiftUI iOS apps with distinct personalities under one brand

This is the practical toolchain for making the apps useful, playful, accessible,
and shippable. It deliberately separates native-iOS tools from web-only tools so
the project does not drift back into a generic CSS template.

## Skills in use

| Skill | Role in this project | Decision |
| --- | --- | --- |
| `ui-ux-pro-max:ui-ux-pro-max` | Priority order, UX heuristics, platform-aware design review | Primary design lens |
| `ui-ux-pro-max:design-system` | Primitive → semantic → component token architecture | Applied to `MASTER.md` |
| `ui-ux-pro-max:brand` | Parent identity, voice, assets, and consistency | Applied to collection rules |
| `ui-ux-pro-max:ui-styling` | Component/accessibility discipline | Use concepts only; its shadcn/Tailwind implementation is web-only |
| `design-motion-principles` | Motion purpose, timing, reduced motion, performance | Applied to `MOTION_DESIGN_SYSTEM.md`; a full audit is a separate pass |
| `build-ios-apps:swiftui-ui-patterns` | SwiftUI state ownership, navigation, sheets, composition | Native implementation standard |
| `build-ios-apps:swiftui-performance-audit` | Code-first review of invalidation, identity, layout, image, and animation cost | Release quality gate |
| `build-ios-apps:ios-debugger-agent` | Build/run/debug native targets | Xcode execution lane |
| `build-ios-apps:ios-simulator-browser` | Inspect and interact with simulator screens | Visual QA lane when available |
| `imagegen` | Generate or edit mascots, icons, and campaign art | Use only for requested assets; inspect existing art first for edits |
| `computer-use:computer-use` | Operate Xcode/Safari UI when a native or account flow requires it | Use with explicit credential/2FA handoff |

Related skills are available for future work—`typography`, `svg-animations`,
`elegance-sophistication`, `excitement-energy`, `frontend-design`, `figma`, and
`refero-design`—but they are not automatically applied to a native SwiftUI
screen. Web-first skills are useful for the social landing page, not for copying
web components into the iPhone apps.

## MCP capabilities available now

### XcodeBuildMCP — the main app-design loop

Use these groups for every pilot app:

- **Project/build:** discover projects and schemes, show settings, build for
  Simulator, clean only when justified, and get the built app path.
- **Runtime:** boot/open a simulator, install, launch, stop, and wait for UI.
- **Visual QA:** take screenshots and accessibility/UI snapshots.
- **Interaction QA:** tap, touch, long-press, swipe, drag, type text, press keys,
  and invoke labeled buttons.
- **Tests/debugging:** run focused UI tests, attach LLDB, inspect stacks and
  variables, and add/remove breakpoints when a behavior—not a visual guess—is
  failing.
- **Performance:** use coverage and runtime/debug hooks; pair with Instruments
  when the code-first audit cannot explain a jank or memory issue.

This is the authoritative loop for the current project because it exercises the
actual SwiftUI build rather than a browser approximation.

The concrete calls currently exposed in this session include
`mcp__xcodebuildmcp__build_run_sim`, `build_sim`, `test_sim`, `boot_sim`,
`launch_app_sim`, `install_app_sim`, `screenshot`, `snapshot_ui`, `wait_for_ui`,
`tap`, `touch`, `long_press`, `swipe`, `gesture`, `type_text`, `button`,
`record_sim_video`, `debug_attach_sim`, and the `debug_*` inspection calls.

### Computer Use via `node_repl`

Use for Xcode Organizer, Apple account, simulator, and other Mac UI flows that
are not exposed cleanly through a project tool. Never type or expose passwords,
one-time codes, private keys, or signing secrets; pause for the user at those
handoffs.

### Image generation and inspection

- `image_gen__imagegen`: create a new mascot/logo or edit a local asset with a
  precise brief.
- `view_image`: inspect local screenshots and generated assets at phone size.

Generated art must remain legible as an icon, contain no accidental readable
text, respect the app’s lane, and not become the only explanation of a control.

### Chrome DevTools MCP

Available for the social website or any web companion: screenshots, snapshots,
Lighthouse accessibility, console/network inspection, and performance traces.
It is not the primary QA tool for the native apps.

### Other connected capabilities

Supabase, Vercel, Sites, and document connectors are available in the runtime,
but they are infrastructure or web capabilities, not a reason to add a backend
to a local-first app. Use them only when a specific feature needs sync, accounts,
or a public campaign site and its privacy/cost boundary is documented.

## Not installed / optional connectors

Figma, Canva, GitHub, Google Calendar, Gmail, and other recommended plugins are
available as optional installs in this environment but are not active MCPs in
this project. None is required to design or test the native apps. Install a
specific connector only when the workflow actually needs it—for example, Figma
for an external handoff or GitHub for repository automation.

The supplied third-party Codex article mentions additional tools and MCPs. That
is a discovery list, not authorization to install arbitrary services, upload
source code, or add paid API keys. Each connector needs an explicit use case,
privacy review, and owner.

## Working loop

```text
reference research
      ↓
app UX contract: premise → primary action → useful result → payoff
      ↓
lane-specific tokens: type, accent, mascot, surface, result mechanic
      ↓
SwiftUI composition with native controls and explicit states
      ↓
accessibility + Dynamic Type + dark mode + Reduce Motion
      ↓
XcodeBuildMCP build → UI test → screenshot → mean visual review
      ↓
clean archive → Organizer/TestFlight when the app is actually useful
```

## Rules derived from the supplied references

- Make the useful surface immediate; do not bury it under onboarding or branding.
- Keep one primary action per screen and place it where a thumb can reach it.
- Use 44pt-or-larger hit areas, a consistent 4/8pt rhythm, and semantic labels.
- Design loading, empty, error, permission, and success states before polishing
  the happy path.
- Use progressive disclosure so the silly premise stays simple while advanced
  options remain available when earned.
- Give every app one peak-end moment: a verdict, result, reveal, or character
  reaction people can understand and share.
- Use motion for orientation and feedback; remove decorative motion under Reduce
  Motion and avoid loops, parallax, large zooms, and layout jumps.
- Use native system fonts and controls for fidelity, accessibility, and Dynamic
  Type; keep the visual personality in composition, color, illustration, and
  interaction.

## Current project mapping

- Shared primitives: `shared/DumbKit.swift`, `shared/Palette.swift`, and
  `shared/LocalNotifications.swift`.
- Native design source of truth: `design-system/unnecessary-apps/MASTER.md`.
- Motion source of truth: `docs/MOTION_DESIGN_SYSTEM.md`.
- UX reference log: `docs/UX_REFERENCES.md`.
- Release and visual QA records: `docs/`, `release/`, and `tests/`.

The four supplied references remain linked in `docs/UX_REFERENCES.md` and are
balanced against Apple platform conventions, App Store requirements, and the
project’s privacy/security review.
