# Skill evals on Claude Code

Claude Code runs eval cases against a plugin with `claude plugin eval`. Its
documentation is at <https://code.claude.com/docs/en/plugin-evals>. Read
`claude plugin eval --help` for the flags of the installed version.

Status: run on Claude Code 2.1.322 against this plugin's own `evals/`
directory, on the default model and on Haiku. The one-skill comparison was
run once, on one case. Mocked MCP servers, resumed transcripts, and the
`baseline` grader were not tried.

## What a run is

Each case runs in an empty temporary workspace, in a session that loads only
the plugin under test. The user's settings, `CLAUDE.md` files, memory, other
plugins, and MCP servers are absent. By default every case runs in two arms,
with the plugin and without it, and the report gives both scores and their
difference.

## Write a case

A case is a directory under the plugin's `evals/`:

```text
evals/<case>/
  prompt.md        the prompt, with run limits in frontmatter
  graders/*.md     one check per file
  case.yaml        optional: setup, such as a scaffold script
  scaffold.sh      optional: creates the starting files
```

`claude plugin eval init --bare <case>` writes a blank one.

`prompt.md`:

```markdown
---
max_turns: 15
allowed_tools: [Read, Glob, Grep, Skill]
tags: [verifying-claims]
---

Before I add one: does this service already have a rate limiter anywhere?
```

List `Skill` in `allowed_tools`, or the agent cannot load any skill. Tools
that write or run commands also need `--allow-tools` on the command line.

Grader types, set by `type` in the file's frontmatter:

| Type          | Passes when                                                     |
| ------------- | --------------------------------------------------------------- |
| `regex`       | `pattern` is found in the final message, or in another `target` |
| `tool_used`   | `tool` was called between `min` and `max` times                 |
| `tool_order`  | one tool call came before another                               |
| `file_exists` | the agent created a file matching `path`                        |
| `llm`         | a judge model passes the rubric in the file's body              |

Check that a skill loaded:

```markdown
---
type: tool_used
tool: Skill
input_match: '"skill"\s*:\s*"(?:[\w-]+:)?<skill-name>"'
---
```

Check that a skill stayed out, on a prompt that should not trigger it, by
adding `min: 0`, `max: 0`, and `arm: both` to the same grader.

In a two-arm run, the harness leaves "the skill loaded" graders out of the
score, because the arm without the plugin can never pass them. It reports them
for the with-arm as pass or fail. A case whose only grader is one of these is
scored on it.

A case that needs starting files names a script in `case.yaml`:

```yaml
schema_version: "1.1"
name: <case>
context:
  scaffold_script: scaffold.sh
```

The script runs in the empty workspace before the agent starts, and only when
the command passes `--scaffold`.

## Run

From the plugin's root:

```bash
claude plugin eval . --no-publish --trust-plugin --scaffold --keep-temp \
  --runs 3 -j 4 --threshold 0 --max-cost-usd 15 --json results.json
```

- `--no-publish` keeps the report on this machine. Without it the harness
  publishes the report, with every prompt and output, to claude.ai. Publish
  only when the user asks, and never for private tasks.
- `--trust-plugin` and `--scaffold` run the plugin's code and the cases'
  scripts as the user. Pass them only for a plugin and cases you have read.
- `--keep-temp` keeps each run's directory, which holds its trace. Without it
  the harness deletes the directory of every run that finished, so a run whose
  graders failed can no longer be read. It may still keep a run that ended in
  an error. The harness prints every directory it keeps and makes it
  read-only. Once the eval is reported, delete each one with
  `chmod -R u+rwx <dir>` and then `rm -rf <dir>`: they hold every prompt and
  output.
- `--threshold 0` reports scores without failing the command. Set a threshold
  when the run gates something, as in CI.
- `--max-cost-usd` stops the run at a spending limit and marks the result
  partial. Leave partial results out of comparisons.
- `--case <glob>` and `--tag <tag>` select cases. Put the target before
  `--tag`, which reads the words after it as tags.
- `--ablation none` runs only the with-arm, at half the cost. Use it while
  fixing graders.

### One skill in a plugin of several

The arm without the plugin has none of its skills, so the two-arm score
compares the whole plugin with no plugin. To measure one skill:

1. Make a second checkout of the plugin and remove the skill from it: its
   directory, its entry in any manifest that lists skills, and any link to it.
2. Run the same cases against each checkout with `--ablation none`, and write
   each result to its own file.
3. Compare the two checkouts grader by grader, on the graders that check the
   result. With one arm, a "the skill loaded" grader counts in the case score,
   and the checkout without the skill always fails it, so the case scores are
   not comparable.

### Private cases

The harness reads cases only from a real directory inside the plugin. It
rejects an absolute `--eval-dir`, a symbolic link that points outside the
plugin, and a case outside the plugin that names it. To run private cases:

1. Copy them into an untracked directory in a checkout of the plugin, such as
   `private-evals/`, and list that directory in `.git/info/exclude`.
2. Run with `--eval-dir private-evals` and
   `--output-dir <a directory outside every public repository>`.
3. Delete the copy and the kept run directories after the run, and confirm
   `git status` shows nothing from the copy.

## Compare models

Run the suite once per model with `--model <id> --ablation none`, and write
each result to its own file. The result does not record the model, so put it
in the file name. Keep `--judge-model` the same across the runs, so the arms
are graded alike.

## Read the result

Each run writes `evals/results/<timestamp>/` with `aggregate-result.json` and
`report.html`. Keep that directory out of version control. In the JSON:

| Field                                           | Meaning                                    |
| ----------------------------------------------- | ------------------------------------------ |
| `aggregates.overallScore`                       | mean case score with the plugin            |
| `aggregates.meanDelta`                          | mean of with-arm minus without-arm         |
| `cases[].aggregates.score`, `.delta`            | the same, per case                         |
| `cases[].arms.with[]`, `cases[].arms.without[]` | each run, with its grader verdicts         |
| `costUsd`, `durationSeconds`                    | list-price estimate, and wall-clock time   |
| `partial`                                       | true when the suite stopped before the end |

The harness runs one turn per run, so **corrections** are not measured here.

Each run in the JSON has a `tracePath`: a JSON Lines file of every message
and tool call in that run. The file is there when the harness kept the run's
directory, which `--keep-temp` makes it do for every run. Read the trace of
the run that failed. A rerun of the same case is a different run and may pass.
