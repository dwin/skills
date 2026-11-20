# Hillclimb

You own the metric and the integrity of the experiment. This is the loop for
sustained improvement of one measurable thing against a target. A one-off fix
is `diagnosing-bugs` or [the perf issue playbook](perf-issue.md).

The discipline is one change, one measurement, keep or revert. Never stack
untested changes, and never claim a win from reading code.

1. **Ground the workload before choosing the metric.** Trace the target.
   Name the workload dimensions that can move the result: data size, history,
   state, concurrency. Select a case that reproduces the user's complaint.
   When no case reproduces it, fix the reproduction before you climb. Then
   fix one metric, the direction that counts as better, and a stop predicate
   a command can check. Pair the target with a floor on attempts, such as "at
   least 50% better than baseline and at least 10 iterations", so a lucky
   early win cannot end the run. Use the user's numbers when they gave them.
2. **Build the measurement harness, prove it is sensitive, then freeze it.**
   Run contrasting realistic workloads. The target case must reproduce the
   symptom, and easier cases must separate from it as expected. When the
   harness cannot tell them apart, revise the workload or the metric. Vet the
   harness with `verifying-claims` and its measurement reference, and make it
   print its error count and a count of the work done. Once frozen, one
   repeatable command emits the metric as a median of several runs. Record
   the baseline, and a passing run of the tests that must keep passing,
   before any change.
3. **Open a work log** in the format of
   [the work log reference](../../figure-it-out/references/work-log.md), one
   row per attempt: the hypothesis in `why`, the commit SHA or the path of a
   saved patch for a reverted attempt in `evidence`, and the metric before
   and after with kept or reverted in `result`. Read it before each attempt.
4. **Ground each hypothesis in the architecture** from step 1, so it names a
   mechanism: "defer X off the boot path because it blocks first paint", not
   "try memoizing something". For a performance metric, order the hypotheses
   by the mantras in the perf issue playbook. Borrow their order only, not
   that playbook's stop rule.
5. **Loop, one hypothesis per iteration.**
   - Make the change with a tight scope. When you delegate it, review the
     diff yourself. Several independent hypotheses can run in parallel, each
     in its own checkout, through `swarm`. When more than one wins, commit one
     and measure the next again on top of it.
   - Measure before and after with the frozen harness, and run the tests.
   - Keep the change only when the metric moves past the noise and the tests
     pass. Otherwise revert all of it. A change that "might help" is not
     kept.
   - Make one commit per kept change, staging only the files you changed.
     Log the row either way.
6. **Push past the first plateau.** After several rejections in a row, change
   category, combine near-misses, re-read the source, or try something more
   radical before concluding the hill is climbed. Correctness and simplicity
   outrank the number: revert a win that breaks behavior, and keep a
   simplification that holds the number.
7. **Stop when the predicate is met,** or when the ideas left are marginal
   and not worth their cost. Hold the predicate fixed. Until it is met, keep
   going while cheap untried hypotheses remain, and report a real dead end
   with what you tried.
8. **Open the pull request** with `file-pr`, with the kept commits in the
   order they landed.

When the run is unattended, `figure-it-out` says how to stay reachable.
Borrow that only, not its exit condition.

Reply with the metric and the target, the baseline and the final number with
the percent difference, the iterations run and how many were kept, each kept
change on one line, the path of the work log, and the best idea you would try
next.
