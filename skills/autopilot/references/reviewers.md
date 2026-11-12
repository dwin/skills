# Reviewers

The local reviewer comes from a different model family than the implementer.
Families share training data and blind spots, so a reviewer from another
family catches more of the implementer's mistakes. Families include Claude
(Anthropic), GPT (OpenAI), and Gemini (Google).

## Choose

1. If the user names a reviewer model or effort, use it. If it is
   unavailable, use the next reviewer for that implementer in `swarm`'s
   [roles table](../../swarm/references/roles.md), keep the family rule
   below, and say in the report which model reviewed and why.
2. Identify your own model family.
3. Use the first route that reaches a model from another family. On that
   route, pick the most capable model from that family:
   - the host's delegation tools, which can run child tasks on another
     provider or model, as in T3 Code, Cursor, or Copilot;
   - an installed CLI, used non-interactively with tool approvals limited to
     read-only work, such as `codex exec`, `claude -p`, `cursor-agent -p`,
     `gemini -p`, or `copilot -p`;
   - a model bridge available in the session, such as an MCP tool that calls
     other models.
4. If no other family is reachable, use a fresh-context subagent of your own
   family. The report must say the review was same-family.

Check that the chosen route actually runs the model you asked for. Record the
effective model and family for the report.

## Brief

Every round starts **blind**: a fresh reviewer with no context and none of
your conclusions. Give it:

- the absolute workspace path, and an instruction to make no edits, commits,
  or GitHub posts;
- the pinned base, the head SHA, and the diff command
  (`git diff <base>...<head>`);
- the task brief or spec, and the repository's standards files;
- an instruction to run `code-review` if the skill is available to it,
  otherwise to review Standards, Spec, and Behavior itself, reporting a
  Behavior finding only when a command it ran shows the failure;
- the output format: a list of findings, each with severity, `file:line`, the
  failure it causes, the smallest fix, and for a Behavior finding the command
  and its output.

Keep the brief to those facts. Where you suspect problems, what you fixed
since the last round, and what earlier rounds found all wait for
reconciliation, because a reviewer told what to expect tends to confirm it.

Run the reviewer in the foreground, or wait for its completion notification.
A review counts only when its report arrives and names the head SHA it
reviewed.

## Reconcile

From the second round on, after the blind report arrives, send the same
reviewer the previous round's findings, each with its disposition and, for a
refutation, the evidence. Ask it to mark each one fixed, not fixed, or
contested with new evidence, and to withdraw any finding in its blind report
that repeats one it now accepts as refuted. When the route cannot continue a
reviewer's session, start a second reviewer and give it the blind report along
with the earlier findings.

A round is clean when the blind report and the reconciliation together leave
no valid in-scope finding without a fix.
