---
name: autopilot
description: Drive a branch to a ready pull request. Keeps it current with its base, gets local review from a different model family, marks it ready, and handles CI and AI-reviewer feedback. With `merge`, also merges it. Use when the user invokes autopilot.
disable-model-invocation: true
---

# Autopilot

Own the branch from local review until the pull request is **ready**:
up to date with its base, reviewed on the current head, green, and with every
review finding given a disposition. With the `merge` argument, or an explicit
instruction to merge, finish by merging it.

The agent running autopilot is the **implementer** and owns every edit. A
**reviewer** is a read-only agent, or a remote review bot, whose findings the
implementer validates.

## Authority

Invoking autopilot authorizes, for this branch and its PR only:

- in-scope fixes, validation, commits, and pushes to the feature branch;
- merging the base branch into the feature branch, or rebasing onto it and
  pushing with `--force-with-lease` when the repository requires linear
  history;
- creating or updating the PR, and marking it ready for review;
- replying to and resolving threads opened by review bots, and re-requesting
  their reviews.

`merge` adds a guarded merge of this PR. Nothing else is implied. Draft replies
to human reviewers for the user instead of posting them. History rewrites,
admin overrides, deployments, and other PRs keep their own authorization.
Honor narrower holds the user states, such as "stay local" or "keep it draft".

## Loop

1. **Baseline.** Resolve the workspace, branch, PR (if any), base branch, and
   head SHA. Record unrelated local changes so commits leave them out. On the
   default branch, create a feature branch first.
2. **Sync.** Fetch and merge `origin/<base>` into the branch when it is behind.
   Rebase instead only when the repository requires linear history. Push in
   step 5, after review. A conflict resolution is new work: it goes through
   the next review.
3. **Validate.** Run focused checks and the repository's required checks.
   Commit the task changes, so the review has an immutable head.
4. **Local review.** Choose a reviewer from
   [Reviewers](references/reviewers.md) and have it run `code-review` against
   the pinned base and the current head. Give every finding a disposition (see
   below). Commit the fixes, validate, and review the whole change again,
   pointing the reviewer at the new commits and the earlier dispositions.
   When step 2 brought in base commits, also have it check how they interact
   with this PR, even in files the PR does not touch. The
   step is done when a round on the current head is **clean**: no valid
   in-scope finding is left without a fix. Five rounds without
   converging means something structural is wrong: stop and report it.
5. **Publish.** Push, then use `file-pr` to create or update the PR. Mark it
   ready for review.
6. **Remote review.** Use `babysit-pr` to monitor CI and reviews, with this
   skill's authority and stop condition. Work out which AI reviewers to expect
   from the PR's requested reviewers and check runs, from repository config
   such as `.cursor/BUGBOT.md`, `greptile.json`, `.coderabbit.yaml`, or a
   Claude review workflow, and from recent merged PRs. A reviewer is **done**
   when it has submitted a completed review, or its check run succeeded; a
   successful run with no comments counts. A failed or cancelled run without
   a review is not done. For a reviewer not done 30 minutes after the PR goes
   ready or after a push, re-request it once. If it is still not done after
   another 30 minutes, it is missing: a missing requested or required
   reviewer blocks, and any other missing reviewer is reported and dropped.
7. **Iterate.** Give every new finding a disposition and batch the fixes.
   Every push goes back through steps 2–4 first, so the local reviewer sees
   every change before remote reviewers do. Reply on each bot thread with its
   disposition in one line, and resolve the thread once it is fixed or
   refuted. Repeat until the stop condition holds.

## Dispositions

Local and remote findings get the same treatment. Check each one against the
current head's source, deduplicate across reviewers, then give it exactly one
**disposition**:

- **Fix**: you can state the failure it causes, as concrete input or state
  that leads to a wrong result. Make the smallest change that removes that
  failure, and add a test when the repository tests that behavior.
- **Refute**: the failure cannot happen, or the claim is wrong. Cite the code
  path, test, or documentation that shows it.
- **Defer**: the problem is real but outside this PR's goal. Report it to the
  user, without changing code.

Scope is the PR's stated goal. A fix that needs new abstractions, options, or
defensive branches for unreachable states is a sign the finding should be
refuted or deferred. Follow `babysit-pr`'s rule on fixing real defects only.
Pass refutations back to the local reviewer in the next round. If it contests
with new evidence, re-evaluate. If the disagreement survives one exchange,
keep your position and list it in the report. When a finding recurs after a
fix, diagnose why the fix missed instead of patching again.

## Stop condition

Without `merge`, stop when all of these hold on the current head:

- the latest local review round is clean;
- every expected AI reviewer is done or dropped, and each of its findings has
  a disposition;
- required CI checks pass;
- the PR is marked ready and has no merge conflicts with its base.

A bot that reviews only once, or only on request, need not re-review every
push. The local review covers the later commits.

Also stop, and report, when progress needs the user: a scope decision,
conflicting reviewers, a human reviewer requesting changes, required checks
failing for reasons outside this PR after three reruns, or a missing required
reviewer.

## Merge

With `merge`, after the stop condition holds:

1. Sync with the base once more. If the base moved, run steps 2–4 on the new
   head before pushing it, then wait for CI on it. The head that passes is
   the one to merge. If the base moves again three times in a row, stop and
   report the moving base.
2. Confirm required approvals, required checks, and conversation-resolution
   rules are satisfied. When a required human approval is missing, stop:
   report the PR as ready and waiting for approval.
3. Merge with the repository's allowed method, guarding the reviewed head:
   `gh pr merge <number> --squash --match-head-commit <sha>` (or `--merge` or
   `--rebase`), or the platform's
   equivalent. When the repository uses a merge queue, enqueue the PR and
   follow it until the PR is merged or removed from the queue. Without a
   head-guarded merge operation, report the blocker instead of merging.
4. Verify that the PR shows as merged and that the base branch contains the
   resulting commit. An enqueued PR or enabled auto-merge does not count as a
   merge.

## Report

Report the PR URL, the final head SHA, the reviewer used and its model family,
the number of local review rounds, and the AI reviewers seen and missing. List
every finding by disposition, with a one-line reason for each refuted or
deferred one. Include CI state, any human-reviewer replies drafted for the
user, and whether the PR is ready, merged, queued, or blocked, along with the
user action still needed.
