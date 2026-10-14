---
name: rift
description: Use Rift copy-on-write workspaces when the user requests Rift isolation, a snapshot of current working state, or Rift workspace management.
---

# Rift

Use [Rift](https://github.com/anomalyco/rift) to give a task an isolated copy
of the current workspace, including its Git index and uncommitted changes.

This skill covers Rift's commands and works on its own. The
`managing-workspaces` skill carries the wider policy: choosing an isolation
method, seed checkouts, ownership, build storage, and cleanup authorization.
Load it alongside this one when it is available.

## Ensure Rift is available

Run `command -v rift` and `rift --help`. If it is missing, install the
`rift-snapshot` package with an available package manager:

```bash
bun add -g rift-snapshot
# With npm when Bun is unavailable:
npm install -g rift-snapshot
```

Use the package manager's global bin directory if installation succeeds but
`rift` is outside PATH. For Bun, try `"$HOME/.bun/bin/rift" --help` and add
that directory to the task's command environment. Change persistent shell
configuration only when requested. If neither package manager is available,
report the prerequisite rather than installing a runtime outside task scope.
Confirm the executable works before creating a workspace.

## Create or reuse a workspace

1. Resolve the intended source to an absolute path. Inspect its Git status,
   HEAD, index, and remote before snapshotting. Record inherited changes so
   later commits include only task-owned edits unless the user requests
   otherwise. Leave the source index and working-tree contents unchanged.
   After creating or selecting the Rift, and only inside that workspace before
   making task commits, unstage inherited entries without changing working-tree
   contents. Stage only task-owned changes (select hunks interactively when
   needed) and inspect the complete staged diff. If inherited and task changes
   cannot be separated confidently, do not commit them; report the blocker.
2. Reuse a suitable Rift workspace already assigned to this task. For a new
   workspace, run `rift init` from the source, then
   `rift create --name <task-name>`. Capture the absolute path printed on
   stdout and verify that it exists before continuing.
3. Run every edit, Git command, dependency setup, and test with that path as
   the explicit working directory. Shell directory changes do not persist
   across separate tool calls. Report the path so the user can open it.

Rift needs a regular Git checkout. It rejects linked Git worktrees,
repositories with active Git operations or lock files, and FIFOs such as a
secret manager's `.env` pipe. Leave those states in place. A clean seed avoids
these blockers for ordinary new isolation; if the user explicitly requests a
snapshot of this current state, report the blocker and ask before using a source
that omits it.

Rift copies Git repositories with detached HEAD. Create a task branch, or check
out the PR's remote branch, before committing.

By default, Rift omits regenerable artifacts, including dependencies and build
caches. Use `--copy-all` when the task needs those files, otherwise run the
repository's normal setup in the new workspace. Check installed CLI help for
supported options. macOS creation requires APFS; Windows workspace creation
is currently unsupported.

Read any `.rift.toml` before creation or removal. Its lifecycle hooks execute
commands and may start services or remove data. Run hooks only within existing
task authorization; use `--no-hooks` when hooks exceed it. If a postcreate
hook fails, inspect `rift list` and the resulting workspace before retrying:
creation may already have succeeded.

## Codex use

This skill controls shell execution in a Rift directory. It does not replace
Codex's native worktree backend or move the chat's project attachment.
Start from the source checkout in local mode. For app project views tied to
the snapshot, open the returned directory as a project and start a local chat
there. Give delegated agents the same explicit workspace boundary, or create
separate Rift workspaces when their edits need isolation.

## Finish and clean up

Report the workspace path, branch, inherited changes, task changes, and
validation.

Keep a Rift the user asked for as a snapshot until the user releases it. Keep
an implementation Rift while its PR is open. Remove a Rift this task created when its PR
merges, its review-only task has reported, or the user asks. Before removal,
confirm all three:

- `git status --porcelain` prints nothing. Discarding uncommitted files needs
  the user's explicit authorization. Inspect ignored files and evidence
  separately with `git status --ignored`; inventory needed configuration,
  inputs, artifacts, and evidence, and move anything worth keeping out of the
  Rift first. Confirm the remaining ignored files are disposable; ask before
  removing evidence or anything whose disposability is unclear.
- Every commit the task made is pushed or merged, or the task made no commits.
- Nothing is held for someone else, such as an adopted probe, a running
  service, or a stash.

Before removal, use `rift list` to inspect the full registered descendant tree:
`rift remove` trashes the selected workspace and its descendants. Keep the
parent unless every affected workspace belongs to this task, is eligible for
cleanup, and passes these retention checks. Read `.rift.toml` and run hooks
only within task authorization; use `--no-hooks` when its hooks exceed that
authorization.

Remove it with `rift remove <absolute-workspace-path>`, never `rm -rf`.
Removal trashes the workspace subtree. Use `rift gc` only when permanent
deletion of Rift trash is explicitly requested; it can affect trash from other
tasks.
