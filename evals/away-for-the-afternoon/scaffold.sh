#!/usr/bin/env bash
set -euo pipefail

mkdir -p src/lib src/accounts src/billing test

cat > package.json <<'JSON'
{
  "name": "portal",
  "version": "4.2.0",
  "private": true,
  "type": "module",
  "scripts": { "test": "node --test" }
}
JSON

cat > src/lib/fetch-json.js <<'JS'
/** @deprecated Use http.get from ./http.js. */
export async function fetchJson(url, { retries = 0 } = {}) {
  for (let attempt = 0; ; attempt++) {
    const res = await fetch(url);
    if (res.ok) return res.json();
    if (attempt >= retries) throw new Error(`${url}: HTTP ${res.status}`);
  }
}
JS

cat > src/lib/http.js <<'JS'
// Returns the parsed body. Retries are configured per client, not per call.
export const http = {
  retries: 2,
  async get(url) {
    for (let attempt = 0; ; attempt++) {
      const res = await fetch(url);
      if (res.ok) return res.json();
      if (attempt >= this.retries) throw new Error(`${url}: HTTP ${res.status}`);
    }
  },
};
JS

cat > src/accounts/profile.js <<'JS'
import { fetchJson } from "../lib/fetch-json.js";

export const getProfile = (id) => fetchJson(`/api/accounts/${id}`);
JS

cat > src/accounts/settings.js <<'JS'
import { fetchJson } from "../lib/fetch-json.js";

export const getSettings = (id) => fetchJson(`/api/accounts/${id}/settings`, { retries: 5 });
JS

cat > src/billing/invoices.js <<'JS'
import { fetchJson } from "../lib/fetch-json.js";

export async function listInvoices(accountId) {
  const page = await fetchJson(`/api/billing/${accountId}/invoices`);
  return page.items;
}
JS

cat > test/profile.test.js <<'JS'
import { test } from "node:test";
import assert from "node:assert/strict";

test("profile module loads", async () => {
  const mod = await import("../src/accounts/profile.js");
  assert.equal(typeof mod.getProfile, "function");
});
JS

git init -q
git add -A
git -c user.name=dev -c user.email=dev@example.test -c commit.gpgsign=false commit -q -m "Add portal clients"
