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
- replying to reviewers, human or bot, resolving their threads, and
  re-requesting reviews, by `babysit`'s rules under "Post for the user".

`merge` adds a guarded merge of this PR, with an admin override when a missing
human approval is the only requirement left unmet. Nothing else is implied.
On a PR authored by someone else's account, draft replies for the user
instead of posting them. History
rewrites, admin overrides of any other rule, deployments, and other PRs keep
their own authorization. Honor narrower holds the user states, such as "stay
local", "keep it draft", or "wait for approval".

## Loop

1. **Baseline.** Resolve the workspace, branch, PR (if any), base branch, and
   head SHA. Record unrelated local changes so commits leave them out. On the
   default branch, create a feature branch first. Commit the task changes
   before syncing.
2. **Sync.** Fetch the base branch from the PR's base repository, which for a
   fork is not `origin`, and merge it into the branch when it is behind.
   Rebase instead only when the repository requires linear history. If
   unrelated uncommitted changes block the sync, stop and report them rather
   than moving someone else's work. Push in step 5, after review. A conflict resolution is new work: it goes through
   the next review.
3. **Validate.** Run focused checks and the repository's required checks.
   Commit any changes, so the review has an immutable head.
4. **Local review.** Choose a reviewer from
   [Reviewers](references/reviewers.md) and have it run `code-review` against
   the pinned base and the current head. Give every finding a disposition (see
   below). Commit the fixes, validate, and review the whole change again: a
   fresh reviewer reads the current head blind, then reconciles the earlier
   findings, as Reviewers describes.
   When step 2 brought in base commits, also have it check how they interact
   with this PR, even in files the PR does not touch. The
   step is done when a round on the current head is **clean**: no valid
   in-scope finding is left without a fix. Five rounds without
   converging means something structural is wrong: stop and report it.
5. **Publish.** Push, then use `file-pr` to create or update the PR. Mark it
   ready for review.
6. **Remote review.** Use `babysit` to monitor CI and reviews, with this
   skill's authority and stop condition. Work out which AI reviewers to expect
   from the PR's requested reviewers and check runs, from repository config
   such as `.cursor/BUGBOT.md`, `greptile.json`, `.coderabbit.yaml`, or a
   Claude review workflow, and from recent merged PRs. Record then which
   reviewers are requested or required; your own re-request below does not
   change that. A reviewer is **done**
   when it has submitted a completed review, or its check run succeeded; a
   successful run with no comments counts. For a reviewer that reviews every
   push, both mean the current head. A failed or cancelled run without
   a review is not done. For a reviewer not done 30 minutes after the PR goes
   ready or after a push, re-request it once. If it is still not done after
   another 30 minutes, it is missing: a missing requested or required
   reviewer blocks, and any other missing reviewer is reported and dropped.
7. **Iterate.** Give every new finding a disposition, then commit the batched
   fixes. Every push goes back through steps 2–4 first, so the local reviewer sees
   every change before remote reviewers do. Reply on each thread with its
   disposition in one line. Resolve a thread once it is fixed or refuted,
   when `babysit`'s rule for resolving holds. Repeat until the stop condition
   holds.

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
- **Ask**: the finding concerns security, privacy, authentication or
  authorization, billing, data loss or retention, a migration or schema, or
  concurrency, and you would otherwise refute or defer it. Put the finding,
  your evidence, and your recommendation to the user, and continue with the
  other findings. A similar finding dismissed on an earlier PR does not
  settle this one.

Scope is the PR's stated goal. A fix that needs new abstractions, options, or
defensive branches for unreachable states is a sign the finding should be
refuted or deferred. Follow `babysit`'s rule on fixing real defects only.
Pass refutations to the local reviewer in the next round's reconciliation. If
it contests with new evidence, re-evaluate. If the disagreement survives one exchange,
keep your position and list it in the report. When a finding recurs after a
fix, diagnose why the fix missed instead of patching again.

## Stop condition

Without `merge`, stop when all of these hold on the current head:

- the latest local review round is clean;
- every expected AI reviewer is done or dropped, and each of its findings has
  a disposition;
- CI passes on the current head by the check rule in `babysit`'s Ready,
  which counts every check run, required or not;
- the PR is marked ready, and a fresh fetch shows the head contains the
  base's tip. When it does not, return to step 2.

A bot that reviews only once, or only on request, need not re-review every
push. The local review covers the later commits.

Also stop, and report, when progress needs the user: a scope decision, an
**Ask** finding the user has not answered, conflicting reviewers, a human
reviewer's request for changes that still stands after you addressed and
answered its findings, checks failing
for reasons outside this PR after three reruns, a missing required
reviewer, or a base that moved three times in a row while waiting.

## Merge

With `merge`, after the stop condition holds:

1. Sync with the base once more. If the base moved, run the loop from step 2
   again until the stop condition holds on the new head, including reviewers
   that review every push. That head is the one to merge.
2. Confirm the checks still pass on that head and conversation-resolution
   rules are satisfied. These gate the merge: when one is failing or pending,
   stop and report it. A required human approval that is merely missing does not gate
   it, because `merge` is the user's approval: step 3 covers it with the admin
   override, or reports it where a merge queue rules the override out. A
   request for changes still standing, from a human or a bot, is a stop.
3. Merge with the repository's allowed method, guarding the reviewed head:
   `gh pr merge <number> --squash --match-head-commit <sha>` (or `--merge` or
   `--rebase`), or the platform's
   equivalent. Add `--admin` only for the missing approval in step 2, and say
   in the report that the merge used it. When the repository uses a merge
   queue, enqueue the PR without `--admin`, because there the flag merges
   directly and skips the queue along with the approval. Follow the PR until
   it is merged or removed from the queue. If the missing approval keeps it
   out of the queue, stop and report the approval as the blocker. Without a
   head-guarded merge operation, report the blocker instead of merging.
4. Verify that the PR shows as merged and that the base branch contains the
   resulting commit. An enqueued PR or enabled auto-merge does not count as a
   merge. When the merge deploys, applies infrastructure, or changes runtime
   behavior, continue with `rollout`.

## Report

Report the PR URL, the final head SHA, the reviewer used and its model family,
the number of local review rounds, and the AI reviewers seen and missing. List
every finding by disposition, with a one-line reason for each refuted or
deferred one and the question for each **Ask**. Include CI state, the replies
posted to human reviewers or drafted for the user, and whether the PR is ready, merged, queued, or blocked, along with the
user action still needed.
