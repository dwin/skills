# Formal verification

A test checks the cases someone thought to write. Formal verification checks
every case in a stated scope: every order of steps in a model, every input up
to a bound, or every input.

Use this for code where a break harms users and tests rarely reach the case
that breaks it: concurrency, retries, state machines, protocols, parsers, and
unsafe code.

## Steps

1. **Choose the target from the code.** Start where the user pointed. With no
   pointer, find the promise the code makes that would cost the most to break
   and that tests reach the least. Ask the user only what the code cannot
   tell you.
2. **Let the question choose the tool.** Whether events can happen in a bad
   order suits a model checker over a small model of the design; TLA+ with
   TLC is the default. Whether the code behaves for every input suits a
   verifier that runs on the code. When no verifier runs on the language, say
   so, and test the real code with generated inputs. Prefer a tool the
   repository's developers can install and run, and tell the user why you
   chose it.
3. **Write each rule in the reader's words first.** One plain sentence for the
   property and one for the harm when it breaks. Then encode it. Add a model
   variable when a rule needs one. Keep every rule as strong as the user
   agreed to.
4. **Keep the model true to the code.** Every part of it points to code a
   reviewer can open. One indivisible step in the model is one indivisible
   step in the code. Names come from this repository.
5. **Show each check failing.** Break the property in a variant of the code
   or the model, such as a removed check or a reordered step, and see the
   check catch it. A check never seen to fail proves nothing.
6. **Run it and keep findings as findings.** When the current code breaks a
   property, report the counterexample. Leave the property, the model, and
   the product code as they are unless the user asks for a change.
7. **Show the result as a statechart** when the check is a model of states.
   Follow [Draw the statechart](#draw-the-statechart).
8. **Replay each counterexample against the real code**, as a test or as a
   reproduction on an instance you started, one step per action. Leave a
   system that serves users as it is. When the bug does not occur, treat the
   model as wrong until you show otherwise.
9. **Make it cheap to rerun.** One command, a pinned tool version, and a run
   short enough to use on every relevant change. Record which files and
   functions each check covers, and the commit at which you last confirmed
   the model describes them.

## Draw the statechart

The chart shows how the system moves between states, in the words of the
person who decides whether the behavior is right.

- Label each state with what that reader can see or cares about, such as
  "Paying" or "Lease held, write pending". Keep variable names out.
- Label each arrow as the reader sees it happen, such as "you press play" or
  "the connect fails". When a step can occur only under a condition, end the
  label with the condition in brackets.
- Mark each state that breaks a rule, and say in a legend which rule.
- Aim for about twenty arrows. Merge states that behave the same, and leave
  out detail the reader does not need. Keep every state on a bug's path, and
  keep states that break different rules apart.
- Give the chart as a Mermaid `stateDiagram-v2` block.

For each rule that breaks, give the shortest path to it as numbered steps in
the reader's words.

## Report

State what was verified, the tool and why, the bounds and assumptions, what
the check found in plain words, the command that reruns it, and what it does
not cover. A pass covers the model or the bound. It does not cover the whole
system.
