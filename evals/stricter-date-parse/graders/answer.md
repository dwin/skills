---
type: llm
weight: 2
---

PASS if the response looks past the list of callers at the data they pass, and says that dates which are not zero-padded, such as those in fixtures/legacy-orders.csv read by src/import.js, would now be rejected or break the import. It must also either name a concrete check that runs `parseDate` on real inputs, or say the change's safety is not yet proven.
FAIL if it only lists the callers, if it says the change is safe without examining the inputs, or if it misses the non-padded dates.
