# Linux Docker builds

## Select a compatible builder

Use the repository's pinned Rust toolchain and required Linux architecture.
On macOS ARM, `--platform linux/arm64` runs on the Linux VM without CPU emulation.
A Linux AMD64 target is a separate compatibility decision, not a default.

Inspect an existing builder before creating another image. It must contain a
Linux `sccache` executable and the requested Rust toolchain. Record the resolved
image digest; a mutable tag alone is insufficient provenance.

[assets/Dockerfile.sccache](../assets/Dockerfile.sccache) is a builder example for
official Debian-based Rust images. It installs checksum-verified Linux sccache
0.18.0 for ARM64 or AMD64, sets the wrapper, disables incremental compilation,
and caps the compiler cache at 10 GiB. Pass the repository's verified image digest
through the required `RUST_IMAGE` build argument.

Build it using the directory containing the asset as the small build context:

```bash
docker build --platform linux/arm64 \
  --build-arg "RUST_IMAGE=${RUST_IMAGE:?Set a verified Rust image digest}" \
  -f "$SKILL_DIR/assets/Dockerfile.sccache" \
  -t "$BUILDER_IMAGE" "$SKILL_DIR/assets"
```

Resolve these variables to explicit values before execution. Do not mount the
host's entire Cargo home over the builder's toolchain or copy a macOS wrapper
path into its Cargo configuration. Mount only supported package-cache directories
and pass container-side settings deliberately.

## Reuse caches without accumulating target volumes

Inspect the volume or BuildKit cache inventory. Reuse compatible existing Cargo
registry and sccache stores. Stable identities such as
`<repo>-cargo-linux-arm64` and `<repo>-sccache-linux-arm64` are examples, not
permission to create duplicates when an equivalent cache already exists.
Labels should identify the owner, purpose, platform, and toolchain compatibility.

For `docker run` builders:

- Mount the source read-only at a stable container path when the command allows it.
- Use `--locked` when the repository supplies `Cargo.lock`. If it intentionally
  omits a lockfile, follow its dependency-resolution policy and build in a
  disposable writable source copy so Cargo can create one. Preserve the resolved
  lockfile with the task's build provenance.
- Keep registry data separate from Cargo's executable and configuration paths.
- Mount the bounded compiler cache at the builder's configured `SCCACHE_DIR`.
- Use a fresh target directory in the disposable builder filesystem when reuse
  could select stale outputs from a different snapshot.
- Copy only required executables or other final artifacts into the task's output
  directory before the disposable container exits.
- When that disposable lifecycle is authorized, `--rm` removes the container and
  its writable layer. Named cache volumes remain and are reused by later runs.

This avoids a permanent target volume per task. Fresh target trees still need
temporary disk headroom, and `sccache` does not cache final executable linking.
An ephemeral target tree is not a substitute for retained runtime evidence.

For Dockerfile builds, prefer stable BuildKit cache-mount IDs for registry and
compiler data, with `sharing=locked` when access must be serialized. Keep final
artifacts outside the mount before copying them into the runtime image. BuildKit
storage has its own lifecycle; a compiler-cache cap does not bound all image,
layer, or build-cache storage.

## Coordinate the local sccache store

One shared local disk cache supports one owning sccache daemon at a time.
Several independent container daemons must not write the same cache concurrently.

Use one common build lock shared by every runner using that store. Keep it held
until the owning container and its daemon have exited. A separate lock inside
each task directory does not coordinate different tasks. If parallel builders
are required, use an appropriate supported shared backend or independent bounded
stores and report the resulting storage cost.

A writable target directory also requires coordination. Serial execution alone
does not prove that Cargo's fingerprints remain correct when snapshots with old
timestamps are mounted at the same source path.

## Verify the Linux path

Record `uname -m`, `rustc -Vv`, `cargo --version`, and `sccache --version`
inside the builder. Inspect statistics before and after compiling a cacheable
library with a fresh target directory, then repeat with another fresh target.

Verify a hit rather than merely a successful build or Cargo's `Fresh` message.
For cross-workspace evidence, distinguish shared package dependencies from
workspace crates whose paths enter the Rust cache key. Run the resulting Linux
binary or test in the required container environment.

Before a large replay or benchmark, estimate peak journal and target storage,
check free space, and decide what evidence must be retained. Preserve Linux-local
block storage when it is part of qualification. A host bind mount can change
filesystem semantics and timing.

## Sources

- [Cargo build cache](https://doc.rust-lang.org/cargo/reference/build-cache.html)
- [sccache Rust limitations](https://github.com/mozilla/sccache/blob/main/docs/Rust.md)
- [sccache local storage and concurrency](https://github.com/mozilla/sccache/blob/main/docs/Local.md)
- [BuildKit cache mounts](https://docs.docker.com/reference/dockerfile/#run---mounttypecache)
