# Create a verification skill

## 1. Interview the repository

Answer these from the code, and ask the user only what the code cannot show:

- **Surface.** What does a user touch: a web UI, a command line or terminal
  UI, a desktop app, an API, a mobile app, a library? When there are several,
  pick the main one and note the rest.
- **Run.** How does the app start locally? Prefer the project's own
  documented command: package scripts, a Makefile, the README. Note ports,
  environment variables, seed data, and sign-in.
- **Drive.** How can an agent act on it from a script? Use a harness the
  project already has first: browser tests, terminal session helpers,
  endpoints a plain HTTP client can call, a debug port. Only then pick a
  general one: a browser automation library for web and desktop web apps, a
  pseudo-terminal or tmux session for a terminal app, an HTTP client for a
  service.
- **Observe.** What evidence can be captured: screenshots, terminal output,
  response bodies, logs, exit codes, stored data?
- **Isolate.** Can two instances run side by side, with their own ports, data
  directories, and profiles? When they cannot, the generated skill says so
  and refuses to drive an instance it did not start.

When the checkout does not build or start as it is, fix that first or report
exactly what fails. A skill written against a broken base teaches wrong
steps. When a missing file the app does not need blocks startup, such as a
static directory nothing serves or a sample config, the skill may create it,
marked as verification scaffolding, and remove it in cleanup.

The step is done when each of the five has an answer you observed, or a named
gap.

## 2. Write the skill

Write `SKILL.md` with frontmatter: `name: verify-<app>` and a `description`
that names the app, its surface, and when to use it. Without frontmatter the
skill never registers. Then these sections, each from what step 1 found:

- **Launch.** The exact command that starts the app for verification, and how
  to tell it is ready, such as a log line or a prompt. Launch reaches a usable
  state from an empty data directory, including migrations and seed data.
  Ready means usable: a database can answer its health check while its setup
  scripts are still running. Include teardown. For a short-lived command line
  or terminal app there is no server to keep up: launch means build or
  install once, then start each drive in its own isolated session.
- **Doctor.** One read-only check that says whether this instance is worth
  driving: the process is up, it is the expected build, the port belongs to
  this run, sign-in is valid. The agent runs it first, and again whenever
  something looks wrong.
- **Drive.** The harness, with real selectors and commands from this project.
  Prefer stable handles, such as accessible names, data attributes, prompt
  strings, and routes, over coordinates and tab order.
- **Evidence.** What to capture for a proof and where it goes, and the proof
  standards from `SKILL.md`.
- **Cleanup.** How to stop what the run started and remove its scratch state.
  Evidence stays.
- **Helpers.** Every script the skill ships is executable, and the skill shows
  how to call it. A helper the reader has to reverse-engineer is not a
  helper.

## 3. Seed the feature map

Create `features/README.md` beside the skill, and one file for each of three
to five user-facing features. Find them in routes, commands, menus, and docs,
and start with the ones recent commits change most. Follow
[feature-map.md](feature-map.md).

When the seed data lacks something a feature's steps need, the steps report a
failure and the feature's Gotchas say why. Keep the steps as strong as the
feature needs, even when that leaves them failing. The map is the project's
source for verification: a proof that drives one convenient entry point is
incomplete when the map lists others.

## 4. Prove it

1. **Run it clean.** Follow the skill's own instructions end to end once:
   launch, doctor, drive one mapped feature, capture evidence, clean up. Then
   confirm the evidence still exists where the skill says. Fix what fails, and
   run the skill's cleanup after every failed attempt, so broken attempts
   leave no processes or ports behind.
2. **Run it broken.** In a disposable copy of the checkout, such as a
   worktree made through `managing-workspaces`, make the smallest change that
   breaks that feature for a user: a handler that returns early, a command
   that exits 0 without writing. Run the feature's steps there. They must
   fail, and the evidence must show what broke. When they pass, the steps
   check the wrong thing: fix them and run both again. Remove the copy.
3. **Name the stand-ins.** When the proof ran somewhere other than the real
   target, such as a container standing in for a fresh machine, list every
   setup step the stand-in did that the target will not. Those steps stay
   unverified.

The step is done when the clean run passed with its evidence intact after
cleanup, the broken run failed, and the copy is gone.

## 5. Hand off

Report as `SKILL.md` describes, and tell the user that running `verifier` on
the project again keeps the map in line with the app as it changes.
