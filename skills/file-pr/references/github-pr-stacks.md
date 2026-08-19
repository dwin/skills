# GitHub PR stacks

GitHub's native stacked pull requests are in public preview. A stack is a chain
of two or more PRs in one repository: the bottom PR targets the trunk, and each
PR above targets the branch below it. Each PR shows only its layer's diff.

## Decide whether to stack

Use a stack when all of these are true:

- The work splits into two or more focused review units.
- Each upper unit depends on a lower unit.
- Review or development should proceed before the lower units merge.
- All branches can live in the same repository.
- The team's review, CI, and merge workflows support stacks.

Prefer a standalone PR for one reviewable unit and independent PRs for unrelated
work. Do not stack fork-based work, branching dependency graphs, or repositories
that rely on GitHub Desktop, auto-merge, or the legacy merge endpoint.
Programmatic merges require GitHub's asynchronous stack-aware endpoint.

Keep the stack modest. Every layer runs the base branch's rules and CI, and a
change low in the stack can rebase and retrigger checks above it. Audit costly
CI and merge automation before using stacks broadly.

## Design the layers

Plan from trunk upward. Put foundations such as schemas and shared types below
the code that consumes them. Dependencies must be in the same or a lower layer.
Each layer may contain multiple commits but must remain independently reviewable.

Record the plan before changing remote state:

```text
feature-ui   -> PR 3 (base: feature-api)  <- top
feature-api  -> PR 2 (base: feature-core)
feature-core -> PR 1 (base: main)         <- bottom
main                                        trunk
```

## Create or link the stack

Use GitHub CLI 2.90.0+, Git 2.20+, and the official `github/gh-stack` extension.
Get permission before installing or upgrading tools.

For a new locally tracked stack:

```bash
gh stack init --base <trunk> <bottom-branch>
# Commit the bottom layer.
gh stack add <next-branch>
# Commit the next layer; repeat as needed.
gh stack submit
```

`gh stack submit` pushes the branches, creates or updates their PRs, and links
the native stack. Its editor sets each title, body, and draft state. With
non-interactive `--auto`, new PRs are drafts unless `--open` is supplied.

Adopt an existing linear chain by passing its branches bottom-to-top to
`gh stack init`. To link without local tracking, use
`gh stack link --base <trunk> <bottom> ... <top>`. Inspect first: linking can push
branches, create PRs, and correct base branches.

Base-linked PRs alone are not a native stack; link them with `gh stack submit`
or `gh stack link`.

On github.com, create the bottom PR against the trunk. Create the next against
the previous PR's head branch and choose **Create stack**. Add more through
**Add to stack**; the web UI always adds them at the top.

## Maintain and verify the stack

Put review fixes in their owning layer. Cascading a lower-layer change rebases
and force-pushes upper branches, so run this only with explicit permission to
rewrite their history:

```bash
gh stack checkout <branch>
# Make and commit the fix.
gh stack rebase --upstack
gh stack push
```

Without permission, report the needed rebase and stop. After lower PRs merge,
run `gh stack sync`; add `--prune` only when deleting merged local branches is
intended. Server-side rebases also force-push and create unsigned commits. Use
the CLI when signed commits are required. The stack must be linear before merge.

Verify all of the following after submit or update:

- The stack map contains each intended PR once, in order.
- The bottom PR targets the trunk; each upper PR targets the layer below.
- Each diff, title, body, and draft state is correct for its layer.
- Reviews, CODEOWNERS, and CI apply as expected, with no unrelated changes.

Request review bottom-up. Merge only when explicitly asked: selecting a PR also
merges every unmerged layer below it. Failures can stop after lower layers land,
so verify every PR. Merge queues preserve order but may land separate groups.
Upper layers remain open and retarget after a partial merge. Closing a mid-stack
PR blocks every layer above it.

## Primary sources

- [About stacked pull requests](https://docs.github.com/en/pull-requests/get-started/about-stacked-prs)
- [Creating stacked pull requests](https://docs.github.com/en/pull-requests/how-tos/create-pull-requests/creating-stacked-pull-requests)
- [Managing stacked pull requests](https://docs.github.com/en/pull-requests/how-tos/create-pull-requests/managing-stacked-pull-requests)
- [Merging stacked pull requests](https://docs.github.com/en/pull-requests/how-tos/merge-and-close-pull-requests/merging-stacked-pull-requests)
- [Troubleshooting stacked pull requests](https://docs.github.com/en/pull-requests/how-tos/merge-and-close-pull-requests/troubleshooting-stacked-pull-requests)
- [Stacked pull requests CLI commands](https://docs.github.com/en/pull-requests/reference/stacked-prs-cli-commands)
- [GitHub stacked pull requests public preview](https://github.blog/changelog/2026-07-30-stacked-pull-requests-are-now-in-public-preview/)
