---
name: file-pr
description: Create or update a pull request with an outcome-focused title and description. Use before running `gh pr create` or its equivalent for any reason, whether the user asked for a PR, the task ends in one, or an existing PR's title or body needs updating.
---

# File PR

Create a pull request that makes the problem, outcome, scope, and validation
easy to review. Prefer why the change matters over an inventory of edits.

## Verify readiness

1. Read repository instructions and any pull request template.
2. Inspect the working tree, commits, complete diff against the intended base,
   and current branch tracking state. Confirm the diff matches the user's goal
   and does not contain unrelated or sensitive material.
3. Run all repository-required validation: the commands the repository's CI
   runs on a pull request, at the tool versions CI pins, on the tree being
   pushed. Name any check that cannot be reproduced locally instead of counting
   it as passed. Do not claim checks that did not run or pass. If required
   validation fails, fix it only when that work is already authorized;
   otherwise report the blocker instead of filing a misleading PR.
4. Push the branch if needed, under its own name: `git push -u origin HEAD`.
   A task branch created from `origin/<base>` can have the base as its
   upstream, and a plain `git push` then aims at the base. A direct request to
   create the PR authorizes this normal prerequisite, but not history
   rewrites.
5. Find an existing open PR for the head branch. Update it instead of creating
   a duplicate.
6. Inspect recent merged PRs and any PR title check for title conventions.
   Preserve meaningful ticket prefixes or conventional-commit style when the
   repository uses them. When the convention requires a ticket key, settle it
   before creating the PR: look in the branch name, the commits, the task
   brief, and the tracker (through `docs/agents/issue-tracker.md` when
   present). Create a ticket when the user asked for one or repository
   instructions call for it; otherwise ask which ticket applies.

## Choose a standalone PR or a stack

Use a standalone PR by default. Use a native GitHub PR stack only when two or
more focused review units form a dependency chain and work must continue before
lower layers merge. File unrelated changes as independent PRs.

Before proposing or filing a stack, read
[references/github-pr-stacks.md](references/github-pr-stacks.md). Confirm the
public preview is available, every branch is in the same repository, and the
repository's review, CI, merge, and automation workflows support stacks. State
the trunk and bottom-to-top layers before changing remote state.

## Write the title

State the outcome concisely. Prefer a result a reviewer or release-note reader
can understand over a low-level implementation action.

- Weak: `perf(server): negotiate permessage-deflate on the websocket`
- Strong: `perf(server): reduce websocket frame size with compression`

Avoid unsupported numbers or claims. Keep the title useful as a squash-merge
commit message.

## Write the description

Lead with a short problem-and-outcome explanation derived from the user's goal
and verified diff. Follow the repository template, filling every applicable
section honestly and preserving template comments that support automation.

Use this order when no template dictates another:

1. Problem and impact.
2. What changes for the user or operator.
3. Important implementation or compatibility notes.
4. Validation actually completed.
5. Known risks, follow-ups, or intentionally deferred work.

Keep change lists brief and secondary. Do not paste commit logs, enumerate
every touched file, invent ticket links, or check boxes for work not completed.

Use repository-relative paths, portable commands, and shared URLs in PR text
and committed documentation. Keep workstation-specific evidence paths in local
notes unless the audience needs them.

## Create or update the PR

- Choose the intended base branch from repository evidence; do not assume it is
  always `main`.
- Open the PR ready for review. File a draft when the user asks for one, when
  repository instructions require it, or when the PR exists to explore an idea
  and is not meant to merge as it stands.
- Do not force-push, rebase, merge, close, enable auto-merge, or announce the PR
  in external channels unless explicitly asked.
- For a stack, create, link, update, and verify every requested layer as one
  operation. Do not merge through a selected layer unless explicitly asked;
  that action also merges every unmerged layer below it.
- Do not add extra implementation while filing. Report unfinished work instead
  of expanding scope at the last moment.

After creation or update, verify the rendered title, body, base/head branches,
and draft state. Follow the required checks triggered for the pushed head to a
result or concrete blocker before handoff. Inspect relevant failure output and
Terraform plan output; PR creation alone does not establish readiness. Fix
in-scope failures when authorized. If validation is blocked by access, an
approval, or a sustained runner failure, report what is needed to finish it.
Respect an explicit request to file a draft without waiting for checks.

For deployment changes, verify the effective workflow gates and environment
settings against the requested rollout. A successful workflow with a skipped
plan, apply, or deployment does not prove that operation succeeded. Preserve
the agreed activation state; use the delivery and approval process to control
execution instead of silently disabling it in the submitted configuration.

Report the PR URL, head SHA, validation, and remaining risk. Call the PR ready
only after the Ready check in `babysit-pr` holds on that head; until then,
report what it is waiting on.

If the user also asked to monitor the PR, continue with the `babysit-pr` skill.
