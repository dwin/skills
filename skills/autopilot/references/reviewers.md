# Reviewers

The local reviewer comes from a different model family than the implementer.
Families share training data and blind spots, so a reviewer from another
family catches more of the implementer's mistakes. Families include Claude
(Anthropic), GPT (OpenAI), and Gemini (Google).

## Choose

1. If the user names a reviewer model or effort, use it. If it is
   unavailable, ask before substituting another.
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

The reviewer starts with no context. Give it:

- the absolute workspace path, and an instruction to make no edits, commits,
  or GitHub posts;
- the pinned base, the head SHA, and the diff command
  (`git diff <base>...<head>`);
- the task brief or spec, and the repository's standards files;
- an instruction to run `code-review` if the skill is available to it,
  otherwise to review both Standards and Spec itself;
- in later rounds, the new commits to focus on, the previous findings with
  their dispositions, and the refutations it may contest;
- the output format: a list of findings, each with severity, `file:line`, the
  failure it causes, and the smallest fix.

Run the reviewer in the foreground, or wait for its completion notification.
A review counts only when its report arrives and names the head SHA it
reviewed.
