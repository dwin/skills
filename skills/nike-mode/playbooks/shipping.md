# Shipping

You own what lands. Verify each pull request on its own, land only the
verified run from the bottom, and keep your hands off the stack while it
lands. The user's word to land these pull requests is the merge approval.
Nothing else is.

1. **Get a verdict for each pull request.** One verifier per pull request,
   started through `swarm`, runs the change the way a user would, base
   against head, and reports `PASS`, `PASS+NOTES`, or `FAIL` with the head
   SHA it ran. Only an agent that did not write the code gives a verdict.
   Green CI and an approving bot review are not verdicts, because neither
   runs the change.
2. **Find the run that can land.** Walk up from the lowest unmerged pull
   request and stop at the first one without `PASS` or `PASS+NOTES`. The pull
   requests below it are the run, and the top one is the ceiling. A verified
   pull request above an unverified one waits. One that does not need the
   code below it can move onto the base and land alone, after a fresh verdict
   there.
3. **Check that each verdict still describes the code.** A rebase gives every
   pull request above it a new SHA without failing any check. Compare
   `git patch-id` at the verdict's SHA with the current head. The same patch
   keeps its verdict. A patch that differs only in tests, docs, or lint
   config keeps it when the same checks pass on both SHAs. Any other change
   gets a new verdict.
4. **Land bottom-up, one at a time.** Merge the run's lowest unmerged pull
   request with a guard on its head, such as
   `gh pr merge <number> --squash --match-head-commit <sha>`. Read the pull
   request back. It must show merged into the base branch. A queued merge or
   enabled auto-merge is not a merge, and a pull request whose base is still
   its parent's branch merged into that branch, not the base. Retarget the
   next pull request to the base, move its patch onto the merge result, and
   push with `--force-with-lease`. Step 3 decides whether its verdict
   survives. Merge it once its checks pass.
5. **Leave the stack alone while it lands.** The move in step 4 is the only
   change to a branch or a base, because a merge lands whatever its branch
   holds at that moment. `babysit` watches each pull request. When a merge
   stalls, find out why before changing anything.
6. **Stop at the ceiling.** Landing more takes new verdicts, which is a new
   pass through step 1.

Reply with the verified run and its ceiling, each pull request's verdict and
who gave it, what landed and how you confirmed it, and what the next pull
request needs.
