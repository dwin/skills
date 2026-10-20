# Storage

## Shared stores

Share package stores and compiler caches across workspaces, outside any
checkout. Use the repository's package manager, lockfile, and its supported
shared-store or hardlink mode. A symlinked writable `node_modules` or build tree
lets one task's install or build overwrite another's.

Keep each workspace's own dependency layout, runtime state, journals, and
benchmark data inside the workspace or its run-specific storage.

Cache helpers keyed on a repository's original `.git` path do not recognize a
Rift, whose `.git` is a copy. Resolve such cache locations from the source
checkout and pass them into the workspace's commands explicitly.

Language specifics:

- Go: keep the existing shared module and build caches.
- Rust: load the `rust-build` skill when available. It covers `sccache`,
  external target directories, and container builds.
- Nx: resolve `NX_CACHE_DIRECTORY` from the source checkout and pass it
  through. Leave `NX_WORKSPACE_DATA_DIRECTORY` unset.

## Build lanes

A **lane** is the task's writable build output: a target directory, a
subdirectory of a shared build volume, or a builder container's output path.
Name lanes for the task, and reuse a compatible lane for every build in
that task. Build release, bench, or other extra profiles only when the task
needs them: each profile adds its own output tree to the lane. Serialize builds
that share a writable lane. Copy executables the task must keep out of the lane
before another build can replace them.

Clean the lane when its workspace meets the
[cleanup conditions](../SKILL.md#clean-up). Use the build tool's clean command
pointed at that lane, such as `cargo clean --target-dir <lane>`. A wrapper
script that owns the lane may provide its own clean entry point; use that.

## Disk space

The disk floor protects a local machine that other sessions and the user
share. A cloud agent sandbox has its own disk, so skip the floor there.

The **disk floor** is the reserve the user or repository states, plus the
run's estimated peak usage, on the volume that will hold the output. Without a
stated reserve, use 30 GB. Check it with `df -h <path>` before storage-heavy
runs. Stop and report instead of starting a run that would breach the floor,
and stop a running loop when free space drops below the reserve. Report actual
usage afterwards.

Free space by cleaning this task's own lanes and temp data. Pruning shared
caches or another task's storage needs the user's approval.

## Test temp data

Tests remove what they create: databases, `initdb` clusters, containers, and
fixture directories. Prefer the framework's cleanup hook, such as Go's
`t.Cleanup`. For a test loop, point the tests at a task-owned temp root, for
example by setting `TMPDIR` for the run, and compare its size before and after.
Growth points to a leak, such as an `initdb` cluster left behind by each test.
Fix a leak when the task covers that code; otherwise report it with the path and
size.

## Containers and Docker

Inspect existing build-cache volumes before creating one and reuse compatible
ones. Name volumes by repository, toolchain, and Linux platform; task, PR, and
date names multiply volumes. Prefer stable BuildKit cache IDs for Dockerfile
builds. Record why any added persistent cache is needed.

Host compiler-cache settings do not configure a container. Configure the
cache, with a size bound, inside the builder. One cache daemon owns a shared
disk cache at a time; give other builders their own bounded cache or serialize
them.

Removing a container keeps its named volumes. Name your own containers and
stop them by name. Stopping containers by image filter also stops other
sessions' containers on that image.

## Evidence

Benchmark data, journals, database state, and replays live in run-specific
storage labeled with the owning task, separate from caches. Estimate peak
storage before a large run. Preserve the benchmark's required storage medium
and warm or cold cache conditions. Report the evidence location, its size, and
whether it is retained or removed; removal needs the user's approval.
