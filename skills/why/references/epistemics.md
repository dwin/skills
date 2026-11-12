# Epistemics

How to judge confidence when the evidence is historical, partial, and
sometimes contradictory, and how to word it so the user can tell what is
known from what is guessed. An answer that sounds sure on weak evidence is
the failure this skill exists to prevent, because the user acts on it.

## Confidence tiers

Every claim in the answer sits in exactly one tier. The tier sets the section
it goes in and how it is worded.

1. **Direct.** Someone wrote down the reason: a pull request saying "this
   fixes pagination for accounts with more than 1,000 items", a ticket saying
   "the customer's security review requires this", a comment saying "clamp to
   100 because the upstream API rejects larger pages", a design doc's
   "we chose A over B because we need state to survive restarts". Word it
   plainly and cite it: "This exists because X [source]."
2. **Supported.** Several indirect items point the same way, though none says
   it outright: the pull request title says "speed up export", the ticket
   carries a performance label, and the neighboring commits all touch the
   same hot path. Word it with the derivation and each item cited: "The
   evidence points to X: [items]."
3. **Inferred.** A reasonable reading that nothing states: the error appears
   in the incident channel the same morning, and the fix merged that
   afternoon without review, so it was likely a hotfix. Hedge it and show the
   chain: "Given A and B, C seems likely because D."
4. **Speculative.** A plausible idea on thin evidence that other explanations
   fit as well. Worth raising, since the user may know which is right: "One
   possibility is X, but no evidence was found for it." It usually sits among
   competing hypotheses.
5. **Unknown.** You looked and could not find out. This is a valid and
   valuable result. Say exactly where you looked: "The tracker was searched
   for A and B, the six pull requests touching this file since 2023 were read,
   and the repository was searched for the constant. None gives a reason."

## Wording

**Words that claim knowledge** need a citation beside them and never carry an
inference: "because", "the reason is", "was designed to", "fixes", "solves",
"the team decided".

**Hedges** mark interpretation, and belong with inferred and speculative
claims: "appears to", "likely", "suggests", "is consistent with", "one reading
is", "may have been".

**Words that hide uncertainty** come out: "obviously", "clearly", "of course",
and a dismissive "just". Replace "I think" with what the evidence suggests.

## Rules of judgment

- **Leave history as messy as it was.** Code that makes sense today may have
  been written for reasons that no longer hold, or that were wrong at the
  time. A consistent pattern may be copy and paste rather than intent. No one
  mentioning a concern does not show it was absent.
- **Treat the user's guess as a candidate.** When the question embeds a
  hypothesis, check it like any other. Confirm it with citations when the
  evidence supports it, and when it does not, say so and give what the
  evidence does support.
- **Show contradictions.** When a ticket says "required for a customer's
  compliance review" and the pull request says "cleaning up tech debt", give
  both with citations. Both may be true, since the ticket motivated the work
  and the pull request gave the author's framing, or one may be wrong. The
  user decides.
- **Name every gap concretely.** An honest "we don't know" tells the user the
  answer is not in the obvious places and whom to ask: the author, the product
  owner, or the team lead. Give the question, the sources searched, the
  queries, and what came back.

## Before finalizing

- Every claim under What We Found has a citation, or it moves down a tier.
- Each claim's wording matches its tier.
- No claim uses the code as evidence of its own intent.
- The answer has a What We Don't Know section. An answer with no gaps is
  suspicious: either the record was unusually complete or something was
  passed over.
