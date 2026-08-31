# All apps — demo scripts

30–45 second screen recordings for all 44 active apps. Run on Mac:

```bash
python3 tools/generate_app_manifest.py
python3 tools/generate_demo_scripts.py
zsh tools/record_all_apps_demos.sh
```

The recorder launches each app, starts a simulator clip, prints the
App Review path below, and waits for Enter when your take is done.

Output: `release/demos/all-apps/NN-slug.mp4`

Use harmless sample text only. Launch from Springboard so the status
bar has no previous-app back label.

Apps marked **HOLD** (38, 40) are documented for completeness but stay
out of the first public App Store cohort per `release/RELEASE_ORDER.md`.

---

## 01. Unnecessary: Chair Finder

**File:** `01-chair-finder.mp4` · **Scheme:** `App01ChairFinder`

**Demo path (from App Review notes):**

Add two harmless sample chairs, adjust their ratings, rank the shortlist, relaunch to verify persistence, remove an observation, and use confirmed clear-all. No login, location permission, or special hardware is required.

---

## 02. Unnecessary: Public Bathrooms

**File:** `02-public-bathroom-quality-map.mp4` · **Scheme:** `App02BathroomMap`

**Demo path (from App Review notes):**

Tap Find restrooms to exercise Apple MapKit local search, choose a possible result, file a private report, relaunch to verify persistence, and clear it. The manual map-pin button completes the same flow without search or location permission. Deny the optional location request to verify map fallback.

---

## 03. Unnecessary: Do Not Text Them

**File:** `03-do-not-text-them.mp4` · **Scheme:** `App03DoNotTextThem`

**Demo path (from App Review notes):**

Enter sample text, tap Start the cool-off, allow notifications if desired, leave the app, wait ten seconds, return, and tap Delete the evidence. The app never sends messages and needs no login.

---

## 04. Unnecessary: Social Receipt

**File:** `04-social-battery-receipt.mp4` · **Scheme:** `App04SocialBatteryReceipt`

**Demo path (from App Review notes):**

With the defaults, file a receipt to see an 8/10 to 3/10 five-point drain over 60 minutes. Move Energy after to 10/10 to see a two-point recharge instead. History supports individual deletion, current-receipt reset, and confirmed complete erasure. No account or personal contact data is required.

---

## 05. Unnecessary: Fridge Witness

**File:** `05-fridge-witness.mp4` · **Scheme:** `App05FridgeWitness`

**Demo path (from App Review notes):**

First launch is empty. Add Greek Yogurt with the default reminder, add the same name again to verify quantity merge, then Interrogate current inventory. Use one decrements a multi-unit row; Remove item deletes it. Complete erasure requires confirmation. No camera, appliance, or food-ordering integration is present.

---

## 06. Unnecessary: Receipt Damage

**File:** `06-receipt-emotional-damage.mp4` · **Scheme:** `App06ReceiptEmotionalDamage`

**Demo path (from App Review notes):**

Enter Reusable Bottle, amount 12,50, and 10 intended uses. File the invoice to see €12.50 ÷ 10 = €1.25. The reminder toggle is optional; notification permission is requested only when filing a purchase with a reminder enabled. Delete cancels that entry's pending reminder, and Erase all requires confirmation. No banking connection is present.

---

## 07. Unnecessary: Sock Tribunal

**File:** `07-sock-tribunal.mp4` · **Scheme:** `App07SockTribunal`

**Demo path (from App Review notes):**

File one suspicious ankle sock with today's date and an optional last-seen location. The court order reports 0 derived missing days. Mark it Reunited, Reopen search, then Close unsolved to inspect all states. The reminder switch is optional; permission is requested only when filing a reminded case. Resolving, deleting, evicting, or erasing cancels related notifications.

---

## 08. Unnecessary: Plant Court

**File:** `08-plant-court.mp4` · **Scheme:** `App08PlantCourt`

**Demo path (from App Review notes):**

Add Fern with today's last-watered date and the default seven-day interval. The care order publishes that rule. Use Watered now to append history, Edit record to amend without duplication, then delete or erase. Notification permission is requested only when saving a plant whose reminder switch is enabled; editing, watering, deletion, and erasure reschedule or cancel requests.

---

## 09. Unnecessary: Laundry Mountain

**File:** `09-laundry-mountain.mp4` · **Scheme:** `App09LaundryMountain`

**Demo path (from App Review notes):**

Add Gym kit with the default two loads, 45-minute wash, and 50-minute dry. Move it through every stage and fold one load; it returns to Dirty with one load remaining. Edit the batch, complete the second load, reopen one load, then delete or erase. Notification permission is requested only when a reminded batch enters Washing or Drying.

---

## 10. Unnecessary: What Was I Doing

**File:** `10-what-was-i-doing.mp4` · **Scheme:** `App10WhatWasIDoing`

**Demo path (from App Review notes):**

Choose a context, optionally enter a last-known mission, and tap I forgot why. Add two incidents, relaunch to verify persistence, delete one row, then use Manage incidents to erase today or the complete archive.

---

## 11. Unnecessary: Am I Early?

**File:** `11-am-i-early.mp4` · **Scheme:** `App11AmIEarly`

**Demo path (from App Review notes):**

File the default 12-minute-early Dentist arrival, then move the signed slider to -30 and file the late verdict. Relaunch to verify the current report and two-record summary, delete one arrival, reset the current report, and confirm Erase all punctuality data. No calendar access is required.

---

## 12. Unnecessary: Bird Verdict

**File:** `12-pigeon-or-seagull.mp4` · **Scheme:** `App12PigeonOrSeagull`

**Demo path (from App Review notes):**

Choose a harmless sample photo from Photos or take one with the camera, inspect the on-device Vision labels, tap the classification action, then reset. Also verify the manual checklist path. Camera permission is requested only after Camera is tapped; no account is required.

---

## 13. Unnecessary: Toilet Timer

**File:** `13-toilet-timer.mp4` · **Scheme:** `App13ToiletTimer`

**Demo path (from App Review notes):**

Start the timer and allow notifications if desired. Leave the app or lock the device to verify elapsed time continues, milestone notifications are scheduled, and the Live Activity appears on the Lock Screen or Dynamic Island when supported. Return, stop, and assess; relaunch to verify local history. Reset cancels the active timer and its milestones without deleting history; complete history erasure requires confirmation.

---

## 14. Unnecessary: One More Episode

**File:** `14-one-more-episode.mp4` · **Scheme:** `App14OneMoreEpisode`

**Demo path (from App Review notes):**

Choose the episode count, minutes per episode, and your own sleep budget, then tap Calculate tomorrow. The result uses exact minute arithmetic. Recent forecasts persist locally and support individual deletion, current-input reset, and confirmed complete erasure. No streaming login is needed.

---

## 15. Unnecessary: Wear Again?

**File:** `15-can-i-wear-this-again.mp4` · **Scheme:** `App15CanIWearThisAgain`

**Demo path (from App Review notes):**

Enter an optional item name, set completed wears and your personal maximum, optionally mark condition flags, then tap Issue & file closet ruling. Test an approval with the defaults, exceed the personal limit, or mark odor to see the transparent branches. History supports individual deletion, current-evidence reset, and confirmed complete erasure. No photo permission is required.

---

## 16. Unnecessary: Microwave

**File:** `16-microwave-sommelier.mp4` · **Scheme:** `App16MicrowaveSommelier`

**Demo path (from App Review notes):**

With the defaults, tap Convert & file the pairing to verify that 4:00 at 1000 W becomes 5:00 at 800 W with a 4-minute checkpoint. Set the appliance to 500 W to receive 8:00 with a 6:25 checkpoint. History supports individual deletion, current-pairing reset, and confirmed complete erasure. No appliance integration is present.

---

## 17. Unnecessary: Meeting Bingo

**File:** `17-meeting-bingo-for-one.mp4` · **Scheme:** `App17MeetingBingo`

**Demo path (from App Review notes):**

Mark all three squares in one row to produce BINGO. Break and restore the row to verify the same board counts only once, relaunch to verify board persistence, deal a new meeting, and use Erase the board history for confirmed complete deletion. No meeting integration or login is required.

---

## 18. Unnecessary: Tiny Gratitude

**File:** `18-tiny-gratitude.mp4` · **Scheme:** `App18TinyGratitude`

**Demo path (from App Review notes):**

Choose a tiny-win category, enter two gratitudes, and tap Archive this miracle. Relaunch to verify persistence, delete one entry, and use Manage the tiny archive to resurface a win or confirm complete erasure. No account is needed.

---

## 19. Unnecessary: Peasant Advice

**File:** `19-medieval-peasant-advice.mp4` · **Scheme:** `App19MedievalAdvice`

**Demo path (from App Review notes):**

Enter a harmless sample question, tap the advice action, and verify either the on-device model response or the clearly labeled local fallback. Reset the question and answer. No cloud AI service, account, or network is required.

---

## 20. Unnecessary: Real Email?

**File:** `20-is-this-a-real-email.mp4` · **Scheme:** `App20RealEmail`

**Demo path (from App Review notes):**

Paste harmless sample text, tap Perform email autopsy, inspect the score, matched phrases, and surgery plan, then tap Clear. Relaunching starts empty. The app does not access an inbox.

---

## 21. Unnecessary: Vibe Meter

**File:** `21-the-vibe-meter.mp4` · **Scheme:** `App21VibeMeter`

**Demo path (from App Review notes):**

Adjust the two sliders, tap Measure the vibe, and reset. No camera or room sensing is used.

---

## 22. Unnecessary: Snack Roulette

**File:** `22-snack-roulette.mp4` · **Scheme:** `App22SnackRoulette`

**Demo path (from App Review notes):**

Enter “Toast, toast, Banana” to verify the pantry becomes two valid options. Spin twice to see immediate-repeat avoidance, relaunch to verify pantry and history persistence, delete one spin, and confirm Erase pantry & spin history for complete local deletion. No shopping or account integration is present.

---

## 23. Unnecessary: Quiet Café

**File:** `23-quiet-cafe-index.mp4` · **Scheme:** `App23QuietCafe`

**Demo path (from App Review notes):**

Tap Find cafés to exercise Apple MapKit local search, choose a result, rate it, save, relaunch to verify persistence, and clear the journal. The manual map-pin button completes the same private flow without search or location permission. Deny the optional location request to verify map fallback.

---

## 24. Unnecessary: Dog Name Guesser

**File:** `24-dog-name-guesser.mp4` · **Scheme:** `App24DogNameGuesser`

**Demo path (from App Review notes):**

Choose a sample image from Photos or take one with the camera, inspect the local Vision finding, enter a name such as Biscuit, tap Present the name, and reset the accusation. Camera permission is requested only after Camera is tapped; no login or network access is required.

---

## 25. Unnecessary: Waiting Room

**File:** `25-waiting-room-simulator.mp4` · **Scheme:** `App25WaitingRoom`

**Demo path (from App Review notes):**

Adjust the simulated wait or advance five minutes, inspect the state, and reset. No appointment or clinic login is required.

---

## 26. Unnecessary: Noise Translator

**File:** `26-neighbor-noise-translator.mp4` · **Scheme:** `App26NeighborNoise`

**Demo path (from App Review notes):**

Tap the two-second listening action and review the local level result, then enter a harmless typed description and tap Translate. Deny microphone access if prompted to verify the fallback. Reset the wall’s evidence.

---

## 27. Unnecessary: Tiny Museum

**File:** `27-tiny-personal-museum.mp4` · **Scheme:** `App27TinyMuseum`

**Demo path (from App Review notes):**

Create two sample exhibits and optionally choose an image from Photos or take one with the camera. Relaunch to verify the catalog, remove one exhibit, and use confirmed complete erasure. Camera permission is requested only after Camera is tapped; images remain local and no account or network is required.

---

## 28. Unnecessary: Worry Board

**File:** `28-overthinking-evidence-board.mp4` · **Scheme:** `App28OverthinkingBoard`

**Demo path (from App Review notes):**

Enter an everyday worry, supporting evidence, counter-evidence, an alternative, and a small next step. Issue a provisional conclusion, relaunch to verify the draft and archived case, then delete the case and clear the current board. No account or network is required.

---

## 29. Unnecessary: Bench Reviews

**File:** `29-local-bench-reviews.mp4` · **Scheme:** `App29BenchReviews`

**Demo path (from App Review notes):**

Pan the map and tap Review the map center. Enter a bench name, adjust ratings, save, relaunch to verify persistence, and use Clear all. The optional location button requests When In Use access only to recenter the map; deny it to verify the manual map fallback.

---

## 30. Unnecessary: Apology Draft

**File:** `30-apology-draft-generator.mp4` · **Scheme:** `App30ApologyDraft`

**Demo path (from App Review notes):**

Enter a harmless tiny crime, choose a tone, generate the draft, and verify either the on-device model response or clearly labeled local template fallback. Copy it if desired, then clear it. No messaging permission is required.

---

## 31. Unnecessary: Human GPS

**File:** `31-human-gps.mp4` · **Scheme:** `App31HumanGPS`

**Demo path (from App Review notes):**

Enter a fictional landmark, tap the directions action, and reset. No location or map permission is requested.

---

## 32. Unnecessary: Last Slice

**File:** `32-the-last-slice.mp4` · **Scheme:** `App32LastSlice`

**Demo path (from App Review notes):**

Enter at least two fictional consenting names separated by commas, convene the tribunal, then choose They passed or Award it. Repeat with the same roster to observe that a prior winner is excluded from the minimum-award tie until others catch up. History supports individual deletion and confirmed complete erasure. No Contacts or notification permission is requested.

---

## 33. Unnecessary: Queue Type

**File:** `33-queue-personality-test.mp4` · **Scheme:** `App33QueuePersonality`

**Demo path (from App Review notes):**

Enter a queue name and start with the default five people/three minutes. Record served people, a joiner, or a correction; then choose Reached front or Left queue. History supports individual deletion and confirmed complete erasure. The optional estimated-turn notification requests permission only after the user enables it and starts that queue. No location or camera permission is requested.

---

## 34. Unnecessary: Outfit Excuse

**File:** `34-weather-outfit-excuse.mp4` · **Scheme:** `App34WeatherOutfit`

**Demo path (from App Review notes):**

Enter a harmless outfit and manual temperature, generate the excuse, and reset. No weather or location permission is requested.

---

## 35. Unnecessary: The Door Was Push

**File:** `35-the-door-was-push.mp4` · **Scheme:** `App35DoorWasPush`

**Demo path (from App Review notes):**

Enter a fictional door/place, choose a mistake direction, adjust attempts and sign clarity, then file the incident. Reopen it with Edit door incident to verify in-place correction, or use individual and complete deletion controls. No hardware or notification permission is requested.

---

## 36. Unnecessary: Step Debt

**File:** `36-step-debt.mp4` · **Scheme:** `App36StepDebt`

**Demo path (from App Review notes):**

Tap the optional Apple Health button and inspect the permission explanation, denial fallback, and today’s step count if data exists. Manual steps, calculation, and reset work without HealthKit.

---

## 37. Unnecessary: Sleep Alibi

**File:** `37-sleep-alibi.mp4` · **Scheme:** `App37SleepAlibi`

**Demo path (from App Review notes):**

Tap the optional Apple Health sleep button and inspect the permission explanation, denial/no-data fallback, and generated alibi if samples exist. Also verify the manual estimate, generate, and reset paths. No data is written to Apple Health.

---

## 38. Unnecessary: Heart Rate Email **[HOLD]**

**File:** `38-heart-rate-during-email.mp4` · **Scheme:** `App38HeartRateEmail`

**Demo path (from App Review notes):**

Enter fictional email subject and manual BPM values, generate the drama entry, and reset. No HealthKit or inbox permission is requested.

---

## 39. Unnecessary: Workout Excuse

**File:** `39-workout-excuse-detector.mp4` · **Scheme:** `App39WorkoutExcuse`

**Demo path (from App Review notes):**

Tap the optional Apple Health workouts button and inspect the permission explanation, denial/no-data fallback, and local audit if workouts exist. Also verify the manual excuse, movement estimate, detector, and reset paths. No data is written to Apple Health.

---

## 40. Unnecessary: Health Horoscope **[HOLD]**

**File:** `40-health-data-horoscope.mp4` · **Scheme:** `App40HealthHoroscope`

**Demo path (from App Review notes):**

Enter manual values or optionally connect Apple Health for steps and sleep, consult the horoscope, and reset. HealthKit is optional read-only; manual mode works without it. The entertainment disclaimer is part of the app.

---

## 41. Unnecessary: Recovery Goblin

**File:** `41-the-recovery-goblin.mp4` · **Scheme:** `App41RecoveryGoblin`

**Demo path (from App Review notes):**

Choose fictional tiredness and soreness values, consult the goblin, and reset. No health permission is requested.

---

## 42. Unnecessary: Walking Meeting

**File:** `42-walking-meeting-escape-plan.mp4` · **Scheme:** `App42WalkingMeeting`

**Demo path (from App Review notes):**

Choose a fictional meeting duration, generate the exit plan, and reset. No calendar or location permission is required.

---

## 43. Unnecessary: Hydration Narc

**File:** `43-hydration-narc.mp4` · **Scheme:** `App43HydrationNarc`

**Demo path (from App Review notes):**

Choose a personal serving goal, log two servings, undo one, and log again. Relaunch to verify same-day persistence. The app automatically rolls a completed day into its seven-day local ledger. Empty today’s ledger requires confirmation and preserves earlier summaries. Optional read-only Apple Health water import and one optional local daily nudge are available; manual logging works without either.

---

## 44. Unnecessary: Rest Day Police

**File:** `44-rest-day-police.mp4` · **Scheme:** `App44RestDayPolice`

**Demo path (from App Review notes):**

Enter a fictional manual training streak, issue the citation, and reset it. No activity or health permission is requested.

---

## Post-production

- Trim to under 45 seconds each.
- No real private emails, health data, or contact info.
- Export H.264 MP4.
- Physical device clips are fine for Live Activity, camera, and HealthKit demos.
