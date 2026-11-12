---
name: how
description: 'Explain how a subsystem works, as a walkthrough built from reading its code. Use for "how does X work", "walk me through Y before I change it", or "where should this live".'
disable-model-invocation: true
---

# How

Answer "how does X work?" with the explanation a senior engineer needs on
their first day in a subsystem: the parts, the flow from trigger to result,
where each piece lives, and the traps. Build it from the code you read in this
session, and change nothing.

Two skills sit next to this one. `why` answers why the code is the way it is,
from its history. `explain` teaches a concept or a change at the user's pace.
This skill maps the mechanism.

## 1. Pin the question

State what you take the subsystem and the question to be, in one line, and
continue. The user can redirect.

A **placement question**, such as "where should this live" or "which layer
owns this", is answered from the same map: build the map, then answer it in
step 4.

## 2. Size it

- **Narrow**: one module, one function, one small utility. Read the code and
  write the explanation yourself. Go to step 4.
- **Wide**: a subsystem across several files or services, a feature that cuts
  across layers, or an overview of an architecture. Go to step 3.

When unsure, treat it as narrow. Widen it when the reading keeps leaving the
module.

## 3. Explore in angles (wide only)

Split the question into two to four **angles**, each a distinct slice of the
subsystem: the entry point and its callers, the core state and its changes,
storage, the boundary with another service.

When your host can start agents, start one read-only explorer per angle, all
at once, each briefed with
[references/explorer-brief.md](references/explorer-brief.md), the question,
and its angle. `swarm` says how your host starts them and which model suits
research and exploration. Without agents, take the angles one at a time
yourself, and write each angle's findings in the brief's format before you
start the next.

The step is done when every angle has returned its findings, including its
open questions.

## 4. Write the explanation

Write it to [references/explanation.md](references/explanation.md). Merge the
angles into one picture. Where two findings disagree, read the code and settle
it; leave neither version standing unchecked. When the findings are long,
hand them and that reference to one fresh agent to write the explanation, and
present its answer with light edits only.

For a placement question, end with the answer: the module or layer whose
current responsibilities already match, two existing pieces of code placed the
same way, and what would break if it went elsewhere. `design` holds the
vocabulary for modules, interfaces, and seams.

The step is done when every step in How It Works names the file and function
that performs it, each one read in this session, and every gap is listed as an
open question.
