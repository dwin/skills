# dwin/skills

Portable skills for disciplined software engineering. The skills are small,
composable Agent Skills that share one installable `dwin-skills` plugin for
Claude Code and Codex. Cursor and other Agent Skills clients can consume the
same `SKILL.md` directories directly.

## Available skills

User-invoked entry points:

- `whats-next` chooses the smallest useful workflow for the situation.
- `grill-with-docs`, `to-spec`, `to-tickets`, and `implement` form the main
  plan-to-delivery flow.
- `triage` turns incoming issues and pull requests into agent-ready work.
- `wayfinder` maps efforts too large or uncertain for a single session.
- `improve-codebase-architecture` surfaces deepening opportunities.
- `setup-dwin-skills` configures a repository's tracker and domain docs.
- `grill-me` explicitly starts a rigorous decision interview before action.
- `focus-output` keeps session responses action-first and low-distraction.
- `handoff`, `teach`, `to-questionnaire`, and `wait-what` cover session
  transitions, learning, asynchronous discovery, and clarification.

Model-invoked skills:

- `code-review`, `babysit-pr`, and `file-pr` cover review and pull request
  delivery.
- `diagnosing-bugs`, `tdd`, and `prototype` provide evidence-driven ways to
  investigate and build.
- `codebase-design`, `domain-modeling`, and `engineering-principles` guide
  design and implementation.
- `research` investigates questions against primary sources.
- `resolving-merge-conflicts` preserves both sides' intent during resolution.
- `wizard` turns manual procedures into resumable shell walkthroughs.
- `writing-for-agents` improves durable instructions written for agents.
- `grilling` provides reusable interview discipline for agents and other
  skills.

These entry points are explicit-only. Claude and Cursor read that policy from
their skill frontmatter; Codex reads the equivalent policy from
`agents/openai.yaml`.

## Install

### Claude Code

Add the marketplace, then install the complete skill collection:

```text
/plugin marketplace add dwin/skills
/plugin install dwin-skills@dwin
```

### Codex

Add the GitHub marketplace, then install the complete skill collection:

```bash
codex plugin marketplace add dwin/skills --ref main
codex plugin add dwin-skills@dwin
```

For local development, replace `dwin/skills --ref main` with the absolute path
to this repository.

### Cursor and other Agent Skills clients

Cursor can import this GitHub repository from **Customize → Rules → Add Rule →
Remote Rule (GitHub)**. It discovers the catalog through `.agents/skills/`,
whose entries point to the canonical packages under `skills/`.

For a manual installation, copy or symlink individual skills into a supported
skills directory such as `~/.agents/skills/`:

```bash
ln -s /absolute/path/to/skills/skills/file-pr ~/.agents/skills/file-pr
```

## Repository layout

```text
.agents/plugins/marketplace.json   # Codex marketplace
.agents/skills/                    # Portable discovery links
.claude-plugin/
├── marketplace.json              # Claude Code marketplace
└── plugin.json                   # Claude Code plugin
.codex-plugin/plugin.json          # Codex plugin
skills/<name>/
├── SKILL.md
├── agents/openai.yaml             # Codex UI metadata
└── references/                    # Optional, loaded on demand
```

Each skill directory is a canonical, independently reusable Agent Skill. The
single plugin is the managed distribution unit; product-specific files do not
duplicate skill instructions.

## Validate changes

```bash
npm ci
npm run check
```

The validator checks every skill against the open Agent Skills specification,
runs Claude Marketplace Lint in strict mode, installs the Codex plugin in an
isolated configuration, and checks Markdown, formatting, JSON, shell scripts,
and GitHub Actions syntax and security. CI runs the same command on every pull
request.

The checks are:

- `claude plugin validate . --strict` for Claude marketplace and plugin schemas;
- `agentskills validate` for portable `SKILL.md` packages, after normalizing
  recognized client-only invocation metadata;
- an isolated `codex plugin add` smoke test for the catalog entry;
- Markdownlint, Prettier, `jq`, ShellCheck, and `bash -n` for repository files;
- actionlint and zizmor for GitHub Actions correctness and security; and
- `npm audit` for the locked Node-based validation toolchain.

Claude and Codex manifests use matching semantic versions. Bump both manifests
when publishing a plugin release.

## Attribution

The initial versions of the imported skills are adapted from
[Matt Pocock's skills collection](https://github.com/mattpocock/skills). The
original `ask-matt` and `setup-matt-pocock-skills` entry points are named
`whats-next` and `setup-dwin-skills` here. See
[`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md) for the MIT license notice.

`focus-output` is inspired by Ayoub Ghriss's
[`i-have-adhd`](https://github.com/ayghri/i-have-adhd) skill. See
[`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md) for the MIT license notice.
