# Toilet Timer

A gentle public-service announcement about leaving the bathroom before you become folklore.

## What actually works

- A real session timer uses its persisted start date, so Home, lock, suspension,
  process termination, and relaunch do not lose elapsed time.
- Local milestone notifications are scheduled for 5, 10, 15, and 20 minutes and
  are cancelled when the session stops or resets.
- A Live Activity shows the running timer on the Lock Screen and, on supported
  iPhones, in the Dynamic Island's expanded, compact, and minimal presentations.
- Stopping records the measured duration and produces a local bathroom assessment.
- A separate manual 1–60 minute estimate action works without starting the live timer.
- Up to 20 completed live or estimated sessions persist in a private local log,
  with individual deletion and confirmed complete erasure.
- Reset stops and clears only the current session; it does not silently delete history.

It is a playful timer, not a health monitor, medical tool, or emergency service.
Notification permission is requested only when a live session starts; declining
it leaves the in-app timer fully usable.
