# Triage

The triage model reads digests and writes one **record** per digest. The
categories are fixed, so records from every batch and every model can be
counted together.

## Categories

A session can have several.

| Category          | The session shows                                                                         |
| ----------------- | ----------------------------------------------------------------------------------------- |
| `repeated-prompt` | A request the user makes often, in the same shape, such as "review this" or "catch me up" |
| `manual-workflow` | A sequence of steps the user drove by hand that a skill, script, or schedule could run    |
| `correction`      | The user correcting what the agent did or how it did it                                   |
| `skill-miss`      | An installed skill that fit the task and did not load, or loaded only when asked          |
| `tool-friction`   | Failed tool calls, denied permissions, retries, or slow and costly calls                  |
| `missing-access`  | Information or access the agent lacked and the user had to supply                         |
| `environment`     | Setup, sign-in, disk space, or flaky tooling                                              |
| `none`            | Nothing worth changing                                                                    |

## Record

One JSON object per line:

```json
{
  "key": "cc-3f9a12",
  "categories": ["correction", "tool-friction"],
  "themes": [
    {
      "category": "correction",
      "theme": "pushes before running the check",
      "evidence": [4, 9]
    }
  ]
}
```

- `theme` is a general phrase of at most twelve words: no project names, no
  people, no quotes. Two sessions with the same habit get the same phrase.
- `evidence` lists indexes into the digest's `user_messages`.

## Brief for each batch

Give the triage worker:

- the categories and the record format above;
- the list of themes seen so far, with the instruction to reuse a theme when
  one fits and to add one only when none does;
- the batch of digests;
- the instruction to return only records, one valid JSON object per line, one
  record per digest, and to judge each session by the user's messages first.

Validate every returned line with a script: valid JSON, a known `key`, known
categories, and evidence indexes inside the digest. Send a failing batch back
once. A batch that fails twice counts as invalid output for that model.

## Merging themes

Before aggregating, list the distinct theme phrases with their counts, and
merge the ones that name the same habit. Record each merge in the private
directory, so the counts can be traced back.
