# Unnecessary Apps UX references

This collection uses the supplied references as directional input for the next product pass. The apps are intentionally silly, but the interactions should still feel obvious, forgiving, and worth showing to another person.

## References used

- [Essential skills to become a successful mobile app developer](https://medium.com/@nareshintern.infasta/essential-skills-to-become-a-successful-mobile-app-developer-812f4a49da83)
- [Mobile App UI Design](https://github.com/ceorkm/mobile-app-ui-design)
- [Mobile App UX Best Practices](https://mcpmarket.com/tools/skills/mobile-app-ux-best-practices)
- [9 must-have skills for Codex in 2026](https://medium.com/@unicodeveloper/9-must-have-skills-for-codex-in-2026-b5124b375eec)

## Principles adopted

### What the references changed

- The GitHub UI guide's five-pass sequence—context, structure, visual, emotion,
  and polish—is now the review order for every app. It also contributes the
  60/30/10 color balance, 8-point spacing rhythm, thumb-zone placement, and a
  deliberate peak-end moment.
- The mobile UX reference adds the operational gates: 44pt-or-larger targets,
  progressive disclosure, inline validation, explicit loading/empty/error/
  success states, and accessibility checks.
- The developer-skills article is used as an engineering reminder: native
  platform fluency, maintainable structure, testing, and version control matter
  as much as the visual pass.
- The Codex-skills article is treated as a non-authoritative discovery list. We
  use its planning, review, security, and verification mindset, but do not add
  third-party MCPs, paid services, or API keys without a specific requirement.

### Make the joke easy to use

- Every screen has one obvious primary action.
- The first useful result is visible without making the user learn the architecture.
- The app explains what happens next in plain, playful language.
- Empty, loading, error, and success states are designed rather than left to system defaults.
- Buttons and controls keep a comfortable 44pt-or-larger touch target.
- Layout follows a 4/8pt rhythm, with 16/24/32pt section tiers and safe-area-aware
  bottom breathing room.
- The first viewport gets the thumb-friendly action; secondary controls arrive
  through progressive disclosure only when they help complete the task.

### Make each app feel like its own tiny world

- Shared SwiftUI primitives keep spacing, type hierarchy, motion, and accessibility consistent.
- Each app chooses its own accent, mascot, vocabulary, and payoff animation.
- Motion supports the punchline and respects Reduce Motion.
- Copy avoids technical terms such as local, cloud, backend, upload, and fallback.
- Color aims for a 60/30/10 balance and never carries meaning without a label,
  icon, shape, or content change.
- SF Symbols and native system typography keep structural UI crisp and Dynamic
  Type-friendly; personality comes from composition and the app's tiny world.

### Put the useful thing first

- Map apps lead with the map: Public Bathroom Quality Map, Quiet Café Index, and Local Bench Reviews now give the map the dominant visual area and place the first action directly against it.
- Image-led apps lead with the image action: Pigeon or Seagull?, Dog Name Guesser, and Tiny Personal Museum offer both Photo library and Take photo at the point of need.
- Camera access is requested only when a person chooses Take photo. On Simulator, the action gives a clear alternative because there is no physical camera.

### Build with a deliberate release loop

- Use native SwiftUI and system frameworks where they are the clearest fit.
- Search the existing collection before introducing a new pattern.
- Rebuild after generated-project changes, run focused UI tests, and then inspect screenshots at phone size.
- Treat the physical-device permission and camera pass as a release gate before TestFlight.

### Reference-fit note

The UI Pro Max search was useful for native SwiftUI loading and accessibility
patterns, but its broad database is web-oriented and returned no match for a
complex SwiftUI UX query. The project therefore keeps the native rules in
`design-system/unnecessary-apps/MASTER.md` and validates them in Xcode rather
than importing Tailwind, shadcn, or browser-only interaction patterns.

These sources are practical design references, not substitutes for Apple Human Interface Guidelines, App Store review requirements, or the project’s privacy/security review.
