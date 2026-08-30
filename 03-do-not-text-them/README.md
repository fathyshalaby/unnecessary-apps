# Do Not Text Them

A local-only cooling-off intervention for messages that should remain drafts forever.

## What works

- The user types a private draft that stays in memory and is never saved or sent.
- A ten-second intervention uses a real deadline, so pausing or backgrounding does not stretch the countdown.
- An optional generic local notification marks the end of the intervention if you leave the app.
- The app provides timed prompts, a completion state, and a deliberate delete-evidence action.
- Completed interventions and deleted-draft totals are persisted locally without storing message content.
- The primary controls expose accessibility identifiers for simulator and UI testing.

No account, backend, analytics SDK, advertising SDK, or network permission is required. Notifications are optional and local; their text never includes the draft.
