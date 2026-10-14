---
name: managing-workspaces
description: Own a task's workspace from creation to cleanup. Use when creating, reusing, or removing a workspace, Rift, worktree, or clone, changing branches, sizing builds and caches, or handing off finished work.
---

# Managing workspaces

A **workspace** is the checkout a task edits, plus the build lanes, temp data,
and evidence it creates. Each task owns exactly one workspace, from creation
through cleanup. Shared stores and anything another task or session created
belong to someone else.

## Choose isolation

1. Reuse the workspace already assigned to this task. Stop here when one exists.
2. For new isolation, prefer Rift: load the `rift` skill for its commands.
   Create from a clean seed checkout of the repository rather than a checkout
   someone is working in. Fall back to a Git worktree, then a fresh clone, when
   Rift is unavailable or blocked. Read
   [Isolation](references/isolation.md) for Rift blockers, seeds, and the
   fallbacks.
3. Name the workspace and its branch for the task. Start the task branch from
   the requested base or PR branch.
4. Record the source path, base commit, and any inherited staged, unstaged, or
   untracked changes. Stage task files by path so inherited changes stay out of
   commits.
5. Run every command with the workspace's absolute path as its working
   directory. Shell directory changes do not persist between tool calls.

The step is done when the workspace path, branch, base, and inherited changes
are recorded.

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
build lane and reuse it for every build. Check free disk space before long
builds, test loops, and benchmarks. Stop and report when free space would fall
below 10% of the volume or 20 GB, whichever is larger, unless the repository
sets its own threshold. Tests clean up the databases, clusters, and fixture
directories they create. Benchmark evidence lives apart from caches.

Read [Storage](references/storage.md) before configuring caches or lanes,
running containerized builds, running long test loops, or keeping evidence.

## Clean up

Clean up when the task's PR merges or its review is reported. Until then, keep
the workspace so the user and reviewers can inspect it. Before removing
anything, confirm all three:

- The tree is clean, or every uncommitted file is deliberately disposable.
- HEAD is pushed or merged.
- Nothing is held for someone else, such as an untracked probe a reviewer told
  an implementer to adopt, a running service, or a stash.

Then use each tool's own remove or clean command: `rift remove <path>` for a
Rift, `git worktree remove <path>` for a worktree, and the build tool's clean
command for the task's lane, such as `cargo clean` with that lane's target.
These commands know the tool's bookkeeping. Delete a fresh clone directory
only after the same three checks.

Cleanup of shared caches, Docker volumes, retained evidence, Rift trash
(`rift gc`), and anything this task did not create waits for the user's
approval.

## Hand off

Report:

- the workspace path, branch, head commit, and whether it is pushed;
- the base and inherited changes;
- what was kept, with the reason for each item;
- what was removed or cleaned, with the commands that did it; and
- any storage concern found, such as a leaking test or a nearly full disk.
