# Queue Personality Test

Measure a real queue while receiving a deeply unserious personality verdict.

## What actually works

- First launch has no active or fictional queue. Start a named session with the
  real people ahead and a manual fallback minutes-per-person estimate.
- A live elapsed timer survives relaunch because it derives from the stored start
  date rather than pretending the app stayed active.
- Record each observed person served, someone joining ahead, or a position
  correction. The app keeps people-ahead and served counts exact.
- Before progress, ETA = people ahead × fallback minutes per person. After a
  served observation, ETA = elapsed seconds ÷ people served × people ahead.
- Finish as Reached front or Left queue. Up to 50 private sessions retain wait,
  starting position, observed throughput, and outcome, with average/longest
  summaries, individual deletion, and confirmed complete erasure.
- An optional one-shot estimated-turn notification is rescheduled when position
  changes, uses generic lock-screen copy, and follows shared quiet hours.

No backend, account, analytics, ads, location, camera, venue feed, or network
permission.
