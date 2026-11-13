// Run the shipped UI against the Python test server. The minimal DOM is a test
// adapter; HTTP and SQLite writes are real. Only the wall clock is adjusted.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const { randomUUID } = require("node:crypto");
const { performance } = require("node:perf_hooks");

const [origin, token] = process.argv.slice(2);
assert.ok(origin && token);
let clockSkew = 0;
class AdjustedDate extends Date {
  static now() {
    return Date.now() + clockSkew;
  }
}
class Element {
  constructor(tag) {
    this.tagName = tag.toUpperCase();
    this.children = [];
    this.listeners = new Map();
    this.dataset = {};
    this.value = "";
    this.textContent = "";
  }
  append(child) {
    this.children.push(child);
  }
  addEventListener(type, handler) {
    this.listeners.set(type, handler);
  }
  setAttribute() {}
}
const roots = new Map();
const document = {
  getElementById(id) {
    if (!roots.has(id)) roots.set(id, new Element("div"));
    return roots.get(id);
  },
  createElement(tag) {
    return new Element(tag);
  },
};
const context = vm.createContext({
  document,
  window: { addEventListener() {} },
  location: { hash: "#token=" + token },
  Date: AdjustedDate,
  performance,
  URLSearchParams,
  URL,
  AbortController,
  crypto: { randomUUID },
  setTimeout,
  clearTimeout,
  fetch: (route, options) =>
    fetch(new URL(route, origin), {
      ...options,
      headers: { ...options.headers, Origin: origin },
    }),
});
async function untilSaved() {
  const deadline = performance.now() + 2000;
  while (!document.getElementById("status").textContent.startsWith("Saved")) {
    assert.ok(
      performance.now() < deadline,
      "Draft never saved after the wall clock moved backward",
    );
    await new Promise((resolve) => setTimeout(resolve, 20));
  }
}
async function main() {
  vm.runInContext(
    fs.readFileSync(path.join(__dirname, "../assets/questionnaire.js"), "utf8"),
    context,
  );
  await untilSaved();
  const card = document.getElementById("questions").children[0];
  const notes = card.children.find(
    (element) => element.tagName === "LABEL" && element.textContent === "Notes",
  ).children[0];
  notes.value = "Draft before clock correction";
  notes.listeners.get("input")();
  assert.equal(document.getElementById("status").textContent, "Saving…");
  clockSkew = -60 * 60 * 1000;
  await untilSaved();
  const response = await fetch(origin + "/api/export", {
    headers: { "X-Questionnaire-Token": token },
  });
  assert.equal(response.status, 200);
  const snapshot = await response.json();
  assert.equal(snapshot.answers[0].notes, notes.value);
  assert.equal(snapshot.answers[0].revision, 1);
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
