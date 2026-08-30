# Flagship iPhone QA — first 30 minutes

Run this only after Apple makes the TestFlight builds installable. Use a real
iPhone, not a simulator. Record the app name, step, result, and one screenshot
or screen recording for every failure.

## Setup once

- Install TestFlight and the five apps below from the collection hub.
- Turn on notifications, location, Health, and camera only when that app asks
  in context. Deny each permission once when noted; a useful manual path must
  remain.
- Test in light mode, then repeat the marked visual check in dark mode with the
  largest Dynamic Type size and Reduce Motion enabled.

## 1. Dog Name Guesser

1. Open it and immediately understand the primary action without reading a
   tutorial.
2. Pick a dog photo, then take one with the camera. The result must arrive
   promptly, explain that it is a playful guess, and reset cleanly.
3. Cancel the picker and camera once. No dead-end screen or permission nag.
4. Pick a non-dog photo. The recovery/manual path must be obvious and kind.
5. Visual check: headline, result, reset, and camera action remain reachable
   at the largest type size.

## 2. Toilet Timer

1. Start a session in one tap; the next milestone must be legible immediately.
2. Lock the phone. Confirm the Live Activity appears and its elapsed time is
   credible after returning to the app.
3. Leave the app in the background. Confirm the requested milestone
   notification arrives once, sounds appropriate, and opens to the right
   state.
4. Stop/reset. The Live Activity and pending timer notification must end.
5. Deny notifications once. The timer remains useful and explains nothing
   repeatedly.

## 3. Quiet Café Index

1. The map is the first useful surface, not an onboarding wall.
2. Allow location: the map recenters without blocking search or manual browsing.
3. Deny location: search and manually place/select a café; no guilt copy.
4. Create one rating and note; close and reopen to confirm local persistence.
5. Visual check: map controls, add/rate action, and selected-place sheet work
   in dark mode and largest type.

## 4. Step Debt

1. Connect Apple Health from the first useful screen, with a plain-language
   reason before the system prompt.
2. Allow Health access: the goal and today’s progress should feel
   understandable, not punitive. Verify the route suggestion opens Apple Maps.
3. Deny Health access: manual goal/progress still makes sense and no medical
   claims appear.
4. Turn on notifications only after choosing a nudge style/time; test that
   the copy is supportive rather than shamey.
5. Visual check: numbers, progress state, map route CTA, and notification
   preference remain usable at largest type.

## 5. Health Data Horoscope

1. Explain that it is playful, not medical, before the Health permission
   prompt.
2. Allow only a subset of Health data. The app should give a graceful result,
   naming no unavailable data as an error.
3. Deny access: offer a readable sample/manual path; no pressure loop.
4. Revoke permission in Settings and reopen. The app must recover calmly.
5. Visual check: disclaimer, primary action, result, and share affordance are
   visible in dark mode, largest type, and Reduce Motion.

## Pass bar

Each app passes when the main action takes one obvious path, permission denial
does not dead-end the experience, no false live/medical claim appears, and
there is no clipped, overlapping, or inaccessible control. Fix a failure
before inviting a wider group.
