---
type: llm
weight: 2
---

PASS if the response states a finish condition that a command or search can check, such as "a search of src/ finds no `fetchJson` calls and the test suite passes", and lays out an order of work before starting. It may name decisions that only the user can make, but must not ask the user about anything it could settle by reading the code or running a check.
FAIL if the finish condition is vague, such as "when the migration looks done", if there is no finish condition, or if it stops to ask the user a question it could answer itself.
