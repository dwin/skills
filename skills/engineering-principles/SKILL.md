---
name: engineering-principles
description: Apply simple, type-safe engineering practices while implementing, refactoring, testing, or reviewing TypeScript, Go, or C#. Use for code-quality decisions involving scope control, durable domain models, behavior-focused tests, idiomatic language patterns, and ceremony proportional to risk.
---

# Engineering Principles

Apply these defaults when writing or changing code. More specific repository,
directory, framework, generated-code, and user instructions take precedence.

## Work from intent

- Treat a question as a request for an answer, not implicit permission to edit.
- Ask only when a missing decision materially changes behavior or safety.
  Otherwise use repository evidence and proceed.
- Preserve behavior outside the requested scope. Surface valuable adjacent
  improvements separately instead of smuggling them into the change.
- Prefer the simplest design that fully represents the domain. Avoid
  speculative abstractions, extension points, compatibility layers, and
  configuration.
- Use types and constructors to make invalid states difficult to represent,
  without turning the type system into a second program.
- Match process and architecture to risk. Do not add coordination or ceremony
  that the task does not earn.

## Design the change

- Keep policy close to the domain that owns it and keep I/O at clear
  boundaries.
- Prefer focused modules with narrow public surfaces. Add an abstraction only
  when it hides meaningful complexity or supports demonstrated variation.
- Reuse established repository patterns and dependencies unless they are the
  source of the problem.
- Make concurrency, ownership, cancellation, resource lifetime, and failure
  behavior explicit.
- Preserve compatibility across APIs, persisted data, messages, and rolling
  deployments unless a breaking change is intentional and approved.

## Test and explain behavior

- Test observable behavior and important boundaries, not implementation trivia.
- Add regression coverage for a bug when it proves the failure and protects the
  corrected contract.
- Prefer deterministic signals, controlled clocks, and explicit fixtures over
  sleeps, retries, hidden globals, or order dependence.
- Comment intent, invariants, external constraints, and surprising tradeoffs.
  Do not narrate obvious syntax.
- Keep comments, public documentation, schemas, examples, and generated
  artifacts synchronized with behavior.

## Load language guidance selectively

Read only the references relevant to files being changed:

- TypeScript and React: [references/typescript.md](references/typescript.md)
- Go: [references/go.md](references/go.md)
- C# and .NET: [references/csharp.md](references/csharp.md)

When a change crosses languages, apply each reference at its boundary while
keeping the end-to-end contract consistent.

## Complete the work

Carry the user's objective through the authorized boundary. A passing test,
review result, commit, or handoff is a checkpoint when assigned work remains.
Answer status questions briefly, then continue the active task unless the user
pauses or changes it.

When a dependency blocks one part, continue independent work within the agreed
scope. Respect explicit holds on shared paths and unresolved policy decisions.
Before stopping, identify the remaining work and the concrete dependency,
permission, or decision that prevents progress. Preserve authorizations already
given in the conversation; a checkpoint does not reset them.

1. Re-read the request and diff for scope drift.
2. Confirm types and validation match the actual runtime contract.
3. Run focused tests and every repository-mandated check.
4. Review error paths, cancellation, resource cleanup, observability, security,
   and compatibility in proportion to risk.
5. Check documentation and generated artifacts affected by the behavior.
6. Report concrete evidence, remaining risks, and intentionally deferred work.
