# Unnecessary Apps notification strategy

“Duolingo-level” means a memorable character voice, a visible progress loop,
and excellent timing. It does not mean copying Duolingo, nagging every day, or
using guilt to manufacture retention.

## Non-negotiable rules

1. Never request notification permission on first launch. Show the value first
   and ask only when the user turns on a concrete reminder.
2. Every notification must map to a user-created object, chosen schedule, or
   unfinished action. Generic “we miss you” pushes are forbidden.
3. Default to one-shot local notifications. Recurring reminders require an
   explicit schedule, a visible off switch, and a frequency cap.
4. Respect quiet hours. The planned collection default is no delivery before
   09:00 or after 20:30 local time unless the user chooses otherwise.
5. A tap must deep-link to the relevant object or action. Never open to an
   unrelated home screen.
6. Editing or deleting the source object must reschedule or cancel its pending
   notifications. Complete data erasure removes pending and delivered items.
7. Denial is a normal product state. The primary feature keeps working and the
   app explains how to enable notifications later without repeatedly prompting.
8. No health panic, shame, threats, fake urgency, misleading badges, or
   relationship manipulation. The joke targets the situation, not the user.
9. Keep notification text private on the lock screen. Avoid amounts, health
   readings, message drafts, lab details, and other sensitive specifics by
   default.
10. Measure usefulness before scale: opt-in, notification-open, completion, and
    disable rates matter more than raw sends. The local-first apps do not add
    analytics merely to measure this; structured QA comes first.

## Product pattern

Each eligible app gets the same reliable lifecycle with its own voice:

`user creates value → offers reminder in context → permission if needed → one
scheduled notification → deep-link to value → completion cancels the loop`

The shared UI language is “Remind me…” rather than “Enable notifications.” The
system prompt appears only after the user has chosen a reason and a schedule.

## Rollout map

| App | Useful notification | Personality line | Decision |
|---|---|---|---|
| Receipt Emotional Damage | One purchase review after 1–30 days | “The receipt requests a follow-up.” | Local scheduling implemented; deep-link and physical-device sign-off pending |
| Sock Tribunal | One open-case recheck after 1–14 days | “The Sock Tribunal reconvenes.” | Shared local helper implemented; deep-link and physical-device sign-off pending |
| Fridge Witness | User-entered use-by reminder | “The leftovers have requested counsel.” | Next shared-helper adopter |
| Tiny Gratitude | Optional user-chosen reflection time | “One tiny good thing is accepting submissions.” | High value; recurring cap 1/day |
| Hydration Narc | User schedule; stop when daily goal is met | “Your water has retained legal representation.” | High value; never medical |
| Step Debt | One user-chosen daily movement-invoice check-in | “The accountant has stamped one tiny reminder.” | Optional recurring local reminder; no health value in notification text |
| Sleep Alibi | One user-chosen morning courtroom opening | “The courtroom is open for testimony.” | Optional recurring local reminder; no sleep duration in notification text |
| Workout Excuse Detector | One user-chosen daily case check-in | “The evidence desk is open.” | Optional recurring local reminder; no workout details in notification text |
| Health Data Horoscope | One user-chosen daily constellation check-in | “The stars have filed another harmless opinion.” | Optional recurring local reminder; entertainment only |
| The Recovery Goblin | One user-chosen daily self-report check-in | “The goblin is accepting one tiny report.” | Optional recurring local reminder; no health interpretation |
| Rest Day Police | One user-chosen daily activity-docket check-in | “Your private docket is ready for review.” | Optional recurring local reminder; no workout details in notification text |
| Plant Court | User-entered care/check date, rescheduled after watering or edits | “Plant Court is back in session.” | Shared local helper implemented; deep-link and physical-device sign-off pending |
| Laundry Mountain | User-timed wash and dry stage checkpoint | “Laundry Mountain checkpoint.” | Shared local helper implemented; physical-device sign-off pending |
| Queue Personality Test | One rescheduled checkpoint near the current estimated front | “Queue checkpoint: the front may be approaching.” | Shared local helper implemented; deep-link and physical-device sign-off pending |
| Do Not Text Them | Cooldown completion or a user-chosen later review | “The draft has completed its sentence.” | Useful only with reliable background scheduling |
| Meeting Bingo | User-chosen meeting start | “The bingo board is entering the call.” | Optional calendar-derived phase |
| One More Episode? | User-chosen stop-time checkpoint | “The next episode has filed an appeal.” | Optional; no retention nags |
| Local place journals | User-created revisit reminder | App-specific field-note voice | Later, only per saved place |
| Health and lab apps | User-created measurement/check-in schedule | Calm, factual, non-diagnostic copy | Hold for separate health safety review |
| Vision, guessing, roulette, and one-off joke apps | No natural reminder | None | Do not add notifications |
| The Last Slice | No deferred action: the group resolves a live ruling together | None | Deliberately no notifications; a later push would be retention spam |
| The Door Was Push | No deferred action: each report describes an already completed incident | None | Deliberately no notifications; pattern history remains useful without nagging |

## Technical rollout

### Phase 1 — local one-shot foundation

- Build a small shared notification coordinator around
  `UNUserNotificationCenter`.
- Use app-scoped identifiers derived from the local record UUID.
- Centralize authorization states, scheduling, cancellation, quiet-hour
  adjustment, and test-only short intervals.
- Add unit tests for identifier stability and date adjustment plus one focused
  simulator journey per adopting app.

### Phase 2 — deep links and actions

- Add an app-specific URL route to the source record.
- Add category actions only where they complete real work, such as “Logged” or
  “Snooze one day.”
- Cancel stale requests whenever a record changes or disappears.

### Phase 3 — recurring loops

- Keep recurring schedules limited to explicit opt-in products: Tiny Gratitude,
  Hydration Narc, and the health-lane check-in cards. Each has schedule, quiet
  hours, and disable controls in the app.
- Cap at one scheduled touch per app per day and never stack missed reminders.

## Release acceptance

An app does not advertise reminders until these pass:

- fresh install with permission not determined;
- allow and deny flows on a physical iPhone;
- delivery at the chosen time;
- tap route to the correct local object;
- edit/reschedule, individual delete/cancel, and erase-all cancellation;
- notification preview contains no sensitive detail;
- VoiceOver, Dynamic Type, reduced motion, and denied-permission state;
- no reminder appears after the user completes or deletes the source action.
