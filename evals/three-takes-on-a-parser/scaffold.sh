#!/usr/bin/env bash
set -euo pipefail

mkdir -p src docs test

cat > package.json <<'JSON'
{
  "name": "scheduler",
  "version": "1.3.0",
  "private": true,
  "type": "module",
  "scripts": { "test": "node --test" }
}
JSON

cat > docs/durations.md <<'MD'
# Durations

Every timeout and interval in the config files is a duration string.
`parseDuration` turns one into milliseconds.

Accepted:

- A unit-suffixed number: `250ms`, `30s`, `5m`, `2h`, `1d`.
- Units combined, largest first, no spaces: `1h30m`, `2m15s`.
- A decimal in the largest unit only: `1.5h`.
- A bare `0`.

Rejected with an error that names the input:

- An empty string, a negative number, or a bare number other than `0`.
- Units out of order (`30m1h`) or repeated (`1h1h`).
- An unknown unit (`5w`).
MD

cat > src/duration.js <<'JS'
// Turns a duration string from the config files into milliseconds.
// See docs/durations.md.
export function parseDuration(input) {
  throw new Error("not implemented");
}
JS

cat > test/duration.test.js <<'JS'
import { test } from "node:test";
import assert from "node:assert/strict";
import { parseDuration } from "../src/duration.js";

test("seconds", () => {
  assert.equal(parseDuration("30s"), 30_000);
});
JS

git init -q
git add -A
git -c user.name=dev -c user.email=dev@example.test -c commit.gpgsign=false commit -q -m "Stub parseDuration"
