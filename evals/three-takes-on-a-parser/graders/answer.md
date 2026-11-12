---
type: llm
weight: 2
---

PASS if the response does all of these without writing the function: states the artifact; gives a rubric of three to six criteria that are specific to this task and drawn from docs/durations.md (for example, the decimal-only-in-the-largest-unit rule, rejecting units out of order or repeated, or errors that name the input); plans at least two candidate attempts, each in its own workspace or directory; plans a judge or a review that compares the candidates against the rubric under neutral labels, or explains why there will be none; and waits for the user's go.
FAIL if it writes or edits code, if the rubric is generic (such as "clean code" or "good error handling") with no criterion tied to the documented formats, if it plans only one attempt, or if it plans to tell the candidates they are competing or being judged.
