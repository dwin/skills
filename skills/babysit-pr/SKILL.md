---
name: babysit-pr
description: Monitor or babysit an open pull request through CI, mergeability changes, and review feedback. Use when the user asks to watch a PR, keep checking it, diagnose checks, address in-scope findings, or stay with it until it is merged, closed, or genuinely needs user input.
---

# Babysit PR

Keep ownership of the pull request until a stop condition is reached. Treat a
green, mergeable, review-clean PR as a milestone rather than completion while
the PR remains open.

## Respect authority

- Treat a request to watch or babysit as permission for read-only monitoring.
- Make and push fixes only when the user also asked to address feedback, fix
  failures, keep the PR green, or otherwise modify the branch.
- Treat permission to change code separately from permission to speak for the
  user. Do not post replies, submit reviews, or resolve threads unless the user
  authorized PR communication.
- Do not merge, close, reopen, force-push, rebase, mark ready, or enable
  auto-merge without explicit authorization for that action.
- Follow repository instructions and work only on the PR branch. Preserve
  unrelated local changes.
- Keep review-driven work within the PR's stated goal. Report scope-expanding
  requests instead of silently broadening the change.
- Never weaken tests, linting, security controls, or intended behavior merely
  to obtain a green check.

## Fix real defects only

A finding earns a code change only when you can state the failure it causes.
Never add a construct whose only effect is to satisfy a reviewer: no hardcoded
"unchanged" summary jobs, no grep guards, no defensive branches for conditions
the code cannot reach. When a finding has no reachable failure case, refute it
with evidence instead of implementing it.

When three or more actionable findings arrive together, post the classification
from step 3 of Monitor and respond before writing code, and let the user
correct the split first. A wrong split wastes every fix built on it.

Use `verifying-claims` whenever a finding's validity depends on state you have
not observed on the current head.

## Establish the baseline

1. Resolve the PR and record its URL, base branch, head branch and SHA, draft
   state, mergeability, review decision, unresolved actionable threads, checks,
   and workflow runs.
2. Read the PR description, repository instructions, changed files, and the
   source behind each actionable finding.
3. Record the latest push time. Verify comments made against older commits
   against the current head before treating them as active.
4. Check whether the base branch advanced or overlapping work made the PR
   stale or obsolete. Report this evidence; do not rewrite history or close the
   PR without authorization.

## Monitor and respond

Repeat at a practical cadence while the PR remains open:

1. Refresh the PR before acting. Review feedback takes priority over retrying a
   check on a SHA that may soon change.
2. Inspect new comments, reviews, unresolved threads, checks, workflow runs,
   mergeability, and head SHA.
3. Classify each new signal as:
   - a real issue introduced or exposed by this PR;
   - stale or already addressed on the current head;
   - an infrastructure, runner, dependency, or unrelated failure;
   - ambiguous or outside the PR scope.
4. When authorized to modify the branch, collect and deduplicate current
   findings across reviewers before editing. Fix real in-scope issues as a
   coherent batch and record each disposition with code or test evidence.
   Complete any requested local review before the next push, address its valid
   findings, and explicitly report an unavailable reviewer. Run focused
   validation plus repository-required checks, commit and push, then immediately
   restart monitoring on the new SHA. Leave changes local only when requested.
5. Retry a likely transient failure only when the platform permits a safe rerun
   and the evidence supports one. Stop retrying the same failure after three
   unsuccessful attempts and request user help.
6. Keep a concise evidence-based rationale for stale or false-positive
   findings. Reply or resolve only when communication was authorized and the
   repository permits it.
7. Present unclear, conflicting, scope-expanding, or permission-dependent
   feedback to the user with the relevant evidence and a proposed next action.

Use the environment's recurring-monitor or wait facility. Keep the watcher
observable; do not leave an unowned detached process. Report meaningful state
changes instead of narrating unchanged polls.

## Stop only when

- the PR is merged or closed;
- the user interrupts or changes the request; or
- progress requires user action, such as missing permission, sustained
  infrastructure failure, exhausted retries, unsafe conflict resolution, or
  ambiguous reviewer direction.

PR monitoring is one part of the user's task. If the PR merges and the user
also asked to watch its apply, deployment, or runtime verification, continue
that authorized work. Follow the merged revision through the relevant workflow
and its actual execution steps. Report skipped operations separately from
successful ones, and verify the requested runtime outcome when access permits.
A merge event alone does not complete a rollout task.

## Hand off

Report the PR URL, final head SHA, terminal or blocking state, check totals and
remaining failing or pending checks, review decision, actionable unresolved
thread count, commits pushed, validation run, retries used, and the exact user
action still required.

When posting an authorized response, identify it as agent-authored according to
the active environment's convention.
