---
name: sprites
description: Run builds, tests, data jobs, development services, or agent tasks on Fly.io Sprites when local CPU, memory, disk, or Linux compatibility is a constraint. Use for Sprite setup, Sprite workspaces, artifact transfer, and optional SSHFS mounts.
---

# Sprites

Move expensive work to an authenticated Fly.io Sprite. Keep editing and orchestration local when useful; run compilers, dependency installation, containers, and data processing remotely.

## Choose the target and source

1. Inspect `sprite --help`, `sprite list`, and relevant command help. Use existing authentication; report an auth failure without printing tokens or reading credential files. Target each command with `-o <org> -s <sprite>` so concurrent agents cannot change each other's target through `sprite use`.
2. Reuse a suitable existing Sprite. Inspect remote CPU, memory, free disk, installed tools, and active jobs before sizing work. Create another Sprite when the authorized task needs isolation and existing capacity is unsuitable; record its purpose and expected storage.
3. Choose one source of truth: a remote checkout for remote development, or a local checkout whose exact source is transferred for remote validation. Record repository, commit, staged and unstaged changes, remote directory, and toolchain. Never treat a remote branch with the same name as proof that it contains local edits.
4. Use a task-specific checkout under `/home/sprite/workspaces/`. Verify the configured GitHub access method before cloning. A Sprites GitHub connector may work even when `gh` and Git are unauthenticated; read [GitHub gateway](references/github-gateway.md) when one is configured. Check out the exact commit and verify HEAD. Read [source transfer](references/source-transfer.md) when the Sprite cannot fetch that commit or the local checkout has uncommitted work. Check repository instructions in the remote source tree before changing it. Keep credentials inside their existing stores; copying local home directories or auth files is unnecessary.

For local editors on a remote checkout, read [SSHFS](references/sshfs.md). When preparing a reusable builder, building Rust, or measuring cache reuse, read [checkpoints and caches](references/checkpoints-and-caches.md).

## Execute remotely

```bash
sprite exec -o <org> -s <sprite> --no-stdin --no-port-forward \
  --dir /home/sprite/workspaces/<task> -- <command> <args...>
```

Pass arguments directly. When shell syntax is needed, invoke `bash -lc` explicitly and quote local and remote variables separately. Use `--no-stdin` for unattended commands; omit it when streaming input. Use `--no-port-forward` for compute jobs to avoid claiming laptop ports.

Install dependencies with the repository's package manager and lockfile on Linux. Write build outputs to task-owned paths, and share a writable cache only when one owner or one lock serializes every writer; [checkpoints and caches](references/checkpoints-and-caches.md) has the Cargo and sccache rules. Run Docker remotely only when the workload needs it and Docker is available; inspect remote volumes before allocating caches. Keep journals, databases, and benchmark results in run-specific paths.

Start with a small representative command, then run the required workload. Capture its exit status, complete log, source SHA and dirty state, tool versions, command, artifact paths, and relevant resource usage. Preserve task-specific copies before a later build can overwrite outputs. Linux binaries must run on the remote Linux platform or a compatible deployment target.

For long tasks, use the session or service mechanism shown by installed help. Disk persists across sleep. A warm pause may preserve processes; a cold pause loses ordinary process memory and connections need reconnection. Verify session state and the process's final result after reconnecting before restarting a job. A sleeping or disconnected Sprite does not prove the job completed.

## Delegate work

Give each agent the skill path, org/Sprite, absolute remote checkout, source SHA and dirty-state transfer, exact task, allowed side effects, cache ownership, and evidence destination. Require the agent to run compute through `sprite exec` and return command results and artifact provenance. Agents sharing a Sprite need separate writable checkouts and outputs; serialize access to shared writable targets or databases. GitHub access inside the Sprite does not expand permission to push, merge, or deploy.

## Return results

Retrieve only needed logs, patches, and artifacts using `sprite file` (inspect its help), or stream an archive through `sprite exec`. For remote edits, review the diff and transfer a patch or commits through the task's authorized delivery path. Verify retrieved artifacts with hashes and verify the final source state.

Report the target, source SHA and local-change coverage, checks with results, retained artifacts, and limitations. Keep Sprites, caches, checkpoints, and evidence by default. Destruction, restore, pruning, or cleanup needs the user's authorization. Keep URL authentication private unless public exposure is requested.

Primary reference: [Working with Sprites](https://docs.fly.io/sprites/working-with-sprites). CLI help is the authority for installed command syntax.
