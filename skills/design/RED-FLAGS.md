# Design red flags

Screen every candidate shape against this list before choosing one. A flag is
a reason to revise the shape or reject it.

Assume the next contributor is an agent that sees only the files it opened,
copies the nearest example, and takes the shortest path that compiles. Prefer
the design where a change that looks right from one file is right for the
whole repository.

Uses the vocabulary in [SKILL.md](SKILL.md).

## Shallow module

The interface is nearly as complex as the implementation. Signs:

- callers coordinate several methods to complete one operation;
- options expose internal stages or implementation choices;
- learning the interface does not save the caller from learning the
  implementation.

A deep module is not a deep call chain. A call chain spreads understanding
across layers. A deep module concentrates behaviour behind one interface.

## Information leakage

Several modules depend on the same internal decision, so changing it needs
edits in all of them. A storage schema, a wire type, or a framework object
that appears in a module's interface is leakage. Parse external data into
domain types behind the interface.

## Temporal decomposition

Modules follow the order of execution: load, validate, transform, save. Each
stage then repeats the same representation and its invariants. Group code by
the knowledge it owns. Methods that run at different times belong in one
module when they protect the same decisions.

## Pass-through method

A method forwards its arguments to another method of the same shape. Remove
it, or move the responsibility to the module that can finish the operation.
Keep a forwarding method only when it adds policy or adapts across a seam.

## Split ownership

More than one module writes the same state, or keeps its own copy. A reader
of one writer cannot see the others, and their rules drift apart. Give each
piece of state one owner. Other modules read it or ask the owner to change it.

## Two ways to do one task

The design offers more than one way to do the same thing. Each way keeps
gaining callers, because a contributor copies whichever it finds first. Keep
one way, move callers off the others, and delete them.

## Importable internals

A caller can import a module's internals, so the shortest path that compiles
makes them part of the interface. Make internals unreachable from outside, so
that such an import fails the build.

## Hand-synced list

Two or more places list the same items, and adding one means editing every
list. Keep one list and derive the others. When a list cannot be derived, make
the build fail when the lists disagree.
