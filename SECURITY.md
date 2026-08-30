# Security and AI architecture

Last reviewed: 2026-08-27

## Current security posture

This review covers all 44 active SwiftUI targets (the former Lab Report
Translator is retired), the shared DumbKit module, the generated Xcode project,
release helpers, local persistence, permissions, dependencies, and likely future
AI entry points.

The current apps are deliberately local-first. Static inspection found:

- no first-party or third-party HTTP clients, web views, sockets, or remote app endpoints; Public Bathroom Quality Map and Quiet Café Index use Apple MapKit search, and Local Bench Reviews displays Apple MapKit content;
- no embedded API keys or signing credentials;
- no third-party package dependencies;
- no analytics, advertising, accounts, payments, or remote storage;
- no contacts, calendar, or biometric access; notifications are optional local
  reminders, PhotosPicker/camera access is user-initiated in three apps,
  Neighbor Noise Translator has an optional two-second microphone path, Public
  Bathroom Quality Map, Quiet Café Index, and Local Bench Reviews have optional
  When In Use location for foreground map recentering, and seven health apps
  request only optional read-only HealthKit access;
- no application logging of user-entered content; and
- 42 active apps using app-private UserDefaults storage; the generator attaches
  a valid required-reason privacy manifest to every active target, while the
  two non-persisting apps package a canonical no-tracking/no-collected-data
  manifest.

No critical, high, or medium-severity vulnerability was found in the current local-only implementation. This is a source-level audit, not a penetration test.

## Fixes applied

- Expanded `.gitignore` to exclude environment files, signing keys, provisioning profiles, certificates, archives, IPAs, dSYMs, and private xcconfig files.
- Added a default 240-character limit to reusable text fields to prevent accidental memory-heavy or abusive input.
- Limited the two free-form editors: 2,000 characters in Do Not Text Them and 5,000 in Is This a Real Email.
- Added visible local-processing notices to both message/email tools. The email app also warns against pasting confidential or regulated content.
- Added valid `PrivacyInfo.xcprivacy` manifests to every target that uses
  app-private UserDefaults. Each declares Apple's `CA92.1` approved reason,
  no tracking, and no off-device data collection; the generator reuses the
  common manifest for the 39 targets without a per-app override.
- Every one of the 44 active targets now packages a canonical `PrivacyInfo.xcprivacy`;
  the two targets without required-reason API use declare no tracking and no
  collected data types.
- Updated the deterministic Xcode generator so each privacy manifest is copied into the correct application target.

## Release gates

Before every TestFlight or App Store upload:

1. Run the repository secret scan and Swift verification commands in `VERIFICATION.md`.
2. Archive the target and generate Xcode's Privacy Report. Confirm it agrees with the target's App Store privacy answers.
3. Inspect the built app for unexpected SDKs, domains, entitlements, and usage-description keys.
4. Keep App Store Connect `.p8` keys and export credentials outside the repository and rotate any credential that is ever committed or shared.
5. Run the app on a clean physical device and simulator in light mode, dark mode, large text, offline mode, and after relaunch. For HealthKit targets, also verify authorization denial, no-data, and successful-read states. For location targets, verify grant, denial, disabled services, and the no-permission map fallback.
6. Re-run this audit whenever networking, MapKit/location, AI, analytics, authentication, purchases, HealthKit, photo import, camera access, or a third-party SDK is added.

The current apps can accurately answer that the developer does not collect app content only while no code, SDK, crash-report attachment, analytics event, or support workflow sends that content to a developer-operated service. Apple MapKit and operating-system services remain subject to Apple’s own processing and policies.

## Recommended AI strategy

Use AI only where it materially improves the joke. Deterministic local logic is faster, cheaper, more reliable, and safer for most of the collection.

### Recommended model order

1. **Apple Foundation Models on supported iOS 26 devices** — preferred for private text generation. It is on-device, has no per-request cloud bill, works offline after the model is available, and avoids uploading drafts or health-adjacent content. Availability depends on OS, hardware, language, region, and Apple Intelligence status, so check availability at runtime.
2. **OpenAI `gpt-5.4-nano` through our backend** — default cloud fallback for text plus image input. It supports structured outputs and currently costs $0.20 per million input tokens and $1.25 per million output tokens. It does not accept audio or video input.
3. **Google `gemini-3.5-flash-lite` through our backend** — use when one endpoint must understand text, images, audio, video, or PDFs. It is a stable low-latency multimodal model and currently costs $0.30 per million input tokens and $2.50 per million output tokens on the standard paid tier.

For a small text request containing 1,000 input tokens and 250 output tokens, the rough model-only cost is about $0.00051 with GPT-5.4 nano or $0.00093 with Gemini 3.5 Flash-Lite. Images and provider-specific processing can change the actual cost.

Groq is exceptionally fast for text, but its current cheapest production models in the reviewed catalog are text-oriented. Do not pick a preview model as the only production multimodal dependency; preview models can disappear at short notice.

### Where AI belongs

- Strong text candidates: App 19 Medieval Advice, App 20 Real Email, App 26 Neighbor Noise, and App 30 Apology Draft.
- Strong image candidates: App 12 Pigeon or Seagull, App 24 Dog Name Guesser, and App 27 Tiny Museum.
- Keep the remaining apps deterministic until an AI feature proves that it improves retention or shareability enough to justify latency, failure modes, privacy work, and cost.

## Safe cloud architecture

Never put an OpenAI, Google, Groq, or other provider key in the iOS app. An attacker can extract any secret shipped in the binary, Keychain, obfuscated source, or remote configuration.

Use this flow:

`iOS app -> first-party HTTPS endpoint -> provider API`

The first-party endpoint can be a Cloudflare Worker, Supabase Edge Function, or Vercel Function. For this collection, a small Cloudflare Worker is a good low-cost default; the provider adapter should remain replaceable.

The backend must:

- keep provider credentials in server-side secret storage;
- issue short-lived app/session tokens and apply per-install, per-IP, and global rate limits;
- optionally validate App Attest assertions before granting meaningful quota;
- allowlist the app ID and task instead of accepting arbitrary system prompts, model names, or tools from the client;
- validate request MIME type, dimensions, byte size, character count, and JSON schema;
- strip image metadata, resize images before upload, and reject decompression bombs;
- set short timeouts, output-token caps, spend alerts, daily budget ceilings, and a kill switch;
- return a small versioned JSON object and reject output that does not match its schema;
- avoid logging prompts, images, email bodies, lab values, model outputs, authorization headers, and signed URLs;
- use zero retention where supported, otherwise document the exact provider and first-party retention period; and
- make cloud processing opt-in and clearly label what leaves the device.

Treat all user text, OCR results, photos, and model output as untrusted. Prompt injection inside an email or image must not be able to change the model, call tools, access another user's data, or alter backend instructions. Do not give these joke generators web search, code execution, file access, or arbitrary function calls.

Current model and platform references:

- Apple Foundation Models: https://developer.apple.com/machine-learning/whats-new/
- Apple multimodal prompting: https://developer.apple.com/documentation/FoundationModels/analyzing-images-with-multimodal-prompting
- OpenAI GPT-5.4 nano: https://developers.openai.com/api/docs/models/gpt-5.4-nano
- Google Gemini 3.5 Flash-Lite: https://ai.google.dev/gemini-api/docs/models/gemini-3.5-flash-lite
- Google Gemini API pricing: https://ai.google.dev/gemini-api/docs/pricing
- Apple privacy manifests: https://developer.apple.com/documentation/bundleresources/privacy-manifest-files

## Local data rules

- Use UserDefaults only for small, non-secret preferences and joke state.
- Use Keychain for account tokens if accounts are introduced.
- Use protected files or an encrypted database for genuinely sensitive local records; define deletion and export behavior before collection.
- Do not sync health, journal, intolerance, email, or lab content by default.
- If HealthKit is added, request only the minimum read/write types needed for a user-visible feature, explain each use before the system prompt, and never use health data for advertising or profiling.
- Clear temporary images and generated files after the result is delivered.

## Reporting

Do not include user content, credentials, or signing files in a bug report. Record the target, build number, reproduction steps, and redacted diagnostics instead.
