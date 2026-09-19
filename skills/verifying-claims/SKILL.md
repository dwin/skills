---
name: verifying-claims
description: Establish the state of a pull request, branch, secret, deployed resource, or file by observing it rather than inferring it. Use when work depends on external state, when about to report that something does not exist, or when another skill needs a reusable evidence discipline.
---

# Verifying Claims

Separate what you observed from what you concluded. Only the first is evidence.

## Name the claims before investigating

List every claim the work depends on and the command that settles each one.
Some claims need a short sequence rather than a single command, and a claim of
absence always does. Show the list. A claim with no command behind it is a
guess, and must be labelled as one when reported.

## Observe before concluding

Run the command before stating the conclusion, and show its output beside the
conclusion it supports. Every claim resolves to exactly one of three verdicts,
and they never collapse into each other:

- **Observed** — the command ran and its output supports the claim.
- **Contradicted** — the command ran and its output refutes the claim.
- **Unverified** — the command failed, the resource was unreachable, or no
  command exists. Report it as unverified and continue. Do not substitute an
  inference for the observation you could not make.

Reporting a conclusion as observed when the command never ran is the failure
this skill exists to prevent. An unverified claim costs the user a moment. A
fabricated observation costs them the decision they made on top of it.

## Redact what you show

This skill has you quote command output, and the state worth verifying often
sits next to credentials. Redact every secret, token, key, and personal
identifier before showing output, writing `<REDACTED>` in its place. Quote only
the lines carrying the signal, and prefer a value's hash or length over the
value. A secret's presence, absence, or equality across two places is almost
always the claim, and none of those require revealing it.

If the redacted output no longer supports the verdict, say so and ask the user
rather than pasting the unredacted original.

## Hold absence to the highest bar

Absence of evidence is the weakest available claim, so it requires the most
work. Before reporting that something does not exist, search at least two
vocabularies: the domain-specific name the requester used, and the generic name
the codebase would plausibly use for the same concept. Report where you looked.

A single-vocabulary search that returns nothing is unverified, not absent.

## Treat state as timestamped

Every observation is true as of the moment it was made. A result gathered
before the last push, deploy, rebase, or apply is a memory rather than an
observation. Re-run it before acting on it.

When a prior observation and a current one disagree, the current one wins and
the disagreement is itself worth reporting.

## Report

State each claim, its verdict, and the command that produced it. Keep
unverified claims visible in the summary instead of dropping them, so the user
can decide whether the gap matters.
