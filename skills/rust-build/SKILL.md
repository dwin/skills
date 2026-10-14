---
name: rust-build
description: Build and test Rust using the repository's toolchain and supported caches. Use when running Cargo builds or tests, configuring Rust build caches or sccache, reducing build storage, or preparing native, cross-compiled, container, or CI builds.
---

# Rust build

## Resolve the build contract

Read the repository's instructions, toolchain pin, Cargo manifests and configuration,
lockfile policy, and build or CI entry point. Reuse an existing runner when it
satisfies the task. Preserve the selected packages, features, profile, target,
compiler flags, integer-overflow checks, and assertion settings.

Identify the build host, artifact target, and required execution environment.
Use the project's normal native build when it meets the task. For a different
target or platform setup, read [Platforms and cross-compilation](references/platforms.md).
For Linux container builds, also read [Linux Docker builds](references/docker-linux.md).
A successful cross-compilation alone does not prove runtime compatibility.

Reuse the task's assigned workspace. Follow the repository's isolation policy
when creating another workspace; load the available Rift skill if Rift is selected.
Record the source revision and inherited changes before compiling.

## Choose storage and caching

Inspect effective Cargo configuration and existing caches before changing settings.
Share supported package stores and compiler caches outside checkouts. Keep cache
identities stable across tasks and separate writable build output from runtime state.
Coordinate any shared target directory and preserve task artifacts before another
build can replace them. Use independent targets when source identity or concurrent
writers make reuse unsafe.

Prefer supported `sccache` for compilation reuse across workspaces. Preserve the
repository's incremental workflow when it is required; disable incremental
compilation for builds selected to use `sccache`. Keep local caches bounded.
When configuring caching, choosing between cache strategies, or diagnosing misses,
read [Cargo and compiler caches](references/caching.md).

Apply task-specific settings in the selected build environment. Inspect existing
wrappers and configuration precedence before overriding them; host settings do
not automatically configure containers or remote runners.

## Build and verify

Run the repository's requested build or test command with its selected packages,
features, target, and profile. Use `--locked` when preserving an existing lockfile;
otherwise follow the project's resolution policy and retain the resolved lockfile
when reproducibility is required. Respect offline or vendored dependency policies.
Set build parallelism to fit the runner's memory and CPU budget when needed.

Verify the required artifact or tests in the intended execution environment.
Identify any emulation or untested target. When cache reuse is part of the task,
check statistics around real compilation; Cargo reporting `Fresh` is not an
`sccache` hit. Measure the relevant workload before claiming build-time or storage
savings.

Preserve required artifacts and provenance: source revision, toolchain, host and
target, effective build options, and artifact hash. Keep databases, journals,
replays, and benchmark evidence separate from caches; preserve required storage
and warm/cold-cache conditions.

Report commands, verification, artifact paths, cache locations and limits, and
retained state. Cleanup of existing caches, volumes, workspaces, or runtime
evidence requires the user's approval.
