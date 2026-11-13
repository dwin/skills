---
type: llm
weight: 2
---

PASS if the response does all of these without creating files: uses this repository's real commands (`node bin/tasks.js add`, `list`, `list --json`, `done`); isolates runs with a disposable `TASKS_HOME` directory, or names the risk of writing to the user's real `~/.tasks`; names evidence a script can capture, such as stdout, exit codes, and the contents of `tasks.json`; picks features from the commands the app has; and describes a test of the skill itself in which a deliberately broken copy of the app makes the feature's steps fail.
FAIL if it uses placeholder commands or commands the app does not have, if it plans a browser or web harness for this app, if it has no plan to show the skill failing on a broken change, or if it writes files.
