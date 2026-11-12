# Feature map

The feature map is a `features/` directory beside the verification skill's
`SKILL.md`: an index and one file per user-facing feature.

## The index

`features/README.md` holds what every feature file shares:

- **Baseline.** How the app is launched for verification, the disposable data
  directory, the seed data, and the doctor check that must pass first.
- **Driving rules.** The harness commands, and the rule that commands and
  names are literal.
- **Proof rules.** What every proof captures, and how to report a feature that
  could not be reached: the command tried and the missing prerequisite. A
  feature driven through one entry point is not proven through another.
- **The list.** One line per feature file.

## A feature file

An H1 title, one paragraph on what the user can do, then four sections in
this order:

1. `Sub-features`: a short id and one line for each behavior.
2. `How to get to it (user POV)`: every way a user reaches the feature.
3. `Driving it with <harness>`: a `Preconditions:` list, then one bullet per
   step pairing the user's action with the exact command and what it shows.
4. `Gotchas`: traps that waste a run or make it prove the wrong thing.

Keep implementation detail out. Name only user paths, stable handles, the
state the steps need, the commands, and what proves the result.

## Example

For an invented bookmarks app with a web UI and a command line, driven by a
helper script the skill ships as `scripts/drive`:

```markdown
# Save a bookmark

A user saves a link with a title and tags, from the browser or the terminal,
and finds it again in the list.

## Sub-features

- `save-web`: saves from the Add dialog.
- `save-cli`: saves with `shelf add`.
- `save-dup`: refuses a link that is already saved.

## How to get to it (user POV)

- Choose `Add` in the toolbar.
- Press `a` with focus outside a text field.
- Run `shelf add <url> --title <title>`.

## Driving it with scripts/drive

Preconditions:

- `scripts/drive doctor` passes for this run's instance.
- No bookmark for `https://example.test/a` exists.

- **Open.** Choose `Add`. Run `scripts/drive web click --role button --name "Add"`. A dialog named `Add bookmark` opens.
- **Save.** Fill the link and title, then save. Run `scripts/drive web fill --role textbox --name "Link" --value "https://example.test/a"`, the same for `Title`, then `scripts/drive web click --role button --name "Save"`. The list shows the new title.
- **Stored.** Read it back another way. Run `scripts/drive cli -- shelf list --format json`. Exit code 0, and the output holds the link.
- **Duplicate.** Save the same link again. A status named `Already saved` appears, and the list count is unchanged.
- **Proof.** Run `scripts/drive web screenshot --path evidence/save/list.png` and keep the command output beside it.

## Gotchas

- Pressing `a` inside a text field types the letter.
- Titles are trimmed on save. Compare the shown title, not the typed one.
- Remove the saved bookmark in cleanup. Keep the evidence.
```
