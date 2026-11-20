# Pull request program

You own the verdicts, not the pull requests. One owner carries each pull
request to a ready pull request. Nothing lands until a verifier that never
wrote the code has proven it, and the landing follows
[the shipping playbook](shipping.md).

1. **Settle the queue and the gates.** List the pull requests in scope, and
   mark the ones the user authorized you to land. A pull request the user
   keeps for themselves, or did not authorize, stops at verified and ready.
   Leave pull requests outside the list untouched. A request to state the
   plan is not a go.
2. **Size the program with `swarm`.** Its four questions decide what runs
   first and what runs in parallel. Pull requests that stand alone branch
   from the base and run in parallel. Stack one on another only when it
   builds on that one's code. `file-pr` covers stacks.
3. **Start one owner per pull request.** Each owner works in its own
   checkout and follows `autopilot` without `merge`, so it ends at a reviewed,
   green, ready pull request. Its kickoff gives the absolute path of
   `autopilot`'s `SKILL.md`, because that skill loads only when typed. It
   also names the base branch, or the parent branch for a stacked pull
   request, and says to push each finished unit to its feature branch while
   building, so a replacement owner can resume from the branch. From the
   first local review on, `autopilot` decides when to push. Keep the
   program's ledger and work log as `swarm` describes.
4. **Verify each pull request at its ready head.** Start one independent
   verifier per pull request, as step 1 of
   [the shipping playbook](shipping.md) describes. It reruns the checks,
   proves the change on the real surface, and audits the diff against the
   pull request's goal. When a branch changes after its verdict, step 3 of
   the shipping playbook decides whether the verdict holds or the pull
   request needs a new verifier. Block a pull request only on the bar in
   [worker.md](../worker.md), and put anything else in a follow-up.
5. **Land, or stop at verified.** For the pull requests the user authorized,
   follow [the shipping playbook](shipping.md) from step 2. Stop the rest
   when each is verified and green at its head. Hand that list to the user,
   and push nothing more to those branches without their go.

## While the program runs

`swarm`'s audit tick judges each owner by its pushes and pull request
activity. Replace a stuck owner with a fresh one briefed with the branch and
the ledger rows. Stay quiet when nothing changed. On the user's stop, follow
`swarm`'s Stop rule in full, then report where each pull request stands.

Reply with each pull request's state and verdict, what landed, the gates
still waiting on the user, and the follow-ups parked, with links to each pull
request and the ledger.
