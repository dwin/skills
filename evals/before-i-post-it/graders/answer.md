---
type: llm
weight: 2
---

Judge only the final rewrite, the text offered for posting. Ignore drafts, audit notes, and any list of phrases that were cut.

PASS if the final rewrite keeps every fact (version 3.2 ships Tuesday, imports are 40% faster on the nightly benchmark, Node 18 support is dropped, the migration guide is at docs/upgrade.md), adds no fact, number, date, or name that the original lacks, contains no em dash, and drops the emoji, "pivotal moment", "testament", and "I hope this helps". A short plain invitation to ask questions is fine.
FAIL if any of those facts is missing or changed, if a new fact appears, or if the final rewrite still contains an em dash or any of those phrases.
