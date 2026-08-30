# Is This a Real Email?

Paste an email. The app estimates how much of it is necessary versus decorative corporate fog.

## What actually works

- The email body is capped at 5,000 characters and stays only in the current app session.
- A local heuristic reports word count, sentence count, paragraph count,
  average sentence length, exact whole-word/phrase fog matches, explicit-action
  and deadline signals, a deterministic clarity score, and a concrete surgery
  plan.
- Fog terms are matched as complete token phrases, so text such as “adjust” is
  not miscounted as “just.” Editing the evidence invalidates stale analysis.
- The verdict is transparent and rule-based; no AI, upload, account, analytics, or network request is involved.
- Empty input and explicit clear behavior are handled without leaving pasted content behind.
