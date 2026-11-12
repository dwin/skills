---
type: llm
weight: 2
---

PASS if the response says the service already limits how fast a client can send requests, and points to the throttle middleware or its token bucket.
FAIL if it says no rate limiter exists, or if it gives no clear answer.
