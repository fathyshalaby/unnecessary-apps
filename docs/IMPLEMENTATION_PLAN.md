# Dumb Apps Collection Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build ten separate, silly, local-first SwiftUI app starters in ordered folders inside `unecessary apps corp`.

**Architecture:** Each app is an independent SwiftUI source folder with a small model and one main interaction. A shared visual vocabulary is documented but not required at runtime. The first delivery uses seeded local data and simulated platform behavior where permissions or device services would add unnecessary complexity.

**Tech Stack:** SwiftUI, Foundation, local in-memory state, iOS 17 minimum when opened as Xcode projects.

**Spec:** `docs/superpowers/specs/2026-08-24-dumb-apps-collection-design.md` in the source workspace.

## Global Constraints

- No accounts, backend, analytics, ads, or payments in the first version.
- Store demo/user-created data locally.
- One core action per app.
- Copy must be funny, concise, and knowingly overdramatic.
- Empty states are part of the joke, not generic placeholders.
- The UI should feel polished enough to be a real app while the premise remains silly.
- Avoid health, financial, legal, or safety claims unless the app is clearly presented as entertainment.

---

### Task 1: Create collection shell and shared visual notes

**Files:**
- Create: `README.md`
- Create: `shared/README.md`
- Create: `shared/Palette.swift`

- [ ] Create the root README listing all ten folders, each premise, and the “one joke, one interaction” rule.
- [ ] Add named palette constants for warm canvas, ink, muted ink, and the ten accent colors.
- [ ] Verify every ordered folder name appears exactly once in the root README.

### Task 2: Build 01 Chair Finder

**Files:**
- Create: `01-chair-finder/README.md`
- Create: `01-chair-finder/ChairFinderApp.swift`
- Create: `01-chair-finder/ContentView.swift`

- [ ] Seed three chairs with shade, comfort, view, and pigeon-density scores.
- [ ] Render a municipal-signage screen with a “Find me a chair” button.
- [ ] On tap, choose the best chair using comfort + shade - pigeon density and explain the verdict in silly copy.
- [ ] Verify the empty/reset state can be reached by clearing the local list.

### Task 3: Build 02 Public Bathroom Quality Map

**Files:**
- Create: `02-public-bathroom-quality-map/README.md`
- Create: `02-public-bathroom-quality-map/BathroomMapApp.swift`
- Create: `02-public-bathroom-quality-map/ContentView.swift`

- [x] Search the visible Apple map for possible public-restroom results and keep a manual map-pin fallback.
- [x] Request optional When In Use location only after the user taps the recenter control.
- [x] Save bounded private reports for cleanliness, privacy, supplies, queue, changing-table observation, coordinates, and notes.
- [x] Label search results as possible facilities and require users to verify access, hours, conditions, and accessibility on arrival.
- [ ] Complete unlocked simulator and physical-device search/location grant/denial smoke passes.

### Task 4: Build 03 Do Not Text Them

**Files:**
- Create: `03-do-not-text-them/README.md`
- Create: `03-do-not-text-them/DoNotTextThemApp.swift`
- Create: `03-do-not-text-them/ContentView.swift`

- [ ] Add a text editor and an intervention timer state.
- [ ] Start a short countdown with escalating judgment messages.
- [ ] Provide “delete draft” and “I am still making a bad decision” actions.
- [ ] Verify the draft remains local and is never sent.

### Task 5: Build 04 Social Battery Receipt

**Files:**
- Create: `04-social-battery-receipt/README.md`
- Create: `04-social-battery-receipt/SocialBatteryReceiptApp.swift`
- Create: `04-social-battery-receipt/ContentView.swift`

- [ ] Add person count, duration, and before/after energy controls.
- [ ] Calculate energy cost and assign a receipt category.
- [ ] Render an ink-on-receipt summary with subtotal, tax, and total social damage.
- [ ] Verify zero-duration and no-attendee states do not crash.

### Task 6: Build 05 Fridge Witness

**Files:**
- Create: `05-fridge-witness/README.md`
- Create: `05-fridge-witness/FridgeWitnessApp.swift`
- Create: `05-fridge-witness/ContentView.swift`

- [ ] Add fridge item chips and an “interrogate the fridge” action.
- [ ] Generate a deterministic witness statement from the selected items.
- [ ] Make the empty state accuse the user of hiding evidence.
- [ ] Verify the statement is clearly fictional entertainment.

### Task 7: Build 06 Receipt Emotional Damage

**Files:**
- Create: `06-receipt-emotional-damage/README.md`
- Create: `06-receipt-emotional-damage/ReceiptDamageApp.swift`
- Create: `06-receipt-emotional-damage/ContentView.swift`

- [ ] Add a purchase amount entry and purchase-category picker.
- [ ] Convert the amount into dramatic regret labels and a fake financial “mood” report.
- [ ] Include a reset action and local-only disclosure.
- [ ] Verify invalid/negative input is handled without a crash.

### Task 8: Build 07 Sock Tribunal

**Files:**
- Create: `07-sock-tribunal/README.md`
- Create: `07-sock-tribunal/SockTribunalApp.swift`
- Create: `07-sock-tribunal/ContentView.swift`

- [ ] Add unmatched sock color/pattern entries.
- [ ] Create a case number and procedural hearing screen.
- [ ] Produce a verdict from the number of socks and elapsed days.
- [ ] Verify the case can be dismissed and reopened locally.

### Task 9: Build 08 Plant Court

**Files:**
- Create: `08-plant-court/README.md`
- Create: `08-plant-court/PlantCourtApp.swift`
- Create: `08-plant-court/ContentView.swift`

- [ ] Add plant name, last-watered date, and condition slider.
- [ ] Generate charges and a verdict with a tiny next action.
- [ ] Style the screen as a courtroom with verdict gold.
- [ ] Verify the app never presents plant status as real agronomic advice.

### Task 10: Build 09 Laundry Mountain

**Files:**
- Create: `09-laundry-mountain/README.md`
- Create: `09-laundry-mountain/LaundryMountainApp.swift`
- Create: `09-laundry-mountain/ContentView.swift`

- [ ] Add pile size and days-since-laundry controls.
- [ ] Calculate a fake threat level and one embarrassingly small action.
- [ ] Render a detergent-blue dashboard with a basket-orange action button.
- [ ] Verify all slider values produce a readable result.

### Task 11: Build 10 What Was I Doing?

**Files:**
- Create: `10-what-was-i-doing/README.md`
- Create: `10-what-was-i-doing/WhatWasIDoingApp.swift`
- Create: `10-what-was-i-doing/ContentView.swift`

- [ ] Add a single giant “I forgot” button.
- [ ] Track local taps for the current day.
- [ ] Produce a daily loss-of-purpose report with escalating copy.
- [ ] Verify reset clears only local in-memory entries.

### Task 12: Cross-app verification and handoff

**Files:**
- Modify: `README.md`
- Create: `VERIFICATION.md`

- [ ] Check every app folder contains README, app entry source, and ContentView source.
- [ ] Run Swift syntax checks where the installed toolchain supports them.
- [ ] Record any Xcode/simulator limitation in `VERIFICATION.md`.
- [ ] Leave GitHub remote creation as a separate explicit publishing step.

## Expansion note

The original implementation plan covered the first ten-app batch. The complete forty-four-app active scope is tracked in `docs/45-apps-roadmap.md`; waves 2–5 use the same per-folder contract: one README, one standalone SwiftUI `@main` source file, local-only state, one core interaction, and an intentionally silly visual voice.
