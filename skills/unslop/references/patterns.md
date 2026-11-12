# Patterns

The marks of machine-written prose, grouped by kind. Each entry says what to
look for and what to write instead. One mark alone proves little. Rewrite
where they cluster.

## Content

- **Inflated significance.** Claims that an ordinary fact marks a turning
  point or reflects a broader trend: "a testament to", "a pivotal moment",
  "marks a shift", "sets the stage for", "the evolving landscape", "an
  indelible mark". State the fact and drop the claim.
  Before: "The 2.0 release marked a pivotal moment in the project's evolving
  journey." After: "Version 2.0 replaced the plugin loader."
- **Notability claims.** Lists of outlets, follower counts, or "widely
  recognized" without context. Keep one source with what it said, or cut.
- **Tacked-on "-ing" analysis.** A participle phrase added for depth:
  "highlighting", "ensuring", "reflecting", "showcasing", "contributing to".
  Cut it, or make it a sentence with its own evidence.
  Before: "The cache stores sessions in memory, ensuring a seamless
  experience." After: "The cache stores sessions in memory, so a page load
  skips the database."
- **Promotional words.** "Boasts", "vibrant", "rich", "stunning",
  "renowned", "groundbreaking", "nestled", "in the heart of", "seamless",
  "powerful". Use neutral words, or a number.
- **Vague attribution.** "Experts believe", "industry reports suggest", "many
  developers find". Name the source, or cut the claim.
- **Formula sections.** "Challenges and future outlook", "despite these
  challenges". Keep the concrete problems as plain facts, and drop the frame.
- **Gap-filling.** A paragraph about missing information followed by a
  plausible guess, or a knowledge-cutoff disclaimer: "while details are
  limited", "it is believed that", "likely began". Say what is not known, or
  cut the sentence.
- **Diff-anchored text.** A doc or comment that narrates a change instead of
  describing the thing as it is: "this function was added to replace the old
  loop". Describe the current behavior. Changelogs, release notes, and
  migration guides are about changes and keep this form.

## Words

- **Overused vocabulary.** "Additionally", "align with", "crucial", "delve",
  "enduring", "enhance", "foster", "garner", "highlight" as a verb,
  "interplay", "intricate", "key" as an adjective, "landscape" for an
  abstraction, "pivotal", "showcase", "tapestry", "testament", "underscore",
  "valuable", "vibrant". These travel together. Use plain words.
- **Avoiding "is".** "Serves as", "stands as", "represents", "boasts",
  "features", "offers". Write "is" or "has".
- **Negative parallelism.** "Not just X, but Y", "it's not merely X, it's Y",
  and a clipped negation tacked onto a sentence ("..., no guessing"). State
  the point directly.
  Before: "The flag picks the region for you, no guessing." After: "The flag
  picks the region, so you do not have to look it up."
- **Forced threes.** Ideas grouped in threes to sound complete. Use the number
  there really is.
- **Synonym cycling.** One thing called by four names in one paragraph:
  "the worker", "the job runner", "the processor", "the consumer". Pick one
  name and repeat it.
- **False ranges.** "From X to Y" where X and Y are not ends of a scale. List
  the items.
- **Passive voice and missing subjects.** "The config is validated", "no
  setup needed". Name the actor: "the loader validates the config", "you do
  not need to set anything up". Keep the passive only when the actor is
  unknown or does not matter.
- **Fancy words.** "Utilize", "leverage", "facilitate", "perform", "numerous",
  "in the event that". Write "use", "help", "do", "many", "if".
- **Adverbs propping up verbs.** "Runs quickly", "significantly improves".
  Use a stronger verb or the measured number.
- **Hyphens after the noun.** A compound modifier takes a hyphen before the
  noun ("a long-term fix") and usually not after it ("the fix is long
  term").

## Figures of speech and jargon

- **Metaphor nouns.** "Substrate", "wedge", "vector" for a method, "locus",
  "nexus", "primitive" as a noun, "harness" as a figure of speech, "surface"
  as in "API surface", "bedrock", "scaffolding" as a figure of speech,
  "modality", "paradigm", "north star", "flywheel", "gold-plating",
  "ratchet", "endgame", moving code as "evacuating" it. Use the concrete word:
  "base", "add", "way", "the public functions", "more than the task needs",
  "a limit that only goes down", "the last phase", "move out".
- **Mannered prose.** A flourish where a literal phrase exists: aphorisms
  ("wire it or delete it"), rhetorical fragments, code described as a person
  ("the plan holds it"), figurative verbs ("rides along", "stands on"). Say
  what is meant.
  Before: "A dial worth turning." After: "A setting worth trying at a few
  values."
- **Aphorism formulas.** "X is the language of Y", "X becomes a trap", "not a
  tool but a mirror". Replace with the plain claim behind it.
- **Authority tropes.** "The real question is", "at its core", "what really
  matters", "fundamentally", "the heart of the matter". Make the point
  without the ceremony.
- **Feelings instead of mechanisms.** "Types that follow your schema", "SQL
  you can read", "the database stays close at hand". Name the mechanism or a
  number: "renaming a column fails the build". Ask what the sentence tells
  the reader to do or know. If it could appear unchanged in another project's
  docs, it says nothing about this one. Cut it.

## Punctuation and layout

- **Dashes.** Em dashes, en dashes, spaced hyphens, and double hyphens used as
  breaks. Replace each with, in order of preference, a period, a comma, a
  colon before an explanation, or parentheses for a true aside, or rebuild
  the sentence. A voice sample that uses dashes overrides this.
- **Colons as connectors.** A colon used to set up a reveal or a comparison
  mid-sentence. A colon before a list, an example, or an explanation is fine.
  Before: "If you're used to event handlers: here you describe conditions."
  After: "Describe the conditions under which the job runs."
- **Bold everywhere.** Bold on every name, acronym, or phrase. Bold what the
  reader must not miss, and little else.
- **Inline-header lists.** Bullets that open with a bold label and colon and
  then restate the label: "**Speed:** Speed improved by caching." Turn them
  into prose or plain bullets. A bold lead-in that names an item, ends in a
  period, and is followed by new detail is fine.
- **Title Case Headings.** Use sentence case.
- **Decorative emoji** on headings and bullets. Remove them.
- **Curly quotes.** Use straight quotes.
- **Warm-up sentences.** A line after a heading that restates the heading
  before the content starts. Delete it.
- **Staccato drama.** A run of short fragments built to land like a closer:
  "No config. No setup. Just results." One short sentence for emphasis is
  fine. A run of them reads as staged.
- **Dense sentences.** A sentence the reader has to parse twice. Split it, or
  drop clauses: one idea per sentence.
- **Over-compression.** Dropped articles, verbless fragments, arrows, and
  abbreviations the reader has to decode. Before: "Parser rejects bad date →
  exit 2, no write." After: "The parser rejects a bad date, exits with code
  2, and writes nothing."

## Conversation left in the text

- **Chatbot phrases.** "I hope this helps", "Certainly!", "Of course!", "let me
  know if", "would you like me to", "here is a". Cut them.
- **Flattery.** "Great question", "you're absolutely right". Answer directly.
- **Signposting.** "Let's dive in", "let's break this down", "here's what you
  need to know". Start with the content.
- **Fake-candid openers.** "Honestly?", "Look,", "Here's the thing", "Real
  talk" used as a standalone hook. Say the thing. The words mid-sentence are
  ordinary.

## Filler

- **Filler phrases.** "In order to" is "to". "Due to the fact that" is
  "because". "At this point in time" is "now". "Has the ability to" is "can".
  "It is important to note that" is nothing.
- **Stacked hedges.** "Could potentially possibly be argued that it might" is
  "may".
- **Upbeat endings.** "The future looks bright", "exciting times ahead". End
  on the last concrete fact, or on real plans the source states.
