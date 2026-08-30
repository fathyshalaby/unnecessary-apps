# Plant Court

Your plants have filed a private care docket. You have been summoned.

## What actually works

- First launch is empty. Add each real plant with a name, optional species and
  room, last-watered date, user-chosen 1–30 day interval, and user-reported 1–5
  condition.
- Next care check is transparent arithmetic: last-watered date + the user's
  interval. Plants are ordered by what is due first; nothing is diagnosed or
  closed automatically.
- Up to 50 plants persist locally with due-now and watering-entry summaries,
  one-tap “Watered now,” full editing, individual deletion, draft cancellation,
  and confirmed complete erasure.
- Each plant keeps its newest 50 watering dates.
- An optional one-shot local reminder follows the next user-defined care date,
  uses generic lock-screen copy, respects 09:00–20:30 quiet hours, and is
  rescheduled or cancelled when the record changes.

Care data is intentionally manual; this app does not claim camera, soil sensor,
plant identification, HealthKit, weather data, or horticultural authority. No
backend, account, analytics, ads, or network permission.
