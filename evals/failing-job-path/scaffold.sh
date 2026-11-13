#!/usr/bin/env bash
set -euo pipefail

mkdir -p src

cat > src/db.js <<'JS'
// In-memory tables, standing in for the database.
export const tables = { jobs: new Map(), dead_jobs: new Map() };
let nextId = 1;
export const newId = () => nextId++;
JS

cat > src/queue.js <<'JS'
import { tables, newId } from "./db.js";

export function enqueue(type, payload) {
  const job = { id: newId(), type, payload, attempts: 0, runAt: Date.now() };
  tables.jobs.set(job.id, job);
  return job.id;
}

export function dueJobs(now = Date.now()) {
  return [...tables.jobs.values()].filter((job) => job.runAt <= now);
}
JS

cat > src/worker.js <<'JS'
import { dueJobs } from "./queue.js";
import { tables } from "./db.js";
import { scheduleRetry } from "./retry.js";
import { handlers } from "./handlers.js";

export async function poll() {
  for (const job of dueJobs()) {
    try {
      await handlers[job.type](job.payload);
      tables.jobs.delete(job.id);
    } catch (err) {
      scheduleRetry(job, err);
    }
  }
}
JS

cat > src/retry.js <<'JS'
import { deadLetter } from "./dead-letter.js";

export const MAX_ATTEMPTS = 5;
const BASE_DELAY_MS = 1000;

export function scheduleRetry(job, err) {
  if (err.permanent) {
    deadLetter(job, `permanent: ${err.message}`);
    return;
  }
  job.attempts += 1;
  if (job.attempts > MAX_ATTEMPTS) {
    deadLetter(job, `gave up after ${job.attempts} failures: ${err.message}`);
    return;
  }
  job.runAt = Date.now() + BASE_DELAY_MS * 2 ** (job.attempts - 1);
}
JS

cat > src/dead-letter.js <<'JS'
import { tables } from "./db.js";

export function deadLetter(job, reason) {
  tables.jobs.delete(job.id);
  tables.dead_jobs.set(job.id, { ...job, reason, deadAt: Date.now() });
}
JS

cat > src/handlers.js <<'JS'
export const handlers = {
  async sendEmail({ to }) {
    if (!to.includes("@")) {
      const err = new Error(`bad address: ${to}`);
      err.permanent = true;
      throw err;
    }
    // Sending is out of scope for this example.
  },
};
JS

git init -q
git add -A
git -c user.name=dev -c user.email=dev@example.test -c commit.gpgsign=false commit -q -m "Add job queue"
