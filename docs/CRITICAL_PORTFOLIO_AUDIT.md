# Critical portfolio audit

Date: 30 August 2026  
Scope: 44 active apps in the current Xcode project, their READMEs, SwiftUI
implementations, social plans, and release notes. `45 Lab Report Translator` is
retired and excluded.

## Executive verdict

This is a strong creator series and a mixed app portfolio. The mistake would be
to treat every idea as a standalone product. Several apps are excellent story
episodes because the premise is funny, physical, and easy to demonstrate; only
some have enough repeat value or utility to justify their own App Store listing.

The practical plan is:

1. Make the creator-story videos first for the strongest concepts.
2. Release a small number of proven apps, not all 44 at once.
3. Combine adjacent map/journal/wellness concepts or leave them as episodes.
4. Reframe misleading titles and hold anything that suggests health sensing,
   diagnosis, live weather, public data, or intelligence the build does not have.

## What the audit found

- **44 active targets** are a lot of release, signing, metadata, screenshot, and
  support overhead for mostly tiny experiences.
- The shared `DumbKit` shell gives the collection a coherent visual voice, but
  many apps still follow the same input-card → chunky button → result-card
  composition. The portfolio risks feeling like one template with different
  jokes.
- The best apps have a physical/social setup, a visible decision, and an output
  people can argue about. The weakest apps are a couple of sliders wrapped in a
  name that implies a larger capability.
- Local-first is a real strength. It is also the reason copy must be precise:
  manual input is not sensing, private notes are not a public index, and a
  deterministic joke is not AI.

## Tier A — make long creator-story episodes and consider shipping

These pass both tests: they make a good 75–105 second story and have a credible
reason to exist after the joke.

| # | App | Critical verdict |
|---:|---|---|
| 01 | Chair Finder | Excellent pilot. Real observation plus a physical test. Keep the boundary that it ranks chairs the user recorded; it does not discover the best chair in Vienna. |
| 03 | Do Not Text Them | Strong universal problem and visible countdown. The “never sends” guarantee is the product; keep it prominent. |
| 06 | Receipt Emotional Damage | Excellent result card and real arithmetic. It is a cost-per-use reflection, not emotional analysis; demo with fictional purchases. |
| 10 | What Was I Doing? | The use case is instantly understood and repeatable. The story should show the embarrassing loop across a day. |
| 17 | Meeting Bingo for One | Strong repeat use, audience participation, and a real-time demo. Keep workplace privacy central. |
| 20 | Is This a Real Email? | Useful local heuristic, but the title overclaims truth detection. Prefer “Corporate Fog Detector” or say clearly that it estimates clarity. |
| 24 | Dog Name Guesser | Best playful pilot for the requested format. It can check photo labels and propose a silly name, but it cannot know the dog’s real name. Fluffers makes the story concrete. |
| 30 | Apology Draft Generator | Strong comments and a meaningful generated output. Keep the on-device/fallback boundary and never imply it repairs a relationship. |
| 32 | The Last Slice | More useful than the joke suggests: a local fairness rotation with a clear group ritual. Use consenting participants. |
| 35 | The Door Was Push | Best pure physical-comedy episode. The incident log makes the joke persist without needing a fake AI claim. |
| 42 | Walking Meeting Escape Plan | A genuinely useful local meeting-session tool wearing a comedy costume. Consider making the utility clearer instead of hiding it behind “escape.” |

## Tier B — good episodes; ship only after a sharper product decision

These are worth filming, but the current version needs a clearer niche, better
repeat loop, stronger interaction, or a companion relationship before it earns a
separate public release.

| # | App | What is wrong or what to change |
|---:|---|---|
| 02 | Public Bathroom Quality Map | Map search is real, but private ratings do not create a public quality map. Call it a private field log or add a real shared-data product later. |
| 04 | Social Battery Receipt | Good social joke, shallow repeat value. Make the receipt/share artifact the payoff or bundle it with other personal “receipts.” |
| 05 | Fridge Witness | Good domestic character and repeat setup, but currently closer to a local inventory tool with a joke skin. Strong episode; prove retention before standalone release. |
| 07 | Sock Tribunal | Great physical prop and verdict. Limited utility, so treat it as a content-first app unless the case/history loop becomes genuinely fun. |
| 08 | Plant Court | Charming, but the verdict is only as good as the user’s manual input. Keep it clearly comedic and avoid plant-care authority. |
| 09 | Laundry Mountain | Real workflow underneath the joke. It can ship if the stage progression and reminders feel faster than a normal task list. |
| 11 | Am I Early? | Relatable but one arithmetic result. Needs a stronger social/shareable verdict to avoid being a one-tap novelty. |
| 12 | Pigeon or Seagull? | Strong public argument and photo moment. Keep the manual fallback honest; generic Vision labels are not reliable species expertise. |
| 14 | One More Episode? | Strong late-night story, but the app must show the next-morning consequence or it is just a bedtime calculator. |
| 15 | Can I Wear This Again? | Good physical demo and social ambiguity. Make condition/evidence meaningful enough that the result is not predetermined. |
| 16 | Microwave Sommelier | Good visual episode. Avoid food-safety authority and be clear that the useful part is wattage conversion, not culinary expertise. |
| 19 | Bad Advice from a Medieval Peasant | Strong character concept. Keep distinct prompt paths and disclose when the on-device model is unavailable and fallback copy is used. |
| 22 | Snack Roulette | Simple but participatory. It needs user-submitted snack combinations to stay alive. |
| 23 | Quiet Café Index | The map is real; the “index” is not. Rename/reframe as private visit notes unless shared data is actually built. |
| 25 | Waiting Room Simulator | The anti-game is funny for a short clip but difficult to watch for 90 seconds. Keep it as a short episode or add a visible escalation mechanic. |
| 26 | Neighbor Noise Translator | Good relatable setup and a responsible non-confrontation boundary. The two-second volume reading should not be sold as identifying a sound. |
| 27 | Tiny Personal Museum | Emotionally strong and technically substantial. It is a better submission/story product than a mass-market utility; let real object stories validate it. |
| 28 | Overthinking Evidence Board | Strong story structure, but keep it entertainment/reflection and not therapy or mental-health treatment. |
| 29 | Local Bench Reviews | Good sequel to Chair Finder, not a good opening release beside two other map apps. Consider a shared “field notes” container. |
| 31 | Human GPS | Funny premise, but the generated instruction is deliberately obvious. Remove default fake evidence and keep it content-first unless the user can add meaningful landmarks/context. |
| 33 | Queue Personality Test | Real queue timing gives it substance, but manual throughput is noisy and the flow is relatively complex for the joke. Pilot with real consented queues. |
| 34 | Weather Outfit Excuse | Good visual creator episode. The current manual temperature input means the title and copy must not imply live weather data. |
| 37 | Sleep Alibi | Strong morning acting bit. Keep the HealthKit path optional and the outcome as a joke, never sleep advice. |
| 39 | Workout Excuse Detector | Filmable and potentially repeatable. The detector should be supportive rather than shaming, especially when HealthKit is involved. |
| 41 | The Recovery Goblin | Excellent mascot potential, but a “train or lie on the floor” ruling can sound like exercise/injury advice. Keep it clearly fictional. |
| 43 | Hydration Narc | Strong character and one-tap loop. The current manual ledger does not justify a title/copy that implies proactive monitoring or nagging. |
| 44 | Rest Day Police | Good fitness-culture satire, but easy to make guilt-heavy. Keep it as supportive comedy and validate whether users return. |

## Tier C — do not promote as standalone products yet

These are not necessarily bad ideas. They are either too thin, too generic, or
too easy to misunderstand. Make a short episode, combine them, or rewrite the
premise before spending release and paid-generation budget.

| # | App | Decision |
|---:|---|---|
| 13 | Toilet Timer | Content can work, but the subject is awkward and the feature is close to a timer. Keep non-explicit and short-form unless there is a clear Live Activity use case. |
| 18 | Tiny Gratitude | Kind but generic. It needs a distinct social artifact or should remain a soft palate-cleanser episode. |
| 21 | The Vibe Meter | The concept is a manual score from a few sliders; the story is better than the product. Consider folding it into a room/space field-notes app. |
| 36 | Step Debt | A fake invoice around low movement can feel guilt-heavy. Keep manual/fictional boundaries and hold from the first release wave. |
| 38 | Heart Rate During Email | The current app is a self-reported drama log, despite the physiological title. Rename to “Inbox Drama Log” or keep it content-only. |
| 40 | Health Data Horoscope | Health data plus astrology is easy to read as misleading. Keep entertainment-only, optional, and in a separate wellness-satire arc; do not use it as an early product. |

## Video priority after this audit

The first long-form episodes should be:

1. Dog Name Guesser — Fluffers
2. The Door Was Push
3. Receipt Emotional Damage
4. Do Not Text Them
5. Chair Finder
6. Apology Draft Generator
7. Meeting Bingo for One
8. Walking Meeting Escape Plan

Dog Name Guesser is first because it has a real character (Fluffers), a clear
personal story, a visual input, a satisfying result, and an honest limitation
that makes the episode more trustworthy rather than less funny.

## Architecture and release recommendation

Keep the existing shared shell and local-first implementation for now; it is a
useful production base. Do not build more targets until the first episodes tell
us which behaviors deserve retention. If the audience responds to clusters,
consolidate later into a smaller number of products:

- **Field Notes:** Chair Finder, benches, cafés, bathrooms.
- **Personal Receipts:** social battery, purchases, sleep/workout/wellness logs.
- **Tiny Courts:** socks, plants, doors, apologies, outfit rulings.
- **Games and Guessing:** dog names, birds, snacks, bingo, queues.

That would preserve the creator universe while reducing App Store minimum-
functionality risk, duplicated metadata, and maintenance across dozens of
targets.

## Go/no-go gate for each public release

Before an app gets a store listing, require: a strong creator episode, explicit
download demand, one repeat-use reason, honest capability copy, a clean privacy
boundary, and a physical-device permission pass for camera, microphone, maps,
notifications, or HealthKit when applicable.
