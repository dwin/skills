# Isolation

## Rift blockers

Rift snapshots a regular Git checkout. It refuses three kinds of source:

- **A linked worktree.** Create the Rift from the repository's regular
  checkout instead.
- **A checkout with an active Git operation or lock file**, such as a rebase,
  merge, cherry-pick, bisect, or a leftover `index.lock`. That state belongs to
  whoever started it. Leave it in place and use another source.
- **A checkout containing a FIFO.** Secret managers can serve `.env` as a named
  pipe, and the snapshot fails or hangs on it. Find pipes with
  `find <source> -type p -not -path '*/.git/*'`.

A clean seed checkout avoids all three.

## Seed checkouts

A **seed** is a regular clone kept only as a Rift source: on the default
branch, with no local edits, FIFOs, or running work. Before creating a Rift,
`git fetch` in the seed. Fetching updates remote refs without touching anyone's
files. Then create the Rift and, inside it, branch from the fetched base:

```bash
git switch -c <task-branch> origin/<base>
```

Unless the user explicitly requests a snapshot of the current workspace, use a
clean seed rather than a checkout carrying someone's work. For a requested
current-state snapshot, use the specified checkout and record its staged,
unstaged, and untracked changes; keep inherited changes out of task commits.
If that source has a Rift blocker, report it and ask before using a source that
omits the requested state.

## Fallbacks

- **Git worktree.** Run `git worktree add -b <task-branch> <path> <base>` from a
  regular checkout. Worktrees share the repository's objects and refs, so a
  branch checked out in one cannot be checked out in another. A worktree
  cannot serve as a later Rift source.
- **Fresh clone.** Use `git clone` into a task-named directory, such as one
  under `/tmp`. Install dependencies with the repository's normal setup.

State which fallback was used and why Rift was not.
