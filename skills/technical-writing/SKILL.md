---
name: technical-writing
description: Write technical prose that a tired engineer understands on the first read. Use when writing, rewriting, or reviewing documentation, a README, a design note, a pull request description, a commit message, or a technical message for people to read.
---

# Technical writing

Write so a tired engineer understands on the first read. This skill sets the
structure and the sentences. `unslop` holds the catalog of machine-written
patterns, and runs on every text this skill touches. Documents that agents
read follow `writing-for-agents` instead.

## Three rules above the rest

- **Cut each word that does no work.** If the sentence survives without the
  word, the word goes.
- **Use the short, everyday word.** Write "use", "help", and "do". A longer
  word earns its place with precision.
- **When a rule makes a sentence worse, fix the sentence another way, or
  leave it.** A sentence that obeys every rule and reads like a machine wrote
  it has failed.

State only what the source text or the repository shows. When the reader
needs a step, command, or fact you cannot confirm there, ask the author, or
mark it in the text as unconfirmed. A plausible install step that turns out
wrong costs the reader more than a gap they can see.

Use the codebase's names: the real symbol, file, flag, or command, not a
synonym or a description of it. Use the words a developer says aloud, such as
"move", "delete", and "a limit that only goes down". A named pattern is fine
when the text defines it on first use. When you meet a jargon word that
`unslop`'s list lacks, propose it to the user as an addition.

## Pick the mode first

Every document serves one of four needs: learning by doing (a tutorial),
reaching a goal (a how-to), looking up facts (reference), or understanding
(an explanation). One document has one mode. Before writing a document, pick
its mode with [references/modes.md](references/modes.md), and split a document
that mixes modes into linked parts.

Pull request descriptions, commit messages, and messages have no mode. Go
straight to the sentence rules.

## Vary the rhythm

Text can obey every rule and still read machine-written: every sentence
clipped, no view anywhere, nothing specific.

- Mix sentence lengths. A short sentence lands a point. A longer one carries a
  fact with its condition or its consequence. Split a sentence that holds two
  thoughts, and keep a long sentence that holds one.
- Take a position where the mode allows one. An explanation weighs
  trade-offs, so say what you make of them. Reference stays dry.
- Be specific, with what the source or the repository shows. Write "renaming
  a column fails the build", not "schema changes can cause issues". When you
  do not have the specific fact, find it or leave the claim out.

## Write to the reader

- Address the reader as "you", in the present tense. Use "will" only for what
  happens later.
- Name the actor: "the compiler checks the types". Use the passive only when
  the actor is unknown or does not matter.
- Write instructions as commands ("Run `make check`.") and facts as plain
  statements.
- Put the condition before the instruction ("To clear the cache, run ..."),
  and the warning before the step it guards.
- Put the common case first and the exceptions after it.
- Leave "please", "simply", "easy", and "quickly" out of procedures. If the
  step were simple, the reader would not need the document.
- Describe what exists now. Announcements of future support belong elsewhere.
- Write link text that names where the link goes. A sentence of context on
  the page beats a link away from it.
- Make each heading carry the point ("Pick the mode first", not "Modes"), in
  sentence case. A task heading is a bare verb phrase. Use one top-level
  heading per page and skip no levels.
- Use numbered lists for sequences and bullets for the rest. Introduce each
  list with a full sentence, and keep its items parallel. When a list is
  partial, say so before it.
- Put code, paths, flags, and commands in code font, and interface labels in
  bold. Use the serial comma.

## Load one thing at a time

- Give one instruction per sentence, and one thought per sentence elsewhere.
- Split an instruction longer than about 20 words, and any other sentence
  longer than about 25.
- Keep the articles: "remove the backup file", not "remove backup file".
- Give each word one meaning, and each action one word. A service you "start"
  is never also "initiated".
- Prefer a verb to an "-ing" noun.

## Leave one reading

- Put "only" and "not" beside the word they change. "Fails only on growth"
  and "only fails on growth" say different things.
- Break up long noun strings. "The proto import budget check script" becomes
  "the script that checks the proto-import budget".
- Make every "it", "they", and "this" point at one thing, and repeat the noun
  when in doubt. Point "this" and "which" at a noun, never at a whole clause.
- Give every clause its own verb: "phase 1 moves the converters and phase 2
  moves the runtime".
- Keep the small words that show structure, such as "that" in "check that
  the switch is off".
- Repeat the article when a series names separate things: "the client and the
  host".
- Show how "and" and "or" group with "both ... and", "either ... or", and
  "if ... then".
- End sentences with periods, in place of semicolons and dashes. Make text in
  parentheses a complete unit, and write plurals without "(s)".
- Write "a, b, or both" in place of a slash.
- Call each thing by one name throughout, and leave unchanged names as they
  are.
- Leave out idioms, Latin abbreviations, and metaphors.

## Pull requests, commits, and messages

Every rule above applies to them. A pull request body is a briefing a reviewer
reads in under a minute, and `file-pr` sets its sections. Link logs, SHA
lists, and metric tables instead of pasting them. Make each count or file-tree
claim true at the commit that lands it, and give the command that regenerates
it. Product interface text follows the product's own copy guidelines.

## Example

Before:

> Retries are handled by the client utilizing an exponential backoff strategy.
> It should be noted that the max attempts value, which can be configured via
> RETRY_MAX, should only be increased if the upstream is known to be flaky,
> otherwise latency may be impacted.

After:

> The client retries a failed request with exponential backoff, up to
> `RETRY_MAX` attempts. Raise `RETRY_MAX` only when the upstream is known to
> fail intermittently. Otherwise the extra attempts may add latency.
