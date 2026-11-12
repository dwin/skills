---
name: arena
description: 'Have several agents attempt the same task, pick the strongest attempt as the base, and graft the best parts of the others into it. Use for "arena this" or when one attempt at an artifact would lock in the wrong shape.'
disable-model-invocation: true
---

# Arena

Several **candidates** attempt one task in parallel. You read them all, pick
one as the **base**, and **graft** into it the few parts of the others that
beat it. The output is one artifact.

`eval` is the neighbor: it measures arms and reports scores. An arena produces
the artifact.

Put the phases below in your task list before you start any candidate: Frame,
Fan out, Judge, Pick, Graft, Verify.

## Frame

Every candidate gets the same prompt, so the prompt is the contract.

1. **State the artifact** each candidate produces: a module, a design note, a
   migration plan, a prompt.
2. **Write the rubric**: three to six criteria specific to this task, each one
   a reader can grade on its own. "Handles a missing config file without a
   stack trace" is a criterion; "good error handling" is not. The rubric is
   yours and the judge's. Candidates see only the task.
3. **Choose the runners.** Run at least two. When your host reaches more than
   one model family, use more than one: different families fail differently.
   Run more when the task has more than one plausible design direction. Use
   one model several times when the work is mostly generation and the shape
   is not in question. `swarm` says how your host starts agents and which
   model fits each role.
4. **Give each candidate its own workspace**: a worktree through
   `managing-workspaces`, or a temporary directory for an artifact that is not
   code.
5. **Blind the run** by `eval`'s rules: an ordinary request, a workspace name a
   user would pick, and no word that the candidate is one of several or is
   being judged.

Show the frame to the user before the fan-out when they are present.

## Fan out

Start every candidate at once. Each gets the task, the shared material it
needs, its own workspace path, and one more request: a short note naming the
alternatives it considered and why it rejected them.

A candidate that produces nothing drops out. Continue with the rest and note
the dropout.

## Judge

After every candidate has finished, start one read-only judge on a model from
a family other than yours. It sees the rubric and the candidates under neutral
labels (A, B, C) and in shuffled order, scores each criterion for each
candidate, and recommends a base with its reasons. When no other family is
reachable, skip the judge and say so in the result.

## Pick

Read every candidate end to end while the judge works. Score each against the
rubric one criterion at a time. Then compare with the judge. When you agree on
the base, the pick is confirmed. When you disagree, the rubric was ambiguous or
one of you is biased: read both sets of reasons before deciding.

Pick the base a future maintainer can extend most easily without breaking its
invariants. Between two that feel tied, take the one with the smaller
interface or the cleaner boundary.

## Graft

Go through each other candidate once more for what beats the base, usually one
or two things each. Fold each one in by hand, so the result reads as one
design. Pasting blocks across leaves two mental models in one artifact.

When the candidates converge on one shape, that is strong agreement: ship
that shape, with no graft needed. When they diverge widely, the frame was
under-specified. Fix the frame and run again; averaging the divergence gives
an artifact none of them would have made.

## Verify

Check the result the way the task is normally checked: its tests, its build,
a run of the real thing, by `verifying-claims`. When the check finds a problem,
decide where it came from. The frame missed it: fix the frame and run again.
A candidate had it right and you missed the graft: go back to Graft.

Remove the candidate workspaces when the result is verified, through
`managing-workspaces`.

## Result

Deliver the artifact with a short note: the base and why, the judge's verdict
or why there was none, each graft and the candidate it came from, what you
rejected and why, any convergence or dropout, and the verification result.
