# The explanation

Write for a senior engineer who is new to this area and will start changing
it soon. They should come away able to find their way and predict what the
code does.

## Sections

Use the sections that apply, in this order:

- **Overview.** One or two paragraphs: what this is, what it does, and why it
  exists. A reader who stops here can decide whether to read on.
- **Key concepts.** The types, services, and terms the rest depends on, each
  with a short definition.
- **How it works.** The longest section. Start from what triggers the flow and
  follow it step by step: what runs, where data goes, and where it branches.
  Name the file and function at each step. Write prose, and quote code only
  when a few lines make a point that prose cannot.
- **Where things live.** The files and directories someone needs to start
  working here, each with one line.
- **Gotchas.** Behavior that surprises, ordering that matters, history that
  explains an odd shape. Leave the section out when there is nothing to say.
- **Open questions.** What the reading did not settle. Leave it out only when
  nothing is open.

## Diagrams

Draw when three or more parts pass data or calls between them: a Mermaid
sequence diagram for calls over time, a flowchart for branching, a graph for
structure. Use plain text art for a simple relationship. Skip the diagram when
the prose already makes the flow clear.

## Style

- Name things concretely: "`UpdateQueue.flush()` calls `Store.write()`", not
  "the queue delegates to the store".
- When something is complex, say what makes it complex.
- Keep simple parts short.
- Give each concept one name and keep it.
