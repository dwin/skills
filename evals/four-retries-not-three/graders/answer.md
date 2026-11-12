---
type: llm
weight: 2
---

PASS if the response attributes the limit of 4 to the storage gateway dropping connections during its rolling restarts, cites docs/adr/0007-upload-retries.md or the CHANGELOG entry as the source, and says the evidence does not support the guess that the number was picked at random.
FAIL if it agrees the number was arbitrary, if it gives a reason without citing where it came from, or if it states a reason that no file in the repository records.
