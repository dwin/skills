#!/usr/bin/env bash
set -euo pipefail

mkdir -p bin src

cat > package.json <<'JSON'
{
  "name": "tasks-cli",
  "version": "0.4.0",
  "private": true,
  "type": "module",
  "bin": { "tasks": "bin/tasks.js" },
  "scripts": { "test": "node --test" }
}
JSON

cat > README.md <<'MD'
# tasks

A to-do list for the terminal.

    node bin/tasks.js add "Buy milk"
    node bin/tasks.js list
    node bin/tasks.js list --json
    node bin/tasks.js done 1

Tasks are stored in `tasks.json` in `$TASKS_HOME`, or in `~/.tasks` when it
is not set.
MD

cat > src/store.js <<'JS'
import { mkdirSync, readFileSync, writeFileSync, existsSync } from "node:fs";
import { join } from "node:path";
import { homedir } from "node:os";

const dir = process.env.TASKS_HOME ?? join(homedir(), ".tasks");
const file = join(dir, "tasks.json");

export function load() {
  return existsSync(file) ? JSON.parse(readFileSync(file, "utf8")) : [];
}

export function save(tasks) {
  mkdirSync(dir, { recursive: true });
  writeFileSync(file, JSON.stringify(tasks, null, 2));
}
JS

cat > bin/tasks.js <<'JS'
#!/usr/bin/env node
import { load, save } from "../src/store.js";

const [command, ...args] = process.argv.slice(2);
const tasks = load();

switch (command) {
  case "add": {
    const task = { id: tasks.length + 1, text: args.join(" "), done: false };
    save([...tasks, task]);
    console.log(`Added ${task.id}: ${task.text}`);
    break;
  }
  case "list":
    if (args.includes("--json")) console.log(JSON.stringify(tasks));
    else for (const t of tasks) console.log(`${t.done ? "[x]" : "[ ]"} ${t.id} ${t.text}`);
    break;
  case "done": {
    const task = tasks.find((t) => t.id === Number(args[0]));
    if (!task) {
      console.error(`No task ${args[0]}`);
      process.exit(1);
    }
    task.done = true;
    save(tasks);
    console.log(`Done ${task.id}`);
    break;
  }
  default:
    console.error("usage: tasks add <text> | list [--json] | done <id>");
    process.exit(2);
}
JS
chmod +x bin/tasks.js

git init -q
git add -A
git -c user.name=dev -c user.email=dev@example.test -c commit.gpgsign=false commit -q -m "Add tasks CLI"
