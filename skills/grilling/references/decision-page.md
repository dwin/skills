# Decision page

A **decision page** is one self-contained HTML file that lists a round's
decisions with your recommendations already selected. The user changes what
they disagree with and pastes a text summary back into the thread.

## Build it

1. Copy [../assets/decision-page.html](../assets/decision-page.html) to a
   path the user can reopen, outside temporary directories.
2. Replace the `PAGE` object with this round's decisions. The comment above it
   describes each field. Leave the rest of the file as it is.
3. Write every item for a reader who has not seen your working notes:
   - `label`: what is being decided, in a few words;
   - `what`: one plain sentence describing the thing;
   - `why`: the reason for your pick, with its cost;
   - `options`: the answers on offer, each with different text, and your
     `pick` among them.
4. Mark a pick the user already stated with `by: "you"`.
5. Group items by topic. Open the groups that need attention, and put items
   that are settled or already carried out in a last group.

Every item keeps its Discuss tick and its note field. The notes are where a
user raises something you did not ask about.

## Show it

Use the host's own surface for a page, and give the file path as well.

| Host                            | Surface                                              |
| ------------------------------- | ---------------------------------------------------- |
| T3 Code                         | its inline HTML render, in the thread                |
| Claude desktop or web           | an artifact beside the chat                          |
| ChatGPT desktop app, with Codex | the HTML preview beside the chat                     |
| Cursor                          | a canvas beside the chat, or its browser on the file |
| Terminal only                   | open the file in the user's browser                  |

Status: run on T3 Code only. The other rows come from each host's
documentation.

When the session has no way to show a page, ask a numbered round.

Let the page speak for itself. In the message beside it, say only what the
page cannot: how to send the answers back, and anything you are unsure of.

## Read the answers

The user pastes the page's summary. It has four parts: changed from the
recommendation, to discuss, notes, and accepted.

- Accepted and changed items are decisions. Update the decision tree.
- Discuss items and notes become the next round. Answer each question a note
  asks, and add any new topic a note raises to the tree. A Discuss item is
  undecided, whatever choice it shows.
- An answer that contradicts an earlier decision reopens it. Say so.
