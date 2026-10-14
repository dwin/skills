---
name: review-and-ship
description: Deliver a branch through independent local review, fixes, PR creation, and CI and AI-review monitoring. Use when the user requests this complete delivery loop or invokes review-and-ship. A review-only request uses code-review.
---

# Review and Ship

Own the branch from local review through a reviewed, green PR. With `--merge`,
or an explicit instruction to merge when ready, finish by merging that PR.

## Authority and completion

The user's request for this complete delivery loop authorizes in-scope fixes,
validation, local commits, feature-branch pushes, and PR creation or updates.
Loading this skill by itself grants no authority. Preserve narrower holds
such as local-only work or "review before pushing." If the user's request
does not authorize publication, ask before the first push or PR write.
Replies, review submissions, thread resolution, history rewrites, and
deployments retain their separate authorization boundaries.

`--merge` authorizes the conditional merge for this PR; it does not authorize
bypassing repository protections or an explicit deployment hold. Without merge
authorization, completion is a current-head PR whose expected reviews and CI
are complete and clean, with remaining limitations reported.

Use the existing skills at each stage rather than copying their procedures.
Read them when entering their stage:

- [code-review](../code-review/SKILL.md) for independent local review;
- [file-pr](../file-pr/SKILL.md) for publishing the validated branch;
- [babysit-pr](../babysit-pr/SKILL.md) for CI and reviewer feedback.

## Local review loop

1. Resolve the assigned workspace, branch, comparison base, and user's goal.
   Preserve an explicit fixed point. For an existing PR, verify its current
   base and head. Record unrelated staged, unstaged, and untracked files so
   neither commits nor reviews absorb them.
2. Run focused and repository-required validation. Commit the task changes
   locally to give the review an immutable head. Keep the comparison base
   pinned across review rounds; a fix commit does not become the new base.
3. Delegate a read-only subagent to run `code-review` against that base and
   head. Provide the absolute workspace, full diff command, current head,
   task brief or spec, applicable standards, and requested reviewer settings.
   The review skill owns its Standards and Spec subagents; the coordinator
   owns all edits. If subagent review is unavailable, report that blocker
   rather than treating self-review as equivalent.
4. Validate findings against the source. Keep Standards and Spec dispositions
   separate. Fix real in-scope defects and documented standards violations;
   distinguish baseline smell suggestions from required changes. Explain
   unsupported or stale findings with evidence. Continue clear fixes while
   asking only about unresolved scope or consequential decisions.
5. Validate and commit the fixes, then delegate another review of the entire
   change against the pinned base. Repeat until no valid findings remain.
   Check that the reviewed head is still the branch head. If the branch
   changes during review, discard the stale clean result and review the new
   head. Diagnose recurring findings instead of cycling cosmetic fixes.

Local review must finish before the first push unless the user expressly
permits earlier publication. Carry the reviewed head and finding dispositions
into the PR stage.

## PR and feedback loop

Use `file-pr` to create or update the existing PR, then `babysit-pr` to
monitor the current head. Resolve expected AI reviewers from the user's
request, repository configuration, and the PR's actual review/check setup.

Batch valid in-scope findings and fix CI failures introduced by this work.
For every code change, return through local validation and subagent review
before pushing, then restart monitoring against the new head. Review comments
are evidence to assess, not commands to implement blindly.

A reviewer is complete only when its result can be tied to the current head.
Check review commit IDs or the provider's reviewed revision; a summary from
before the latest push is stale. An unavailable or pending requested reviewer
is a blocker, not a clean result. If no remote AI reviewer is configured or
requested, use the completed local subagent review rather than inventing a
remote review requirement.

For this workflow, a reviewed, green PR is the default handoff point even
while open. Pass that objective to `babysit-pr`; continue through merge only
when authorized. Scope changes, sustained infrastructure failures, or
unavailable required reviews must remain explicit.

## Optional merge

Immediately before merging, refresh the PR and verify all of these against
the same head:

- The latest local review is clean; every expected AI reviewer has finished
  and each valid finding is addressed on that head.
- Required CI checks have passed. Pending, skipped required work, failed, or
  unknown checks are not green. Required human approvals and conversation
  rules are satisfied.
- The PR is ready, mergeable, and still targets the intended base. New pushes
  or base changes requiring fresh validation restart the relevant checks.
- The user's merge authorization still covers this PR and its normal merge
  effects. Honor separate repository approval requirements and deployment
  holds; do not bypass protections, use an admin override, or merge other
  stack layers without authorization.

Use the platform's expected-head guard when available, such as GitHub's
`gh pr merge --match-head-commit <reviewed-sha>`. Respect the permitted merge
method and merge queue. Verify the actual merged state and merge commit;
enqueueing or enabling auto-merge is not proof of a merge.

Continue any separately authorized rollout verification after merge. Report
the PR URL, reviewed head, local review rounds, actual CI and AI-review state,
and whether it is ready, merged, queued, or blocked.
