# First wave demo scripts

30–45 second screen recordings for the ten launch apps. Run on Mac:

```bash
chmod +x tools/record_first_wave_demos.sh
zsh tools/record_first_wave_demos.sh
```

The script launches each app, starts a simulator recording, prints these steps, and waits for you to press Enter when the take is done. Output lands in `release/demos/first-wave/`.

Use harmless sample text only. Hide the simulator status-bar back label by launching from Springboard, not Xcode.

---

## 1. Real Email? (`01-real-email.mp4`)

**Hook:** Paste a bloated corporate email.  
**Steps:**

1. Paste: *"Just circling back to touch base on the robust alignment we discussed. Moving forward, please note we need to leverage bandwidth by EOD."*
2. Tap **Perform email autopsy**.
3. Hold on clarity score + fog terms + surgery plan (3 sec).
4. Tap **Clear email evidence**.

**End frame:** Empty editor + “No email means no problem. Yet.”

---

## 2. Do Not Text Them (`02-do-not-text.mp4`)

**Hook:** Type the text you shouldn’t send.  
**Steps:**

1. Enter: *"I know it's 2am but we need to talk."*
2. Tap **Start the cool-off** — show countdown briefly (3 sec).
3. Wait for **Intervention complete** (or fast-forward in edit if recording live).
4. Tap **Delete the evidence** — show “A narrow escape” result.

**End frame:** Stats showing 1 completed cool-off.

---

## 3. What Was I Doing? (`03-what-was-i-doing.mp4`)

**Steps:**

1. Set context **Opened phone**.
2. Optional note: *"Reply to the landlord"*
3. Tap **I forgot why** twice with different notes.
4. Show incident count **2** and log rows.
5. Swipe-delete one incident.

**End frame:** Count drops to 1.

---

## 4. Tiny Gratitude (`04-tiny-gratitude.mp4`)

**Steps:**

1. Pick category **Tiny win**.
2. Enter: *"Elevator arrived immediately."*
3. Tap **Archive this miracle**.
4. Add a second gratitude.
5. Tap **Resurface a tiny win** (if enabled) or open archive.

**End frame:** Summary showing journal days / entry count.

---

## 5. Overthinking Board (`05-overthinking-board.mp4`)

**Steps:**

1. Worry: *"They left me on read."*
2. Evidence sections auto-expand — fill supporting, counter, alternative, next step.
3. Tap **Issue provisional conclusion**.
4. Show mixed-evidence result quoting your next step.

**End frame:** Archive count **1**.

---

## 6. Hydration Narc (`06-hydration-narc.mp4`)

**Steps:**

1. Tap **Log one serving** twice.
2. Tap **Undo last serving** once.
3. Show progress toward daily goal.
4. (Optional) scroll to Apple Health card — do not require permission on camera.

**End frame:** Bottle report with attitude after logging.

---

## 7. Toilet Timer (`07-toilet-timer.mp4`)

**Steps:**

1. Tap **Start stall timer**.
2. Show live elapsed readout ticking (5 sec).
3. Tap **Stop & assess the situation** — show bureaucratic ruling.
4. Briefly scroll to session history.

**End frame:** One session in history. Skip Live Activity unless on physical device.

---

## 8. Meeting Bingo (`08-meeting-bingo.mp4`)

**Steps:**

1. Tap three squares in one row.
2. Hold on **BINGO** result.
3. Tap **Deal a new meeting** — fresh board.
4. Show completed-game count still **1**.

**End frame:** New unmarked board + lifetime stat.

---

## 9. Snack Roulette (`09-snack-roulette.mp4`)

**Steps:**

1. Enter pantry: *"Toast, toast, Banana"*
2. Tap **Spin the tiny wheel** twice.
3. Show history with two different picks (no immediate repeat).

**End frame:** Latest ruling visible.

---

## 10. Am I Early? (`10-am-i-early.mp4`)

**Steps:**

1. Occasion: *"Dentist"*
2. Leave default **12 minutes early** — tap file/punctuality button.
3. Show **Comfortably early** verdict.
4. Drag slider to **-30** (late) — file again.
5. Show **causing a scene** verdict + summary **2 filed, 1 not late, 1 late**.

**End frame:** Punctuality summary card.

---

## Post-production checklist

- Trim dead air at start/end (keep under 45s each).
- No private real emails, phone numbers, or names.
- Export H.264 MP4; 1080p or simulator native is fine.
- Name files exactly as above for App Store preview / social reuse.
