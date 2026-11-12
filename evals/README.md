# Eval cases

Public cases for this plugin's skills, in the format `claude plugin eval`
reads. They are small invented tasks. The `eval` skill explains how to write,
run, and read them.

Run them from the repository root:

```bash
claude plugin eval . --no-publish --trust-plugin --scaffold --threshold 0
```

Each case runs with the plugin and without it. Results go to `evals/results/`,
which is not committed.

An agent cannot load a user-invoked skill by itself. A case for one starts its
prompt with the command a user would type, such as `/dwin-skills:how`, and
grades what the skill does rather than whether it loads.

| Case                      | Asks                                                                       |
| ------------------------- | -------------------------------------------------------------------------- |
| `absent-or-renamed`       | Is the thing found when the code names it differently?                     |
| `green-means-live`        | Is a merged PR with a green deploy run reported as live?                   |
| `two-models-one-change`   | Does `swarm` load when the user assigns models to roles?                   |
| `plain-edit`              | Do `swarm` and `whats-next` stay out of a request that needs neither?      |
| `tidy-without-changing`   | Is behavior captured in a rerunnable check before a cleanup?               |
| `heap-snapshot-in-hand`   | Does the agent reach the forensics playbook from a leak report?            |
| `two-holders-one-lease`   | Does the agent reach the formal-verification playbook?                     |
| `stricter-date-parse`     | Are the inputs a small change now rejects found before it ships?           |
| `back-from-lunch`         | Does a status catch-up lead with the decision waiting on the user?         |
| `away-for-the-afternoon`  | Is a checkable finish stated before an unattended migration?               |
| `four-retries-not-three`  | Is a constant explained from the record, not the user's guess?             |
| `before-i-post-it`        | Is machine-written prose rewritten with every fact kept?                   |
| `setup-doc-for-new-hires` | Does a setup doc become steps a new engineer can follow alone?             |
| `failing-job-path`        | Does `how` trace a failure path through the code, off-by-one included?     |
| `csv-export-pickup`       | Does `recall` mark a reverted fix and find the planned next move?          |
| `three-takes-on-a-parser` | Does `arena` frame a rubric for the task before any attempt starts?        |
| `conversion-drop-summary` | Does `sharpen` deepen a prompt without doing the task?                     |
| `verify-skill-for-a-cli`  | Does `verifier` plan with the app's real commands and a broken-change run? |
| `what-should-i-automate`  | Does `lookback` ask for its scope before reading any session?              |

Cases built from real work stay out of this repository.
