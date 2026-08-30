# App Privacy submission matrix (draft)

This matrix reflects the current local/manual binaries and must be rechecked
against the signed archive before App Store Connect submission.

| # | App | Data collected by publisher | Linked to user | Used for tracking | Device permissions in current build |
|---:|---|---|---|---|---|
| 01 | Chair Finder | None | No | No | None |
| 02 | Public Bathroom Quality Map | Saved coordinates, ratings, observations, and notes stay locally on-device and are not collected | No | No | Apple MapKit restroom search; optional When In Use location only to recenter; manual map fallback |
| 03 | Do Not Text Them | None; optional local notification contains generic completion text and is not collected | No | No | Optional local notifications |
| 04 | Social Battery Receipt | None | No | No | None |
| 05 | Fridge Witness | None | No | No | None |
| 06 | Receipt Emotional Damage | None | No | No | None |
| 07 | Sock Tribunal | None | No | No | None |
| 08 | Plant Court | None | No | No | None |
| 09 | Laundry Mountain | None | No | No | None |
| 10 | What Was I Doing? | None | No | No | None |
| 11 | Am I Early? | None | No | No | None |
| 12 | Pigeon or Seagull? | None; selected or captured photo analyzed on-device and not retained | No | No | User-initiated PhotosPicker or camera capture |
| 13 | Toilet Timer | None; start time, session duration, optional estimate, and history remain on-device | No | No | Optional local notifications and Live Activity |
| 14 | One More Episode | None | No | No | None |
| 15 | Can I Wear This Again? | None | No | No | None |
| 16 | Microwave Sommelier | None | No | No | None |
| 17 | Meeting Bingo for One | None | No | No | None |
| 18 | Tiny Gratitude | None | No | No | None |
| 19 | Bad Advice from a Peasant | None | No | No | None |
| 20 | Is This a Real Email? | None | No | No | None |
| 21 | The Vibe Meter | None | No | No | None |
| 22 | Snack Roulette | None | No | No | None |
| 23 | Quiet Café Index | Saved coordinates, ratings, visit period, and notes stay locally on-device and are not collected | No | No | Apple MapKit venue search; optional When In Use location only to recenter; manual map fallback |
| 24 | Dog Name Guesser | None (selected or captured photo is processed on-device and not collected) | No | No | User-initiated PhotosPicker or camera capture |
| 25 | Waiting Room Simulator | None | No | No | None |
| 26 | Neighbor Noise Translator | None; two-second microphone sample processed in memory and not retained | No | No | Microphone |
| 27 | Tiny Personal Museum | Exhibit text and selected or captured photos are stored locally in the protected app container; not collected | No | No | User-initiated PhotosPicker or camera capture; photos resized/re-encoded locally |
| 28 | Overthinking Evidence Board | None | No | No | None |
| 29 | Local Bench Reviews | Saved coordinates, ratings, and notes stay locally on-device and are not collected | No | No | Optional When In Use location only to recenter Apple MapKit; manual map fallback |
| 30 | Apology Draft Generator | None | No | No | None |
| 31 | Human GPS | None | No | No | None |
| 32 | The Last Slice | None | No | No | None |
| 33 | Queue Personality Test | None | No | No | None |
| 34 | Weather Outfit Excuse | None | No | No | None |
| 35 | The Door Was Push | None | No | No | None |
| 36 | Step Debt | Optional read-only Apple Health step count and one-off route coordinates are processed on-device and not collected | No | No | HealthKit read; optional When In Use location only for a requested route; optional local notifications; manual fallback |
| 37 | Sleep Alibi | Optional read-only Apple Health sleep samples are processed on-device and not collected | No | No | HealthKit read permission only; optional local notifications; manual fallback |
| 38 | Heart Rate During Email | None | No | No | None |
| 39 | Workout Excuse Detector | Optional read-only Apple Health workout durations are processed on-device and not collected | No | No | HealthKit read permission only; optional local notifications; manual fallback |
| 40 | Health Data Horoscope | Optional read-only Apple Health steps and sleep samples are processed on-device for entertainment and not collected | No | No | HealthKit read permission only; optional local notifications; manual inputs |
| 41 | The Recovery Goblin | Optional read-only Apple Health workout duration is processed on-device and not collected | No | No | HealthKit read permission only; optional local notifications; self-report fallback |
| 42 | Walking Meeting Escape Plan | None | No | No | None |
| 43 | Hydration Narc | Optional read-only Apple Health water entries are processed on-device and not collected; the local serving ledger remains separate | No | No | HealthKit read permission only; optional local notifications; manual ledger |
| 44 | Rest Day Police | Optional read-only Apple Health workout entries are processed on-device and not collected | No | No | HealthKit read permission only; optional local notifications; manual fallback |

“None” means the publisher does not receive the local values from the current
binary. Local storage, including the system clipboard after a user taps Copy
in App 30, is not publisher collection. Confirm this interpretation with the
final signed archive and any future SDK changes.
