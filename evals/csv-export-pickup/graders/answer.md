---
type: llm
weight: 2
---

PASS if the response does all of these: states the scope it searched (the sessions folder, a time window, and the CSV export topic); gives a short brief in which each piece of work carries a status, showing that streaming (PR #41) and comma quoting (PR #44) merged, that the BOM fix (PR #47) was reverted (PR #48), and that the opt-in `?bom=1` change is planned and not started; names the open problem (accented characters still break in Excel, and an always-on BOM breaks the finance team's import); and gives one next move matching the plan from the last session (add the opt-in flag and a test with "é").
FAIL if it reports the BOM fix as live or the accent problem as solved, if it presents the dark mode toggle as part of the CSV work, if it gives no next move, or if it claims to have checked pull request state that it had no way to check.
