# One More Episode

Calculate tomorrow’s regret before pressing play.

## What actually works

- User-chosen episode count, episode runtime, and sleep budget drive exact
  minute-level arithmetic; no whole-hour truncation remains.
- The published rule is simple: each minute watched is subtracted from the
  sleep budget chosen by the user. The app does not prescribe sleep needs.
- An optional show name and up to 20 complete forecasts persist locally with
  recent/full-history browsing and individual deletion.
- Reset clears only the current inputs; confirmed complete erasure removes the
  current forecast and all history.

No streaming, calendar, sleep-sensor, HealthKit, account, analytics, ads, or
network integration. This is a transparent trade-off calculator, not medical advice.
