# Linux Docker builds

## Builder image

Reuse an existing builder that already has a Linux `sccache` and the pinned
toolchain. Otherwise, [assets/Dockerfile.sccache](../assets/Dockerfile.sccache)
extends an official Debian-based Rust image: it installs checksum-verified
sccache 0.18.0 for `linux/arm64` or `linux/amd64`, sets `RUSTC_WRAPPER`, sets
`CARGO_INCREMENTAL=0`, and caps the store at 10 GiB. Pass the repository's Rust
image digest as `RUST_IMAGE` and use the asset directory as the build context:

```bash
docker build --platform "${LINUX_PLATFORM:?linux/arm64 or linux/amd64}" \
  --build-arg "RUST_IMAGE=${RUST_IMAGE:?Rust image digest}" \
  -f "$SKILL_DIR/assets/Dockerfile.sccache" \
  -t "$BUILDER_IMAGE" "$SKILL_DIR/assets"
```

## `docker run` builders

- Reuse existing named volumes for the Cargo registry, Git checkouts, and
  `SCCACHE_DIR` before creating new ones.
- Mount the source at the same container path every run; that path enters the
  cache key.
- Build into a fresh target directory inside the container and copy final
  artifacts out before it exits, so no per-task target volume accumulates.

## BuildKit cache mounts

Cache mounts (`RUN --mount=type=cache,id=...`) persist only in that builder's
local storage. `--cache-to` and `--cache-from` export layer cache, not mount
contents. On ephemeral CI runners, use a persistent builder, an explicit step
that saves and restores the mount contents, or a remote sccache backend.

Mount the sccache directory with `sharing=locked` so only one `RUN` step's server
uses the store, and run `sccache --stop-server` at the end of that step so the
server exits while the lock is held.

## Sources

- [Dockerfile cache mounts](https://docs.docker.com/reference/dockerfile/#run---mounttypecache)
- [Cache mounts on GitHub Actions](https://docs.docker.com/build/ci/github-actions/cache/#cache-mounts)
