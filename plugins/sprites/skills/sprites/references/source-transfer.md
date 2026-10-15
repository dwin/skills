# Source transfer

Choose one direction for a run. Keep the local checkout authoritative for a local edit/build loop, or keep the remote checkout authoritative when editing over SSHFS.

## Committed source

Choose the configured GitHub access method first. For native Git authentication, inspect `gh auth status` when applicable without printing token values, verify repository access, then clone or fetch. If a Sprites gateway is configured, follow [GitHub gateway](github-gateway.md); ordinary `gh` or Git login may be unnecessary. Fetch or retrieve the requested commit and verify its identity. Use a task-specific checkout; preserve any existing dirty checkout.

## Local edits

A remote clone omits local edits. Record local `git status --short`, HEAD, and staged/unstaged diffs before transfer. Include submodule revisions, Git LFS objects, and relevant untracked files when the task uses them. Freeze local edits while capturing the snapshot. If that is impractical, record HEAD and status before and after capture, regenerate the tracked patch and selected-untracked manifest with content hashes, and compare their hashes; restart the capture when any input changed.

For a tracked-source snapshot, create an archive of HEAD and a binary patch:

```bash
git archive --format=tar HEAD > /task/evidence/source.tar
git diff --binary HEAD > /task/evidence/working.patch
```

These files represent tracked working-tree content, not the staging boundary. Record `git diff --cached --binary` separately when index state matters. Package selected untracked files explicitly after checking for secrets, and create a manifest containing each selected path and SHA-256 hash. Do not archive ignored credentials, dependencies, host build outputs, or the entire home directory.

Hash the source archive, working patch, untracked bundle and manifest locally. Upload them with the installed `sprite file` CLI or `sprite exec --file <local>:<remote>`, then verify the same hashes remotely. Reconstruct the source in a new task checkout at the recorded HEAD, apply the patch, and unpack only the selected untracked files; check every command's result. Compare the reconstructed `git status --short`, patch, untracked manifest, and content hashes with the captured evidence before building. A source archive lacks Git metadata, so retain the checkout when the build uses Git-derived version information. Transfer submodule contents and LFS objects through their supported Git workflows.

For a directory tree or larger artifact, inspect `sprite file --help` and its subcommands rather than guessing cp direction or recursive syntax. Streaming tar over stdin is another option; use `set -o pipefail` locally and omit `--no-stdin`.

## Results

Keep source archives and manifests beside build logs on the remote side. Record SHA-256 hashes before and after downloading important artifacts. Return a patch or named commits for remote source edits and review them locally before applying. Never copy a remote .git directory over an existing local repository.
