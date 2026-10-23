---
name: t3code-remote
description: Connect outside agents to T3 Code over remote MCP with OAuth, troubleshoot connection or permission failures, and read or steer projects and threads in the connected environment.
---

# T3 Code remote access

Use the environment's remote MCP server to work with T3 Code from an agent that
T3 Code did not start.

## Choose the workflow

- Already running inside a T3 thread: use its app-owned tools and injected
  instructions. Configure an outside-agent connection only when that is the
  user's task.
- Outside agent: reuse an existing connection to the requested environment.
  For setup, login or permission failures, or revocation, read
  [connection and access](references/connection.md).
- Script on the environment's host: read
  [the host CLI reference](references/host-cli.md).

## Work in the connected environment

Discover the tools actually exposed by this connection and inspect the relevant
schemas. Tool availability and names can differ from those injected into agents
inside T3 Code; use advertised operations rather than assuming internal
delegation tools are available.

Resolve the target project and thread from live reads before sending work.
Read the thread's current state and recent context before continuing it. For a
requested model or provider, check the live catalog and supported options before
starting a thread. Starting, messaging, or stopping a thread must stay within
the user's requested work and the OAuth grant.

Retain returned thread and run identifiers. Use available read/status/wait
operations to distinguish an accepted request, active work, a pending user
answer, a failure, and a completed reply. If a start request has an ambiguous
result, inspect existing threads before retrying to avoid duplicate work.
Completion requires the requested result, with any remaining question or
permission boundary reported clearly.
