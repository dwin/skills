---
name: handoff
description: Compact the current conversation into a handoff document for another agent to pick up.
argument-hint: "What will the next session be used for?"
disable-model-invocation: true
---

Write a handoff document summarising the current conversation so a fresh agent can continue the work. Save to the temporary directory of the user's OS - not the current workspace.

Include a "suggested skills" section in the document, which suggests skills that the agent should invoke.

Capture the state needed to resume without repeating decisions:

- The active objective, acceptance criteria, and next executable step.
- Repository and worktree paths, branch, head SHA, PR links, and local changes.
- Decisions and permissions already given, their scope, and explicit holds or
  actions still awaiting approval.
- Completed validation with its revision and environment; distinguish local
  checks, remote CI, deployment, and runtime evidence.
- Outstanding findings, dependencies, owners, and any running monitor or review
  that the next session must reattach to or replace.

Label observations with their time or revision. Tell the receiving agent which
mutable state to refresh before acting, especially the PR head, remote checks,
worktree changes, and coordinator ownership. A handoff preserves the task and
its authorization; it does not make old observations current.

Do not duplicate content already captured in other artifacts (specs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.

Redact any sensitive information, such as API keys, passwords, or personally identifiable information.

If the user passed arguments, treat them as a description of what the next session will focus on and tailor the doc accordingly.
