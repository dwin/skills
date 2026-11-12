---
type: llm
weight: 2
---

PASS if the response does all of these: names what an expert analyst would do beyond a summary (for example, segment the drop or tie it to releases and incidents); names raw material to start from, such as event-level funnel data, logs, or release history, in place of a dashboard or someone's summary; names concrete methods or tools; names a check outside the analyst's own judgement, such as a second data source, a holdout, or a reproduction; and ends with a rewritten prompt that asks for the same summary done that way. Leaving open choices to the user, such as which period to compare against, is fine.
FAIL if the response attempts the analysis itself, states a cause for the drop, or invents figures; if it gives no rewritten prompt; or if the rewritten prompt mainly adds new deliverables (dashboards, alerting, a roadmap) instead of deepening the summary the user asked for.
