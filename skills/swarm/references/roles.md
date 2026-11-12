# Roles

Default model for each role, in order of preference. The first model the host
can reach is the one to use. When the host offers neither, use its closest
model from the same family and name it in the ledger. A table the user states in the thread overrides
this file.

| Role                     | First choice      | Then          | Effort |
| ------------------------ | ----------------- | ------------- | ------ |
| Implementer              | Claude Opus 5.5   | GPT-6.1 Sol   | high   |
| Planner, second opinion  | Claude Fable 5.2  | GPT-6.1 Sol   | high   |
| Reviewer                 | see below         | see below     | medium |
| Research and exploration | Claude Sonnet 5.5 | GPT-6.1 Terra | medium |
| Bulk analysis            | Claude Haiku 5.5  | GPT-6.1 Terra | low    |

**Reviewer.** Pick from a different model family than the implementer: GPT-6.1
Sol for a Claude implementer, Claude Opus 5.5 for a GPT implementer. When no
other family is reachable, use the implementer's family with a fresh context
and say the review was same-family.

**Bulk analysis** is classifying, extracting, or summarizing at volume. Run a
small calibration batch before the full run, and drop a model that stalls or
returns invalid output.

Send the most critical correctness work to the implementer's first choice at
its highest effort.

## Machine-specific routes

Provider and account names differ by machine. `~/.config/swarm/local.md`,
when present, says which provider instance to prefer for a model on this
machine, and where the ledger for each kind of project lives.
