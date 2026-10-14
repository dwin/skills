# Platforms and cross-compilation

## Separate host, target, and runtime

Record the compiler host from `rustc -Vv` and the artifact target from the
repository's command or configuration. Preserve the selected target triple,
including its ABI. Choose the build environment from the runtime requirement:
a native toolchain, cross-toolchain, container, remote runner, emulator, or device.

For a cross-target build, check that the pinned toolchain supplies the required
standard library. With rustup, inspect installed targets and add the required
one to that toolchain when needed. This supplies Rust components, not every
linker, SDK, sysroot, or native library required by dependencies.

Inspect `target.<triple>.linker` and any `target.<triple>.runner`. Build scripts
and procedural macros execute on the build host, while native dependencies may
need target-specific compilers and libraries. A successful `cargo build --target`
proves compilation; use the intended runtime or configured runner for execution
and report any remaining validation gap.

## Apply only relevant platform guidance

| Environment                  | Checks                                                                                                                                                                                          |
| ---------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Native Windows               | Match the MSVC or GNU ABI to the repository's toolchain and native dependencies. Use the corresponding linker/SDK and shell-compatible paths. Windows and WSL are different build environments. |
| Native macOS                 | Match the requested CPU architecture, SDK, and deployment requirements. Use a Linux runtime when the task requires Linux behavior.                                                              |
| Native Linux                 | Match architecture, libc/ABI, system libraries, and runtime requirements. GNU and musl targets are separate compatibility choices.                                                              |
| Linux container or CI runner | Select the required platform and toolchain in the runner. Configure its own wrappers and caches; read [Linux Docker builds](docker-linux.md) for Docker.                                        |
| Other targets                | Consult the target's Rust support and repository instructions for its linker, SDK, standard-library availability, and test runner or device.                                                    |

When the runtime architecture differs from the host, choose native remote execution
or an explicit emulator as the task requires. Record emulation in performance
evidence. For portable artifacts, validate against the intended deployment
platform and minimum requirements rather than relying on the builder's environment.

Use the executable suffixes, path conventions, and environment-variable syntax
of the active shell. A wrapper must run on the build host; a target executable
need not be runnable there. Reuse platform-compatible caches through Cargo and
sccache instead of copying another platform's writable target tree.

## Sources

- [Rust target support](https://doc.rust-lang.org/rustc/platform-support.html)
- [rustup cross-compilation](https://rust-lang.github.io/rustup/cross-compilation.html)
- [Cargo target configuration](https://doc.rust-lang.org/cargo/reference/config.html#target)
- [Cargo build target selection](https://doc.rust-lang.org/cargo/commands/cargo-build.html)
