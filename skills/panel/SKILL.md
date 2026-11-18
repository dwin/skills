---
name: panel
description: 'Convene three independent reviewers on the same change or design. Use when the user asks for a panel, including "panel 9.5" for a minimum score from every reviewer.'
disable-model-invocation: true
---

# Panel

For implementation review, settle known in-scope issues and outstanding PR
feedback and run relevant checks before round one, when edits are authorized.
For feedback only, review the current state. For brainstorming, give everyone
the design question and constraints. Skip repairs to code being discarded.

## Resolve model families

At the start of each panel, resolve every named family to its newest stable
release available for delegation on this account, unless the user specifies a
version. Use the provider's family-specific stable alias or its release dates
and numeric versions to identify the newest release. Pass the model ID the
catalog advertises. Keep the lineup for subsequent rounds when available.

## T3 Code

Use Claude Opus and Codex GPT Sol at `xhigh`. For the third seat, select the
first available family in this order:

1. Moonshot Kimi Pro. Look up Cursor first, then the other configured
   providers. Select the newest available Pro release across them, preferring
   Cursor when it offers that release. Use `max` when advertised, otherwise
   the provider default.
2. Gemini Carbon at `high`.
3. Codex GPT Astra at `xhigh`.

Record each reviewer's actual model, provider and effort (or `provider default`).

In T3 Code, call `orchestrator_capabilities` once before the first delegation
in the thread. Resolve each seat to a child-capable provider instance, model ID,
and advertised effort option. If the catalog is truncated, use its search.
If a required tool or fixed seat is unavailable, or all third-seat options are
exhausted, report the blocker before launching the round.

Launch three independent `delegate_task` calls in parallel, one per seat.
Set `target.providerInstanceId`, `target.model`, and any selected effort
field in `target.options`. Use the shared checkout for read-only reviews so
each child can see pending edits.
Track each task and follow its returned `next` instruction. If a provider rejects the third seat as unavailable at dispatch,
refresh capabilities and continue down the list for that seat only. For other failures,
report the affected seat and keep the round marked incomplete.

## Native harnesses

Outside T3 Code, use the active harness's own independent reviewer sessions.
Resolve models from the catalog available to child sessions on this account.
Use these priorities from left to right:

- **Claude:** latest stable Opus, then Fable.
- **ChatGPT / Codex:** latest stable Sol, then Astra.
- **Cursor:** latest stable Grok, Gemini Carbon, then Opus.
- **Copilot:** latest stable Sol (use Astra if Sol is unavailable), Gemini
  Carbon, then Opus. If a seat is still open, consider the unused Astra.
- **Other harnesses:** start with the active model, then other distinct
  native models available for code review in the host's recommended order.

Fill up to three seats with distinct current models first. For open seats,
consider the preceding generation of each listed family in the same order.
Count aliases for the same model once. For example, Codex can select current
Sol, current Astra, and the previous Sol. If seats remain, cycle through the selected models
in priority order until there are three independent reviewers. With one
available model, run three fresh sessions using that model.

Use the host's native delegation tool and launch the reviewers in parallel
when supported. If children can only inherit the active model, use that as
the sole available choice. If the host cannot launch independent sessions,
report the limitation. Record the model and effort the host actually used.

## Run and report each round

Give all three reviewers the same scope, snapshot, acceptance criteria and
check results. Ask each to leave files untouched and return findings with
evidence, impact and suggested fixes.

For code review or `panel N`, ask every reviewer for a score out of ten and
what would change it. For design feedback, collect alternatives and tradeoffs.
In the thread, identify each reviewer's conclusions, disagreements, and which
recommendations you accept or decline. Keep changes within the original scope.

When edits are authorized, apply accepted fixes, rerun relevant checks, and
start three fresh tasks with the updated snapshot, earlier findings and any
unresolved objections. Count each full pass as one round. For `panel N`, stop
when every reviewer reaches N in the same round. Otherwise stop when all three
are satisfied. If further progress needs a user decision, report the blocker.
For feedback only, return the findings after the requested review.

Report the round count and a table with one row per reviewer seat and one
column per round. Identify the actual model for each score, including repeats. Transcribe each score or write `no score` when omitted.
A missing score cannot meet a numeric target. When maintaining an open PR
within the user's authorization, update a single `## Panel review` section
of its description with the same results, preserving the surrounding text.

[T3 Code orchestration contract](https://github.com/pingdotgg/t3code/blob/8cf97b5f06f30a872ce30ab8a888f2ff012365a2/docs/orchestration-v2/orchestrator-mcp-server.md)
