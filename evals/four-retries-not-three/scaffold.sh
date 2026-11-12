#!/usr/bin/env bash
set -euo pipefail

mkdir -p src docs/adr

cat > src/retry.js <<'JS'
export const DEFAULT_RETRIES = 3;

export async function withRetries(fn, retries = DEFAULT_RETRIES) {
  for (let attempt = 0; ; attempt++) {
    try {
      return await fn();
    } catch (err) {
      if (attempt >= retries) throw err;
      await new Promise((r) => setTimeout(r, 200 * 2 ** attempt));
    }
  }
}
JS

cat > src/upload.js <<'JS'
import { withRetries } from "./retry.js";

const UPLOAD_RETRIES = 4;

export function upload(file, put) {
  return withRetries(() => put(file), UPLOAD_RETRIES);
}
JS

cat > src/search.js <<'JS'
import { withRetries } from "./retry.js";

export const search = (query, get) => withRetries(() => get(`/search?q=${query}`));
JS

cat > docs/adr/0007-upload-retries.md <<'MD'
# 7. Uploads retry four times

Status: accepted, 2025-03-12

## Context

During a rolling restart the storage gateway closes open connections for up
to about three seconds. With three retries and exponential backoff starting at
200 ms, the last retry fires at 1.4 seconds, before the gateway is back, and
uploads failed during every gateway deploy (incident INC-88).

## Decision

Uploads use four retries. The fourth retry fires at 3 seconds. Other calls
keep the default of three, because they go to services that do not restart
this way.

## Consequences

A failing upload now takes about 3 seconds longer to report its error.
MD

cat > CHANGELOG.md <<'MD'
# Changelog

## 2.6.0

- Uploads retry four times instead of three, to ride out storage gateway
  restarts. See ADR 7.

## 2.5.0

- Search results are paginated.
MD

git init -q
git add -A
git -c user.name=dev -c user.email=dev@example.test -c commit.gpgsign=false commit -q -m "Add storage client"
