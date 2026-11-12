# Codex

Status: run once as a trial on 2026-11-11 with `codex exec`. Starting workers
and waiting on them in the foreground worked. The rest comes from the Codex
documentation.

## Start a worker

- Codex starts subagents when asked for them directly, and when skill or
  project instructions request them. State how to divide the work and what each
  worker returns.
- A custom agent file in `.codex/agents/` sets `model`,
  `model_reasoning_effort`, and `developer_instructions` for a role. A spawn
  request can also name the model and effort.
- `max_concurrent_threads_per_session` under `[agents]` caps open workers. Six
  is the documented default.
- `codex exec --worktree` gives a run its own Git worktree. Otherwise create
  workspaces through `managing-workspaces`.

## Reach another model family

The documented models are OpenAI's. For another family, run an installed CLI
such as `claude -p` or `cursor-agent -p`, or use an MCP tool that calls other
models.

## Be woken

Codex waits for every requested worker and then returns one response. Treat
this host as unable to wake you: run workers in the foreground and say so
before starting. No scheduled wake was found in the documentation, so a long
run has no audit tick here.

## Follow up

Codex routes follow-up instructions to an open worker thread. Close a worker's
thread when its lane is done.
