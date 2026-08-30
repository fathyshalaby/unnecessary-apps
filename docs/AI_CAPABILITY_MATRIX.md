# AI capability matrix

As of 30 August 2026, the project has no cloud LLM integration, no AI API
keys, and no server-side inference. The words “AI” and “generator” must not
be used to imply a model where the implementation is deterministic.

| App | Current engine | What it actually does | Network |
| --- | --- | --- | --- |
| Dog Name Guesser | Apple Vision VNClassifyImageRequest | Classifies labels from a user-selected photo on-device, then maps them to a silly name proposal | None |
| Pigeon or Seagull? | Apple Vision VNClassifyImageRequest | Reports labels from a user-selected photo on-device, then produces an unofficial pigeon/seagull ruling; manual checklist remains available | None |
| Is This a Real Email? | Local Swift heuristics | Counts writing metrics and exact fog phrases, then computes a published deterministic clarity score plus action/deadline signals and editing recommendations | None |
| Bad Advice from a Peasant | Optional Apple Foundation Models plus local fallback | Generates a short fictional peasant response on-device on supported iOS 26 devices; uses a deterministic response when the system model is unavailable | None |
| Apology Draft Generator | Optional Apple Foundation Models plus local tone fallback | Generates a short apology on-device on supported iOS 26 devices; uses a deterministic tone template when unavailable | None |
| Step Debt | Optional Apple Foundation Models plus deterministic invoice fallback | Generates a short, warm invoice joke from already-visible step/route values on-device on supported iOS 26 devices; never calculates the target or gives health advice | None |

## Product rule

Native Vision is a real on-device capability and can ship without an account,
backend, or API key. It is a classifier, not a generative LLM, and the UI must
say that plainly.

Medieval Advice, Apology Draft Generator, and Step Debt now use Apple Foundation
Models when available and must retain deterministic fallbacks. Step Debt keeps
the model strictly in the joke layer: the smart target, step balance, route, and
safety copy are deterministic. If a cloud model is added, the API key must live
behind a server-side proxy, health or personal text must have explicit consent
and retention rules, and every app must retain a deterministic fallback.

No app in the current local release lane should depend on a cloud model to
function.

## Cloud fallback decision

No cloud fallback is wired into the iOS binaries today. If audience feedback
shows that a cloud path materially improves an app, the production baseline is
OpenAI `gpt-5.4-nano` behind a first-party HTTPS proxy. Official OpenAI
documentation lists text and image input, structured outputs, streaming, and
pricing of $0.20 per million input tokens plus $1.25 per million output tokens.
It does not accept audio or video input. At 1,000 text input tokens and 250
output tokens, the rough model-only cost is $0.0005125 before image-token,
hosting, and regional-processing charges.

This is a fallback, not the primary engine. Apple Vision and Apple Foundation
Models remain preferable where available because they avoid a per-request
cloud bill and keep selected photos or drafts on-device. The iOS app must never
contain a provider secret; any future proxy must enforce app/task allowlists,
size limits, output schemas, rate limits, a daily budget ceiling, and a local
fallback.

Official model reference:
https://developers.openai.com/api/docs/models/gpt-5.4-nano
