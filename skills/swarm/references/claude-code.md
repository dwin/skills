# Claude Code

Status: run once as a trial on 2026-11-11 with `claude -p`. Background
workers, completion wakes, and a GPT reviewer through `codex exec` all worked.
`SendMessage` follow-ups and scheduled ticks have not been run.

## Start a worker

- The `Agent` tool starts a worker from the prompt alone, so the kickoff must
  be complete. Several `Agent` calls in one message run at the same time.
- Workers run in the background by default and notify you when they finish.
  Set `run_in_background: false` only when your next action needs the result.
- `isolation: "worktree"` gives the worker its own checkout.
- Start a reviewer with an agent type whose tool list has no `Edit` or
  `Write`, when one fits the review. Otherwise use `general-purpose` and rely
  on the reviewer line in the kickoff.

## Reach another model family

`Agent` runs Claude models only. For a worker from another family, use the
first route that works:

1. an installed CLI as a background command, such as `codex exec` or
   `cursor-agent -p`, with approvals limited to what the role needs. Give it
   the full kickoff as its prompt and the lane's workspace as its directory;
2. an MCP tool that calls other models.

With neither, use a fresh-context Claude worker and report that the review was
same-family.

## Be woken

- A background worker or background command re-invokes you when it exits.
- `ScheduleWakeup` or the cron tools provide the audit tick. Mark a tick that
  found nothing as `noop: true` so it collapses in the user's view. End the
  tick with `ScheduleWakeup` and `stop: true`, or with `CronDelete`, and
  confirm with `CronList`.
- Nothing wakes you on pull request events. Schedule one check sized to how
  long CI takes.

## Follow up

`SendMessage` to a worker's name or ID continues it with its context.
`ListAgents` shows who is addressable. Named workers can message each other the
same way, under the channel rules.
