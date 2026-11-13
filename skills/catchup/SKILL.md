---
name: catchup
description: Catch the user up on work in flight in plain words, covering what changed since their last message, where each piece stands, and every decision waiting on them. Use when the user asks "where are we", "catch me up", "what's the status", or "still going?".
---

# Catchup

Tell the user what changed since the last message they wrote, so they
understand each change and not only where it stands. Then lay out every
decision waiting on them, with enough in the reply to make each one without
opening anything else.

Assume the user remembers their last message and nothing after it.
Notifications, tool results, and reports from other agents are not their
messages.

When the user wants to pick up work from earlier sessions rather than this
thread, tell them that typing `recall` rebuilds it across sessions.

## Gather

Keep this turn read-only: change no code, start no job or application, and
post nothing. Collect:

- your own work since their last message;
- reports from agents you started, and messages from anyone else in the
  thread;
- the ledger and the work log, when the run keeps them.

Then observe the current state of every pull request, check run, deployment,
and agent the thread touched, by `verifying-claims`. A report from earlier in
the thread is a memory, not the current state. Check each number you will
show against its source, and say so when you correct one.

An **action item** is a step only the user can take: a product choice, an
approval, an action that cannot be undone, or access you lack. Include every
one still open, including those raised before their last message. Work you
can still do yourself belongs in your own next steps, and a step the work does
not need belongs nowhere. Report only real items.

For each item, collect its link, what it changes for users, the evidence
behind your recommendation, its risk, and the recommendation. Write "unknown"
for a fact the decision needs that you lack. One decision can cover many
items, such as several pull requests waiting to merge.

## Write plainly

Write like one person catching another up: plain words and short sentences.
Say what changed for the user, not how you did it: "the tests pass", not "CI
is green". Leave out hashes, file paths, commands, build numbers, and test
counts unless the user needs one to act. Call each pull request, branch, or
agent by a name the user knows. Give a fact the context it needs, or leave it
out. Run the prose through `unslop`.

## Shape the reply

1. **Open with one sentence** naming what waits on the user, or saying that
   nothing does. When nothing happened and nothing waits, say so and stop.
2. **Show what happened.** Pictures first: screenshots and recordings the work
   produced, then any diagram that explains a change. Then one bullet per
   thing the user asked for, saying what came of it and whether it is done,
   running, failed, or unchecked. Write each bullet the way you would say it
   aloud ("search was slow because of a missing index"), and make it true when
   read alone. Name any bug found and fixed on the way. Mark nothing done that
   still waits on the user, and leave to the action items what they cover.
   Add at most three short lines that change what the user knows or must do,
   then one line naming the work you can still do yourself.
3. **List the action items**, riskiest first. For each, ask the decision the
   user owns, such as merge, approve, or pick, and give your recommendation.
   The recommendation includes any step you would take first and anything
   that cannot be undone. Give the number or link of every pull request,
   issue, or agent the decision is about.

Fit each item to its decision:

- **One item, one decision.** One bullet: the decision, your recommendation,
  what it changes for users, the evidence, and the risk.
- **Several items, one decision.** State the decision and your recommendation
  once. Then give each item a bullet with its link, what it changes for users,
  the evidence, and the risk. Give an item its own recommendation only where
  it differs.
- **A choice between options.** Give every option the work weighed, each with
  what it gets the user, what it costs, and its current state when it has
  one. The costs are the risk.

State every item's risk, including a low one: "low risk: only the colors
change". Say what waiting costs only when it is more than delay, such as a
deadline or lost data.

## Length

Spend words on the decisions, not the story. Keep what happened under 100
words, not counting pictures, and shorter when less happened. Give each action
item about 30 words. The reply grows with the number of items. Keep every item
whole: a count or a bare link in place of an item leaves the user unable to
decide. A link can add depth, but the reply alone must be enough.

## Visuals

A visual is a picture: a screenshot, a recording, a Mermaid diagram, a chart,
or a generated image. A Markdown table is not a visual.

Draw when a picture explains faster than sentences: how a design or system
works, a chain of dependent pull requests with each one's state, a before and
after, or options side by side. Status lists and action items stay as text,
and every box in a diagram connects to another. Show each fact once, across
the text and the visuals.

Keep each visual small: at most six boxes, at most eight words in each, with
labels in words a person would say. Use a Mermaid diagram for how things
connect, and a chart for numbers when the host can render one. Draw only from
facts you have. Show only screenshots you captured. When a visible change has
none, mark its bullet "no screenshot yet" and say what changed on screen. Link
only artifacts that exist.
