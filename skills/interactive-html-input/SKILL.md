---
name: interactive-html-input
description: Collect choices and notes in long browser questionnaires with a local durable runner, or protect and recover answers in generated interactive HTML forms, decision reviews, and surveys.
---

# Interactive HTML Input

Keep the requested interactive experience while protecting the user's work.
Static charts, filters, navigation, and disposable demo state do not need a
persistence subsystem. Choices and notes the user expects to keep do.

## Long questionnaires: prefer the local runner

When a local Python process and a regular or T3 browser are available, use the
bundled [questionnaire runner](references/local-runner.md) for substantial
questionnaires. It uses Python 3 standard library, SQLite, and vanilla browser
controls; no package install or remote service. Write a declarative form with
stable IDs, choose an explicit task-owned state path, launch the runner, and
open its reported loopback URL. Keep its process available while the user works.
Choices and notes commit to disk; CLI export works after the server or browser
stops. Verify recovery with synthetic input before collecting real answers.

In T3, open the actual browser pane with `preview_open` using
`target: {kind: "environment-port", port: <reported port>, path: "/#token=<reported token>"}`.
Preserve the reported loopback origin. Some T3 versions rewrite that target to
`localhost`, which this runner rejects. On a local desktop host, retry with
`preview_open` and `url: <exact reported 127.0.0.1 URL>`; verify it loads and saves.
If the host proxies to another origin or cannot reach that address, report the
limitation and open the exact URL in a browser on the machine running the helper.
Do not loosen Origin checks, CORS, or sandbox permissions. `html_render` is
not a verified persistence/network host; inline rendering is optional and must
be tested separately. The runner intentionally rejects embedding in frames.

For a few questions, or when a local runner/browser is unavailable, use native
questions or chat and record submitted answers through a verified durable write.
Unsubmitted native-question drafts have no assumed recovery guarantee. Keep
long-form browser collection as the preferred experience when available.

## Before collecting answers

Check the actual delivery host and sandbox for persistence, download, and
Clipboard capabilities before asking for substantial input. A standalone page,
a file viewer, and an inline frame may have different permissions. Browser
storage such as `localStorage` can be useful, but its availability and recovery
scope need verification in that surface.

Declare where answers are kept and what they survive: reload, reopening the
artifact, or application restart. **Saved** means an acknowledged durable write
at that declared scope, with recovery verified. JavaScript memory, a caught
storage error, or a download click is not a save receipt. Show pending and
failed saves visibly; retain the draft and pause further collection if saving
fails rather than silently accumulating answers only in memory.

If the host cannot preserve answers, explain the limitation before collection
and choose or discuss an alternative suited to the requested experience:
submitted native questions or chat recorded through a validated local write,
or a durable app when the full form interaction matters. Do not assume
unsubmitted native-question drafts survive restart. Keep useful HTML reading
and navigation controls; do not replace the user's chosen product without
explaining the tradeoff.

Use documented, available host capabilities. Recheck version-specific behavior
rather than inventing a save API. Preserve sandbox security; broad permission
relaxation is not the default repair.

## Make export usable

Expose the current answers as selectable text, such as JSON with manual-copy
instructions, whenever download or Clipboard access is unavailable. Keep that
fallback reachable even when an attempted export fails silently. Include all
choices, notes, and recorded timestamps; keep user answers separate from model
recommendations. Report errors visibly instead of announcing success on click.

**Export is a backup, not autosave.** A manually exported snapshot protects
only the state it contains; later edits still need saving. Label session-only
state and pending changes accurately.

## Verify in the delivery surface

Use disposable answers in the actual host and sandbox. Exercise the real save,
reload or reopen at the declared recovery scope, and compare the recovered
values. Complete a real export, reopen the saved artifact, and compare its
contents. Also exercise blocked download and Clipboard paths and confirm the
selectable output remains usable.

A mocked or intercepted download verifies the payload, not the user's ability
to save it. A lookalike sandbox probe is useful but does not replace delivery
host verification. Report the host/version tested, checks actually performed,
and any unverified persistence or export limits before handoff.

## Recover without destroying the only copy

Preserve the original live view. Before refreshing, rebuilding, navigating
away, or replacing it, extract and save the exact choices, notes, and recorded
timestamps to a separate artifact; read it back and verify equality. Preserve
missing values as missing and distinguish user input from recommendations.
Work on a copy until recovery is confirmed. An embedded recovered snapshot
preserves those answers; it does not establish autosave for subsequent edits.
