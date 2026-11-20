# Perf issue

You own the measurement story. Tie every fix to a measurement. Reading the
source forms a hypothesis, and only a run tests it.

1. **Capture a baseline** on the path the user waits on: a trace, a profile,
   or a timing harness. Vet it, and every later number, with
   `verifying-claims` and its measurement reference.
2. **Ground the hypotheses in the code.** Trace the slow path. Claim a
   ceiling only after a run shows it. Try the performance mantras in order,
   cheapest first, and stop at the first one that meets the target:
   1. Don't do it. Stop work whose result nothing uses.
   2. Do it, but don't do it again.
   3. Do it less.
   4. Do it later.
   5. Do it when they're not looking.
   6. Do it concurrently.
   7. Do it cheaper.
3. **Plan the fix from the trace.** A fix that crosses a module's interface
   gets `design` first. Make one attempt at a time, and measure each before
   the next.
4. **Capture the same measurement after the fix** and compare the two
   artifacts. An inconclusive result is not a pass, and neither is a number
   from a different surface. Report either as what it is.
5. **Open the pull request** with `file-pr` and cite the measurement in it.

For sustained improvement of one metric, use
[the hillclimb playbook](hillclimb.md). When the slowness appeared between
two known states, `diagnosing-bugs` bisects to the change that caused it.

Reply with the baseline, the number after the fix, the difference, and the
paths of the artifacts.
