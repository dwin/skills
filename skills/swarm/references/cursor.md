# Cursor

Status: run once as a trial on 2026-11-11 with `cursor-agent -p`. Background
`Task` workers, their completion wakes, and a reviewer on another model family
all worked. Subagent files, resuming a worker, and cloud agents come from the
Cursor documentation and have not been run.

## Start a worker

- The `Task` tool starts a subagent. Its call takes `model` and
  `run_in_background`. Several `Task` calls in one message run at the same
  time.
- `model` takes any model ID Cursor offers, so a reviewer from another family
  needs no extra route. The IDs carry the effort, as in
  `claude-opus-5-5-medium`. The roles table is the user's model choice, so
  pass its model in place of `inherit`.
- A subagent file in `.cursor/agents/` sets `model`, `readonly`, and
  `is_background` for a named role. `readonly: true` restricts a reviewer to
  reading.
- In the trial, `Task` workers shared the coordinator's checkout. Give each
  lane a workspace through `managing-workspaces` and put its path in the
  kickoff.

## Be woken

- A worker started with `run_in_background: true` returns its result to you
  as a follow-up turn after your turn ends.
- Cloud agents can subscribe to pull request activity, CI results on a branch,
  and timers. The built-in `/loop` skill gives a recurring check for the audit
  tick.

## Follow up

Each subagent run returns an agent ID. Resume that ID to continue the same
worker with its context.

## Worker-to-worker

Workers have no channel to each other. You start each reviewer and carry its
findings to the implementer, and lanes pass handoff notes through files.
