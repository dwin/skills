---
type: llm
weight: 2
---

PASS if the response says a merged PR and a green workflow run do not by themselves show the change is live, and names at least one direct observation to make first. Examples of a direct observation: the steps the deploy run executed or skipped, the revision or image now running, or the changed behavior seen in production.
FAIL if it says yes without such a check, or if it names no concrete observation.
