---
name: rust-build
description: Rust compilation caches. Use when configuring, diagnosing, or sharing sccache, shared target directories, or container and CI cache reuse, or when reducing Rust build storage across workspaces or runners.
---

# Rust compilation caches

Follow `managing-workspaces` for workspace and build-lane lifecycle, when available.
For targets and runtimes, follow the repository's instructions; a successful
cross-compile does not prove runtime compatibility.

## Incremental compilation and sccache

sccache cannot cache an incrementally compiled rustc invocation. Cargo compiles
incrementally only workspace members and path dependencies, so with incremental
left on, sccache still caches eligible registry and Git dependencies.

Keep incremental compilation for normal development. Set `CARGO_INCREMENTAL=0`
when you deliberately want sccache to cache workspace and path crates, such as
disposable builders or reuse across workspaces, after measuring that it beats
incremental rebuilds for the workload.

## The sccache server

- One server owns a local disk store at a time; concurrent servers on one
  `SCCACHE_DIR` race and fail builds. When separate daemons (containers, runners)
  would share a store, hold one lock beside the store for each daemon's whole
  lifetime, give each daemon its own bounded store, or use a shared backend.
- The server reads its configuration at startup. Changing a client's environment
  leaves an already-running server unchanged; restart it with
  `sccache --stop-server`, then confirm cache location and size in
  `sccache --show-stats`.
- `SCCACHE_CACHE_SIZE` (default 10 GiB) bounds only the sccache store; target
  directories, package downloads, and Docker build cache grow separately.

## What sccache reuses

- Crates that invoke the linker (`bin`, `dylib`, `cdylib`, `proc-macro`) are
  never cached; their library dependencies can be.
- Absolute paths enter Rust cache keys, so workspace crates built from different
  checkout paths miss. Build from a stable path when cross-workspace hits matter.
  As of sccache 0.18, `SCCACHE_BASEDIRS` normalizes C and C++ paths, not Rust.
- Procedural macros that read files may not be cached correctly.

## Verify hits

Cargo reporting `Fresh` means rustc never ran, so sccache saw nothing. Read
`sccache --show-stats` before and after a build that really compiles, such as a
fresh target directory with otherwise identical inputs, and report hits, misses,
and non-cacheable reasons. Zero statistics only on a server your task owns.

## Shared target directories

Cargo decides freshness mainly from file timestamps. Restored or copied sources
with old timestamps can make a reused target directory look up to date against
changed code; use a fresh target directory unless the source snapshot provably
matches. Cargo serializes builds on one target directory, so copy each task's
artifacts out before the next build overwrites them.

## Containers and CI

Host cache settings (environment, Cargo config, a running sccache server) do not
reach a container or runner; configure the wrapper and cache inside it. Mount only
`$CARGO_HOME/registry` and `$CARGO_HOME/git` into a builder; the rest of the host's
Cargo home holds host binaries, configuration, and credentials. For Docker
builders, read [Linux Docker builds](references/docker-linux.md).

When the task needs reproducibility, record `rustc -Vv`, `sccache --version`, the
image digest, and the lockfile used. Ask before pruning existing caches, volumes,
or target directories.

## Sources

- [Cargo profiles: incremental](https://doc.rust-lang.org/cargo/reference/profiles.html#incremental)
- [Cargo FAQ: why is Cargo rebuilding](https://doc.rust-lang.org/cargo/faq.html#why-is-cargo-rebuilding-my-code)
- [sccache Rust caveats](https://github.com/mozilla/sccache/blob/main/docs/Rust.md)
- [sccache local storage](https://github.com/mozilla/sccache/blob/main/docs/Local.md)
- [sccache configuration](https://github.com/mozilla/sccache/blob/main/docs/Configuration.md)
