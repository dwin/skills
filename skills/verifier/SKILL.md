---
name: verifier
description: 'Create a project-local skill that proves changes by driving the real app the way a user does, or bring an existing one back in line with the code. Use for "make a verify skill for this repo" or "audit the verify skill".'
disable-model-invocation: true
---

# Verifier

A **verification skill** lives in a project and tells the next agent how to
prove a change works there: launch the app, drive a feature the way a user
does, capture evidence, and clean up. It carries a **feature map**, one file
per user-facing feature, each with the exact steps that prove the feature
works.

This skill writes one for a project, or brings an existing one back in line
with the code. It covers runtime verification. To prove a property for every
case with a model checker or a verifier, use the
[formal verification playbook](../whats-next/playbooks/formal-verification.md).

## Choose the mode

- **Create**, when the project has no verification skill: read
  [references/create.md](references/create.md).
- **Maintain**, when it has one: read
  [references/maintain.md](references/maintain.md). A verification skill is a
  project skill with launch and drive steps and a feature map. When there are
  several, ask which one.

When the user asks for a new one and one already exists, say so, and maintain
it unless they want a second one for a different surface.

## Rules for both modes

- **Ground every line in this project.** Commands, ports, paths, selectors,
  and prompt strings come from the code and docs you read, and each one ran in
  this session. No placeholder survives.
- **Write for an agent reading cold**, by `writing-for-agents`. The generated
  skill is one the agent picks up on its own, so its description names the
  app, the surface, and when to reach for it.
- **Hold the proof standards**, and write them into the generated skill:
  - drive the real user path, not internal setters or test-only endpoints;
  - capture the action and the state it leaves, not only the final screen;
  - check side effects, such as files written, rows stored, and messages
    sent, alongside what the user sees;
  - mock only where a production boundary already isolates an outside system;
  - when the safe path is a dry run or a test mode, observe what it actually
    skips, such as files, network calls, and Git refs, rather than trusting
    its name.
- **Show it catching a broken change.** Before hand-off, break the behavior a
  feature file proves, in a disposable copy, and watch that feature's steps
  fail with evidence of the failure. A check never seen to fail proves
  nothing.
- **Clean up what you started, and keep the evidence.** Stop processes by the
  id you started, never by name. Evidence survives every cleanup, at a
  location the skill names.

## Where the skill lives

Put it where the project already keeps skills. In a project with none, use
`.agents/skills/verify-<app>/`, and when the project also uses Claude Code,
link `.claude/skills/verify-<app>` to it. Deliver it the way the project takes
changes: as a commit, or as a pull request through `file-pr` when the user
wants one.

## Report

- **Create:** the skill's path, the features mapped, the proof run with its
  commands and evidence paths, the result of the broken-change run, and any
  step that is unverified because the proof ran in a stand-in for the real
  target.
- **Maintain:** the outcome, the features covered from source and live, the
  drift fixed, the harness gaps fixed, the product bugs found for the user,
  and the change shipped, if any.
