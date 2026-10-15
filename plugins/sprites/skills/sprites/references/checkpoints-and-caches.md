# Checkpoints and caches

Use Git commits and verified source archives for code identity. Use Sprite checkpoints for environment rollback. Check `sprite checkpoint --help` and the storage driver before relying on version-specific behavior.

For a new builder, prepare pinned tools and a bounded cache configuration, verify them, then create one named baseline checkpoint before expensive build outputs accumulate. Record its ID and tool versions. Create another checkpoint before an environment change worth rolling back. A checkpoint contains the filesystem, including credentials, caches, and targets; it is not a directory-scoped source snapshot. Copy-on-write history can retain changed cache blocks. Keep checkpoints deliberately and obtain cleanup authorization before pruning. Restore affects the whole Sprite and interrupts other work; inspect read-only checkpoint paths when recovery only needs a file.

On a 100 GB Sprite, start with a 5–10 GiB sccache cap rather than copying a workstation's larger limit. Also budget registry downloads, toolchains, targets, preserved artifacts, and checkpoint history; the sccache cap bounds only its own cache. Estimate peak usage and reserve headroom before building.

One daemon owns each writable local sccache store. Set its environment before starting it; later client environment changes do not reconfigure a running daemon. Configure `RUSTC_WRAPPER=sccache`, `CARGO_INCREMENTAL=0`, `SCCACHE_DIR`, and `SCCACHE_CACHE_SIZE` on Linux. Reuse stable task-owned Cargo target paths across the task's runs. Different target or checkout paths can miss Rust cache entries, including dependencies. Executables and procedural macros still need linking.

To measure reuse, record stats and time a real build, preserve exact binaries, then rebuild with an empty target at the same path and the same inputs while keeping sccache. Renaming a task-owned target aside preserves evidence without deletion, but temporarily doubles target storage. Compare hit/miss deltas and exit codes; Cargo's unchanged-target no-op measures a different behavior. Preserve the requested warm/cold benchmark protocol.

Sources: [Sprite checkpoints](https://docs.fly.io/sprites/concepts/checkpoints), [lifecycle and storage](https://docs.fly.io/sprites/concepts/lifecycle), [sccache local storage](https://github.com/mozilla/sccache/blob/main/docs/Local.md), [Rust limitations](https://github.com/mozilla/sccache/blob/main/docs/Rust.md).
