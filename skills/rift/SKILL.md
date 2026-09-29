---
name: rift
description: Use Rift copy-on-write workspaces when the user requests Rift isolation, a snapshot of current working state, or Rift workspace management.
---

# Rift

Use [Rift](https://github.com/anomalyco/rift) to give a task an isolated copy
of the current workspace, including its Git index and uncommitted changes.

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
   later commits include only task-owned edits unless the user requests otherwise.
2. Reuse a suitable Rift workspace already assigned to this task. For a new
   workspace, run `rift init` from the source, then
   `rift create --name <task-name>`. Capture the absolute path printed on
   stdout and verify that it exists before continuing.
3. Run every edit, Git command, dependency setup, and test with that path as
   the explicit working directory. Shell directory changes do not persist
   across separate tool calls. Report the path so the user can open it.

Start from a regular Git checkout. Rift rejects linked Git worktrees and
repositories with active Git operations or lock files. Preserve those states;
use a suitable regular checkout or report the blocker.

Rift copies Git repositories with detached HEAD. Create a task branch before
committing. For existing PR work, preserve the requested remote branch and
inspect its relationship to the snapshot HEAD before choosing a branch.
Inherited staged changes require special care: avoid blanket staging or
commits that absorb the source's unrelated work.

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
validation. Preserve the workspace by default so the user can review it.

When cleanup is requested, inspect Git status and confirm needed commits,
untracked files, and artifacts are retained elsewhere before running
`rift remove <absolute-workspace-path>`. Removal trashes the workspace
subtree. Use `rift gc` only when permanent deletion of Rift trash is explicitly
requested; it can affect trash from other tasks.
