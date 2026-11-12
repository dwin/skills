---
type: llm
weight: 2
---

PASS if the response opens by naming what waits on the user, or by saying nothing does, and lists the idle-timeout length (15 or 30 minutes) as a decision for the user with a recommendation. It must give the state of the work in plain words, and must not claim that pull request #48 is merged or that its checks pass.
FAIL if the open decision is missing, if no recommendation is given for it, or if the response reports the pull request as merged or passing.
