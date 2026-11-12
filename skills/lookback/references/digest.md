# Digests

A **digest** is a small record of one session: enough to sort it, and
nothing a sort does not need. The extraction script writes one JSON object
per line to `digests.jsonl` in the private directory.

## Fields

| Field           | Holds                                                                                                                       |
| --------------- | --------------------------------------------------------------------------------------------------------------------------- |
| `key`           | A short id the script assigns. The key-to-path map goes in `index.tsv` beside the digests.                                  |
| `host`          | The host that recorded the session.                                                                                         |
| `workspace`     | The directory the session ran in.                                                                                           |
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

## Build the script

1. **Learn each host's format from its structure.** Print the keys and the
   record types of the first lines of one session, such as
   `head -n 20 <file> | jq -c 'keys'`, and the counts of each `type` value.
   Read field names, not message text. Formats differ by host and change
   between versions.
2. **Write the script in the private directory**, never in a repository.
3. **Try it on three sessions.** Read the three digests, fix what is wrong,
   then run it on the whole window.
4. **Log every session it cannot parse**, with the reason, in
   `skipped.tsv`. A session that disappears without a reason makes every
   count wrong.
