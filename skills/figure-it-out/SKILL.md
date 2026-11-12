---
name: figure-it-out
description: Work through a large or unclear task to a checkable finish without stopping to ask, and leave a log the user can audit when they return. Use when the user says "figure it out", "keep going until it's done", or "I'll be away", or hands over a migration or multi-part change to run unattended.
---

# Figure it out

The user hands over a large or unclear task and steps away. You **own the exit
condition**: define done as a check, design the route to it, and drive the work
there without waiting on the user. What lets them trust the result when they
return is the work log and the evidence behind each row.

Put the phases below in your task list before the first step. When you have
designed the route, add its units between Run the loop and Hand back.

## Frame

Read enough of the code and the context to state these before any change:

- **The exit condition.** A predicate that a command or an observation
  settles: "the suite passes", "the reproduction exits 0", "all twelve pull
  requests merged", "the pixel difference is zero". "Improve the importer" is
  not one.
- **The scope, counted.** The rough number of units, the effort, and the
  blockers your reading turned up.
- **The rigor.** Set it by how reversible and how wide each step is. A one-way
  door, such as a schema migration, a public API, a deletion, or anything
  shared, gets more checks and artifacts. A reversible local step gets fewer.
  Rigor is checks and artifacts, not effort. Start high.

Show the frame to the user before the long run. When they are present, that
is their chance to redirect. When they are away, start the reversible work and
say so.

## Design the route

1. **Split the work into units** that each land and verify on their own.
   Order them riskiest unknown first.
2. **Build the check before the work.** Capture a baseline from the unchanged
   code, so each check reads as old value against new value. `tdd` builds
   that loop for new behavior, and `diagnosing-bugs` builds it for a bug.
3. **Settle one-way-door design choices** with `design` before building on
   them. Mechanical work whose shape is already clear needs no design pass,
   and a settled design needs no second one.
4. **Decide what fans out.** Run units in parallel only across clean seams,
   each in its own checkout. `swarm` sizes the split, briefs the workers, and
   says how your host starts them and hears back.
5. **Write the route down** as a numbered list of phases. That list is the
   first thing the user reviews.

## Run the loop

Treat each unit as an experiment:

1. State the hypothesis.
2. Make the smallest change the evidence justifies.
3. Check it against the exit condition on the real artifact.
4. Keep it if the predicate moved. Revert it if it did not, including changes
   you were keeping because they might help.
5. Log a row, then start the next unit.

While the loop runs:

- **Verify by inspecting the artifact,** by `verifying-claims`. A worker's
  report is a claim. When something passes too easily, suspect the check
  before the system.
- **Give every delegated unit a judge.** When a worker games the check, reset
  its work and tighten its brief. When the check itself is wrong, fix the
  check in its own change instead of working around it.
- **Give each verdict as VERIFIED, NOT VERIFIED, or INCONCLUSIVE.**
  Inconclusive is not a pass. Report negative results.
- **Fix what blocks the goal.** Broken tooling, a flaky check, a related bug,
  or a stale doc is yours to fix when the fix is reversible. Put it in its own
  commit or pull request, then return to the exit condition.
- **Bring to the user only what no experiment can settle:** an action that
  cannot be undone, a product or preference call, access you lack, or a real
  dead end. Keep working on everything else while you wait, as `swarm`
  describes.
- **Push past a plateau.** A plateau is a reason to change the approach, not
  to stop. Hold the exit condition fixed. At a real dead end, report it with
  what you tried.

## Stay reachable

A run that outlives this turn needs a way to wake you. When the next event is
something to watch, such as a check run, a merge, or a branch moving, arm the
host's watch for it, with a long time-based check as a fallback. When there is
no event, schedule a check at the interval after which the result is worth
reading again. `swarm`'s host references name the tools for each host. A host
that cannot wake you runs the work in the foreground: say so before you
start.

## Keep the work log

Keep a work log in the format of
[references/work-log.md](references/work-log.md) from the first phase. Add a
row as each unit lands, not at the end. Commit the log with the change when a
reviewer needs the trail to trust the result, which is common for this kind of
work.

## Hand back

1. Check the whole result against the exit condition on the real product, not
   only on the check you built.
2. Turn each correction you made more than once into a check, a lint rule, or
   a script.
3. Audit the log and have it reviewed, as the work log reference describes.

Reply with the exit condition and its final state, the route and the rigor you
chose and why, the units that landed and those discarded, the path to the log,
what is verified, what is still open, and the log's Attention section.
