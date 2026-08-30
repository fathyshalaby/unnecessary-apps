# Unnecessary Apps Motion Design System

## Direction

The collection should feel like a cabinet of tiny, polished toys: one tap creates one clear joke, the character reacts, and the interface settles immediately. Motion supports the punchline instead of becoming wallpaper.

The visual weighting is:

- Jakub Krehel: polished consumer-app timing, clear entrances, and cohesive transitions.
- Jhey Tompkins: characterful anticipation, overshoot, and comedy at the moment of payoff.
- Emil Kowalski: restraint for repeated actions, short durations, and immediate feedback.

## Shared motion vocabulary

| Token | Purpose | SwiftUI value |
| --- | --- | --- |
| DumbMotion.quick | Buttons, counters, repeated actions | Spring, 0.22 response / 0.78 damping |
| DumbMotion.playful | Mascot payoff and major selection | Spring, 0.38 response / 0.64 damping |
| DumbMotion.settle | Return to rest after a reaction | Spring, 0.46 response / 0.84 damping |

DumbCharacterStage provides three trigger-based personalities:

- bounce: optimistic success and discovery.
- shake: intervention, warning, embarrassment, or refusal.
- stamp: official verdicts and bureaucratic comedy.

No shared component uses a repeating animation. Every transform begins with user intent, returns to rest, and collapses to a static state when Reduce Motion is enabled.

## Flagship implementations

### Chair Finder

- Personality: optimistic.
- Character: custom pigeon seating inspector generated for the app.
- Motion: anticipation, hop, settle when a chair wins.
- Signature UI: seating scores, animated winner crown, selected candidate card.

### Do Not Text Them

- Personality: dramatic.
- Motion: brief phone-officer shake at intervention start and completion.
- Signature UI: animated ten-second cooling-off dial, numeric text transition, local-only evidence notice.
- High-frequency countdown changes stay short and restrained.

### The Door Was Push

- Personality: chaotic.
- Motion: door witness shakes after each failed pull; result lands like an official incident stamp.
- Signature UI: physical PUSH evidence card, failed-attempt tally, animated numeric count.

## Accessibility and performance

- Respect accessibilityReduceMotion everywhere.
- Prefer opacity and transforms; avoid animating layout constraints.
- Keep decorative layers static and limit each screen to one primary character reaction.
- Preserve 44-point minimum interactive targets and semantic accessibility labels.
- Use content transitions for changing text so labels remain stable and readable.

## Rollout for the remaining apps

Assign one personality and one signature interaction per app. Reuse the shared timing tokens and character stage, but do not reuse the same joke, hero composition, or result mechanic twice in the same release wave. Validate each wave in Reduce Motion, dark mode, large Dynamic Type, and on the smallest supported iPhone before TestFlight.

## Generated asset

- File: assets/characters/chair-finder-inspector.png
- In-app asset: 01-chair-finder/Assets.xcassets/ChairInspector.imageset/ChairInspector.png
- Prompt summary: transparent editorial-style pigeon facilities inspector seated in the existing blue chair, holding a clipboard and wearing the collection's green staff sash; expressive, readable at mobile size, and matched to the existing mascot family.
- Generator: built-in image generation.
