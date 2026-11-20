/* SQLite is canonical. Drafts live only until a commit receipt; never claim otherwise. */
"use strict";
const el = (id) => document.getElementById(id);
const token = new URLSearchParams(location.hash.slice(1)).get("token") || "";
const drafts = new Map();
let active = null;
let stopped = false;
let conflict = null;
let exportText = "";
let lastQuestion = -1;
let form = null;

async function api(path, body) {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), 12000);
  try {
    const response = await fetch(path, {
      method: body ? "POST" : "GET",
      headers: {
        "X-Questionnaire-Token": token,
        ...(body ? { "Content-Type": "application/json" } : {}),
      },
      ...(body ? { body: JSON.stringify(body) } : {}),
      signal: controller.signal,
      cache: "no-store",
      credentials: "omit",
    });
    const result = await response.json();
    if (!response.ok)
      throw Object.assign(new Error(result.error || "Request failed"), {
        result,
        code: response.status,
      });
    return result;
  } finally {
    clearTimeout(timer);
  }
}
function node(tag, text, parent) {
  const n = document.createElement(tag);
  if (text !== undefined) n.textContent = text;
  if (parent) parent.append(n);
  return n;
}
function pending(d) {
  return d.generation !== d.savedGeneration;
}
function refresh() {
  let answered = 0;
  let dirty = 0;
  for (const d of drafts.values()) {
    if (d.committed.value !== null) answered++;
    if (pending(d)) dirty++;
    d.status.textContent = pending(d)
      ? stopped
        ? conflict
          ? "Conflict — draft retained"
          : "Save failed — draft retained"
        : "Saving…"
      : `Saved · revision ${d.committed.revision}${d.committed.updated_at ? " · " + d.committed.updated_at : " · undecided"}`;
    for (const control of d.controls) {
      // Read-only text stays focusable/selectable for draft recovery.
      if (control.tagName === "TEXTAREA") control.readOnly = stopped;
      else control.disabled = stopped;
    }
  }
  el("progress").textContent =
    `${answered} answered · ${drafts.size - answered} remaining (committed)`;
  el("status").textContent = stopped
    ? conflict
      ? "Conflict — collection paused"
      : "Save failed — collection paused"
    : dirty || active
      ? "Saving…"
      : "Saved — all visible edits committed";
}
function edited(d) {
  d.generation++;
  refresh();
  clearTimeout(d.timer);
  d.ready = false;
  d.timer = setTimeout(() => {
    d.ready = true;
    pump();
  }, 300);
}
function choiceEdited(d) {
  edited(d);
  clearTimeout(d.timer);
  d.ready = true;
  pump();
}
function pause(error) {
  stopped = true;
  conflict = error.code === 409 ? error.result.current : null;
  el("recovery").hidden = false;
  el("error").textContent = error.message;
  el("conflict").textContent = conflict
    ? "Current committed answer:\n" + JSON.stringify(conflict, null, 2)
    : "";
  el("retry").hidden = !!conflict;
  el("keep").hidden = !conflict;
  el("accept").hidden = !conflict;
  el("draft-json").value = JSON.stringify(
    {
      status: "uncommitted-drafts",
      form,
      drafts: [...drafts.values()].filter(pending).map((d) => ({
        id: d.q.id,
        value: d.value,
        notes: d.notes,
        based_on_revision: d.committed.revision,
      })),
    },
    null,
    2,
  );
  refresh();
}
async function sendActive() {
  const job = active;
  try {
    const saved = await api("/api/answer", job.body);
    const d = job.draft;
    d.committed = saved;
    d.savedGeneration = job.generation;
    active = null;
    stopped = false;
    conflict = null;
    el("recovery").hidden = true;
    refresh();
    pump();
  } catch (error) {
    pause(error);
  }
}
function pump() {
  if (stopped || active) return;
  const d = [...drafts.values()].find((d) => pending(d) && d.ready);
  if (!d) return;
  active = {
    draft: d,
    generation: d.generation,
    body: {
      question_id: d.q.id,
      value: d.value,
      notes: d.notes,
      expected_revision: d.committed.revision,
      mutation_id: crypto.randomUUID(),
    },
  };
  refresh();
  sendActive();
}
function syncControls(d) {
  if (d.q.type === "choice") {
    for (const radio of d.radios)
      radio.checked = radio.dataset.value === (d.value === null ? "" : d.value);
  } else d.input.value = d.value === null ? "" : d.value;
  d.notesInput.value = d.notes;
}
function resumeConflict(keep) {
  const d = active.draft;
  d.committed = conflict;
  if (!keep) {
    d.value = conflict.value;
    d.notes = conflict.notes;
    d.savedGeneration = d.generation;
    syncControls(d);
  }
  // Explicit user choice rebases the retained draft; never silently overwrite.
  active = null;
  conflict = null;
  stopped = false;
  d.ready = true;
  el("recovery").hidden = true;
  refresh();
  pump();
}
function showQuestion(d) {
  el("search").value = "";
  for (const item of drafts.values()) item.card.hidden = false;
  d.card.scrollIntoView({ behavior: "smooth", block: "start" });
  d.heading.focus({ preventScroll: true });
  el("jump").value = d.q.id;
  lastQuestion = [...drafts.values()].indexOf(d);
}
async function start() {
  const state = await api("/api/state");
  form = state.form;
  el("title").textContent = state.form.title;
  document.title = state.form.title;
  el("description").textContent = state.form.description || "";
  const answers = new Map(state.answers.map((a) => [a.id, a]));
  for (const [index, q] of state.form.questions.entries()) {
    const a = answers.get(q.id);
    const d = {
      q,
      committed: a,
      value: a.value,
      notes: a.notes,
      generation: 0,
      savedGeneration: 0,
      ready: true,
      controls: [],
    };
    drafts.set(q.id, d);
    const card = node("article", undefined, el("questions"));
    d.card = card;
    d.heading = node("h2", `${index + 1}. ${q.title}`, card);
    d.heading.id = "question-" + q.id;
    d.heading.tabIndex = -1;
    node("p", q.description || "", card);
    for (const link of q.links || []) {
      // Server validates too. Render text, never supplied HTML.
      let url;
      try {
        url = new URL(link.url);
      } catch {
        continue;
      }
      if (
        !["http:", "https:"].includes(url.protocol) ||
        url.username ||
        url.password
      )
        continue;
      const p = node("p", undefined, card);
      const anchor = node("a", link.label, p);
      anchor.href = url.href;
      anchor.target = "_blank";
      anchor.rel = "noopener noreferrer";
    }
    const field = node("fieldset", undefined, card);
    const legend = node("legend", "Your answer", field);
    legend.id = "answer-label-" + q.id;
    field.setAttribute("aria-labelledby", d.heading.id + " " + legend.id);
    if (q.type === "choice") {
      d.radios = [];
      for (const option of [{ value: "", label: "Undecided" }, ...q.options]) {
        const label = node("label", undefined, field);
        label.className = "choice";
        const radio = node("input", undefined, label);
        radio.type = "radio";
        radio.name = "answer-" + q.id;
        radio.dataset.value = option.value;
        node("span", option.label, label);
        d.radios.push(radio);
        d.controls.push(radio);
        radio.addEventListener("change", () => {
          d.value = option.value === "" ? null : option.value;
          choiceEdited(d);
        });
      }
    } else {
      const label = node("label", "Answer (empty means undecided)", field);
      label.id = "text-label-" + q.id;
      d.input = node("textarea", undefined, label);
      d.input.setAttribute("aria-labelledby", label.id + " " + d.heading.id);
      d.input.rows = 3;
      d.input.maxLength = 20000;
      d.controls.push(d.input);
      d.input.addEventListener("input", () => {
        d.value = d.input.value === "" ? null : d.input.value;
        edited(d);
      });
    }
    const label = node("label", "Notes", card);
    label.id = "notes-label-" + q.id;
    d.notesInput = node("textarea", undefined, label);
    d.notesInput.setAttribute("aria-labelledby", label.id + " " + d.heading.id);
    d.notesInput.rows = 3;
    d.notesInput.maxLength = 20000;
    d.controls.push(d.notesInput);
    d.notesInput.addEventListener("input", () => {
      d.notes = d.notesInput.value;
      edited(d);
    });
    d.status = node("p", "", card);
    syncControls(d);
    const option = node("option", `${index + 1}. ${q.title}`, el("jump"));
    option.value = q.id;
  }
  refresh();
}
el("search").addEventListener("input", () => {
  const query = el("search").value.toLocaleLowerCase();
  for (const d of drafts.values())
    d.card.hidden = ![
      d.q.id,
      d.q.title,
      d.q.description || "",
      ...(d.q.options || []).map((o) => o.label),
    ]
      .join(" ")
      .toLocaleLowerCase()
      .includes(query);
});
el("jump").addEventListener("change", () =>
  showQuestion(drafts.get(el("jump").value)),
);
el("next").addEventListener("click", () => {
  const all = [...drafts.values()];
  for (let offset = 1; offset <= all.length; offset++) {
    const d = all[(lastQuestion + offset) % all.length];
    if (d.value === null) {
      showQuestion(d);
      return;
    }
  }
});
el("retry").addEventListener("click", () => {
  if (active) {
    el("retry").disabled = true;
    sendActive().finally(() => {
      el("retry").disabled = false;
    });
  } else location.reload();
});
el("keep").addEventListener("click", () => resumeConflict(true));
el("accept").addEventListener("click", () => resumeConflict(false));
el("export").addEventListener("click", async () => {
  try {
    const snapshot = await api("/api/export");
    exportText = JSON.stringify(snapshot, null, 2);
    el("json").value = exportText;
    el("backup").hidden = false;
    el("json").focus();
    el("json").select();
    el("download-status").textContent =
      "Committed snapshot retrieved. Pending drafts are excluded.";
  } catch (error) {
    el("backup").hidden = false;
    el("download-status").textContent =
      "Export failed: " +
      error.message +
      ". Any displayed text is an older snapshot. Use CLI export if needed.";
  }
});
el("download").addEventListener("click", () => {
  if (!exportText) return;
  let url;
  try {
    url = URL.createObjectURL(
      new Blob([exportText], { type: "application/json" }),
    );
    const a = node("a");
    a.href = url;
    a.download = "questionnaire-answers.json";
    a.click();
    el("download-status").textContent =
      "Download requested; verify the saved file. Selectable JSON remains available.";
  } catch (error) {
    el("download-status").textContent =
      "Download unavailable: " +
      error.message +
      ". Select and copy the JSON above.";
  } finally {
    if (url) setTimeout(() => URL.revokeObjectURL(url), 30000);
  }
});
window.addEventListener("beforeunload", (event) => {
  if (active || [...drafts.values()].some(pending)) {
    event.preventDefault();
    event.returnValue = "";
  }
});
start().catch(pause);
