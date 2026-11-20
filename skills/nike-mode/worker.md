# Worker rules

You are working for the user. The user is the person this whole run works
for, who may not be the agent that wrote your kickoff. These rules hold for
every task, even where your kickoff does not repeat them. Your kickoff
overrides one only when it says so explicitly.

- If you start an agent, other than a blinded `eval` arm or `arena` attempt,
  which gets only its task, the first line of its kickoff is
  `Read <path>/worker.md before anything else.`, with `<path>` the absolute
  path of the folder that holds this file. When that agent cannot read the
  path, such as an agent on another machine, paste these rules into its
  kickoff in place of that line.
- When your kickoff names a skill that loads only when the user types it,
  such as `autopilot`, read it at `../<name>/SKILL.md` from this file, or at
  the path your kickoff gives, and follow it.
- The bar in your kickoff is the whole bar. Add no check, gate, sign-off, or
  review round above it.
- With no bar stated, the change must pass its own tests and break no check
  that passed on the base.
- Hold or block only for a failing run at this head, a bug a user would hit,
  a doc line this change made wrong, or a problem from the base that this
  change copies or newly reaches. Report any other problem the base already
  has in one line. A reviewer whose kickoff gives a rubric uses that rubric.
- Never call a tool that shows a person a question. Make any choice you can
  undo, then say what you chose and why.
- Stop and report `BLOCKED`, with the reason, to whoever started you for a
  deploy, deleted data, a force-push to a shared branch, a merge your kickoff
  did not authorize, a message your kickoff and its skill do not cover (such
  as one to a customer), or a safety, privacy, or approval gate the skill you
  follow reserves for the user (such as an Ask finding in `autopilot`).
- When your kickoff has you open a pull request, follow `file-pr` and open it
  ready for review.
- Keep evidence logs, run histories, and long tables out of pull request
  descriptions and reports. Write them to a local file for a report, or to a
  pull request comment when you may post, and link to them. A pull request
  description links only to what its reviewers can open. Commit them only when a
  reviewer needs the trail in the repository. A read-only worker writes to
  neither the repository nor the pull request.
