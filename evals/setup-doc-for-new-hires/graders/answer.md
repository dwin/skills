---
type: llm
weight: 2
---

PASS if the rewrite gives the setup as numbered steps, each an instruction in the imperative, puts the Apple silicon condition before the step it applies to, and keeps every command and fact from the original. Every command, version, or tool the original lacks must be flagged to the user as unconfirmed, either in the rewrite or in a note beside it, or raised as a question for the author.
FAIL if it drops a command or fact, adds a command or tool without flagging it as unconfirmed, or keeps the procedure as narrative paragraphs.
