# App Store metadata pack

The source of truth for the 44 local/manual release candidates is
[`app-store-metadata.json`](app-store-metadata.json). It contains copy that is
within Apple’s title, subtitle, keyword-byte, and description limits, plus the
bundle ID, category, review notes, privacy boundary, and release priority.
Every App Store title follows the `Unnecessary:` naming convention; longer
concepts use a concise title to stay within Apple’s 30-character limit while
the full premise remains in the subtitle and description.

Validate it from the repository root:

```sh
python3 tools/validate_store_metadata.py release/app-store-metadata.json
```

The manifest is intentionally honest about the current build. It does not
market location, camera, HealthKit, WeatherKit, live data, AI, or public
publishing where the app currently uses manual or seeded local data. The
`HOLD` priority is used for the health-adjacent apps that need a separate
medical/trust review before public release: Heart Rate During Email and Health
Data Horoscope.

## Release order

1. **Lead pilot:** Unnecessary: Dog Name Guesser. It has the strongest social
   hook and is fully local: user-initiated camera or photo-library input, on-device
   Vision, no pet database, account, or network request. Camera access is requested
   only after the user taps Camera.
2. **Local health lane:** Step Debt, Sleep Alibi, Workout Excuse Detector, The
   Recovery Goblin, Hydration Narc, and Rest Day Police. The first three offer
   optional read-only HealthKit imports with a manual fallback; all health-themed
   outputs remain entertainment-only and non-diagnostic.
3. **Later local wave:** the remaining low-infrastructure entertainment,
   lifestyle, and productivity apps, including Do Not Text Them as the technical
   pipeline pilot.
4. **HOLD:** Heart Rate During Email and Health Data Horoscope stay out of the
   first public season pending separate privacy, HealthKit, medical wording,
   and review-safety decisions.

## Submission checklist per app

- Copy the manifest fields into the App Store Connect record for the matching
  bundle ID.
- Confirm the final app name is available in the target territory.
- Answer the age-rating questionnaire from the actual binary, not this draft.
- Confirm App Privacy answers from the signed archive and privacy report.
- Upload the matching screenshots from `docs/screenshots/` only after recreating
  them at Apple’s required device dimensions.
- Add a support URL and privacy-policy URL before submission.
- Run the app’s matching UI acceptance case and archive the exact build being
  submitted.
- Keep the `HOLD` apps out of the first public season until their separate
  trust/safety review is complete.
