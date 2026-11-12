---
name: why
description: Find out why code is the way it is from its history, reviews, tickets, docs, and other records, and say how sure each answer is. Use when the user asks why something is built, written, or behaves a certain way, why a choice was made, or where a number or limit came from.
---

# Why

Code shows what it does, not why it exists. The reason lives in commits,
reviews, tickets, design docs, chat, and runtime data, and every one of those
records is incomplete and sometimes contradicts another. Find the evidence,
and give each claim with how sure the evidence makes it.

Work as a careful investigator: keep what the record says apart from what you
infer. [references/epistemics.md](references/epistemics.md) defines the
confidence tiers and the wording for each. Read it before you write the
answer.

## 1. Pin the target and the question

The **target** is a piece of code, a pattern, a feature, or a named decision.
The **question** asks for a rationale, a trade-off, the edge case behind the
code, an outside constraint, whether the code is dead, or a sweep of its
history.

When the target is vague, take your best reading from the conversation: open
files, recent edits, what was just discussed. State it in one line so the user
can redirect, and continue.

When the question carries a guess ("I assume it's for performance?"), the
guess is one candidate to check against the evidence, the same as any other.

## 2. Build the code anchor

Gather the seed that every later step uses:

- the files, line ranges, and key symbols;
- what the code does now, read from the code itself;
- the commits that touch it: `git log --follow --oneline -- <file>`,
  `git blame -L <start>,<end> <file>`, and `git log -S '<exact text>'` for
  when a line or a constant appeared;
- the pull request numbers in those commits, and each pull request's body and
  review discussion:
  `gh pr view <number> --json title,body,author,mergedAt,labels,closingIssuesReferences,comments,reviews`;
- the ticket IDs named in commits and pull requests.

## 3. Search every source you can reach

Sort the sources this session can reach into seven categories:

1. source control: history, reviews, comments, and tests, always reachable
   through `git` and `gh`;
2. issue tracker;
3. long-form docs: design docs, specs, ADRs, and postmortems;
4. team chat;
5. infrastructure observability: metrics, monitors, logs, traces, and
   incidents;
6. error tracking;
7. product analytics or data warehouse.

Place each connected tool, CLI, and MCP server by its name, instructions, and
tools. Note any that could fit two categories.
[references/sources.md](references/sources.md) says what each category is
best at and how to search it.

**Search every category that has a source.** The goal is a complete coverage
map, and an empty search is a finding. A category is skipped only with a
written reason that goes into the answer: no source for it is reachable here,
which is a gap and not a choice, or it provably cannot bear on the target,
such as error tracking for a build-time script. When the target is defensive
code, such as a null check, a retry, a timeout, a rate limit, a feature flag,
or a memory guard, add the incident searches from the sources reference to
every category.

When your host can start agents, run one investigator per category in
parallel, each owning one source and briefed with
[references/investigator-brief.md](references/investigator-brief.md), the code
anchor, and the user's question. `swarm` says how your host starts them and
which model suits research. Investigators only read. Without agents, work
through the categories yourself, one at a time, under the same brief.

A trivial target, whose single pull request already states the whole answer,
may be answered from the anchor. Do that only after confirming the other
searches would add nothing, and say so in the answer.

## 4. Synthesize

Weigh the findings by [references/synthesis.md](references/synthesis.md):
merge overlapping citations, surface contradictions, place every claim in a
tier, spot-check the citations you are unsure of, and name the gaps. When the
findings are long, hand them to one fresh agent along with the synthesis and
epistemics references. Present its answer with the confidence wording intact.

## 5. Answer

Use the structure in the synthesis reference. Sources Consulted keeps one line
per category, including those that found nothing and those skipped, with the
reason.

When the question comes before a change to this code, end with the constraints
the change must respect:

- **Preserve.** What the evidence says the code must keep doing.
- **Change.** What the evidence says no longer applies.
- **Avoid.** Approaches the record shows were tried and rejected.
- **Risk.** What could break, and how sure you are.

## Failure modes

- **Recency bias.** The latest commit is rarely the whole story. The current
  shape is many decisions in layers, so trace back.
- **Code as its own evidence.** "The code clamps to 100, so the author wanted
  100" is circular. Code is the mechanism, not the motive.
- **Rationalizing.** Messy history stays messy in the answer. A missing record
  is a gap, not proof that nobody cared.
- **A tidy story.** When two sources disagree, show both.
