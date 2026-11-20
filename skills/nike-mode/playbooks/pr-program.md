# Pull request program

You own the verdicts, not the pull requests. One owner carries each pull
request to merge-ready. Nothing lands until a verifier that never wrote the
code has proven it, and the landing follows
[the shipping playbook](shipping.md).

1. **Settle the queue and the gates.** List the pull requests the user handed
   over. Items the user names as theirs, and anything outside the list, stop
   at merge-ready. A request to state the plan is not a go.
2. **Size the program with `swarm`.** Its four questions decide what runs
   first and what runs in parallel. Pull requests that stand alone branch
   from the base and run in parallel. Stack one on another only when it
   builds on that one's code. `file-pr` covers stacks.
3. **Start one owner per pull request.** Each owner works in its own
   checkout and runs `autopilot` without `merge`, so it ends at a reviewed,
   green, ready pull request. Its kickoff names the base branch, or the
   parent branch for a stacked pull request, and says to push each finished
   unit before starting the next. A replacement owner then resumes from the
   branch. Keep the program's ledger and work log as `swarm` describes.
4. **Verify once, at the ready head.** Start independent verifiers per
   [the shipping playbook](shipping.md), step 1. They rerun the checks,
   prove the change on the real surface, and audit the diff against the
   pull request's goal. A rebase, a conflict resolution, or a small fix gets
   one verifier at the new head. A change of wording only gets none. New
   behavior or a redesign gets the full set again.
5. **Block only for a problem you can show:** a failing run at the head, a
   bug a user would hit, or a doc line the pull request made wrong. A
   problem the base already has goes in a follow-up unless the pull request
   copies or newly reaches it.
6. **Land, or stop at verified.** With the user's word to land, follow
   [the shipping playbook](shipping.md) from step 2. Without it, stop when
   every pull request is verified and green at its head. Hand the list to
   the user, and push nothing more without their go.
7. **Audit the owners while the program runs.** `swarm`'s audit tick judges
   each owner by its pushes and pull request activity, replaces a stuck one
   with the branch and the ledger rows, and stays quiet when nothing
   changed. On the user's stop, every owner stops writing and reports where
   it stands.

Reply with each pull request's state and verdict, what landed, the gates
still waiting on the user, and the follow-ups parked, with links to each pull
request and the ledger.
