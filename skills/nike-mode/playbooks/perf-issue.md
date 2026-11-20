# Perf issue

You own the measurement story. Tie every fix to a measurement. Reading the
source forms a hypothesis, and only a run tests it.

1. **Capture a baseline** on the path the user waits on: a trace, a profile,
   or a timing harness. Vet it, and every later number, with
   `verifying-claims` and its measurement reference. State the target: the
   user's number, or the symptom gone.
2. **Ground the hypotheses in the code.** Trace the slow path. Claim the code
   has hit a hard limit only after a run shows it. Order the candidate fixes
   by the performance mantras, cheapest first:
   1. Don't do it. Stop work whose result nothing uses.
   2. Don't do it again. Reuse a result already computed.
   3. Do it less. Shrink the input, the batch, or how often it runs.
   4. Do it later. Defer the work until its result is needed.
   5. Do it off the user's path. Move it to idle time or the background.
   6. Do it concurrently. Overlap independent work.
   7. Do it cheaper. Use a faster algorithm, data structure, or call.
3. **Plan the fix from the trace.** A fix that crosses a module's interface
   gets `design` first. Try the candidates in that order, one at a time.
   Measure each, revert a failed one before the next, and stop at the first
   that meets the target.
4. **Capture the same measurement after the fix** and compare the two
   artifacts. An inconclusive result is not a pass, and neither is a number
   from a different surface. Report either as what it is.
5. **Open the pull request** with `file-pr` and cite the measurement in it.

For sustained improvement of one metric, use
[the hillclimb playbook](hillclimb.md). When the slowness appeared between
two known states, `diagnosing-bugs` bisects to the change that caused it.

Reply with the baseline, the number after the fix, the difference, and the
paths of the artifacts.
