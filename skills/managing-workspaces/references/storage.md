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
Create one lane per task, named for the task, and reuse it for every build in
that task. Serialize builds that share a writable lane. Copy executables the
task must keep out of the lane before another build can replace them.

When the task finishes, clean its lane with the build tool's clean command
pointed at that lane, such as `cargo clean --target-dir <lane>`. A wrapper
script that owns the lane may provide its own clean entry point; use that.

## Disk space

Check free space with `df -h <path>` on the volume that will hold the output,
before long builds, test loops, and benchmarks. Estimate the run's peak usage
and keep headroom above it. Stop and report when free space would fall below
10% of the volume or 20 GB, whichever is larger, unless the repository sets
its own threshold. Report actual usage afterwards.

Free space by cleaning this task's own lanes and temp data. Pruning shared
caches or another task's storage needs the user's approval.

## Test temp data

Tests remove what they create: databases, `initdb` clusters, containers, and
fixture directories. Prefer the framework's cleanup hook, such as Go's
`t.Cleanup`. After a test loop, compare the size of `$TMPDIR` with its size
before the loop. Growth points to a leak: one `initdb` Postgres cluster left in
`$TMPDIR` per test cost about 74 MB each. Fix a leak when the task covers that
code; otherwise report it with the path and size.

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
