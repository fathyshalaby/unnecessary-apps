# Laundry Mountain

Plan real laundry batches, move each load through the mountain, and call actual
progress progress.

## What actually works

- First launch is empty. Add a named batch, category, estimated load count, and
  your expected wash/dry durations.
- Every batch follows an explicit manual trail: Dirty → Washing → Drying →
  Folding → Done. Nothing advances automatically and no appliance is controlled.
- Folding completes one load; multi-load batches return to Dirty until every
  load is finished. Finished batches can reopen one load.
- Up to 50 batches persist locally with active-batch, remaining-load, and
  finished-load summaries, due-first queue ordering, editing, stage correction,
  individual deletion, and confirmed complete erasure.
- Optional one-shot stage reminders use the user-entered wash/dry duration,
  generic lock-screen copy, and shared quiet-hour handling. Stage changes,
  deletion, eviction, and erasure cancel stale notifications.

No backend, account, analytics, ads, appliance, sensor, or network permission.
