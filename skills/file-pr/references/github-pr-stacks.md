# GitHub PR stacks

Use this guide for GitHub's native stacked pull requests, which are in public
preview and subject to change. A stack is an ordered chain of two or more pull
requests in one repository: the bottom PR targets the trunk branch, and each PR
above it targets the branch immediately below it. Each PR should expose only
its layer's focused diff.

## Decide whether to stack

Use a stack when all of these are true:

- The change naturally decomposes into two or more focused review units.
- Each upper unit genuinely depends on a lower unit.
- Review or development should proceed before the lower units merge.
- All branches can live in the same repository.
- The team accepts the operational cost of maintaining and reviewing the whole
  dependency chain.

Prefer a standalone PR or independent PRs when the changes do not depend on one
another, the change is already one reviewable unit, contributors must work from
forks, the dependency graph branches instead of forming a line, or the
repository's tools are not ready for native stacks. GitHub Desktop and
auto-merge do not support stacks. Programmatic merge tooling must use GitHub's
asynchronous stack-aware merge endpoint rather than the legacy merge endpoint.

Keep the stack modest. Every layer runs the base branch's rules and CI, and a
change low in the stack can rebase and retrigger checks above it. Audit costly
CI and merge automation before using stacks broadly.

## Design the layers

Plan from trunk upward. Put foundations such as schemas, shared types, and core
behavior in lower layers; put code that consumes them in higher layers. A
dependency must be in the same layer or a lower one. Each layer may contain one
or more commits, but it must remain a coherent unit that can be reviewed and
validated on its own.

Record the plan before changing remote state:

```text
feature-ui   -> PR 3 (base: feature-api)  <- top
feature-api  -> PR 2 (base: feature-core)
feature-core -> PR 1 (base: main)         <- bottom
main                                        trunk
```

## Create or link the stack

Use GitHub CLI 2.90.0 or later, Git 2.20 or later, and the official
`github/gh-stack` extension. Do not install or upgrade tools without the user's
permission when the required versions are not already available.

For a new locally tracked stack:

```bash
gh stack init --base <trunk> <bottom-branch>
# Commit the bottom layer.
gh stack add <next-branch>
# Commit the next layer; repeat as needed.
gh stack submit
```

`gh stack submit` pushes the branches, creates or updates a PR for each branch,
and links them into a native stack. Its interactive editor lets you set each
title, body, and draft state. In non-interactive `--auto` mode, new PRs default
to draft unless `--open` is supplied.

To adopt an existing linear chain, pass all branches in bottom-to-top order to
`gh stack init`. To link existing branches or PRs without local stack tracking,
use `gh stack link --base <trunk> <bottom> ... <top>`. Linking may push branches,
create missing PRs, and correct their base branches, so inspect the chain first.

Do not create each layer separately with `gh pr create` and stop there. The base
branches may look stacked, but `gh stack submit` or `gh stack link` is what links
the PRs into GitHub's native stack.

On github.com, create the bottom PR against the trunk first. Create the next PR
against the previous PR's head branch, then choose **Create stack** instead of
creating a standalone PR. Add further layers from **Add to stack**; website-added
layers always go on top.

## Maintain and verify the stack

Put review fixes in the layer where they logically belong. After changing a
lower layer, cascade it upward and push the updated branches:

```bash
gh stack checkout <branch>
# Make and commit the fix.
gh stack rebase --upstack
gh stack push
```

After lower PRs merge, synchronize local state with `gh stack sync`; use
`--prune` only when deleting merged local branches is intended. A stack must be
linear before merge. Server-side rebases force-push rewritten branches and do
not create signed commits, so use the CLI rebase path when signed commits are
required.

Verify all of the following after submit or update:

- The stack map lists every intended PR exactly once and in the right order.
- The bottom PR targets the intended trunk and each upper PR targets the layer
  below it.
- Each PR diff contains only its layer and has an accurate title, body, and
  draft state.
- Required reviews, CODEOWNERS, and CI apply to every layer as expected.
- No branch, PR, or unrelated change was accidentally added to the stack.

Request review from the bottom upward. Never merge as part of filing or updating
a stack unless explicitly asked. Merging a selected PR merges it and every
unmerged PR below it. An unexpected failure can stop a stack merge after lower
layers have landed, so verify every PR afterward. With a merge queue, selected
PRs keep their order but may land in separate groups. Upper layers remain open
and are retargeted when only part of the stack lands. Closing a mid-stack PR
blocks every PR above it.

## Primary sources

- [About stacked pull requests](https://docs.github.com/en/pull-requests/get-started/about-stacked-prs)
- [Creating stacked pull requests](https://docs.github.com/en/pull-requests/how-tos/create-pull-requests/creating-stacked-pull-requests)
- [Managing stacked pull requests](https://docs.github.com/en/pull-requests/how-tos/create-pull-requests/managing-stacked-pull-requests)
- [Merging stacked pull requests](https://docs.github.com/en/pull-requests/how-tos/merge-and-close-pull-requests/merging-stacked-pull-requests)
- [Troubleshooting stacked pull requests](https://docs.github.com/en/pull-requests/how-tos/merge-and-close-pull-requests/troubleshooting-stacked-pull-requests)
- [Stacked pull requests CLI commands](https://docs.github.com/en/pull-requests/reference/stacked-prs-cli-commands)
- [GitHub stacked pull requests public preview](https://github.blog/changelog/2026-07-30-stacked-pull-requests-are-now-in-public-preview/)
