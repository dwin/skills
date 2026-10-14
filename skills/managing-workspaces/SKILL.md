---
name: managing-workspaces
description: Manage task workspace and build-lane lifecycles. Use when creating, reusing, or cleaning up workspaces, Rifts, Git worktrees, clones, or build lanes; switching branches in task checkouts; or planning their storage.
---

# Managing workspaces

A **workspace** is the checkout a task edits, plus the build lanes, temp data,
and evidence it creates. Each task works in exactly one workspace. The task
cleans up only the workspaces and lanes it created. Shared stores and anything
another task or session created belong to someone else.

## Choose isolation

1. Reuse the workspace already assigned to this task, then continue from
   step 3.
2. For new isolation, prefer Rift: load the `rift` skill for its commands.
   Unless the user explicitly requests a snapshot of the current workspace,
   create from a clean seed checkout rather than a checkout someone is working
   in. For a requested current-state snapshot, use that source so staged,
   unstaged, and untracked changes are preserved. If it cannot be snapshotted,
   report the blocker and ask before using a source that omits those changes.
   For other tasks, fall back to a Git worktree, then a fresh clone, when Rift
   is unavailable or blocked. Read [Isolation](references/isolation.md) for
   Rift blockers, seeds, and the fallbacks.
3. Name a new workspace and its branch for the task, and start the branch from
   the requested base. For an existing PR, check out the PR's remote branch and
   compare it with the workspace HEAD before committing. Push to that branch so
   the PR updates. A read-only review can use a detached checkout at the
   fetched PR SHA.
4. Record the source path, base commit, and inherited staged, unstaged,
   untracked, and ignored files. Rift preserves the source index: staging task
   files by path alone can include inherited staged entries and inherited edits
   in the same file. Unstage inherited entries without changing working-tree
   contents, stage only task-owned changes (select hunks interactively when
   needed), and inspect the complete staged diff before committing. If inherited
   and task changes cannot be separated confidently, do not commit them; report
   the blocker.
5. Run every command with the workspace's absolute path as its working
   directory. Shell directory changes do not persist between tool calls.

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

Share package stores and compiler caches outside checkouts. Give the task one
build lane and reuse it for every build. Check free space against the
[disk floor](references/storage.md#disk-space) before long builds, test loops,
and benchmarks, and stop and report when a run would breach it. Tests clean up
the databases, clusters, and fixture directories they create. Benchmark
evidence lives apart from caches.

Read [Storage](references/storage.md) before configuring caches or lanes,
choosing build profiles, running containerized builds, running long test
loops, or keeping evidence.

## Clean up

The owner has authorized removing finished workspaces and lanes this task
created. Everything else needs the user's approval: `rift gc`, shared caches,
Docker volumes, retained evidence, and anything this task did not create.

Clean up a task-created workspace and its lanes when:

- the task's PR merges;
- a review-only task has reported its review; or
- the user asks.

Keep an assigned workspace that existed before the task, an implementation
workspace while its PR is open, and anything under an explicit retention hold,
such as a snapshot the user asked for, until the holder releases it.

Before removing anything, confirm all three:

- The tree is clean: `git status --porcelain` prints nothing. Discarding
  uncommitted files needs the user's explicit authorization. Inspect ignored
  files and evidence separately with `git status --ignored`; inventory needed
  configuration, inputs, artifacts, and evidence, and move anything worth
  keeping out first. Confirm the remaining ignored files are disposable; ask
  before removing evidence or anything whose disposability is unclear.
- Every commit the task made is pushed or merged, or the task made no commits,
  as in a read-only review.
- Nothing is held for someone else, such as an untracked probe a reviewer told
  an implementer to adopt, a running service, or a stash.

For a Rift, use `rift list` to inspect the full registered descendant tree
before removal: `rift remove` trashes the selected workspace and its
descendants. Keep the parent unless every affected workspace belongs to this
task, is eligible for cleanup, and passes these retention checks. Read
`.rift.toml` and apply the
[Rift hook-authorization checks](../rift/SKILL.md#finish-and-clean-up); use
`--no-hooks` when its hooks exceed task authorization.

Then use each tool's own remove or clean command: `rift remove <path>` for a
Rift, `git worktree remove <path>` for a worktree, and the build tool's clean
command for the task's lane. These commands keep the tool's bookkeeping
consistent. Never run `rm -rf` on a Rift, a worktree, or a shared build target.
Delete a directory directly only for a standalone clone the task created, after
all three checks pass.

## Hand off

Report:

- the workspace path, branch or SHA, head commit, and whether it is pushed;
- the base and inherited changes;
- what was kept, with the reason for each item;
- what was removed or cleaned, with the commands that did it; and
- any storage concern found, such as a leaking test or a nearly full disk.
