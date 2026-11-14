---
name: visual-explainer
description: Render interactive visual explanations, architecture simulators, option tradeoff matrices, permission or blast-radius maps, and phased rollout cards on the host's native visual surface. Use when answering a question that compares three or more options across multiple dimensions, traces a multi-gate request or state flow, maps permissions or blast radius, lays out a multi-phase architecture plan, or when the user asks to visualize or sends `viz`.
---

# Visual Explainer

Compress dense engineering answers into an interactive visual card so the user
can click scenarios, toggle options, and act in seconds rather than reading
walls of prose.

## When to render vs stay in plain text

Render an interactive visual when the answer:

- Compares three or more options across multiple evaluation dimensions.
- Traces a request, authentication, permission, or state flow across three or
  more gates or components.
- Maps blast radius, tenant or role permissions, or **Today vs Target** state.
- Lays out a multi-phase rollout or architecture plan alongside its tradeoffs.
- Responds to an explicit visualization request or the standalone `viz` alias.

Stay in plain text (a short paragraph, a small Markdown table, or a fenced
Mermaid block) for simple factual lookups, single-file bug reports, routine git
or CI checks, and one-decision answers.

## 1. Pick the host surface

Check what rendering or file-writing tools this session actually exposes before
choosing a surface. In a read-only session with neither a host visual tool nor
file-write access, deliver a compact Markdown comparison matrix and a fenced
`mermaid` diagram inline without attempting unavailable writes.

Otherwise, identify the host this session runs in and read the matching section
in [references/surfaces.md](references/surfaces.md):

| Host                                                     | Surface to render on                                                                                                                                                 |
| -------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **T3 Code** (`html_preview` and `html_render` available) | Inline HTML card via `html_preview` (`width: 728` and `390`) then `html_render`                                                                                      |
| **Cursor IDE / Cloud** (outside T3 Code)                 | In-transcript HTML fragment (`<cursor-content kind="visualization" ...>`) for immutable answers, or `.canvas.tsx` (`cursor/canvas`) for durable workspace dashboards |
| **Claude Code** (CLI / IDE outside T3 Code)              | `Artifact` tool publishing a self-contained `.html` page (or `/tmp/<slug>.html` + inline Mermaid/table when signed out)                                              |
| **Claude Chat / Cowork** (`claude.ai` or Desktop)        | Self-contained HTML or React Artifact beside the conversation                                                                                                        |
| **ChatGPT**                                              | GPT-6 Intelligent UI inline interactive cards/charts, or a downloadable self-contained `.html` simulator when custom stateful logic is needed                        |
| **Codex CLI / App** (outside T3 Code)                    | Compact Mermaid + Markdown table inline, plus `/tmp/<slug>.html` linked by path when stateful interaction helps                                                      |
| **Notion** (`create_attachment` available)               | Uploaded `.html` `<embed source="file-upload://..." />` followed by a collapsed `<toggle>` table fallback                                                            |

## 2. Choose the smallest interactive pattern

Pick one primary interaction, or combine at most two panels when the question
has both a flow and a comparison:

1. **Path / Gate Simulator:** Persona or input chips at top -> 3 to 5 stage
   cards showing what each gate checks -> verdict bar with outcome badge and
   audit trail.
2. **Architecture / Option Switcher:** Segmented tabs (`Option A`, `Option B`,
   or `Proposed target` vs `Today's state`) switching an inline SVG topology
   diagram and 3 to 4 key constraint boxes underneath.
3. **Blast-Radius / Access Matrix:** Scannable grid of principals or services
   by targets with semantic status pills (`Allow`, `JIT`, `Read-Only`,
   `Blocked`, `Gap`) and keyboard-accessible hover/focus detail tooltips.
4. **Phased Rollout Card:** Compact `P1` to `PN` list pairing each phase's
   action with its concrete target or gate.

Every visual must make its first paint useful before any click or hover.

## 3. Authoring invariants

1. **Zero external dependencies.** Inline `<style>`, vanilla `<script>` IIFE,
   and inline `<svg>` or semantic HTML (`cursor/canvas` imports only on Cursor
   Canvases). Never load external CDNs, fonts, images, or `fetch()` calls.
2. **Theme-native colors.** Use host CSS tokens where provided (T3 `:root`
   variables or Cursor `useHostTheme()`), and support both light and dark modes
   via `@media (prefers-color-scheme: dark)` and `[data-theme="dark"]` on
   standalone HTML files. Keep surfaces flat: no gradients, decorative shadows,
   or rainbow borders.
3. **Responsive and keyboard-accessible.** Compose for ~728px desktop width
   down to 360px mobile width so grids stack cleanly (`2` or `1` columns on
   narrow screens) and code badges wrap instead of clipping. Use `<button>`
   with `aria-pressed` for toggles, or `role="tab"` with `aria-selected` (and
   arrow-key navigation) inside a `role="tablist"`, and pair hover handlers
   with `tabindex="0"` and `focus`/`blur`.
4. **Truthful data only.** Every role, file, metric, limit, and status comes
   from verified session evidence. Mark unverified items explicitly as open
   questions rather than inventing values.

## 4. Let the visual do the explaining

Do not narrate, announce, or restate what the visual already shows. Keep the
text reply underneath to a few lines covering only:

- The direct answer or recommendation in the opening sentence (when the host
  places text below an inline frame, skip repeating the card's tables).
- Links to created files, pages, or pull requests.
- Numbered or coded open decisions (`Q1`, `Q2`) waiting on the user.
