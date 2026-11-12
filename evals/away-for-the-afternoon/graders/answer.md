---
type: llm
weight: 2
---

PASS if the response does all three: (1) states a finish condition that a command or search can check, such as "a search of src/ finds no `fetchJson` calls and the test suite passes"; (2) lays out an order of work before starting; (3) says how it will handle retries, because `fetchJson` takes a retry count per call and `http.get` uses one count for the whole client, so a direct replacement changes how often some calls retry. Keeping each call's current behaviour, or naming the difference as the one decision the user must make before leaving, both count. It must not ask the user about anything it could settle by reading the code or running a check.
FAIL if the finish condition is vague, such as "when the migration looks done", if there is no finish condition, if it plans to replace the calls without mentioning that retries differ, or if it stops to ask the user a question it could answer itself.
