---
name: refactor
description: Change the structure of code without changing its behavior. Use when the user asks to refactor, restructure, clean up, simplify, or deepen code, or asks what in a codebase is worth refactoring.
---

# Refactor

A **refactor** changes structure and leaves behavior as it was. A change that
adds behavior is a feature. A change that corrects behavior is a bug fix. When
the work turns up either one, split it out and finish the structural change
first.

Use the `design` skill's vocabulary for structure and `CONTEXT.md` for the
domain's names.

## Choose the target

- When the user named the code, start at [Pin the behavior](#pin-the-behavior).
- When the user asked what is worth refactoring, read
  [FIND-CANDIDATES.md](FIND-CANDIDATES.md). It scans the codebase, shows the
  candidates in an HTML report, and interviews the user about the one they
  pick. Then return here.

## Pin the behavior

Before any structure moves, capture what the code does now in a check you can
rerun: a characterization test, a snapshot, or a script that records the
outputs for fixed inputs. A passing type check or lint run is not a pin.

Write the pin at the module's interface, so it survives the restructuring.
Run it on the unchanged code and see it pass.

## Name the target shape

State what the modules, types, and call graph would be if the code were
written today, knowing everything known now. Design that shape as a whole,
then deliver it in steps.

The new shape must remove something: a branch, an invalid state, a layer, a
duplicate. A reshape that only adds indirection is not worth making, and code
whose shape is already clear and local stays as it is.

When the target changes a module's interface, sketch at least two shapes with
`design` before moving anything.

## Move in small steps

1. Subtract first. Delete dead code, collapse a wrapper that has one caller,
   and remove a check that repeats an earlier one.
2. Make one structural move, then run the pin. Continue only when it passes.
3. After a rename, search for the old name in strings, comments, docs, and
   configuration. A rename tool misses those.
4. Update every description of the old shape: types, docs, examples, and the
   comments that explain why.

## Change an interface

By default, keep callers working through the change, as
`engineering-principles` requires: add the new interface, move callers to it,
and remove the old one once nothing uses it. Every step passes the pin.

**Option: migrate every caller and delete the old interface in one change.**
This leaves no shim and no period with two ways to do one thing. Use it only
when the user asks for it, or agrees after you propose it. Propose it when all
of these hold:

- every caller is in this repository;
- nothing stored, sent between services, or deployed in stages depends on the
  old shape;
- the old interface has no reason to remain.

With this option, change the tests to assert the new contract, and delete the
tests that only protected details of the old implementation.

## Prove it and decide

- Run the pin on the final tree. For a larger reshape, also compare old and
  new outputs with a script over recorded inputs.
- Keep the change only when the code is easier to read or to change
  somewhere. When it is not, revert it and say so.
- Commit the subtraction first, then the reshape, then any cleanup that
  follows. Each commit passes the pin.

## Report

State the structure that changed, the pin and its result, what was removed,
what was reverted, and any feature or bug fix that was split out.
