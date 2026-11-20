# Shipping

You own what lands. Verify each pull request on its own, land only the
verified run from the bottom, and keep your hands off the stack while it
lands. The user's word to land these pull requests is the merge approval.
Nothing else is.

1. **Get a verdict for each pull request.** One verifier per pull request,
   started through `swarm`, runs the change the way a user would, base
   against head, and reports `PASS`, `PASS+NOTES`, or `FAIL` with the base
   and head SHAs it ran. Only an agent that did not write the code gives a
   verdict. Green CI and an approving bot review are not verdicts, because
   neither exercises the change the way a user would.
2. **Find what can land.** A standalone pull request with `PASS` or
   `PASS+NOTES` lands on its own. For a stack, walk up from the lowest
   unmerged pull request and stop at the first one without `PASS` or
   `PASS+NOTES`. The pull requests below it are the run, and the highest
   pull request in the run is the ceiling. A verified pull request above an
   unverified one waits. One that does not need the code below it can move
   onto the base and land alone, after a fresh verdict there.
3. **Check that each verdict still describes the code.** A rebase gives every
   pull request above it a new SHA without failing any check. Compare
   `git diff <base>...<head> | git patch-id --stable` at the verdict's SHAs
   with the same command at the current base and head. The same patch keeps
   its verdict. A patch that differs only in tests, docs, or lint config keeps
   it when the same checks pass on both heads. Any other change gets a new
   verdict.
4. **Land one at a time, from the bottom, and leave the stack alone.** The
   retarget below is the only change to a branch or a base while the run
   lands, because a merge lands whatever its branch holds at that moment.
   Before each merge, confirm the pull request targets the base branch, its
   checks pass at its head, and no request for changes stands. Merge with a
   guard on the head, such as
   `gh pr merge <number> --squash --match-head-commit <sha>`, and read the
   pull request back. It must show merged into the base branch. A queued
   merge or enabled auto-merge is not a merge. For a stack, retarget the next
   pull request to the base, move its patch onto the merge result, and push
   with `--force-with-lease`. Step 3 decides whether its verdict survives.
   Merge it once its checks pass. `babysit` watches each pull request, watch
   only. When a merge stalls, find out why before changing anything.
5. **Stop at the ceiling.** Landing more takes new verdicts, which is a new
   pass through step 1.

Reply with what landed and the ceiling, each pull request's verdict and who
gave it, how you confirmed each merge, and what the next pull request needs.
