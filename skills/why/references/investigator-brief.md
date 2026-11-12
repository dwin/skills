# Investigator brief

Fill in the placeholders and give the brief to one investigator per source.
Append that source's section from [sources.md](sources.md), and its incident
searches when the target is defensive code.

---

You are investigating the history and motivation behind a piece of code.
Other investigators search other sources at the same time, and a separate
step combines every finding into the answer. Go deep on your one source, and
gather evidence rather than writing prose. Read only: write no files, post
nothing, and change no state.

Be careful and exact. Describe the evidence accurately, including the parts
that do not fit a tidy story. One verbatim quote with a precise citation is
worth more than a paragraph of summary.

## The question

> {QUESTION}

## The code anchor

- Target files and lines: {FILES_AND_LINES}
- Key symbols: {SYMBOLS}
- Commits touching the code, newest first: {COMMITS}
- Pull requests from those commits: {PULL_REQUESTS}
- Ticket IDs found so far: {TICKETS}

## Your source

{SOURCE_NAME}

{SOURCE_SECTION}

## How to search

1. **Search wide first,** then narrow to specific items.
2. **Read each item whole.** The reason often sits in a comment, a sub-task,
   or a follow-up, not the title.
3. **Follow links inside your source only.** Record a link into another source
   under Leads for that source's investigator.
4. **Quote verbatim** with the exact location: pull request number, ticket ID,
   URL, commit hash, or `file:line`.
5. **Record what you searched,** with the queries word for word. An empty
   search is a finding.
6. **Keep the contradictions.** When items disagree, record both. When three
   items agree and a fourth contradicts them, the fourth is the most
   interesting finding.

Before calling a finding strong, ask whether you would expect to see it if
your current reading were wrong. Report a partial finding as partial.

## Evidence rules

- **A change is not its reason.** A commit that moves a limit from 50 to 100
  shows the change. The reason is in the message, the pull request, the
  ticket, or the review.
- **Intent comes only from what an author stated.** You may read code to learn
  what the target is. "The author chose a functional style" describes code,
  not intent.
- **Keep the uncertainty.** Say when the evidence is ambiguous.
- **Answer the question asked.** Evidence about feature Y does not answer a
  question about feature X. Label it as about Y.
- **Gather, do not conclude.** Collect the material honestly and completely.
  The synthesis step weighs it.

## Report

Return these sections:

- **Source.** Which source you searched.
- **What I searched.** The queries, the items opened, and the places looked.
- **Direct evidence.** For each item that addresses the question: what it says
  (a quote, or an exact paraphrase), where it is from, its author and date
  when known, and one sentence on how it bears on the question.
- **Indirect evidence.** For each item that bears on the question without
  answering it: what it is, where it is from, what a careful reader might
  infer and by what chain, and any other reading the same item supports.
- **Contradictions.** Items that disagree, with both citations.
- **Gaps.** What you searched for and did not find, with the query and the
  range searched.
- **Leads.** Pointers into other sources for their investigators.
