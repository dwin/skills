---
name: unslop
description: Remove the marks of machine-written prose from text while keeping every fact and the author's voice. Use when the user asks to unslop, humanize, or de-AI a draft, says text sounds like AI wrote it, or wants prose for people checked for AI tells before it is posted or sent.
---

# Unslop

Edit prose so it reads as a person wrote it. Find the patterns in
[references/patterns.md](references/patterns.md), rewrite them, and keep the
meaning, the facts, and the author's voice.

## Scope

This skill edits prose that people read: docs, pull request descriptions,
commit messages, code comments, posts, and messages. Three kinds of text keep
their own rules:

- **Documents agents read**, such as a skill, an `AGENTS.md` or `CLAUDE.md`,
  or a doc an agent reaches by a pointer, follow `writing-for-agents`. A
  leading word there is repeated on purpose and may be a figure of speech, so
  it stays. Apply only the patterns that add nothing in any document: filler,
  chatbot phrases, and inflated significance.
- **Formats another skill sets** win over this one. When `focus-output` is on,
  its `failure -> cause -> fix` lines, numbered steps, and `Now` and `Later`
  lists stay as they are.
- **Quotations, titles, names, and code** stay as they are, and so does a
  phrase that is being discussed rather than used.

## Rules

1. **Keep every claim.** Each fact in the original survives into the rewrite.
   The shape need not: compress the dull parts, dwell where a person would,
   and merge or split paragraphs. When keeping the information and keeping the
   structure conflict, keep the information.
2. **Invent nothing.** The rewrite contains no fact, name, number, date,
   quote, or citation that is absent from the source and not given by the
   user. Replace a vague claim with a specific one only from those two places.
   When a sentence needs a detail you lack, write the plain version or ask. An
   unsupported claim is cut, not dressed up with a source.
3. **Match the voice.** Fit the register: formal, casual, or technical. When
   the user gives a sample of their own writing, read it first, note its
   sentence lengths, words, punctuation, and habits, and match those. A sample
   outranks the patterns, the dash rule included: when the sample uses dashes,
   keep them at about its rate.
4. **Add voice only where it belongs.** Opinion, asides, and uneven rhythm
   suit essays, posts, and personal writing, and they never add a fact.
   Reference, technical, and legal text stay neutral and plain, which is the
   human voice for that kind of text.
5. **Act on clusters.** One tell proves nothing. Clean grammar, formal words,
   one dash, one short sentence, or curly quotes are ordinary in human
   writing. Rewrite where tells pile up. Keep the marks of a person: odd
   specific detail, mixed feelings, dated references, self-corrections, and
   varied sentence length.

## Process

1. Read the text and mark every pattern from the catalog.
2. Write a draft rewrite. Read it as if aloud, and check for varied sentence
   length, plain constructions such as "is", "are", and "has", and the right
   register.
3. Ask two questions of the draft, and answer each in a line or two: "What
   still makes this read as machine-written?" and "Does it state any fact,
   name, number, date, or citation that the source lacks?" A fabrication is a
   defect even when it reads better than the vague original.
4. Revise into the final text. Search it for `—` and `–`. A hit used as a
   break in a sentence you may edit means it is unfinished, unless a voice
   sample uses them. A dash inside a quotation, a title, a name, code, or a
   range of numbers stays.

## Output by mode

- **Pasted text**, the default: give the draft, the audit lines, and the final
  rewrite.
- **A file the user asked you to edit**: rewrite the prose in place, leaving
  code blocks, frontmatter, data, and link targets untouched. Report a short
  summary of what changed.
- **A file the user asked you to check or review**: leave the file as it is.
  Report the patterns you found, each with its line and a proposed rewrite.
- **A step inside another task**, such as a pull request description another
  skill is writing: run the loop silently and return only the final text.
