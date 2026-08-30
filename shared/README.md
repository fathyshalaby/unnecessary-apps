# Shared app foundation

The apps share generous spacing, large rounded cards, friendly system typography, and copy that treats tiny inconveniences as national emergencies. Each app should keep its own accent color and visual joke.

`LocalNotifications.swift` provides the local-only reminder lifecycle for apps
with a concrete user-created reason to notify. It centralizes authorization,
one-shot calendar scheduling, the 09:00–20:30 quiet-hours adjustment, and
pending/delivered cancellation. It contains no remote-push or analytics path.
