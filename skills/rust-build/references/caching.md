# Cargo and compiler caches

## Choose the cache for the workload

Cargo's package downloads, build output, incremental state, and `sccache` entries
have different lifecycles. Inspect the repository's existing setup before adding
another store. A compiler cache still materializes output and needs temporary disk
headroom; its cap does not bound target trees or package downloads.

- Reuse supported Cargo registry and Git dependency caches. Share these stores
  without copying platform-specific toolchains, executables, or credentials into
  a different build environment.
- For repeated edits in one workspace, preserve the configured incremental build
  workflow unless the task calls for a change. Incremental compilation and shared
  compiler caching solve different reuse problems; measure before switching.
- For reuse across workspaces or disposable builders, prefer compatible `sccache`.
  Disable incremental compilation for that build and retain independent outputs
  when correctness or concurrency requires them.
- If reusing a writable target directory, scope it by repository, toolchain, host
  and target compatibility. Coordinate writers and preserve each task's final
  artifacts. Restored source timestamps can make Cargo consider a changed snapshot
  up to date; use a fresh target when source identity cannot be proved safe.

Use Cargo's supported output-directory settings rather than symlinking one
workspace's writable build tree into another. Distinguish final artifacts from
intermediate build output when the repository's Cargo version supports separate
locations; check the pinned version before adopting newer settings.

## Configure sccache in the build environment

Check the installed version and its Rust support. Use a compatible executable
on the build host; the artifact target may be different. Inspect Cargo's resolved
configuration, environment overrides, and existing wrappers before selecting
`RUSTC_WRAPPER` or `build.rustc-wrapper`. Apply changes at task or runner scope
unless persistent configuration is requested.

Set `CARGO_INCREMENTAL=0` for the chosen cacheable build. Set `SCCACHE_DIR` or use
the platform's default cache location, and set an explicit `SCCACHE_CACHE_SIZE`
suited to available storage. Check the owning daemon's effective configuration;
changing a client's environment does not prove an already-running server adopted it.

A local disk store supports one owning sccache server at a time. Clients may use
that server, but independent daemons must not concurrently write the same store.
For containers or runners with separate daemons, hold one common build lock until
the daemon exits, use independent bounded stores, or use a supported shared backend.
Separate locks in individual task directories do not coordinate a common cache.

Cache keys include build inputs and paths. Different workspace paths, compiler
versions, flags, or dependency inputs can produce misses. Verify reuse for the
actual workload rather than forcing path normalization or relaxing correctness
checks to manufacture hits.

## Verify cache behavior

Capture `rustc -Vv`, `cargo --version`, `sccache --version`, and statistics around
the requested command. For a cache probe, compile a cacheable library twice with
fresh disposable target directories and otherwise matching inputs. Keep probe
output separate from retained artifacts. Inspect hits, misses, errors, and
non-cacheable reasons; do not reset shared daemon statistics during another task.

Rust incremental compilation prevents sccache reuse. Crates that invoke the system
linker, including executables and procedural macros, are not cached; their library
dependencies can still benefit. A metadata-only `cargo check` is not equivalent
to a cacheable library build. Procedural macros that read external files need
particular care because their inputs may not be tracked correctly.

Validate artifacts and tests even when compilation hits the cache. Preserve the
benchmark's required cache conditions; a deliberately cold run should remain cold.
Request approval before pruning existing storage or running `cargo clean` on a
retained build tree.

## Sources

- [Cargo build cache](https://doc.rust-lang.org/cargo/reference/build-cache.html)
- [Cargo configuration and precedence](https://doc.rust-lang.org/cargo/reference/config.html)
- [Cargo profiles and incremental compilation](https://doc.rust-lang.org/cargo/reference/profiles.html)
- [sccache Rust limitations](https://github.com/mozilla/sccache/blob/main/docs/Rust.md)
- [sccache local storage](https://github.com/mozilla/sccache/blob/main/docs/Local.md)
