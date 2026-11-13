# Host visual surfaces

Read only the section matching the host your session runs in.

## 1. T3 Code (`html_preview` + `html_render`)

T3 Code renders self-contained HTML inline above your final reply.

- Leave `html`, `body`, and the outer wrapper with `background: transparent`,
  `margin: 0`, `padding: 0`, and no outer card border or banner title.
- Never use `vh` units (`100vh`) or `height: 100%` on `html` or `body`; T3
  auto-sizes the frame to content height and rejects viewport-dependent loops.
  Give SVG wrappers explicit pixel heights (for example `156px` desktop, `116px`
  under `620px`).
- Style exclusively with T3 `:root` CSS variables: `--background`,
  `--foreground`, `--muted`, `--muted-foreground`, `--card`,
  `--card-foreground`, `--secondary`, `--secondary-foreground`, `--border`,
  `--ring`, `--primary`, `--primary-foreground`, `--accent`, `--destructive`,
  `--warning`, `--success`, `--info` (plus `-surface` variants where supported),
  `--code-background`, `--radius`, `--font-sans`, and `--font-mono`.
- Call `html_preview` at `width: 728` (light or dark) and `width: 390` (phone)
  to check wrapping, console output, and `contentHeight`, then call
  `html_render` with `title` and `height` set to the desktop `contentHeight`.

## 2. Cursor IDE and Cloud Agents (outside T3 Code)

Cursor provides two distinct visual surfaces. Pick by lifetime:

- **In-transcript answer (`<cursor-content kind="visualization">`):** Use when
  the visual answers a question inside the conversation. Follow Cursor's
  built-in `visualize` skill if present:
  1. Resolve `<store-root>` from `CURSOR_AGENT_STORE_FILES_DIR` (or "Current
     agent's store" in context) and write a raw HTML **fragment** (no
     `<!doctype>`, `<html>`, `<head>`, or `<body>`; one scoped root `id`; zero
     network or external scripts) to
     `<store-root>/visualizations/<slug>.html` without overwriting prior slugs.
  2. Emit `<cursor-content kind="visualization" src="visualizations/<slug>.html"></cursor-content>`
     on its own line in the same turn's final response.
- **Durable workspace artifact (`.canvas.tsx`):** Use when the user wants a
  reusable dashboard, audit, or architecture explorer beside the chat. Follow
  Cursor's built-in `canvas` skill (`~/.cursor/skills-cursor/canvas/SKILL.md`
  and `sdk/index.d.ts`): write one file to
  `~/.cursor/projects/<workspace>/canvases/<name>.canvas.tsx` importing only
  from `cursor/canvas` and `useHostTheme()`, verify `Canvas TypeScript check`
  reports no errors, and link the absolute `.canvas.tsx` path in chat.

## 3. Claude Code (CLI and IDE extensions outside T3 Code)

- **With the `Artifact` tool available and signed in:** Write a self-contained
  `.html` file in a temporary directory outside the repository and publish it
  with `Artifact` so it opens as a live, interactive `claude.ai` artifact
  (`Ctrl+]` reopens it, and subsequent publishes update it in place).
- **Without `Artifact` (or when signed out):** Keep a compact fenced `mermaid`
  diagram and Markdown table inline in the terminal reply, and write the
  interactive `.html` file to `/tmp/<slug>.html` with its path when the user
  asked for `viz` or an interactive simulator.

Support both `@media (prefers-color-scheme: dark)` and `:root[data-theme="dark"]`
(`#fcfcfb` light surface, `#1a1a19` dark surface).

## 4. Claude Chat and Cowork (`claude.ai` and Claude Desktop)

Create a self-contained HTML (`text/html`) or React Artifact so it opens in the
side panel beside the conversation (and expands full screen). Support light and
dark themes via `prefers-color-scheme`, embed all data inline, and keep the
chat message to the direct recommendation and open questions.

## 5. ChatGPT and Codex (outside T3 Code)

- **ChatGPT web and desktop:** GPT-6 Intelligent UI natively composes inline
  interactive cards, tappable selectors, and charts inside the conversation
  when structured clearly. When custom multi-step simulation or SVG state
  toggling exceeds native inline widgets, also provide a single self-contained
  `.html` file the user can open locally (note that legacy ChatGPT Canvas HTML
  preview was retired in 2026).
- **Codex CLI and desktop app (outside T3 Code):** Codex transcripts render
  Markdown, so lead with a concise Markdown matrix and fenced `mermaid` diagram
  inline, and write a standalone `/tmp/<slug>.html` page linked by path when the
  user requests `viz` or a stateful explorer.

## 6. Notion pages (`create_attachment` + `<embed>`)

When embedding a visual into a Notion RFC, spike, or post-mortem:

1. Build one self-contained `.html` file under 200 KiB matching Notion's `#fcfcfb`
   light and `#1a1a19` dark surfaces, with `min-height: 100vh` on the root card
   so bottom-row hover/focus tooltips can flip upward inside Notion's iframe.
2. Upload via `create_attachment` (`filename: "<slug>.html"`, omit
   `content_type`) and place `<embed source="file-upload://..." />` (`source=`,
   never `src=`).
3. Immediately follow the `<embed>` with a collapsed `<toggle>` holding the same
   data as a plain Markdown table for search and screen readers.
