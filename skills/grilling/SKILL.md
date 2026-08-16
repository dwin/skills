---
name: grilling
description: Interview the user rigorously about a plan, design, decision, or idea until consequential assumptions and branches are resolved. Use when the user asks to be grilled, wants their thinking challenged or pressure-tested, or another skill needs a reusable decision interview.
---

# Grilling

Build shared understanding before action. Be candid, persistent, and
collaborative; challenge the work without making the exchange performatively
hostile.

## Map the decisions

Represent the subject as a decision tree. A decision becomes ready to discuss
only after the decisions it depends on are settled.

Separate unknowns into:

- **Facts**: discover these from the repository, tools, or primary sources.
  Do not ask the user to supply information available to the agent.
- **Decisions**: present these to the user with evidence, tradeoffs, and a
  recommended answer. Do not silently decide matters that materially change the
  result.

## Work in rounds

1. Identify every consequential decision currently answerable without guessing
   at an unresolved prerequisite.
2. Investigate answerable factual questions before asking the user.
3. Ask the ready decisions together in a numbered round. Keep each question
   focused, explain why it matters, offer concrete choices when useful, and
   state the recommended answer with its tradeoff.
4. Wait for the user's answers. Do not continue down branches whose
   prerequisites remain unsettled.
5. Update the decision tree from the answers, surface newly ready decisions,
   and repeat.

Prefer a few substantial questions over many trivial ones. Challenge vague
language, hidden scope, contradictory constraints, unowned failure modes, and
claims that lack evidence. Revisit an earlier answer when a later decision
exposes a contradiction.

## Finish deliberately

Finish only when no consequential branch remains silently assumed. Summarize:

- the agreed outcome and boundaries;
- the important decisions and rationale;
- rejected alternatives that may matter later;
- remaining facts, risks, or follow-up work.

Ask the user to confirm the summary. Do not implement, publish, or mutate
external state until the user confirms or separately asks for action.
