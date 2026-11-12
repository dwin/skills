# Sources

What each evidence category holds, what it is best at, how to search it, and
what to return. Give an investigator only its own category's section, plus the
incident searches at the end when the target is defensive code. The tool names
differ between products in a category, so read the connected tool's own
instructions and adapt the searches to it.

Every category shares four rules:

- Bound each search in time, usually about 30 days either side of the date
  the target changed. Widen only for a reason.
- A source you cannot reach, or whose retention ends before the date you
  need, is a gap. Report it as a gap, not as an empty result.
- Finding a signal shows someone cared enough to record it, not that the code
  exists because of it. Pair it with a commit or pull request date before
  claiming a cause.
- When authentication fails, stop and report the source as unsearchable.
  Return no findings from it.

## Source control

Commits, pull requests and their reviews, code comments and TODOs, ADRs kept
in the repository, tests, changelogs, and ticket IDs in commit messages. It is
tied directly to the code and always reachable. Best at the reasons given at
implementation time and in review.

```bash
git log --follow --oneline -- <file>          # history through renames
git log -S '<exact text>' -- <file>           # commits that added or removed it
git log -G '<regex>' -- <file>                # the same, by pattern
git blame -L <start>,<end> <file>             # last change to each line
git show <commit>                             # one commit in full
gh pr view <number> --json body,comments,reviews
gh api --paginate repos/{owner}/{repo}/pulls/<number>/comments
```

The second command returns the comments left on individual lines. `gh pr view`
gives only the conversation and each review's summary.

Also search for ADRs (`docs/adr/` and similar), for `TODO`, `FIXME`, `HACK`,
and `NOTE` near the target, for tests that name the target's symbols, since
their names and assertions often record the edge case that motivated a
change, and for files changed in the same commits.

## Issue tracker

Issues with their descriptions and comments, parent and child issues, attached
specs, labels, milestones, and linked pull requests. Best at the product or
business reason, especially when the reason came from outside engineering.

1. Fetch the tickets the anchor already names, and read each in full,
   comments included.
2. Search by the feature name, the key symbols, and the business terms, in
   several phrasings.
3. Walk up to the parent issue. Child issues are tactical, and the parent
   often carries the reason.
4. Read specs attached to the issue or its project.
5. Note labels and milestones, which hint at the kind of reason (customer
   request, incident follow-up, compliance) and at deadlines.

Pitfalls: a ticket reopened with a different scope, a "why" section filled
with boilerplate, a plan that changed after the ticket was written, and chains
of duplicates. Follow duplicates to the canonical ticket.

Return for each ticket: its ID, title, and link; the motivation quoted
verbatim; its labels, parent, and project; and its author and dates.

## Long-form docs

Design docs, specs, RFCs, ADRs, design-review notes, postmortems, and
runbooks. Best at reasoning written out before it became code: a significant
feature usually has a doc.

1. Search by the feature name, the key symbols, the author's name, error
   strings, and terms a user sees.
2. Read each candidate page whole. The reason is often mid-document.
3. Follow child pages and backlinks, such as "alternatives considered".
4. Search meeting notes from the weeks before the change.

Pitfalls: a spec written before the work and never updated, a doc that says X
while the code does Y (report the divergence), several drafts of one doc (find
the final one), and pages you cannot open (a gap).

Return for each doc: its title and link, its authors and last update, the
motivating text quoted with its section, related pages, and whether it was
final or a draft.

## Team chat

Discussion that never reached a doc. It matters most when the commit, ticket,
and doc trail is thin.

1. Search messages from the pull request's author around the merge date.
2. Search for the pull request's URL or its number.
3. Search for error strings the code handles. Incident threads often surface.

Pitfalls: retention that ends before the date you need (report where it ends),
direct messages you cannot search, jokes read as decisions, and a single
message read without its thread. Always open the whole thread.

Return for each thread: the channel, the date, a link, and the relevant
messages quoted.

## Infrastructure observability

Metrics, monitors and alerts, dashboards, traces, logs, and incident records:
what happened in production, as opposed to what was planned. Best at the
runtime conditions behind timeouts, retries, rate limits, and circuit
breakers.

1. Find the service that owns the target and its neighbors.
2. Search dashboards and monitors first. A monitor's threshold often answers
   "why is this capped at N".
3. Read the metrics around the target's change date. A spike just before the
   merge and stable values after are strong supporting evidence.
4. Search logs by symbol, error string, or feature name, narrowly and
   aggregated rather than dumped.
5. Read traces for slow paths and calls across services.
6. Search incidents near the change date. An incident timeline that names the
   fix is close to direct evidence.

Pitfalls: other changes that landed in the same window, so check the
neighboring pull requests; a chart that reflects its maker's framing; and
metrics renamed or expired.

Return for each item: its kind, name, and link or ID; its owner and dates; the
exact query, condition, or threshold that bears on the question; and how
strongly it connects to the target.

## Error tracking

Exceptions and their history. Best at the specific errors behind defensive or
corrective code: catch blocks, null guards, type checks, and retries.

1. Search by the exception types the target handles, its function and file
   names, and the error strings it checks for.
2. For each candidate issue, read when it was first and last seen, the
   releases it affected, and how often it occurred. An issue that stops at the
   target's release is strong evidence.
3. Open a full event and check that its stack trace passes through the
   target.
4. Match release versions to the pull request's merge date.

An automated root-cause analysis from the tool is a hypothesis. The events and
stack traces are the evidence.

Return for each issue: its ID, title, and link; first and last seen; event
count; affected releases; a short verbatim stack excerpt that shows the
connection; and any resolution notes.

## Product analytics

Event data, experiment and feature-flag exposure, usage and billing data,
warehouse query history, and data-pipeline lineage. Best at the product and
data facts behind flag-gated code, experiment-driven launches, data
migrations, and "where did this number come from".

1. Find the tables first. Schemas differ between companies, so list and
   describe tables before trusting a name. A result from a table you never
   confirmed exists is a classic failure.
2. Prefer modeled, deduplicated tables over raw event streams, and drop to the
   raw data only for recent events a model has not picked up yet.
3. Useful shapes:
   - daily counts of an event across the change date: a step up suggests a
     launch, and a decay to zero suggests a removal;
   - the distribution of a value before the change: a 99th percentile that
     matches the target's constant suggests the number came from data;
   - exposure by variant for the target's feature flag;
   - query history for the tables a migration or rewrite touched.

Pitfalls: a jump in volume that comes from new logging rather than new
behavior (check for instrumentation changes in the same window), properties
that did not exist when the target was written, refresh lag in modeled tables,
and analyses kept in notebooks the query tool cannot reach (a gap).

Return for each finding: its kind, the full table name and the exact query,
the time window, a compact numeric summary rather than raw rows, how its
timing lines up with the change, and how strong it is.

## Incident searches

Add these to every category when the target is defensive code: a null check,
a retry, a timeout, a rate limit, a feature flag, an egress guard, or a memory
guard.

- **Tracker.** Tickets labeled as incidents, severity levels, postmortem
  action items, or reliability.
- **Chat.** Incident channels around the date the target was added.
- **Source control.** Commits that say "fix for incident" or "add defensive
  check", and a revert followed by a re-apply.
- **Docs.** Postmortems that name the target, its symbols, or its error
  strings.
