# Apology Draft Generator

Apologize for tiny crimes such as finishing the milk or saying “you too” to a waiter.

## What actually works

- On supported iOS 26 devices, Apple Foundation Models generates a complete
  apology on-device.
- If the Apple model is unavailable (including the simulator), a deterministic
  local tone template keeps the app useful.
- Four tones are available: sincere-ish, formal, text message, and dramatic.
- The draft can be copied to the device clipboard without an account or network request.
- Empty input, copy state, and a clear flow are handled explicitly.

Drafts are session-only by design; this app does not send messages, save personal apologies, use analytics, or request network access.
