# Step Debt

Turn a low-step day into a fake invoice for movement you allegedly owe yourself.

Step Debt asks before reading today’s step count from Apple Health. It builds an
editable smart target from the recent on-device baseline (Apple Health supplies
steps, not a universal step goal), then shows the remaining fictional balance.
The user can request a nearby walking route, see its estimated step coverage,
and hand the real walking directions to Apple Maps. Manual entry remains
available in the simulator, offline, or after permission is denied.

After an explicit connection, the app refreshes read-only context on relaunch;
choosing manual mode keeps that choice until the user reconnects Apple Health.
No HealthKit values are stored by the app.

The optional joke clerk uses Apple Foundation Models on supported iOS 26
devices, with a deterministic local fallback. A single quiet-hours-aware daily
check-in is opt-in. No health or location data is uploaded or written back.
