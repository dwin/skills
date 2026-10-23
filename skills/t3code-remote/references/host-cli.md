# Scripts on the environment host

Use this branch only on the machine running the T3 Code environment. The
`t3 thread` CLI exposes the same tools there without an OAuth sign-in. Follow
the installed CLI's `--help` for available flags; this is not a remote-client
authentication workaround.

```sh
t3 thread list
t3 thread show "$thread_id"
```

For authorized new work, capture the returned thread ID and reuse it:

```sh
thread_id=$(t3 thread start . "Find why the tests are slow")
t3 thread show "$thread_id"
t3 thread send "$thread_id" "Now fix it" --wait
```

Use the actual task instead of these example prompts. `.` selects the project
containing the current folder; a project ID also works. New threads use the
project's default model and permission mode and run in the project folder.
Pass `--worktree <base-branch>` when the task needs its own worktree.

`send` queues a busy thread's message as its next turn; it never interrupts.
Pass `-` as the message to read it from stdin. `--wait` prints the agent's reply;
add `--json` for a result that always includes the thread ID.

Handle `--wait` exit statuses explicitly in scripts: exit 1 means the run failed
or stopped; exit 2 means it is waiting for an answer in the app. Preserve the
thread ID and surface that state instead of treating either as completion or
starting another thread.

Source: [T3 Code outside agents — scripts on the host](https://github.com/pingdotgg/t3code/blob/main/docs/user/outside-agents.md#scripts-on-the-host).
