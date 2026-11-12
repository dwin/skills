---
name: eval
description: "Measure whether a skill or a model does a set of tasks better, by correctness, corrections needed, cost, and time. Compares a skill against no skill or an earlier version, or one model against another."
disable-model-invocation: true
---

# Eval

An **eval** runs the same tasks under two or more **arms** and compares the
results. An arm is one configuration: a skill version, no skill, or a model.
Everything except the variable under test stays the same in every arm.

| Mode  | Varies                                               | Held fixed       | Answers                                                             |
| ----- | ---------------------------------------------------- | ---------------- | ------------------------------------------------------------------- |
| Skill | the skill: present or absent, or one version or next | model and tasks  | Does the skill load when it should, and does it improve the result? |
| Model | the model                                            | tasks and skills | Which model should a role use?                                      |

Ask which mode the user wants when the request does not say.

## Frame the eval

Write these down before any run, and show them to the user:

- the arms;
- the tasks, and why each one can tell the arms apart;
- the result that would change a decision, such as "adopt the new version if
  it passes more cases and costs no more than 20% extra".

An eval with no decision attached is finished when it reports. It changes
nothing.

## Measure four things

Record all four for every arm:

- **Correctness**: the share of graders the arm passed. Prefer a grader a
  program checks, such as a pattern, a file, or a test run. Use a judge model
  only for what a program cannot check.
- **Corrections**: the follow-up messages the arm needed before its graders
  passed. After a failed attempt, send one message that quotes the failing
  check's output and nothing else. Allow two. Record 0, 1, 2, or "failed". A
  harness that runs one turn cannot measure this: report "not measured".
- **Cost**: the harness's own figure, or the token counts in the worker's
  final report. Report tokens when the host gives no price.
- **Time**: wall-clock seconds from the prompt to the final answer.

## Choose tasks

A task is a prompt a user would type, the files it starts from, and graders
with a known right answer. Pick tasks where the arms can differ: a mistake
from a past session is the best source, and `retro` findings name them.

- **Public tasks** are small invented cases. They live in the plugin's
  `evals/` directory and may be committed.
- **Private tasks** come from real work. They live in the directory that
  `~/.config/eval/local.md` names, or in `~/Documents/agent-evals/`. A private
  task's prompt, files, output, and project name stay out of every public
  repository, PR, and published report.

Use both sets when the decision matters. Public tasks alone show that the
harness works. Private tasks show whether the arm helps on real work.

## Blind the run

An arm that knows it is being measured behaves differently.

- Write each prompt as an ordinary request. Leave out the skill's name and
  every word about measuring, such as "eval", "test", "judge", "rubric",
  "score", "benchmark", and "candidate".
- Give each worker a directory with a name a user would pick.
- Tell no worker that other arms exist.
- Ask no worker to list the skills or files it used. Read that from its
  transcript.
- Keep the graders and the rubric away from the workers.
- A judge sees outputs under neutral labels, such as A and B, and scores every
  arm in one pass on one scale.

## Run a skill eval

On Claude Code, use its built-in harness: read
[references/claude-code.md](references/claude-code.md). It runs each case with
the plugin and without it, in sessions that load nothing else.

To compare two versions of a skill, check out each version in its own
workspace and run the same cases against each.

A skill eval answers two separate questions. Report them separately:

1. **Does the skill load?** Count the runs in which the agent loaded it, for
   prompts that should trigger it and for prompts that should not.
2. **Does it change the result?** Compare correctness between the arms.

On another host, use the model-eval procedure below with the skill installed
in one arm and absent in the other.

## Run a model eval

1. Give each model its own copy of the task's starting files.
2. Start one worker per model with the same prompt, through the route your
   host has for that model. `swarm`'s host references list the routes. Record
   the model and effort each worker ran with, as the host reports them.
3. When a worker finishes, run the graders yourself in its directory. Send
   corrections by the rule above.
4. For a judge, use a model from a family none of the arms belong to. When the
   arms cover every family you can reach, use the strongest one and say so.
5. Read every output yourself, end to end. When you and the judge disagree,
   the rubric is ambiguous or one of you is wrong: settle which before
   reporting.

For Claude models on Claude Code, the built-in harness does steps 1 to 3: run
the suite once per model.

## Read the results

- Run each task at least three times per arm, and five when the arms are
  close.
- Read the transcript of every failing run before you trust its score. A
  failure caused by the grader or the harness is a defect in the eval. Fix it
  and run again.
- A gap smaller than the spread between runs of one arm shows no difference.
- For a claim about cost or time, apply `verifying-claims`'s measurement
  checks.

## Report

Give one table: a row per arm, with correctness, corrections, cost, time, and
the number of runs. Below it, state:

- for a skill eval, how often the skill loaded, and how often on prompts where
  it should stay out;
- the decision the results support, by the rule set in the frame;
- what the eval cannot show. A harness that loads no user instructions
  measures the skill against a bare session, and a real session may already
  behave that way without the skill.

Link the result files. Keep them: the next eval of the same skill or model
compares against them.

## Change the roles table

`swarm` reads its role-to-model table from `swarm/references/roles.md` in the
skills repository. When a model eval supports changing a row, open a pull
request against that repository with the new row and the result table in its
description. The user merges it. Leave installed copies of the file alone.

To repeat a model eval when a new model ships, schedule this skill with the
host's scheduler and the same tasks. The scheduled run opens the pull request
only when the results change a row.
