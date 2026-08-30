# Beta usability measurement

## Current answer

The apps do not currently contain a product-analytics SDK and do not send custom
usage events to the publisher. That matches the current privacy copy.

Internal TestFlight still provides Apple-hosted beta evidence: installs,
sessions, crashes, and tester feedback. Testers can attach a screenshot and
context from the TestFlight feedback flow. This is enough for the first personal
test pass, but it cannot answer where a user abandoned an app-specific flow.

## First TestFlight pass

Use the Apple metrics plus one structured feedback loop:

1. Install each build through TestFlight rather than Xcode.
2. Complete the app's `What to Test` journey once without help.
3. Send TestFlight feedback immediately when the main action is unclear,
   permission copy feels suspicious, a result is disappointing, or a screen
   feels slow.
4. Include a screenshot and start the note with one label: `BLOCKED`,
   `CONFUSING`, `BORING`, `DELIGHTFUL`, or `BUG`.
5. Review crashes, sessions, and feedback after 3 days and again after 7 days.

This keeps the first build honest: no new collection is introduced merely to
measure one tester.

## Recommended product analytics for a wider beta

TelemetryDeck is the preferred lightweight option for this portfolio. It has a
native Swift SDK, is designed around explicit anonymous signals, and can be used
without recording advertising identifiers, typed content, photos, health data,
or precise location.

If enabled, use one portfolio namespace and attach only these coarse fields:

- app bundle ID and build number;
- anonymous installation and session identifiers;
- event name;
- coarse duration bucket such as `<10s`, `10–30s`, `30–120s`, or `>120s`;
- permission type and outcome, never the underlying data.

Canonical event names:

- `app_opened`
- `primary_action_started`
- `result_shown`
- `reset_used`
- `permission_outcome`
- `flow_abandoned`

Never send photos, HealthKit values, coordinates, journal text, names, drafts,
AI prompts or results, notification content, clipboard content, or free-form
error messages. Do not add session replay.

Enabling this requires a TelemetryDeck account/namespace plus updates to the
privacy policy, the per-app privacy matrix, and App Store Connect privacy
answers before that instrumented build is uploaded.

## Seven-day scorecard

For each app, record:

| Signal | Healthy beta threshold |
|---|---:|
| Launches without crash | 100% |
| Main journey completed without help | Yes |
| Time to first useful action | Under 30 seconds |
| Permission denial leaves app usable | Yes |
| Tester wants to repeat or share it | Yes/Maybe |
| Unresolved blocking feedback | 0 |

An app that is stable but fails the final two rows is not a release winner; it
needs a product or storytelling change rather than more polish.
