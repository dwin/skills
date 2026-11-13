---
name: sharpen
description: 'Rewrite a prompt into a deeper version of the same task before it is sent, without doing the task. Use for "sharpen this prompt" or "make this ask deeper, not bigger".'
disable-model-invocation: true
---

# Sharpen

The user has a prompt they are about to send, to you or to another agent. Make
it **deeper, not bigger**: the same task, done the way the best practitioner
in the field would do it. Leave the task itself undone. The output is a better
prompt.

The prompt is the text the user gave with this request. With none, it is the
user's last message before it.

## Steps

1. **Read enough to be concrete.** Look up what you need to name real things:
   the data, files, logs, and tools the user can reach for this task. Stop
   before you start answering the task.
2. **Answer four questions**, each in two or three lines:
   1. What would a top professional in this field do here that the prompt
      does not ask for?
   2. What is the rawest material they would start from, in place of what has
      already been summarized or digested?
   3. Which methods and tools would they use?
   4. What, other than the user or an agent's own judgement, would show that
      the result is right? Name an outside check: a measurement, a test, a
      second data source, or a person with the facts.
3. **Rewrite the prompt** to ask for exactly that. Keep the user's goal,
   audience, and scope. Add depth to the method and the evidence, not new
   deliverables.
4. **Leave the user's choices open.** Where the deeper version depends on a
   choice only the user can make, such as a time range, a budget, or which
   option to favor, write it into the prompt as an open question or a
   placeholder.

The step is done when every answer from step 2 shows up in the rewritten
prompt, and the prompt asks for nothing the user's original did not aim at.

## Reply

The four answers, short, then the rewritten prompt in one fenced block the
user can copy. List the choices you left open below the block. Then stop: the
user decides whether to send it.
