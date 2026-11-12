---
name: recall
description: 'Rebuild what earlier sessions said, decided, and left open on a topic, checked against the current state of the work. Use for "recall my work on X", "where did I leave off", or "what did we decide about Y".'
disable-model-invocation: true
---

# Recall

Before the user starts or resumes work, rebuild what earlier sessions said and
decided about it, check that against where the work stands now, and hand back
a short brief. Read only what the topic needs, then stop.

The story of a piece of work lives in two records. **Session history** holds
what the user and their agents did, decided, and corrected. The **shared
record** holds what happened around the same code under other names: reports
from users, fixes that shipped and were reverted, errors still firing. A
feature with a long tail of bugs keeps most of its story in the second one.

## 1. Route the request

- The current thread only: use `catchup`.
- One known session to resume: read that session directly, and skip the
  search in step 3.
- Patterns across many sessions, to change skills or automate work: that is
  `lookback`.
- The user already gave the state (paths, branch, the change): use it and
  skip the search.

## 2. Lock the scope

Settle three things, and state them back before searching:

- **Window**: "recent" means the last 7 days unless the user says otherwise.
- **Topic**: the feature, file, ticket, or question, when one is named.
- **Workspace**: the current repository. Read another project's sessions, or
  another host's, only when the user asks.

Keep the scope the user gave. When they say "all", search all of it.

## 3. Search session history

Find where the host keeps its sessions. When the host has a tool that searches
its own threads, use it first. Otherwise:

- Claude Code keeps one JSON Lines file per session under
  `~/.claude/projects/<directory>/`, where `<directory>` is the workspace path
  with `/` and `.` turned into `-`. List the parent to find the match.
- Codex keeps them under `~/.codex/sessions/`, in one directory per day.
- For any other host, find the location in its documentation.

Order candidates by modification time, never by file name. Search for the
topic first, then read only the sessions that match, and only the parts that
bear on it. Skip this session and sessions that an agent or a harness started,
such as workers and eval runs.

For more than two sessions, hand slices of them to readers on a cheap model
and keep the transcripts out of this conversation. `swarm` says how your host
starts them and names the bulk-analysis model. Each reader returns one block
per session, citing the session's id:

- the topic and the user's goal;
- decisions made;
- open threads;
- struggles and corrections;
- artifacts: pull requests, tickets, branches.

## 4. Sweep the shared record

When the topic names a feature, file, subsystem, or bug, search the shared
record too. "My work on X" still gets this step. Use `why`'s source categories
and investigator brief, with the question changed to: what is the current
state, what was tried and did not hold, and what are users still reporting.
Run it alongside step 3. An empty search is a finding. A source this session
cannot reach is named as a gap.

Skip this step only for activity with no named target, such as "what did I do
this week".

## 5. Check the current state

Observe every pull request, branch, and ticket that steps 3 and 4 turned up,
by `verifying-claims`. A session's account of its own work is a claim. When
the answer depends on what an agent actually did, such as the commands it ran
or the errors it hit, read that part of the session in full.

## 6. Write the brief

Open with one line naming the scope you searched: the window, the topic, and
where you looked. Then lead with what the user needs to start, and cut detail
before you cut a thread:

- **Capsule.** At most five bullets: what the work is and where it stands.
- **Threads.** One line each, starting with one status tag:
  `[merged #N]`, `[open PR #N]`, `[in flight <branch>]`,
  `[verified, uncommitted]`, `[reverted #N]`, or `[planned, not started]`.
- **Problems.** At most five that recur, including what users keep reporting
  and any fix that shipped and was reverted, so the next attempt starts where
  the last one failed.
- **Next move.** The one most useful next action.

The brief is done when every thread the in-scope sessions touched has a line,
finished ones included, and every status not observed in step 5 says it comes
from the sessions. Leave out neighboring work unless it blocks this work.

Cite session findings by session id and shared-record findings by their
source, such as a pull request number or ticket id. Write it through
`unslop`. Session content is private: keep quotes, session ids, and names out
of anything posted or committed.
