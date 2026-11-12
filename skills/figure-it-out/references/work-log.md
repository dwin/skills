# Work log

A **work log** is the running record of a long piece of work: what was done,
decided, and verified, with a pointer to the evidence for each. Someone who
stepped away reads it to check the result without redoing the work.
`figure-it-out`, `swarm`, and `handoff` use this format.

## Format

One tab-separated file, one row per decision. Every cell is a single line, and
evidence is a pointer, never prose.

| Column     | Holds                                                                                             |
| ---------- | ------------------------------------------------------------------------------------------------- |
| `ts`       | the UTC time, in ISO 8601                                                                         |
| `phase`    | the phase or lane                                                                                 |
| `decision` | what was chosen or done, in one line                                                              |
| `why`      | the reason, in plain words                                                                        |
| `evidence` | a commit SHA, a pull request number, a `file:line`, or the path of an artifact, trace, or capture |
| `result`   | the outcome or predicate state: `tests pass`, `reverted`, `pixel diff 0`, `INCONCLUSIVE`, `open`  |

Rows read like a note to a teammate:

| ts                   | phase   | decision                                                 | why                                           | evidence                       | result                    |
| -------------------- | ------- | -------------------------------------------------------- | --------------------------------------------- | ------------------------------ | ------------------------- |
| 2026-05-24T09:02:00Z | frame   | counted the work: 96 forms, about 70 hours               | to size the run before starting it            | commit 3a9f1c2                 | five blockers to settle   |
| 2026-05-24T09:40:00Z | check   | captured screenshots of every form before any change     | to compare old against new on each unit       | `scripts/snap.sh`, `baseline/` | 96 baseline images        |
| 2026-05-24T11:15:00Z | billing | moved the billing form to the new field components       | smallest unit that exercises every field type | commit 7c21e0a                 | pixel diff 0, tests pass  |
| 2026-05-24T12:30:00Z | billing | discarded a worker's change whose screenshots were blank | read the images instead of its summary        | worker branch reset            | reverted, brief tightened |

Write each cell the way you would tell a teammate what you did, in plain
words. `unslop` applies to log text.

## Add a row

Run [`scripts/work-log.sh`](../scripts/work-log.sh), in the `figure-it-out`
skill's directory, as
`work-log.sh <file> <phase> <decision> <why> <evidence> <result>`. It stamps the time,
writes the header on first use, flattens tabs and newlines, and puts a single
quote before any cell that starts with `=`, `+`, `-`, or `@`, so a spreadsheet
reads the cell as text instead of a formula. When you append a row another
way, clean any cell built from generated or outside text the same way.

Log decision points, not every action: a fork chosen, a unit landed with its
check result, a pivot or revert with its trigger, a blocker found, a check
fixed. A loop gets one row per iteration.

## Where it lives

Keep the log at `~/Documents/agent-work/<date>-<task>/work-log.tsv`, beside
the `swarm` ledger when the run has one, or in the directory the user names.
It stays out of the repository by default. Commit a copy with the change when
a reviewer needs the trail to trust the result.

## Runs

A **run** is one agent session, including its later turns and any compacted
summary of it. A pickup, a replacement agent, or a new session is a new run.

When a run adds to a log that already has rows, its first row has phase
`start`. Before writing in a later turn, read the last rows: when another
run's `start` row follows your last row, write a new `start` row of your own.
A `start` row's decision names the `ts` range of the rows before it that this
run did not write, and its evidence names this run, such as its thread or
agent ID. Use `start` for nothing else.

## Rules

- **Append only.** A wrong row gets a new row that supersedes it. History is
  never edited or deleted.
- **Prefer reproducible evidence.** Output from a committed script beats a
  one-off command.

## Audit before handing back

Walk this run's rows against what you did in this session. This run's rows
start at each of its `start` rows, or at the first row when this run created
the log, and end at the next `start` row of another run.

- Every row maps to a real decision or action.
- Every evidence pointer resolves and shows what the row claims.
- A fork, pivot, or abandoned approach that shaped the work and has no row is
  a gap. Add the row.

Correct the log by appending. A row that is wrong, or that records nothing
real, gets a superseding row with what happened and a pointer that resolves.
Rows from other runs are outside the audit unless your own work shows one is
wrong.

## Review by another model

Have an agent on a different model family from the one that did the work read
the log, the diff, and the evidence, and flag what the user should look at.
`swarm` says how your host starts one. The review is a scan, not a redo, and
looks for:

- rows whose evidence is weak or missing;
- checks claimed in a row but never shown;
- choices that look risky in hindsight: premature, beyond the scope, or
  treating a symptom;
- anything a quick skim would miss.

End the reply with an **Attention** section. Its first line is
`reviewed by <model>`, followed by one line per flag, each pointing at rows.
"No flags" is a valid result. When no other family is reachable, use the same
family in a fresh context and say the review was same-family.

## Read a log

`column -s $'\t' -t work-log.tsv` renders the log in a terminal. GitHub renders
a committed `.tsv` file as a table.
