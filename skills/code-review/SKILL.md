---
name: code-review
description: Review the changes since a fixed point (commit, branch, tag, or merge-base) along three axes — Standards (does the code follow this repo's documented coding standards?), Spec (does the code match what the originating issue/spec asked for?), and Behavior (does the change hold up when a reviewer runs it and tries to break it?). Runs the reviews in parallel sub-agents and reports them side by side. Use when the user wants to review a branch, a PR, work-in-progress changes, or asks to "review since X".
---

Three-axis review of the diff between `HEAD` and a fixed point the user supplies:

- **Standards** — does the code conform to this repo's documented coding standards?
- **Spec** — does the code faithfully implement the originating issue / spec?
- **Behavior** — does the change hold up when run? A Behavior finding counts only when a command shows the failure.

The axes run as **parallel sub-agents** so they don't pollute each other's context, then this skill aggregates their findings.

If `docs/agents/issue-tracker.md` exists, follow it. Otherwise, use the issue
tracker tools or CLI available in the current environment and keep the review
self-contained.

## Process

### 1. Pin the fixed point

Resolve the comparison from the user's commit, branch, or supplied PR. For a PR,
inspect its current base and head and verify the selected checkout against that
head. Preserve an explicit fixed point. Ask only when available repository and
PR evidence leaves the intended comparison unclear.

Capture the diff command once: `git diff <fixed-point>...HEAD` (three-dot, so the comparison is against the merge-base). Also note the list of commits via `git log <fixed-point>..HEAD --oneline`.

Before going further, confirm the fixed point resolves (`git rev-parse <fixed-point>`) and the diff is non-empty. A bad ref or empty diff should fail here — not inside two parallel sub-agents.

### 2. Identify the spec source

Look for the originating spec, in this order:

1. Issue references in the commit messages (`#123`, `Closes #45`, GitLab `!67`, etc.) — fetch them using `docs/agents/issue-tracker.md` when present, or the available issue-tracker tools otherwise.
2. A path the user passed as an argument.
3. A spec file under `docs/`, `specs/`, or `.scratch/` matching the branch name or feature.
4. The user's task brief and acceptance criteria, when supplied.
5. If nothing is found, ask the user where the spec is. If they say there isn't one, the **Spec** sub-agent will skip and report "no spec available".

The Behavior axis needs the change's **intent** even when there is no spec. With a spec, the intent is the spec. Without one, write the intent in a sentence or two from the commits and the PR description, and label it as inferred.

### 3. Identify the standards sources

Search the repo for every file that documents how code should be written. When `CODING_STANDARDS.md` or `CONTRIBUTING.md` exists, it must be on the list.

On top of whatever the repo documents, the Standards axis always carries the **smell baseline** below — a fixed set of Fowler code smells (_Refactoring_, ch.3) that applies even when a repo documents nothing. Two rules bind it:

- **The repo overrides.** A documented repo standard always wins; where it endorses something the baseline would flag, suppress the smell.
- **Always a judgement call.** Each smell is a labelled heuristic ("possible Feature Envy"), never a hard violation — and, like any standard here, skip anything tooling already enforces.

Each smell reads _what it is_ → _how to fix_; match it against the diff:

- **Mysterious Name** — a function, variable, or type whose name doesn't reveal what it does or holds. → rename it; if no honest name comes, the design's murky.
- **Duplicated Code** — the same logic shape appears in more than one hunk or file in the change. → extract the shared shape, call it from both.
- **Feature Envy** — a method that reaches into another object's data more than its own. → move the method onto the data it envies.
- **Data Clumps** — the same few fields or params keep travelling together (a type wanting to be born). → bundle them into one type, pass that.
- **Primitive Obsession** — a primitive or string standing in for a domain concept that deserves its own type. → give the concept its own small type.
- **Repeated Switches** — the same `switch`/`if`-cascade on the same type recurs across the change. → replace with polymorphism, or one map both sites share.
- **Shotgun Surgery** — one logical change forces scattered edits across many files in the diff. → gather what changes together into one module.
- **Divergent Change** — one file or module is edited for several unrelated reasons. → split so each module changes for one reason.
- **Speculative Generality** — abstraction, parameters, or hooks added for needs the spec doesn't have. → delete it; inline back until a real need shows.
- **Message Chains** — long `a.b().c().d()` navigation the caller shouldn't depend on. → hide the walk behind one method on the first object.
- **Middle Man** — a class or function that mostly just delegates onward. → cut it, call the real target direct.
- **Refused Bequest** — a subclass or implementer that ignores or overrides most of what it inherits. → drop the inheritance, use composition.

### 4. Spawn the sub-agents in parallel

Issue the sub-agent calls together, in the foreground, and aggregate the reports they return. Background sub-agents can finish without their reports reaching you.

A review is **read-only**. Open every prompt with: "Read the code and run checks, then report. The author owns every edit, commit, push, and post, so leave the working tree, the branch, and the PR exactly as you found them." The same rule binds you when you are the reviewer.

When your own brief rules out sub-agents, as a reviewer started by another agent usually is, run the Standards axis, then Spec, then Behavior yourself and report them under the same three headings.

**Standards sub-agent prompt** — include:

- The full diff command and commit list.
- The list of standards-source files you found in step 3, **plus the smell baseline from step 3** pasted in full — the sub-agent has no other access to it.
- The brief: "Report — per file/hunk where relevant — (a) every place the diff violates a documented standard: cite the standard (file + the rule); and (b) any baseline smell you spot: name it and quote the hunk. Distinguish hard violations from judgement calls — documented-standard breaches can be hard, but baseline smells are always judgement calls, and a documented repo standard overrides the baseline. Skip anything tooling enforces. Under 400 words."

**Spec sub-agent prompt** — include:

- The diff command and commit list.
- The path or fetched contents of the spec.
- The brief: "Report: (a) requirements the spec asked for that are missing or partial; (b) behaviour in the diff that wasn't asked for (scope creep); (c) requirements that look implemented but where the implementation looks wrong. Quote the spec line for each finding. Under 400 words."

If the spec is missing, skip the Spec sub-agent and note this in the final report.

**Behavior sub-agent prompt** — include:

- The diff command and commit list.
- The intent from step 2.
- How this repo builds and runs its tests, from its instructions.
- The brief: "Try to break this change. Prove each finding with a run against the real code: a failing test, a repro script, or command output that shows the wrong behavior. Report each finding with a title, the exact command, the path of any repro file, the output it printed, and the output the intent requires. Leave out anything you did not run. Style, naming, structure, and risks that need a future change to matter belong to the other axes. Keep repro files in a temporary directory outside the checkout; when one has to sit inside the tree, as a test file does, work in a disposable copy of the checkout. 'No findings' is a valid result. Under 400 words, not counting quoted output."

When the diff has nothing to run, as with a prose-only change, skip the Behavior sub-agent and note this in the final report.

### 5. Aggregate

Before reporting, rerun the command behind each Behavior finding. Keep a finding when the output shows the failure and the failure breaks the intent. Drop the rest, and merge findings that share a root cause.

Present the reports under `## Standards`, `## Spec`, and `## Behavior` headings. Give Standards and Spec verbatim or lightly cleaned. Under Behavior, give each kept finding's command, its output, and how it breaks the intent, then the number dropped and why; say "no verified findings" when none survive. Do **not** merge or rerank findings across axes — they are deliberately separate (see _Why three axes_).

End with a one-line summary: total findings per axis, and the worst issue _within each axis_ (if any). Don't pick a single winner across axes — that's the reranking the separation exists to prevent.

## Why three axes

A change can pass one axis and fail another:

- Code that follows every standard but implements the wrong thing → **Standards pass, Spec fail.**
- Code that does exactly what the issue asked but breaks the project's conventions → **Spec pass, Standards fail.**
- Code that follows the standards and reads as a match for the spec but gives the wrong result when run → **Standards and Spec pass, Behavior fail.**

Standards and Spec are readings of the diff. Behavior reports only what a run showed, so it catches what a reading passes over and stays silent on anything it could not execute.

Reporting them separately stops one axis from masking another.
