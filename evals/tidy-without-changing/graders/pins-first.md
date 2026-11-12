---
type: llm
weight: 2
---

PASS if the plan captures the function's current behavior in something that can be rerun, such as tests or recorded outputs for fixed inputs, and does this before any restructuring step.
FAIL if the plan restructures first, if it relies only on reading the code, a type check, or a linter, or if it mentions tests only as a step after the changes.
