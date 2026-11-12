---
name: managing-workspaces
description: Manage the lifecycle of isolated task checkouts and their build storage. Use when creating or removing a Rift, Git worktree, or task clone; when a task needs a different branch than a shared checkout has; or when sizing build lanes, caches, or disk for a long build or test run.
---

# Managing workspaces

A **workspace** is the checkout a task edits, plus the build lanes, temp data,
and evidence it creates. The task cleans up only the workspaces and lanes it
created. Shared stores and anything another task or session created belong to
someone else.

## Choose isolation

1. Reuse the workspace already assigned to this task, then continue from
   step 3.
2. For new isolation, match the environment:
   - **Cloud agent environments**, such as Cursor cloud agents, Codex cloud,
     or Claude Code on the web, already give each task its own sandbox. Work
     in it; Rift and extra worktrees add nothing there.
   - **On a local machine**, prefer Rift: load the `rift` skill for its
     commands. Create from a clean seed checkout, unless the user explicitly
     requests a snapshot of a current workspace. When Rift is unavailable or
     blocked, fall back to a Git worktree, then a fresh clone. Read
     [Isolation](references/isolation.md) for Rift blockers, seeds, and the
     fallbacks.
3. Name a new workspace and its branch for the task, and start the branch from
   the requested base. For an existing PR, fetch its branch and compare it with
   the workspace HEAD before switching. Report commits that only HEAD has, and
   keep them on a branch, before checking out the PR branch. Push to that branch
   so the PR updates. A read-only review can use a detached checkout at the
   fetched PR SHA.
4. Record the source path, base commit, and any inherited staged, unstaged, or
   untracked changes, so task commits include only task-owned edits.

Use a second workspace or lane in the same task when the work needs another
repository, revision, toolchain, or concurrent writer.

The step is done when the workspace path, branch or SHA, base, and inherited
changes are recorded.

## Respect ownership

Change branches only inside the task's own workspace. A shared or regular
checkout keeps its branch: other sessions, editors, and builds read its files.
When the task needs another branch, create a workspace for it.

Act only on what this task created. Workspaces, lanes, caches, volumes,
containers, and evidence from another agent or session stay untouched, even
when they look stale. When ownership is unclear, treat the item as someone
else's and report it.

## Keep storage bounded

Share package stores and compiler caches outside checkouts, and reuse one
compatible build lane for the task's builds. On a local machine, check free
space against the [disk floor](references/storage.md#disk-space) before
storage-heavy runs, such as large builds, long test loops, and benchmarks. Tests clean up the databases,
clusters, and fixture directories they create.

Read [Storage](references/storage.md) before configuring caches or lanes,
choosing build profiles, running containerized builds, running long test
loops, or keeping evidence.

## Clean up

Remove a task-created workspace and its lanes as soon as one of these holds:

- the task's PR merged and no follow-up work will reuse the workspace;
- a review-only task has reported its review; or
- the user asks.

A merge is the authorization: remove then, without asking. User or repository
instructions that say to keep workspaces take precedence.

Keep a workspace that existed before the task, an implementation workspace
while its PR is open, a workspace that planned follow-up work will reuse, and
anything under an explicit retention hold, such as a snapshot the user asked
for.

`rift gc`, shared caches, Docker volumes, retained evidence, and anything this
task did not create always need the user's approval. List them with their
paths and sizes and ask.

When the user asks to reclaim space or clear out old workspaces, audit first.
Build the list from the tools' own listings, such as `git worktree list`,
because paths recalled from memory miss workspaces. For each one, record its
size, age, branch, whether that branch is merged, its PR state, and its
tracked and untracked changes. For Git worktrees,
[`scripts/worktree-audit.sh`](scripts/worktree-audit.sh) `[-b <base>] [repo]`
prints these columns for every worktree, plus unpushed commits, and removes
nothing; its `--help` explains each column. Then sort the rows: merged, clean, and used by
no session may go; uncommitted tracked changes wait for the user's decision; a
workspace another session is using stays, and so does a locked worktree. Show the table with the proposed
action for each row before removing anything.

Before removing anything, confirm all three:

- The tree is clean: `git status --porcelain` prints nothing. Discarding
  uncommitted files needs the user's explicit authorization. Check ignored
  files with `git status --ignored`, move anything worth keeping out first,
  and ask before removing evidence or anything whose disposability is unclear.
- Every commit the task made is pushed or merged, or the task made no commits,
  as in a read-only review.
- Nothing is held for someone else, such as an untracked probe a reviewer told
  an implementer to adopt, a running service, or a stash.

Then use each tool's own remove or clean command, so its bookkeeping stays
consistent: the `rift` skill's removal steps for a Rift,
`git worktree remove <path>` for a worktree, and the build tool's clean command
for the task's lane. Delete a directory directly only for a standalone clone
the task created, after all three checks pass.

`git worktree remove --force` discards uncommitted and untracked files. Use
it only with the user's approval for that one workspace, given after you
showed what it would discard: the `git status --porcelain` output and the
diff of the tracked changes. Approval for one workspace does not carry to the
next.

## Hand off

Report the workspace path, branch or SHA, head commit, and whether it is
pushed; what was kept and why; what was removed and with which commands;
storage that removal did not reclaim, such as Rift trash; and any storage
concern found, such as a leaking test or a nearly full disk.
