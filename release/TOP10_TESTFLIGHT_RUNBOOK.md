# Top 10 internal TestFlight runbook

## Current state

The portfolio contains 44 active apps. The five-app internal beta is the
current canary; the remaining records and external beta paths are provisioned
for the full release lane.

- Apple Developer team is configured in the generated project.
- The audited internal beta lane is uploaded and verified in App Store Connect:
  Do Not Text Them Build 3, Dog Name Guesser Build 6, Step Debt Build 1, Sleep
  Alibi Build 1, and Workout Excuse Build 1. Each is `Ready to Submit`.
- Four new internal groups each contain the owner tester and one build. Dog Name
  Guesser’s internal pilot group contains the owner tester and its prior build
  history; its external group contains Build 6 and the owner tester.
- All 44 App Store Connect app records exist. Each app also has an external
  group and public invitation link; those links are listed in
  `release/TESTFLIGHT_INVITE_LINKS.md` and become installable after a processed
  build is assigned.
- The repository’s next App24 archive must use a number greater than 6. The
  current per-app build ledger is `config/build-numbers.json`.
- An App Store Connect API key is installed outside the repository at
  `~/.private_keys/appstoreconnect.env`; never commit it or its `.p8` file.
- The local keychain exposes a valid iPhone Distribution identity for team
  `2CGZC35S8K`, and the four refreshed HealthKit distribution profiles are
  installed outside the repository.
- The Mac must be unlocked before Xcode Organizer or App Store Connect can be
  controlled. Never store a tester email in this repository.

## Release order

1. Dog Name Guesser — `App24DogNameGuesser`
2. Pigeon or Seagull? — `App12PigeonOrSeagull`
3. The Door Was Push — `App35DoorWasPush`
4. Receipt Emotional Damage — `App06ReceiptEmotionalDamage`
5. Meeting Bingo for One — `App17MeetingBingo`
6. Sock Tribunal — `App07SockTribunal`
7. Apology Draft Generator — `App30ApologyDraft`
8. Plant Court — `App08PlantCourt`
9. Medieval Peasant Advice — `App19MedievalAdvice`
10. Laundry Mountain — `App09LaundryMountain`

## Per-app gate

1. Confirm the exact bundle ID in `release/app-store-metadata.json`.
2. Verify the App Store Connect app record and its external group/public link.
3. Confirm `CURRENT_PROJECT_VERSION` is greater than every uploaded build.
4. Run the focused UI scheme listed in `docs/TOP10_VIRAL_UX_AUDIT.md`.
5. Archive for generic iOS with the team distribution identity.
6. Validate and upload with `tools/release_all_testflight.sh`, or use Xcode
   Organizer if interactive signing repair is needed.
7. Wait for processing, set the app-specific “What to Test” text, assign the
   internal group, and assign the processed build to the app’s external group.
8. Install from TestFlight on the physical iPhone and smoke-test permissions,
   notifications, dark appearance, Reduce Motion, and large Dynamic Type.

## Upload blocker checklist

- [ ] Mac unlocked
- [x] Xcode account session healthy
- [x] Distribution signing available through Xcode remote signing
- [x] All 44 App Store Connect records created
- [x] External group and public link provisioned for all 44 apps
- [x] Five audited internal pilot groups contain the owner tester and their
  pilot build assignments
- [x] Five audited builds uploaded and verified as `Ready to Submit`
- [ ] App Store Connect processing completes with no export-compliance or privacy warning for the new full-lane builds
- [ ] Physical iPhone accepts the invitations, installs the audited builds, and completes the smoke pass
