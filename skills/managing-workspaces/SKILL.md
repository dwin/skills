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
   Create from a clean seed checkout of the repository rather than a checkout
   someone is working in. Fall back to a Git worktree, then a fresh clone, when
   Rift is unavailable or blocked. Read
   [Isolation](references/isolation.md) for Rift blockers, seeds, and the
   fallbacks.
3. Name a new workspace and its branch for the task, and start the branch from
   the requested base. For an existing PR, check out the PR's remote branch and
   compare it with the workspace HEAD before committing. Push to that branch so
   the PR updates. A read-only review can use a detached checkout at the
   fetched PR SHA.
4. Record the source path, base commit, and any inherited staged, unstaged, or
   untracked changes. Stage task files by path so inherited changes stay out of
   commits.
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
  artifacts and evidence separately with `git status --ignored`, and move
  anything worth keeping out first.
- Every commit the task made is pushed or merged, or the task made no commits,
  as in a read-only review.
- Nothing is held for someone else, such as an untracked probe a reviewer told
  an implementer to adopt, a running service, or a stash.

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
