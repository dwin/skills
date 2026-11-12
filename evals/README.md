# Eval cases

Public cases for this plugin's skills, in the format `claude plugin eval`
reads. They are small invented tasks. The `eval` skill explains how to write,
run, and read them.

Run them from the repository root:

```bash
claude plugin eval . --no-publish --trust-plugin --scaffold --keep-temp \
  --threshold 0
```

`--keep-temp` keeps each run's directory, so a failing run's trace can be
read. The harness prints the directories; the `eval` skill's reference says
how to delete them.

Each case runs with the plugin and without it, so the difference between the
two measures the whole plugin. The `eval` skill explains how to measure one
skill. Results go to `evals/results/`, which is not committed.

| Case                    | Asks                                                          |
| ----------------------- | ------------------------------------------------------------- |
| `absent-or-renamed`     | Is the thing found when the code names it differently?        |
| `green-means-live`      | Is a merged PR with a green deploy run reported as live?      |
| `two-models-one-change` | Does `swarm` load when the user assigns models to roles?      |
| `plain-edit`            | Does `swarm` stay out of a request that needs no other agent? |
| `tidy-without-changing` | Is behavior captured in a rerunnable check before a cleanup?  |

Cases built from real work stay out of this repository.
