# Forensics

Use this to find the cause of a behavior from evidence a running or recorded
program gives: a process that spins, memory that grows, a visual glitch, a
profile, a trace, a heap snapshot, or a spindump.

The result is a diagnosis with its evidence cited. It includes no fix unless
the user asks for one. Once the cause is known, continue with
`diagnosing-bugs`.

Choose the branch:

- The process can be run or is running now: [Live process](#live-process).
- A capture already exists: [Captured artifact](#captured-artifact).

## Live process

1. **Capture the signal that matches the symptom**, from the process itself:
   a CPU profile for a spinning process, a heap snapshot for a leak, a
   browser trace for a visual glitch. Reasoning from the source alone is not
   a capture. A capture can pause or slow the process. On a process that
   serves users, ask before taking one.
2. **Reduce the capture to the cause**: the function on the hot path, the
   chain of references that keeps a leaked object alive, the loop that fires
   with no input. Parse a large capture in a sub-agent, or with a script, and
   keep only the reduced finding in this conversation.
3. **Prove the mechanism** on an instance you may change: one you started, or
   one the user said you may alter. Add instrumentation to it, or patch its
   code, and see the behavior change as the explanation predicts. Leave a
   process that serves users as it is. When no instance may be changed, report
   the mechanism as unconfirmed.
4. **Map the finding to source**: the file, the symbol, and the line that
   allocates or schedules.

## Captured artifact

The artifact is a fixed dataset. Read it. Do not rerun the program in its
place.

1. **Identify the format and load it with the right tool**: a trace or
   profile parser for a CPU profile, heap tooling for a heap snapshot, a text
   editor for a spindump.
2. **Make it queryable before you read it.** Load a trace or a heap snapshot
   into SQLite, one row per sample, frame, or node.
3. **Narrow to the cause.** Query for the frames that hold the most time and
   walk the call tree to the hot path. For a leak, follow the references from
   the leaked object back to a root. For a spindump, find the thread that is
   running or blocked, and its wait reason.
4. **Attribute it to source** through the artifact's own symbols: file,
   symbol, and line. A frame with no source mapping is not yet a diagnosis.
   Resolve the symbols, or say that the artifact does not carry them.
5. **Confirm with a paired capture when there is one**, by comparing before
   and after. Without one, report the finding as the strongest hypothesis
   the artifact supports.

## Report

State the signal or artifact and its format, the reduced finding, how the
mechanism was proved or why it could not be, the source location, and the
paths of the artifacts.
