# TestFlight release lane

This folder contains the release checklist, export-options template, external
credential template, and the shareable beta-link hub for all 44 active apps.

All 44 App Store Connect records, processed TestFlight builds, and external
TestFlight groups/public links are provisioned. The current builds are
submitted to Apple for Beta App Review. Once approved, attach external testers
to each app's group. Real App Store Connect credentials belong in
`~/.private_keys/appstoreconnect.env`, never in this repository.

The editable App Store Connect Store metadata is also synced for all 44 apps:
localized titles use the `Unnecessary:` convention, subtitles are present, and
the hosted privacy URL is attached to each record.

Apple keeps TestFlight invitations app-scoped, so the collection’s single
shareable entry point is [TESTFLIGHT_INVITE_LINKS.md](TESTFLIGHT_INVITE_LINKS.md)
or [the web link hub](../site/testflight.html). The hosted hub is
https://fathyshalaby.github.io/unnecessary-apps/testflight.html. Each app link
becomes installable only after Apple approves the corresponding external beta
build. The live hub accurately marks the collection as in Apple review.

Start with [TESTFLIGHT_CHECKLIST.md](TESTFLIGHT_CHECKLIST.md).

The copy, categories, privacy boundaries, review notes, and release priorities
for all 44 active local/manual candidates are in
[APP_STORE_METADATA.md](APP_STORE_METADATA.md) and its machine-readable
[app-store-metadata.json](app-store-metadata.json). Validate the manifest with
`python3 tools/validate_store_metadata.py release/app-store-metadata.json`
before copying metadata into App Store Connect.
Also run `node tools/validate_testflight_hub.js` after changing the public hub.

The 44 iPhone 6.9-inch images under `release/screenshots/` are QA reference
captures, not final Store screenshots: they need a clean simulator/device
recapture so the status-bar chrome and older capability surfaces cannot drift
from the uploaded build.

To repeat the unsigned distribution-archive sweep locally, run
`tools/archive_all_local_apps.sh`. It writes ignored archives and a manifest
under `build/local-archives/`; the manifest records each archive’s actual
version/build values. Signing and upload still require Apple Developer
credentials.

To validate the current local signing lane without uploading anything, run:

```sh
ARCHIVE_OUTPUT_DIR=build/signed-archives \
ARCHIVE_CODE_SIGNING_ALLOWED=YES \
ARCHIVE_CODE_SIGNING_REQUIRED=YES \
ARCHIVE_DEVELOPMENT_TEAM=2CGZC35S8K \
./tools/archive_all_local_apps.sh
```

This produces development-signed archives for on-device checks. It is not the
App Store distribution export or TestFlight upload step.

For a future signed archive/export/upload update, use
`tools/release_all_testflight.sh` with a new build number and a deliberately
selected app batch. Successful API uploads attach each processed build to its
app’s `Unnecessary Apps Friends` external group. Submit the updated build to
Beta App Review with `ASC_SUBMIT_BETA_REVIEW=true` after confirming its review
notes and privacy report.

Beta App Review contacts are already populated in App Store Connect and are
intentionally not stored in this repository. See
`release/appstoreconnect.env.example` for the local configuration shape.

Verify the completed sweep with python3 tools/verify_local_archives.py. The
verifier checks all 44 active archive products against the metadata bundle IDs,
their recorded version/build values, and the encryption flag.
