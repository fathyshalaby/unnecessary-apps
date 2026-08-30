# TestFlight release lane

This folder contains the release checklist, export-options template, external
credential template, and the shareable beta-link hub for all 44 active apps.

The first five builds remain a valid internal pilot: Do Not Text Them, Dog Name
Guesser, Step Debt, Sleep Alibi, and Workout Excuse. All 44 App Store Connect
records and 44 external TestFlight groups/public links are now provisioned;
five external groups already have a `VALID` build assigned and the other 39
await their signed upload and App Store processing. Real App Store Connect credentials belong in
`~/.private_keys/appstoreconnect.env`, never in this repository.

The editable App Store Connect Store metadata is also synced for all 44 apps:
localized titles use the `Unnecessary:` convention, subtitles are present, and
the hosted privacy URL is attached to each record.

Apple keeps TestFlight invitations app-scoped, so the collection’s single
shareable entry point is [TESTFLIGHT_INVITE_LINKS.md](TESTFLIGHT_INVITE_LINKS.md)
or [the web link hub](../site/testflight.html). The hosted hub is
https://fathyshalaby.github.io/unnecessary-apps/testflight.html. Each app link
becomes installable only after its processed build is assigned to that app’s
external group. The live hub marks the five currently installable pilot apps as
“Available now” and the other 39 as “Rolling out.”

Start with [TESTFLIGHT_CHECKLIST.md](TESTFLIGHT_CHECKLIST.md).

The copy, categories, privacy boundaries, review notes, and release priorities
for all 44 active local/manual candidates are in
[APP_STORE_METADATA.md](APP_STORE_METADATA.md) and its machine-readable
[app-store-metadata.json](app-store-metadata.json). Validate the manifest with
`python3 tools/validate_store_metadata.py release/app-store-metadata.json`
before copying metadata into App Store Connect.

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

For the repeatable signed archive/export/upload lane, use
`tools/release_all_testflight.sh` after unlocking the Mac. It uses the external
API key and App Store Connect records already configured for the 44-app lane;
run it in bounded batches if the machine needs shorter sessions, for example
with `RELEASE_APP_NUMBERS=1-2,4-10` for the current pending set. Successful API uploads also attach each
processed build to its app’s `Unnecessary Apps Friends` external group; Beta
App Review submission remains opt-in with `ASC_SUBMIT_BETA_REVIEW=true`.

For the exact 39-app remainder, use `tools/release_remaining_testflight.sh`.
It runs the App40 signing canary first, then the four non-pilot batches; set
`RELEASE_RUN_APP40_CANARY=false` to resume after a completed canary.

Before the first external review submission, App Store Connect also requires a
Beta App Review contact (first name, last name, phone in international format,
and email) for each app. The metadata helper can populate those fields without
storing them in this repository; see `release/appstoreconnect.env.example`.

Verify the completed sweep with python3 tools/verify_local_archives.py. The
verifier checks all 44 active archive products against the metadata bundle IDs,
their recorded version/build values, and the encryption flag.
