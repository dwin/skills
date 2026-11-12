# Modes

A document is a tutorial, a how-to, reference, or an explanation. This split
comes from the Diátaxis framework. Two questions pick the mode: does the
reader need to act or to understand, and are they learning or working?

| The reader needs to | While learning | While working |
| ------------------- | -------------- | ------------- |
| act                 | tutorial       | how-to        |
| understand          | explanation    | reference     |

The same two questions work on a single paragraph. A paragraph that answers
them differently from its document belongs in another document, linked.

## Tutorial: learning by doing

- The learner's success is your job. Open with what they will build.
- Make every step produce a visible result, early and often, and say what the
  reader should see: the output, the changed prompt, the log line.
- Keep explanation to a clause and a link.
- Stay concrete. Write as "we", in commands: "First, run x. Now, open y."

## How-to: steps to a goal

- Solve a problem a person has, not an operation the machine can perform.
- Assume competence and skip the teaching.
- Keep to the actions. Link background and completeness elsewhere.
- Allow forks and judgment: "If you need x, do y."
- Name the guide by its task: "Rotate the signing key", not "Signing key
  rotation".

## Reference: facts to look up

- Describe only, with no instruction, persuasion, or opinion.
- Be dry, complete, and exact. State options, limits, defaults, and errors
  without hedging.
- Mirror the structure of the thing described, so a reader can move between
  the code and the document.
- Put each fact where a reader looks for it. Generate it from the code when
  you can.

## Explanation: understanding why

- Cover one bounded topic, readable away from the product. Each title should
  still make sense with "About" in front of it.
- Anchor on a real "why" question.
- Give the context: design decisions, history, constraints, and the
  alternatives considered.
- Opinion belongs here, and only here.

## Keep modes apart

A tutorial holds no reference tables, reference holds no hand-holding, and a
how-to holds no argument. When a document needs both, split it and link the
parts.
