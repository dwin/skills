---
name: explain
description: Explain a change, a subsystem, or a concept so the user understands it, or run a learning workspace for a topic studied over several sessions.
disable-model-invocation: true
argument-hint: "What would you like explained, or what do you want to learn?"
---

# Explain

The goal is that the user understands the thing. Change nothing in the code.

## Choose the mode

- **One explanation** is the default: a change, a subsystem, a design, or a
  concept, explained in this conversation. Follow the steps below.
- **A learning workspace** is for a topic the user wants to learn over several
  sessions. Use it when the user asks for lessons or a course, or when the
  current directory already holds a `MISSION.md`. Read
  [WORKSPACE.md](WORKSPACE.md) and follow it instead of the steps below.

## Explain once

1. **Decide what the user should come away with.** Pick a few things. Infer
   them from why the user is asking (about to change it, reviewing it,
   debugging it, new to it) and from what the conversation shows they already
   know. Skip what they know.
2. **Learn it before you explain it.** Read the code to see how the thing
   works. Read the history, such as commits, pull requests, and decision
   records, to see why it is built that way. Give a reason only when a source
   states it, and mark a guess as a guess.
3. **Start with a plain definition.** Name the thing, with its common name
   when it has one, and say what it is in general terms. Then tie it to the
   case in front of you, and build from there: how it works, why, and the edge
   cases.
4. **Give the smallest complete answer first.** A sentence or two. Add a layer
   when the user asks for one.
5. **Walk through a use.** Follow what happens as a person or a caller uses
   the thing, when that is what makes it clear. A list of functions and
   constants is reference, and it explains nothing.
6. **Draw when a picture is faster than words.** For three or more moving
   parts, draw a series: each diagram repeats the last one and adds a single
   part. One diagram with everything in it, saved for the end, is reference.
   Use a Mermaid diagram for a flow or a structure. For something spatial,
   such as a layout or a before and after, use the host's page or image
   surface when it has one. A single simple point needs no figure.
7. **Keep it a conversation.** Offer to go deeper or to move on, and follow
   the user's lead. Ask no quiz questions. When there is no live user, give
   the whole explanation and put the offer at the end.

## Write plainly

Write the way you would explain it aloud to a colleague.

- State the mechanism itself. Leave out the metaphor and the preview of what
  is coming.
- Give each concept one name and keep it.
- Keep sentences short: one idea, and at most two commas.
- Leave out labels that announce importance or difficulty, such as "the key
  insight" or "this is the tricky part". Say the thing.

The reply is the explanation. Leave out any account of what you read or did.
