---
name: blast-radius
description: Find what a change can break outside its own diff, and prove the fact its safety rests on by running real code. Use when the user asks for the blast radius of a change, asks what a change could break, or wants a small diff they don't trust checked before it ships.
---

# Blast radius

The **blast radius** of a change is everything it can break outside the lines
it touches. Listing the callers is not the job, because a search finds them in
seconds. The job is the breakage a search does not show.

A written analysis reads as convincing whether or not it is true. So the
deliverable is proof: find the one or two facts the change's safety rests on,
and run code that shows they hold.

The Behavior axis of `code-review` runs a change to break what it set out to
do. This skill looks for what the change breaks somewhere else.

## Rate each fact

Take each fact the safety depends on as far down this ladder as is cheap, and
report the level it reached:

1. **Asserted.** You said so. Worth nothing alone.
2. **Cited.** You pointed at the line: a real `file:line`, or the library's
   own source at the version the project pins.
3. **Walked.** You traced the failure case step by step and showed it cannot
   be reached.
4. **Run.** A script or test calls the real code and fails loudly if the fact
   is false.
5. **Reproduced.** You saw it hold in the running application.

Level 4 is usually one small script that imports the library version the
application ships and calls the exact function in question.

## Steps

1. **Read the change.** Read the diff, the symbols it adds, changes, and
   deletes, and what now behaves differently, including what the diff leaves
   implicit. Read the pull request and its commits for intent:
   `gh pr view <number> --json title,body,commits`, and `git log` on the
   touched files. When the reason for the current shape is unclear, `why`
   digs into its history.
2. **Find the safety fact.** Most changes that look risky are safe because of
   one fact, such as "this call only drops cache entries that have already
   expired". When that fact holds, most of the risky cases clear at once.
   Spend your effort here, not on a long list of possibilities.
3. **Look where search stops.** Read the source of each library the change
   calls, at the version the lockfile pins, including any local patch. Work
   out when code runs: microtask order, teardown and unmount, retries, and
   process shutdown. Follow what a symbol search misses: the JSON an API
   returns, a database column, a wire format, a second language reading the
   same bytes, a feature flag, configuration, and code several hops
   downstream.
4. **Weigh each risk.** Give each one a likelihood and a cost. Keep the risks
   you confirmed, and list the ones you checked and cleared separately. Cite a
   real `file:line` for every claim. A search that finds nothing is an
   answer, so report the search. Name only callers and APIs you have seen.
5. **Prove the safety fact.** Write the script or test that runs the real
   code, run it, and keep its output. Put it in a temporary directory outside
   the checkout, or in a disposable copy of the checkout when it has to sit
   inside the tree.
6. **Get a second reading on a wide change.** When the change spans many
   modules or services, have an agent on a different model family answer the
   same question without seeing your answer, then merge the two. Different
   models find different real breakage. `swarm` says how your host starts
   one.

Apply `verifying-claims` throughout. A fact you could not run stays at the
level it reached, and the report calls it unproven.

## Report

- **What it does.** What changed, including the part that is not obvious.
- **The safety fact.** The fact, the level it reached, and the proof. Write
  "unproven" when it stayed below level 4.
- **Risks.** For each: how it breaks, the `file:line`, how likely and how
  costly it is, and how to check it. Paste the output for the ones that
  matter.
- **Cleared.** What you checked, and why it is safe.
- **Before merging.** The cheapest test or reproduction that catches the real
  failure, including the script you wrote.

Write the report through `unslop`. Remove secrets and private names before it
goes anywhere public.
