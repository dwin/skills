---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

Use `tdd` where possible, at pre-agreed seams.

Run focused validation while changing the code and repository-required checks
before delivery. Repeat broader checks when later changes or failures warrant
them.

Once done, use `code-review` to review the work.

For an existing PR, a request to implement fixes or address valid feedback
includes committing and pushing the validated changes to that PR, unless the
user asks to keep them local. Verify the remote head and inspect its checks
after pushing. Permission to fix code does not include review replies, thread
resolution, rebasing, force-pushing, merging, or deployment.

For new work, follow the delivery boundary already agreed with the user. If
publication was not requested, leave validated changes local. Use `file-pr`
when they want a pull request.
