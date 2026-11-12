# Digests

A **digest** is a small record of one session: enough to sort it, and
nothing a sort does not need. The extraction script writes one JSON object
per line to `digests.jsonl` in the private directory.

## Fields

| Field           | Holds                                                                                                                       |
| --------------- | --------------------------------------------------------------------------------------------------------------------------- |
| `key`           | A short id the script assigns. The key-to-path map goes in `index.tsv` beside the digests.                                  |
| `host`          | The host that recorded the session.                                                                                         |
| `workspace`     | The last two parts of the path of the directory the session ran in.                                                         |
| `started`       | The first timestamp, and `ended` the last.                                                                                  |
| `user_messages` | The user's own messages, in order, each cut to about 500 characters.                                                        |
| `tools`         | A count per tool name.                                                                                                      |
| `commands`      | A count per program name, the first word of each shell command.                                                             |
| `errors`        | Up to 20 failed tool calls: the tool and the first line of the error.                                                       |
| `corrections`   | The indexes of user messages that look like pushback (see below).                                                           |
| `skills`        | The skills loaded in the session.                                                                                           |
| `started_by`    | `user`, or `agent` when an agent or a harness started the session, such as a worker or an eval run. Count these, skip them. |

**The user's own messages** are what the user typed. Leave out what the host
or a tool put in the user's turn: tool results, system reminders, the body of
a skill or command, and the contents of attached files. Cut a long paste to
its first lines and a note of how many lines followed.

**Corrections** are a heuristic flag for the triage model, not a verdict: a
user message that opens with words like "no", "don't", "stop", "actually",
"again", or "I said", or that comes right after a failed tool call or an
undone edit.

## Secrets

A digest goes to a model, and a session file does not. So the script removes
secrets before it writes anything. It works by pattern and misses some: the
scope question tells the user so, and every reader writes `<REDACTED>` for
one that got through.

- **Redact first, then cut.** Run the patterns over the whole string, and
  only then cut it to length. A cut made first can leave the front half of a
  token, with nothing left for a pattern to match.
- **Redact every string that leaves the session**, not only messages and
  errors. Tool names, command names, and skill names come from the session
  too. For `workspace`, keep only the last two parts of the path.
- **Prefer losing text to keeping a secret.** A pattern that also removes a
  harmless id or a long path costs the sort little.

Replace each of these with `<REDACTED>`:

- an `Authorization`, `Cookie`, or `Set-Cookie` header value, and whatever
  follows `Bearer` or `Basic`;
- the user and password part of a URL, and the whole query string of a URL,
  which is where a signed link keeps its signature;
- a private key block, from its `BEGIN` line to its `END` line;
- a token in a known format: one that starts with `sk-`, `ghp_`, `gho_`,
  `github_pat_`, `xox`, `AKIA`, or `AIza`, and a JSON Web Token, which
  starts with `eyJ` and has three parts joined by dots;
- the value of an assignment, a `name=value` pair, or a JSON or YAML field
  whose name contains `token`, `secret`, `password`, `passwd`, `pwd`,
  `credential`, `auth`, `cookie`, `session`, or `key`, in any letter case
  and whatever the value's length. That covers `export API_KEY=...`,
  `Pwd=...;` in a connection string, and `"client_secret": "..."` inside an
  error;
- a long opaque value: an unbroken run of 32 or more letters, digits, and
  `+`, `/`, `=`, `_`, `-` characters that holds both letters and digits,
  such as a hex digest, a base64 blob, or the path of a webhook URL.

Then check the output before any of it goes to a model: search
`digests.jsonl` for the patterns above, for `BEGIN`, for `Bearer`, and for
`://` followed by `@`. A match is a bug in the script. Fix it and run the
extraction again.

`index.tsv` maps keys to session paths. It stays in the private directory and
goes to no model.

## Build the script

1. **Learn each host's format from its structure.** Print the keys and the
   record types of the first lines of one session, such as
   `head -n 20 <file> | jq -c 'keys'`, and the counts of each `type` value.
   Read field names, not message text. Formats differ by host and change
   between versions.
2. **Write the script in the private directory**, never in a repository.
   Start it with `umask 077`, so only the user can read what it writes.
3. **Try it on three sessions.** Read the three digests, fix what is wrong,
   then run it on the whole window. Test the redaction on made-up values,
   one per pattern under Secrets, never on a real secret.
4. **Log every session it cannot parse**, with the reason, in
   `skipped.tsv`. A session that disappears without a reason makes every
   count wrong.
