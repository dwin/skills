---
name: rust-build
description: Build and test Rust with shared compilation caches. Use when running Cargo builds or tests, configuring Rust build caches or sccache, reducing Rust build storage, or building and running Rust in Linux Docker containers from macOS.
---

# Rust build

Choose the required execution platform before choosing the compiler.
On an ARM Mac, use native Linux ARM64 containers when the code must run on Linux.
Use Linux AMD64 only when the requested target requires it, and identify emulation
in any timing or performance evidence. Cross-compiling a Linux executable on
macOS does not provide a Linux runtime.

## Resolve the build

Read the repository's toolchain pin, Cargo configuration, lockfile, and build
entry point. Preserve the requested Rust version, features, build profile, target,
integer-overflow checks, and assertion settings. Use existing runners when they
meet the requested platform and cache requirements.

Reuse the task's assigned workspace. When new isolation is needed, use the
available Rift skill and carry source-resolved cache settings into the snapshot.
Record the source revision and inherited changes before compiling.

## Use supported caches

Inspect existing caches before allocating more storage. Reuse compatible package
stores and compiler caches with stable identities based on repository, toolchain,
and execution platform. Give task outputs and benchmark state their own paths.
Creating a volume with a new task, PR, lane, or date in its name defeats reuse.

Use `sccache` when available and supported by the selected compiler. For cacheable
Rust compilation, configure `RUSTC_WRAPPER` or `build.rustc-wrapper` and disable
incremental compilation. Respect an explicit need for incremental builds and
report the resulting cache limitation. Keep cache size bounded.

For host builds, inspect effective Cargo settings rather than replacing existing
configuration. For Linux containers, read
[Linux Docker builds](references/docker-linux.md). Host macOS executables and
Cargo configuration do not configure a Linux builder.

A shared compiler cache still materializes build outputs. Workspace crates at
different absolute paths can miss even when source contents match. Verify cache
hits for the workload before claiming reuse or storage savings.

## Keep artifacts correct

Coordinate any shared writable target directory. Separate source identity or
force a fresh build when restored timestamps could make Cargo consider a changed
snapshot up to date. Prefer fresh disposable target output plus shared compiler
caching when this cannot be proved safe.

Preserve the exact task executable outside a shared build tree before another
build can replace it. Record its hash, source revision, toolchain, platform, and
effective profile. Keep journal, database, replay, and benchmark evidence separate
from caches. Preserve the required storage medium and warm/cold-cache protocol.

## Verify and finish

Run the requested build or tests and inspect their exit status. Check cache
statistics before and after a real compilation: Cargo reporting `Fresh` does
not prove an `sccache` hit. Exercise the required runtime when execution is part
of the task, and report what ran natively or under emulation.

Report artifact paths, cache identities and limits, verification, and retained
state. Removing a container does not remove named volumes. Cleanup of existing
caches, volumes, workspaces, or benchmark evidence requires the user's approval.
