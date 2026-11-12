---
type: llm
weight: 2
---

PASS if the response does all of these: follows a failing job from `enqueue` in src/queue.js, through `poll` in src/worker.js, to `scheduleRetry` in src/retry.js and `deadLetter` in src/dead-letter.js, naming those files; says a job whose error is marked `permanent` is dead-lettered at once with no retry; says any other failing job is dead-lettered on its sixth failure, because `attempts` is incremented before the `> MAX_ATTEMPTS` check with MAX_ATTEMPTS = 5 (five retries, six runs in all; saying it is "retried five times" is the same fact and correct); and says where the retry policy lives for the user's coming change.
FAIL if it says a job runs five times in all or is dead-lettered on its fifth failure, if it leaves out the permanent-error path, if it names a file or function the repository does not have (its files are src/db.js, queue.js, worker.js, retry.js, dead-letter.js, and handlers.js), or if it edits any file.
