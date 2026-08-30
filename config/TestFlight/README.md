# TestFlight release preparation

The active collection contains 44 app targets. The current canary lane is the
five-app internal beta documented in `release/TESTFLIGHT_CHECKLIST.md`; the
same release helper can upload the complete collection in bounded batches.

Before archiving:

1. Replace `REPLACE_WITH_APPLE_TEAM_ID` in `App01-ExportOptions.plist` with the Apple Developer Team ID.
2. Set `DEVELOPMENT_TEAM` for the selected target in Xcode, or add it as a project build setting.
3. Create the matching app record and bundle ID in App Store Connect.
4. Create `~/.private_keys/appstoreconnect.env` outside this repository with `ASC_KEY_ID`, `ASC_ISSUER_ID`, and `ASC_KEY_PATH`. The `.p8` key stays outside the repo.
5. Confirm the Mac is signed into the Apple Developer account in Xcode and that automatic distribution signing is available.

The current release helper is:

```sh
RELEASE_APP_NUMBERS=1-10 \
ASC_BETA_GROUP="Unnecessary Apps Friends" \
./tools/release_all_testflight.sh
```

Archives and exported IPAs are written under `build/`, which is ignored and must not be committed. The shared `release/ExportOptions-TestFlight.plist` and profile manifest cover the active targets; verify the target’s metadata and profile before adding it to a release batch.

All 44 App Store Connect app records and their external group/public-link
records are already provisioned. A processed build must be assigned to its
app’s group before its public link becomes installable; the release helper does
that automatically in API mode. Beta App Review submission remains opt-in via
`ASC_SUBMIT_BETA_REVIEW=true`.
