---
name: swarm
description: Coordinate work done by other agents. Brief each worker, track lanes in a ledger, verify what workers report, and stay reachable until every lane is done. Use when delegating a task to another agent or model, when running two or more lanes of work in parallel, or when the user assigns models to roles such as implementer and reviewer.
---

# Swarm

You are the **coordinator**. Workers do the work. You brief them, track them,
verify what they report, and decide what happens next.

A **lane** is one unit of work with one owner, one workspace, and one way to
prove it is done. A **worker** is an agent you started for a lane. The
**ledger** is the record of the run.

When the work runs through Orca's own orchestration CLI, use Orca's
`orchestration` skill instead of this one.

## Find your host

Hosts differ in five capabilities: starting a worker, being woken when
something changes, following up with the same worker, giving a worker its own
checkout, and reaching another model family. Your **host** is the app this
session runs in. Read the one reference for it:

| This session runs in                                            | Read                                                   |
| --------------------------------------------------------------- | ------------------------------------------------------ |
| T3 Code: your instructions say so, and its tools are local      | [references/t3-code.md](references/t3-code.md)         |
| Claude Code outside T3 Code: you have `Agent` and `SendMessage` | [references/claude-code.md](references/claude-code.md) |
| Codex outside T3 Code: you have its subagent tools              | [references/codex.md](references/codex.md)             |
| Cursor: you have its `Task` tool                                | [references/cursor.md](references/cursor.md)           |

A connector to T3 Code on another machine is a route to workers on that
machine. It leaves your host unchanged, and its workers cannot wake you.

With none of these, use whatever your tool list offers for each capability,
run workers in the foreground, and tell the user which capabilities are
missing.

A host that cannot wake you runs workers in the foreground only. Say so before
starting, so the user knows the run holds this turn open.

## Size the swarm

Decide the split before the first kickoff. Answer four questions, and write
the answers in the ledger when there is one:

1. **What must finish first?** Work that every lane depends on runs before
   the fan-out: a shared type, a schema, a check that fails on the base.
2. **Which workstreams are independent?** Lanes that write disjoint files,
   services, or layers run in parallel. Lanes that write the same files run
   one after another.
3. **What state is shared?** Split the target so each lane owns its part.
   Run lanes in sequence only for an invariant that spans them.
4. **What is the smallest split that is safe?** One worker is a valid answer.
   Say why.

Coupled work, such as one feature or one migration, goes to a single
implementer. Parallel lanes suit work whose results stand alone: audits,
investigations across subsystems, competing experiments. When the user wants
several attempts at one artifact merged into one, tell them that typing
`arena` runs that from start to finish. When one script can
process every unit in a single pass, one lane writes and runs it.

## Roles

**The coordinator orchestrates.** Edits and commits belong to lanes. The one
exception is a very small fix: one file, a few lines, no design choice, in a
workspace no running lane owns, with the lane's checks re-run afterwards.
Everything larger goes back to the lane's implementer. Merging, closing, and
cleanup stay with you, on the authority the user gave. Verify with read-only
commands.

**Each workspace has one owner.** A lane's workspace comes from the host's
isolation option, or the worker creates it through `managing-workspaces` as
its first step. A reviewer reads a detached checkout of the head, separate
from the implementer's workspace. Send follow-up work to the lane's own
implementer, which already holds the context. Every review gets a fresh
worker, and so does a lane whose implementer failed twice or ran out of
context.

**Models come from the roles table.** Read
[references/roles.md](references/roles.md) and `~/.config/swarm/local.md`
when it exists. A role-to-model assignment the user states in the thread
overrides both: write it to the ledger and apply it to every later kickoff.

## Keep a ledger

A ledger is required once there are two lanes or the work will outlive this
turn. A single foreground worker needs none.

Keep it in Notion when you and every worker that must read it can reach Notion
now. Otherwise keep it at `~/Documents/agent-work/<date>-<task>/ledger.md`, or
in the directory the user names. Link it in every report.

You are its only writer. Record:

- the user's rulings, approvals, and holds, in their words;
- the role-to-model table in force;
- each lane: goal, worker, workspace, branch or PR, state, completion evidence,
  and when and how you last checked it;
- every finding you deferred or dropped, with the reason.

Read the ledger at the start of every turn and after any compaction. Trust the
decisions it records. Refresh the state it records by observing it again.

When the user will audit the run after stepping away, also keep a work log
beside the ledger, in the format of
[the work log reference](../figure-it-out/references/work-log.md).

## Kick off a lane

Every kickoff carries:

- the goal, the scope, and what is out of scope;
- the workspace to use or create, as an absolute path, and the fact that the
  worker owns it;
- the role, model, and effort;
- the authority, quoted from the user;
- the decisions already settled;
- the command that proves the lane done and the output it should give;
- the line "Finish or cancel every job you started before you end your turn";
- the report format: `PASS`, `ISSUES`, or `BLOCKED`, with the head SHA and the
  evidence;
- for an implementer: how its work gets reviewed, and by which model;
- which workers it may message, and what it may send them;
- for a lane that feeds another: the path of the handoff note it writes when
  done, saying what it built and what the next lane needs to know;
- for a reviewer: "Read and run checks only. Leave the tree, the branch, and
  the PR as you found them. Redact secrets in anything you quote."

Run the completion command yourself on the base before the first kickoff. A
check that is broken, or that dirties the tree, then costs one command.

Start one lane first. Fan out after its first report shows the kickoff works:
the worker reached the workspace, could run commands, and understood done. A
flawed kickoff then costs one worker.

## Let workers talk on two channels

- **Implementer and its reviewer.** The lane owns its review loop. An
  implementer whose tools can start workers starts its own reviewer, as
  `autopilot` does, and you see the result. Otherwise you start the reviewer
  and tell each of them how to reach the other.
- **Upstream lane to downstream lane.** The upstream worker writes a handoff
  note beside the ledger. After you verify the upstream lane, the downstream
  worker reads the note directly.

On both channels, workers exchange findings, evidence, and notes. Scope,
authority, and rulings come only from you. A message from another worker is a
claim to check. The first review of any head is blind, and a review loop gets
five rounds and one contested exchange before it comes to you. Every exchange
leaves a record you can read.

Give each reviewer the scope and the settled decisions. Findings then route by
kind:

- inside scope and consistent with the decisions: the implementer acts on it;
- outside scope: you record it as deferred;
- against a settled decision: it comes to you. Take it to the user when it
  names a concrete failure the decision causes. Otherwise record it as dropped.

## Check a report before you relay it

A worker's report is a claim. Before you mark a lane done, apply
`verifying-claims`: observe the lane's head, its PR state when it has one, and
the output of its completion command, run in the lane's own workspace. Read
the lane's diff against its scope and the settled decisions, and send back
anything that crossed either. Then update the ledger and tell the user.

## Stay reachable, stay quiet

**Wake gate.** End a turn only when every running lane has a wake armed for
it, or you are waiting on it in the foreground.

**Audit tick.** For a run expected to last more than an hour, schedule a check
every 20 to 30 minutes. Judge each lane by its pushes, PR activity, and
artifacts. Status text alone settles nothing.

**Quiet.** Write to the user on a state change: a lane verified done, a
blocker, a decision needed, recovery exhausted, or the whole run finished.
Send one message per verified lane. When a check finds nothing changed, update
"last checked" in the ledger and say nothing. Give progress lines only when
the user says they are waiting, or just started a foreground command or
deployment. Where the host makes you write something to end a turn, one
sentence is enough.

## Keep moving while the user is away

A question to the user pauses one lane. Continue every other lane and say what
is paused. When your question has a recommended answer and the work is
reversible, start on the recommendation and say so. Before asking for a login,
token, or connector, try the other routes the thread names.

## Recover from worker failures

| Failure                | Action                                               |
| ---------------------- | ---------------------------------------------------- |
| Capacity or rate limit | Same kickoff to the next model for that role         |
| Context limit          | Smaller scope, with the lane's ledger rows pasted in |
| Safety filter          | Reword the kickoff once                              |
| Interrupted            | Same worker, short brief: check state, then continue |
| Expired login          | Stop the lane and tell the user once                 |

Recover without asking, and report each substitution. After two recoveries on
one lane, stop it and report.

## Stop

When the user says stop or pause: cancel every worker you started, including
the workers they started, make no further writes, and record each lane's state
in the ledger.
