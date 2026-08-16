---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

Use `tdd` where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, use `code-review` to review the work.

Leave the validated changes in the working tree. Commit, push, or open a pull
request only when the user asks. Use `file-pr` when they want the work filed as
a pull request.
