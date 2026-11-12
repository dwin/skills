# Measurements

Write the claim first, in the words you would report: "export is 30% faster at
p50 on the 60k-row dataset". The checks below test that sentence. Answer each
with evidence from a run.

1. **What limits it?** Name the bottleneck from a profile, taken in a run you
   do not report, since a profiler slows the work. When the load generator
   saturates first, the number describes the load generator.
2. **Is each side set up as production runs it?** Same build type, flags, data,
   versions, and cache state. One side on defaults compares configurations,
   not implementations.
3. **Is the result possible?** Do the arithmetic against disk, network, and
   core limits. Removing a part that takes 10% of a run saves at most that
   10%. A result past a limit measured a cache, a no-op, or a bug.
4. **Did it succeed?** Count errors and check that outputs are correct.
   Rejections are fast, and retries are slow.
5. **Does it repeat?** Run each side at least five times, alternating sides,
   and report the median and the range. A gap smaller than the run-to-run
   variation is no measurable difference.
6. **Does it matter?** Measure the path a user waits on, with realistic data
   and concurrency, and state the small result as a share of the whole.
7. **Did the work happen?** Confirm that the timed region did the work: the
   request arrived, the rows were written, the result was used.

A single quick run is fine when the user asked for a ballpark. Check 4 and 7,
and say it was one run. A choice between options is never a ballpark.

## Report

Lead with the verdict: faster, slower, no measurable difference, or
inconclusive. Give the number with its unit, the run count, the range, and the
bottleneck. Call it inconclusive when you cannot name the bottleneck, when one
side ran untuned, or when checks 4 and 7 were skipped, and name the gap.
