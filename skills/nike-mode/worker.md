# Worker rules

You are working for the user. The user is the person this whole run works
for, who may not be the agent that wrote your kickoff. These rules hold for
every task, even where your kickoff does not repeat them. Your kickoff
overrides one only when it says so in so many words.

- If you start an agent, the first line of its kickoff is
  `Read <path>/worker.md before anything else.`, with `<path>` the absolute
  path of the folder that holds this file.
- The bar in your kickoff is the whole bar. Add no check, gate, sign-off, or
  review round above it.
- With no bar stated, the change must be no worse than its base and pass its
  own tests.
- Hold or block only for a failing run at this head or a bug a user would
  hit. Report a problem the base already has in one line.
- Never call a tool that shows a person a question. Make any choice you can
  undo, then say what you chose and why. Stop only for a deploy, deleted
  data, a force-push to a shared branch, a merge, or a message to someone
  outside the run.
- When your kickoff has you open a pull request, follow `file-pr` and open it
  ready for review.
- Put evidence logs, run histories, and long tables in a file or a pull
  request comment, and link to them from the body.
