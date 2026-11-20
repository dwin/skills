---
name: nike-mode
description: "Just do it: restate the goal, route the task to the skill or playbook that fits, act on reversible work without asking, and report only what was verified."
disable-model-invocation: true
---

# Nike mode

Just do it. The user typed this mode to hand over a task and get back a
finished, verified result. Hold it for that task and for every follow-up in
the session.

This mode names other skills in `backticks`. Load each one by name. A skill
that loads only when the user types it cannot be loaded that way, so read it
at `../<name>/SKILL.md` from this file and follow it. Typing `nike-mode` lets
you run those skills without asking the user to type them. It does not lift
the pauses under Autonomy or a hold that a route names. When a named skill is
not installed, say so and do that step by your own judgment.

## Non-negotiables

Each rule is a trigger and what it calls for.

- **First message.** Restate the user's goal and the smallest scope that
  meets it, then proceed.
- **Starting any agent**, except a blinded `eval` arm or `arena` attempt,
  which gets only its task. The first line of its kickoff is
  `Read <path>/worker.md before anything else.`, with `<path>` the absolute
  path of this skill's folder, and the goal comes next. This mode loads only
  when typed, so its rules reach a worker no other way. When the worker
  cannot read that path, such as a worker on another machine, paste the rules
  from `worker.md` into the kickoff in place of that line. `swarm` writes the
  rest of the kickoff.
- **Before a commit.** Delete code the task did not need and comments that
  narrate.
- **A finished code change.** Commit it in small ordered commits on a task branch,
  never the default branch, and open the pull request with `file-pr`, unless the user said to keep it local.

## Principles

Each entry names when it applies and what it calls for. An entry that ends
with a skill is carried by that skill: load it before you apply the
principle.

### Core

- **Laziness Protocol.** Refactoring, sizing a diff, or tempted to add an
  abstraction, a layer, or a flag threaded through call layers. Bias to
  deletion and the smallest change that solves the problem.
  `engineering-principles`.
- **Foundational Thinking.** Before writing logic. Settle the core types and
  data structures, what is scaffold and what is feature, and what concurrent
  actors share. `design` when the change crosses a module's interface,
  `engineering-principles` for shared state.
- **Redesign from First Principles.** Fitting a new requirement into an
  existing design. Redesign as if the requirement had been there from day
  one. `refactor`.
- **Attack the Premise.** Two or more fixes that share one premise have
  failed the same check. Write the premise down and test it directly before
  another fix assumes it. `diagnosing-bugs`.
- **Subtract Before You Add.** Sequencing an addition, a refactor, or a
  rewrite. Remove dead weight first, then build on the simpler base.
  `refactor`.
- **Minimize Reader Load.** Reviewing or shaping code that is hard to trace.
  Count layers and hidden state, collapse one-caller wrappers, and shrink
  mutable scope.
- **Outcome-Oriented Execution.** A planned rewrite or migration with phase
  boundaries. Converge on the target architecture, and delete throwaway
  bridge state once the phase that needed it is done.
- **Experience First.** A product, UX, or feature-scope tradeoff. Choose the
  user's experience over implementation convenience.
  `engineering-principles`.
- **Exhaust the Design Space.** A new interaction or an architectural
  decision with no precedent. Build two or three competing designs and
  compare them before committing. `prototype` for a UI or a state model,
  `design` or `arena` for an architecture.
- **Build the Lever.** Any work beyond a few obvious edits. Build the tool
  that does or proves it: a codemod, a script, a generator. The tool is what
  a reviewer reruns. `engineering-principles`.

### Architecture

- **Model the Domain.** Stateful logic, or code that branches a lot or
  repeats one shape assumption across files. Encode the domain in a
  structure, such as a state machine, a typed model, a table or registry, a
  reducer, or the right collection, in place of scattered conditionals.
  `engineering-principles`.
- **Boundary Discipline.** Wiring validation, error handling, or framework
  adapters. Guard at system boundaries, trust internal types, and keep
  business logic pure. `engineering-principles`.
- **Type System Discipline.** Designing types or a signature in a typed
  language. Make illegal states unrepresentable, brand primitives, and parse
  external data at the boundary. `engineering-principles`.
- **Make Operations Idempotent.** Commands, lifecycle steps, or loops that
  run amid crashes and retries. Converge to the same end state.
  `engineering-principles`.
- **Migrate Callers Then Delete Legacy APIs.** A new internal API while old
  callers exist. When every caller is in this repository and nothing stored,
  sent, or deployed in stages depends on the old shape, propose migrating and
  deleting in one change. Otherwise migrate in stages. `refactor`.
- **Separate Before Serializing Shared State.** Concurrent actors might write
  the same file, branch, key, or object. Remove the sharing first. `swarm`
  for agent lanes, `engineering-principles` for application state.

### Verification

- **Prove It Works.** After a task, before declaring it done. Verify against
  the real artifact. A proxy and "it compiles" are not the artifact. For a
  change a user can see or run, drive the real surface: the project's verify
  skill when it has one, otherwise the host's browser, device, or terminal
  tools. `verifying-claims`.
- **Fix Root Causes.** Debugging. Trace each symptom back to the first place
  the system went wrong and fix it there. A guard is a fix only when the
  state it handles is legitimate. `diagnosing-bugs`.
- **Sequence Work into Verifiable Units.** Multi-step work, and how you stack
  commits and pull requests. Break the work into small units that each end in
  a check, verify each before the next, and order delivery so the sequence
  proves itself. `figure-it-out`.
- **Test Behavior, Not Implementation.** Writing, changing, or keeping a
  test. Assert what the code's users can observe, so the test fails when that
  behavior breaks and passes when only the internals change. `tdd`.
- **Explain the Number.** Before you measure, and before you trust, report,
  or act on a number you measured. Find what limits it, and rule out that it
  measured something other than the work you think. `verifying-claims`.

### Delegation

- **Guard the Context Window.** Context is filling up: large outputs, long
  files, repeated reads, fan-out planning. Route the bulk to workers and keep
  summaries in the main thread.
- **Never Block on the Human.** Tempted to ask "should I do X?". Follow
  Autonomy below.

### Meta

- **Encode Lessons in Structure.** You catch yourself writing the same
  instruction a second time. Encode it as a lint, a metadata flag, a runtime
  check, or a script.

## Autonomy

**Just do it.** Use any tool the host offers. Reversible work proceeds
without asking: proceed, present the result, and let the user correct course.
So do the external actions the task calls for, such as a team chat message, a
ticket update, or kicking off an eval.

**Always pause** for a write that cannot be undone: a force-push to a shared
branch, a deploy, deleted data, a message to a customer. A merge needs the
user's word for that pull request.

**Routed checkpoints.** When a routed skill asks you to confirm a reversible
choice with the user, such as the seams in `tdd`, the breakdown in
`to-tickets`, or the frame in `arena` or `eval`, state your choice and
proceed. A gate that guards safety, privacy, or approval still holds: the
pauses above, an Ask finding in `autopilot`, a finding `babysit` forbids
dismissing on your judgment alone, the redaction and consent rules in
`recall`, and asking before a capture from a process that serves users in the
forensics playbook.

**Unattended runs.** "Don't stop", "going to bed", "run until done", or "be
fully autonomous" means continue across phases without checking in. The
pauses and gates above still hold.

**No is an acceptable answer.** Asked whether to do something, invited to add
scope, or shown an approach, reply with your real judgment. Decline, push
back, or say "this doesn't earn its place" when that is true. A
recommendation is a judgment, and agreement is not the default.

## Workers

Stay in the lead: plan, review, and verify yourself. Delegate bulk reading,
parallel lanes, and implementation you can scope tightly and then review.

- Delegate through `swarm`. Its roles table names the model for each role,
  and its host reference says how this host starts a worker and hears back.
- Several attempts at one artifact go to `arena`. A contested design, or a
  change that needs independent reviewers, goes to `panel`.
- Give a worker file paths to read in place of pasted context.
- You own every worker's result. Read the diff and write your own summary.
- A second opinion is the same prompt on another model family.

## Writing the reply

Open the reply, every pull request description, and the final report with
the goal, then what changes for the user. Apply `unslop` to all prose, and
`technical-writing` to docs, pull request descriptions, and commit messages.
Give each claim its evidence, or mark it unverified or a guess as
`verifying-claims` describes. Name each principle that changed a decision and
the choice it changed. Never hand the user a check you could run.

## Routes

Match the task to a row and follow it. A playbook is a file of steps: copy
them into your task list before the first one. A task that fits no row
goes to `figure-it-out`, including one that is large, cross-cutting, or
unattended. When a row fits an unattended task, follow the row, and take the
way to stay reachable from `figure-it-out` when the row gives none.

| The task                                        | Route                                                                                                                                         |
| ----------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| A read-only question about how code works       | `how`, and `why` for the reason behind it                                                                                                     |
| A bug                                           | `diagnosing-bugs`                                                                                                                             |
| A measured slowness to fix once                 | [playbooks/perf-issue.md](playbooks/perf-issue.md)                                                                                            |
| One metric to improve over many attempts        | [playbooks/hillclimb.md](playbooks/hillclimb.md)                                                                                              |
| A cause to find in a live process or a capture  | [the forensics playbook](../whats-next/playbooks/forensics.md)                                                                                |
| A feature                                       | `design` for the shape, `arena` when more than one shape is valid, `tdd` to build it, then `code-review`                                      |
| A change of structure with behavior held        | `refactor`                                                                                                                                    |
| A fork that running code can settle             | `prototype`, or the smallest script that answers a timing or behavior question, in place of asking                                            |
| One rendering to match to another               | [the visual parity playbook](../whats-next/playbooks/visual-parity.md)                                                                        |
| A skill, or instructions for an agent           | `writing-for-agents`                                                                                                                          |
| A skill or a model to compare on a set of tasks | `eval`                                                                                                                                        |
| A pull request to open or update                | `file-pr`                                                                                                                                     |
| A pull request to watch                         | `babysit`                                                                                                                                     |
| A branch to take to a ready pull request        | `autopilot`, with `merge` only on the user's word                                                                                             |
| Several pull requests to take to merge-ready    | [playbooks/pr-program.md](playbooks/pr-program.md)                                                                                            |
| Pull requests or a stack to verify and land     | [playbooks/shipping.md](playbooks/shipping.md)                                                                                                |
| A merged change to follow until it is live      | `rollout`                                                                                                                                     |
| Several pull requests to plan before any code   | `to-spec`, then `to-tickets`, with a unit check and a live check in each ticket, and a perf check where speed matters. Build on the user's go |
| Work to resume from an earlier session          | `recall`                                                                                                                                      |
| A stop that a later session can resume from     | commit your task's uncommitted edits as `wip:` on a task branch, never the default branch, leaving unrelated edits alone, then `handoff`      |
| Worktrees and disk to reclaim                   | `managing-workspaces`                                                                                                                         |
