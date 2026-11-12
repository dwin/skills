# T3 Code

Status: run once as a trial on 2026-11-11. Starting workers from a child
thread, completion wakes, a follow-up through `t3_thread_send`, and a reviewer
on another provider all worked. The unbound audit tick and a child messaging a
sibling come from tool descriptions and have not been run.

A session in T3 Code holds two layers of tools: T3's own, and the subagent
tool of the agent it runs on. Use T3's tools for any worker that needs another
provider's model, its own checkout, or a life longer than this turn. Use the
agent's own subagent tool for short foreground work on your own model family.

## Start a worker

- Call `orchestrator_capabilities` once before the first `delegate_task`. It
  lists the providers, models, and options this machine offers.
- `delegate_task` starts one worker from the task text alone, so the kickoff
  must be complete. Set `role`, the `target` model and options, and
  `isolation: "worktree"` when the lane needs its own checkout.
- With the default `isolation: "shared"`, the worker's shell starts in your
  checkout. When its workspace is somewhere else, such as a Rift or a path the
  user named, put the absolute path first in the kickoff and tell the worker
  to work only there.
- When two provider instances offer the same model, follow
  `~/.config/swarm/local.md`, or name the one you chose in the ledger.
- Leave `runtimeMode` unset unless the user asked for a supervised worker. A
  narrower mode pauses the worker for approvals nobody is there to give.
- A worker on another machine takes that machine's `environmentId` in
  `target`.
- Keep each `taskId` and thread in the ledger.

## Be woken

- A delegated task wakes this thread when it completes, including one on
  another machine. Follow the `next` field it returns and leave status polling
  alone.
- `watch_pull_request` wakes the thread on failed checks, passed required
  checks, new comments or reviews, and conflicts. Confirm a merge by reading
  the PR.
- `t3_background_wait` holds the turn for a background command you started.
- For the audit tick, `schedule_task` with an interval. Bound to this thread,
  every run posts here. For a quiet tick, set `bindToCurrentThread: false`,
  give the task the ledger path, and have it message this thread with
  `t3_thread_send` only when a lane's state changed. Write the task's id in
  the ledger. Remove it with `delete_scheduled_task` when the run finishes,
  pauses, or stops, and confirm with `list_scheduled_tasks`.

## Follow up and cancel

- `t3_thread_send` to the worker's thread continues the same worker. Sent to a
  finished worker, it starts a new task in that thread with its history.
- `freshContext: true` gives a fresh worker in the same thread.
- `task_cancel` stops a worker you no longer need.

## Worker-to-worker

Give both workers the path of the handoff note. When a worker's own tools
include `t3_thread_send`, it may message its peer's thread directly, under the
channel rules.

## Pull requests

Link every PR a lane opens with `link_pull_request`, so the thread shows its
state.
