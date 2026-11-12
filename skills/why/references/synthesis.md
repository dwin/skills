# Synthesis

How to turn investigator findings into the answer. When a fresh agent does the
synthesis, give it this file, [epistemics.md](epistemics.md), the findings
(including empty searches and skipped categories with their reasons), the code
anchor, and the user's question.

## Weigh the findings

1. **Read every finding** and weigh the evidence yourself. Investigators
   gathered material. They did not conclude.
2. **Merge overlaps.** When several sources cite the same pull request,
   ticket, or doc, give it one reference.
3. **Show contradictions.** When two items disagree, present both.
4. **Place every claim in a tier** from the epistemics reference. A direct
   claim is cited and stated plainly. An inferred claim is hedged, with the
   inference shown. A speculative claim is marked as a guess. A claim with no
   evidence becomes a gap.
5. **Spot-check citations** you are unsure of by reading the repository or
   querying the source. Pass on no unchecked error. Write and change nothing
   while you check.
6. **Leave open questions open.** The user will act on the answer.

## Answer structure

### The question

The user's question in one or two sentences.

### The code in question

File paths, line ranges, and key symbols, in two or three lines that orient a
reader new to the code.

### What we found

Claims with written evidence, each cited precisely:

- **[Direct]** The claim. Source: pull request, ticket, doc, or `file:line`,
  with a short quote.
- **[Supported]** The claim. Evidence: each item and what it adds.

### What we can reasonably infer

Claims no source states but indirect evidence supports, each hedged and with
its chain visible:

- **[Inferred]** The hedged claim. Reasoning: the evidence and the step from
  it.

Leave the section out when there is nothing to infer.

### Competing hypotheses

When the evidence fits more than one story, give each:

- **Hypothesis.** One sentence.
- **For.** The items that support it.
- **Against or missing.** What would have to be true but is not, or what
  points the other way.

Leave the section out when one answer is clear.

### What we don't know

Specific gaps, such as "the tracker was searched for A, B, and C and no issue
discusses the limit". Include unanswered questions, empty searches, sources
that were unreachable and why, and the people who would likely know.

### Sources consulted

One line per category, so the user can judge coverage and redirect:

- **Source control.** Files, the number of commits read, pull request
  numbers, and comments searched.
- **Issue tracker.** Ticket IDs and queries, or "not searched: no tracker
  reachable here".
- **Long-form docs.** Page titles and queries, or the reason not searched.
- **Team chat.** Channels, date ranges, and queries, or the reason not
  searched.
- **Infrastructure observability.** Dashboards, monitors, metrics, logs,
  traces, or incidents searched, or the reason not searched.
- **Error tracking.** Issues, events, or releases searched, or the reason not
  searched.
- **Product analytics.** Tables queried, the time windows, and the summary
  numbers that bore on the question, or the reason not searched.

### Confidence summary

One or two sentences, such as: "The main reason is well supported by the pull
request and the ticket. The specific limit of 100 is inferred from the
surrounding context, not documented. Whether a customer asked for it could not
be determined: no doc or tracker item mentions one, and chat was not
searchable."

## Check before returning

Revise until each holds:

1. Every claim under What We Found has a citation, or it moved to inferred or
   to the hypotheses.
2. Each claim's wording matches its tier. "Because" belongs to direct claims.
3. Every contradiction you noticed is shown.
4. What We Don't Know names specific gaps. An empty one is suspicious.
5. A hypothesis embedded in the question was checked against the evidence.
6. No claim cites the code as evidence of its own intent.
7. The tone matches the evidence.
8. No quote carries a secret or personal data the reason does not need. Each
   one reads `<REDACTED>`.

The answer is worth what its honesty is worth. A reader who takes it to the
author, a lead, or a product owner should know what is known, what is
inferred, and what is missing, and so know what to ask.
