# Local workflow patterns

This note records anonymized, directional patterns from locally retained Codex
and Claude Code histories. It exists to guide skill naming and prioritization,
not to profile individual projects or preserve conversation content.

## Strong patterns

- Direct implementation and change requests are the dominant workflow.
- Planning, design, documentation, tickets, and implementation frequently form
  one continuous chain.
- Review, testing, CI, commits, pull requests, and persistent monitoring recur
  often enough to deserve first-class skills.
- Debugging and investigation are common on-ramps into implementation.
- The user prefers short collaborative directives such as “let's,” followed by
  direct verbs including review, fix, commit, push, and continue.
- Decision checks—whether an approach makes sense, or which option to take—are
  common. Neutral task-oriented names fit better than assistant personas.

## Skill implications

The primary flow should be:

1. `grill-with-docs` to settle the plan and preserve its vocabulary.
2. `to-spec` to capture the agreed plan.
3. `to-tickets` for multi-session work.
4. `implement`, using `tdd` and ending with `code-review`.
5. `file-pr` when the user requests a pull request.
6. `babysit-pr` when the user requests persistent monitoring.

Use `handoff` at a true harness, directory, colleague, or side-task boundary.
Use `wayfinder` only when an effort is too foggy for one planning session.

The imported `ask-matt` router is named `whats-next`, matching the user's
preferred conversational phrasing. An earlier `workflow-advisor` name was
discarded after verifying that prior `/advisor` usage invoked Claude's built-in
functionality rather than expressing a naming preference. The imported setup
command is named `setup-dwin-skills`.

`teach`, `to-questionnaire`, and `wait-what` had little explicit historical
demand. They remain available for completeness but should not dominate the
router or marketplace description.

## Safety and limitations

The review used local history indexes and transcript metadata under
`~/.codex/sessions`, `~/.codex/archived_sessions`, `~/.codex/sqlite`,
`~/.claude/history.jsonl`, and `~/.claude/projects`. It did not preserve or
quote secrets, proprietary code, personal messages, project names, or raw
conversation text.

Counts were directional: local retention is incomplete, histories include
subagents and injected context, and keyword categories overlap. Treat these
patterns as product-design evidence, not precise behavioral analytics.
