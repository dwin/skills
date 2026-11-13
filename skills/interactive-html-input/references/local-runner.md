# Local questionnaire runner

Use Python 3.9+ with its standard library. The process handles persistence; the
browser renders the UI. There are no pip, npm, CDN, or cloud runtime dependencies.

## Launch and recover

Resolve the installed skill directory as `SKILL_DIR`. Write a task-owned form
JSON using [the synthetic example](../assets/example-form.json), and choose an
explicit state file outside the skill checkout. The containing directory must
already exist and should be private to the user/task.

```bash
python3 "$SKILL_DIR/scripts/questionnaire.py" serve \
  --form /absolute/task/form.json \
  --state /absolute/task/answers.sqlite3 --port 0
```

The first stdout line is JSON containing `url`, `port`, and `state`. Open the
complete URL in a regular browser; in T3 use the environment-port browser target
described in SKILL.md. It binds only `127.0.0.1`. Port 0 selects a free port;
a fixed `--port` is optional. The capability is in the URL fragment and request
header, never query parameters. Treat the URL as private; do not publish it or
send it to external services. Reload retains the fragment. Links open with no
referrer. Restart generates a new token: reopen the newly printed URL.

Launch through the agent's execution tool in a persistent execution session,
retain its session/process handle, and keep it available while the user answers.
Do not use a short command timeout that kills it at turn end. Report the state
path and how to stop/restart the owned process. No daemon or automatic cleanup
is installed. Ctrl+C stops the server; it does not delete state. Preserve the
form and database. After a crash, restart with the same files; opening or rendering
does not write new answer timestamps. Keep state on a local filesystem with
SQLite locking/durability support, not a network share or synced folder.

To read committed values even after the browser or server dies:

```bash
python3 "$SKILL_DIR/scripts/questionnaire.py" export \
  --form /absolute/task/form.json \
  --state /absolute/task/answers.sqlite3 \
  --output /absolute/task/answers-backup.json
```

Omit `--output` for stdout. Export opens the database read-only and refuses to
overwrite an existing output file. Browser export shows selectable committed
JSON and offers a download request; verify the actual downloaded file in the
delivery host. Neither export includes unsaved drafts. On a failed write, the
recovery panel shows all pending drafts as selectable JSON, explicitly marked
uncommitted. Keep the tab open, copy that text if needed, repair the runner/disk issue, and
retry the same mutation. Refreshing loses uncommitted drafts. If a restarted
runner has a new token, preserve drafts before opening its new URL.

## Form and answer contract

The JSON object has `schema_version: 1`, a stable `form_id`, `title`, optional
`description`, and `questions`. Each question has:

- Stable `id`, `title`, `type` (`choice` or `text`).
- Optional `description` and `links: [{"label": "…", "url": "https://…"}]`.
- For choices, `options: [{"value": "stable-value", "label": "Visible label"}]`.
  Text questions omit options. All questions always expose a notes field.

IDs use 1–128 ASCII letters, digits, underscores, dots or hyphens, starting with
a letter or digit. Question IDs and choice values must be unique in their scope.
The form limit is 2 MiB and 1–1000 questions, with 1–100 options per choice and
up to 20 links per question. Titles/labels and choice values allow 500 characters;
descriptions, text answers and notes allow 20,000. URLs allow 2048 characters
and must be absolute HTTP(S), without credentials or whitespace. Unknown fields
are rejected. Supplied text renders as text, never HTML. No answer defaults or
recommendations are part of this schema.

An export includes the complete `form` and ordered `answers`, each with `id`,
`value`, `notes`, `updated_at` and `revision`. `value: null` means undecided;
notes alone do not mark a question answered. Empty browser text means undecided.
Untouched rows have revision 0 and null timestamp. Successful mutations increment
the question revision and set a UTC timestamp; reopening/exporting does not.

The runner compares the entire canonical JSON form against the stored spec.
Any changed form content, schema version, ID, question order or option meaning
requires a new state path. Whitespace and object key order may change without
creating new state. It refuses
mismatched, empty existing, unsupported or corrupt databases without resetting
them. There is no implicit migration or import. Preserve the original state and
form rather than deleting them to bypass a mismatch.

## Saving and conflicts

SQLite uses transactions, `synchronous=FULL`, and a rollback journal; save
receipts follow commit. Each new database is created with mode 0600 (directory
permissions and filesystem behavior remain the caller's responsibility).
Per-question revisions reject stale tabs. Mutation IDs make lost-ack retries
idempotent across process restarts. Receipts remain in the database for the
state file's lifetime; there is no automatic compaction.

The browser serializes writes. Choices queue promptly; typing debounces about
300 ms. Edits made while a write is in flight remain pending until their own
receipt. Controls keep their DOM nodes and focus. A failure pauses answer
controls and retains drafts. Retry repeats the same mutation; a conflict shows
the committed answer and requires an explicit choice to rebase the local draft
or discard it. Other tabs' changes appear on conflict or reload, not live push.

The UI provides search, question navigation, committed progress, next unanswered,
and per-question saving state. Before real collection, verify in the intended
browser: typing during an in-flight save, reload/restart recovery, failed writes
and retry, two-tab conflicts, download and selectable fallback, keyboard focus,
and 390px/desktop layout. Automated HTTP/SQLite tests do not establish these
browser behaviors. There are no Jira/GitHub actions in the UI.
