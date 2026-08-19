---
name: file-pr
description: Create, open, file, or submit a pull request with an outcome-focused title and description. Use when the user asks to turn completed branch work into a PR, update the PR for the current branch, or prepare a pull request for review.
---

# File PR

Create a pull request that makes the problem, outcome, scope, and validation
easy to review. Prefer why the change matters over an inventory of edits.

## Verify readiness

1. Read repository instructions and any pull request template.
2. Inspect the working tree, commits, complete diff against the intended base,
   and current branch tracking state. Confirm the diff matches the user's goal
   and does not contain unrelated or sensitive material.
3. Run all repository-required validation. Do not claim checks that did not run
   or pass. If required validation fails, fix it only when that work is already
   authorized; otherwise report the blocker instead of filing a misleading PR.
4. Push the branch if needed. A direct request to create the PR authorizes this
   normal prerequisite, but not history rewrites.
5. Find an existing open PR for the head branch. Update it instead of creating
   a duplicate.
6. Inspect recent merged PRs for title conventions. Preserve meaningful ticket
   prefixes or conventional-commit style when the repository uses them.

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

## Create or update the PR

- Choose the intended base branch from repository evidence; do not assume it is
  always `main`.
- Prefer a draft when material validation, migration, documentation, or user
  decisions remain. Otherwise follow the user's request and repository norm.
- Do not force-push, rebase, merge, close, enable auto-merge, or announce the PR
  in external channels unless explicitly asked.
- For a stack, create, link, update, and verify every requested layer as one
  operation. Do not merge through a selected layer unless explicitly asked;
  that action also merges every unmerged layer below it.
- Do not add extra implementation while filing. Report unfinished work instead
  of expanding scope at the last moment.

After creation or update, verify the rendered title, body, base/head branches,
and draft state. Report the PR URL, head SHA, readiness state, validation, and
remaining risk.

If the user also asked to monitor the PR, continue with the `babysit-pr` skill.
