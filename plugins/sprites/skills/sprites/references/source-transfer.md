# Source transfer

Choose one direction for a run. Keep the local checkout authoritative for a local edit/build loop, or keep the remote checkout authoritative when editing over SSHFS.

## Committed source

Start from a Git checkout at the exact commit, in a new task-specific directory; preserve any existing dirty checkout. In order of preference:

1. **Fetch.** Clone or fetch through native Git access (inspect `gh auth status` when applicable, without printing token values) or through a Sprites connector already verified to serve Git (see [GitHub gateway](github-gateway.md)). Check out the recorded SHA detached.
2. **Bundle.** When the Sprite cannot fetch, create a bundle locally with `git bundle create /task/evidence/source.bundle HEAD` and check it with `git bundle verify /task/evidence/source.bundle`. Remotely, `git clone` the bundle and check out the recorded SHA detached. A bundle carries the history reachable from HEAD, so it is part of the outgoing payload below.
3. **Archive.** Use `git archive` only when Git transfer is unavailable. It applies `export-ignore` and `export-subst`, which drop or rewrite tracked files, and so do GitHub tarball endpoints. Check the attributes of the archived commit itself, directories included: `git ls-tree -r -t -z --name-only <sha> | git check-attr -z --stdin --source=<sha> export-ignore export-subst`. When either attribute is `set` on any path, the archive no longer equals the commit, so pick a Git transfer or record the affected paths and report source coverage as partial. An archive also lacks Git metadata that builds may read for version information. It has no `.git`, so the HEAD check and the source tree ID below do not apply: verify the archive by its SHA-256 hash on both sides, and report the source as archive-based.

Confirm `git rev-parse HEAD` equals the recorded SHA before building. Transfer submodule contents and LFS objects through their supported Git workflows.

## Local edits

A remote checkout omits local edits. Record HEAD, `git status --short`, and the submodule and LFS state the task uses. The parent's patch and tree ID record only each submodule's commit, so a submodule with local edits needs its own capture, transfer, and verification in its own checkout, using the steps below; when that is not practical, stop and report it. Capture the edits as:

- **Working patch:** `git diff --binary --no-ext-diff --no-textconv --src-prefix=a/ --dst-prefix=b/ HEAD > /task/evidence/working.patch`, covering staged and unstaged tracked changes together.
- **Untracked files:** only the ones the task needs, packaged explicitly with a manifest of path and SHA-256 hash. Exclude ignored credentials, dependencies, host build outputs, and home directories.

**Source tree ID.** The tree ID is the comparison key for working-tree content and file modes. First record the changed paths, staged additions and deletions included, plus the selected untracked files, in a path list that travels with the payload:

```bash
untracked=(<selected-untracked-paths...>)
{ git diff -z --name-only --no-renames HEAD
  if ((${#untracked[@]})); then printf '%s\0' "${untracked[@]}"; fi
} > /task/evidence/paths.nul
```

Then compute the tree ID with a temporary index, which leaves the real index untouched and writes only loose objects. Use the same path list on both sides; an empty list means HEAD's tree. `git update-index` takes each path literally, records it whether or not ignore rules match it, and does not descend into directories:

```bash
(
  idx=$(mktemp) || exit
  trap 'rm -f "$idx"' EXIT
  GIT_INDEX_FILE="$idx" git read-tree HEAD &&
    GIT_INDEX_FILE="$idx" git update-index --add --remove -z --stdin \
      < /task/evidence/paths.nul &&
    GIT_INDEX_FILE="$idx" git write-tree
)
```

Freeze local edits while capturing. Record the source tree ID before and after capture, and restart the capture when they differ.

**Secret check.** Before any upload, scan the entire outgoing payload for credentials: the bundle or archive tree, every line of the working patch (added, removed, and context lines), and every selected untracked file. Use the repository's configured secret scanner when it has one. Report a finding by path and line, keeping the value out of logs and reports, and stop for the user's decision. When a file or hunk is excluded to resolve a finding, record the exclusion and report source coverage as partial; the source tree ID will then differ by design.

**Upload and verify.** Hash every payload file locally, upload with `sprite file` or `sprite exec --file <local>:<remote>`, and verify the same hashes remotely. In the fresh checkout at HEAD, run `git apply --binary` with the working patch (skip it when the file is empty, since `git apply` rejects an empty patch), unpack the selected untracked files, and check every command's result. Compute the source tree ID remotely with the uploaded path list and compare it with the local one before building. `git ls-tree -r` on both IDs shows which paths differ. `git status --short` differs legitimately here: the patch lands staged changes as unstaged.

**Index fidelity.** When the staging boundary matters to the task, capture `git diff --cached --binary --no-ext-diff --no-textconv --src-prefix=a/ --dst-prefix=b/` and `git diff --binary --no-ext-diff --no-textconv --src-prefix=a/ --dst-prefix=b/` instead of the single working patch. Apply the first with `git apply --index --binary` and the second with `git apply --binary`, skipping either one when it is empty, then also compare `git write-tree` of the real index on both sides.

For a directory tree or larger artifact, inspect `sprite file --help` and its subcommands rather than guessing copy direction or recursive syntax. Streaming tar over stdin is another option; use `set -o pipefail` locally and omit `--no-stdin`.

## Results

Keep bundles, archives, and manifests beside build logs on the remote side. Record SHA-256 hashes before and after downloading important artifacts. Return a patch or named commits for remote source edits and review them locally before applying. Never copy a remote .git directory over an existing local repository.
