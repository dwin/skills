#!/usr/bin/env bash
set -euo pipefail

mkdir -p src

cat > package.json <<'JSON'
{
  "name": "billing-client",
  "version": "0.3.1",
  "private": true,
  "type": "module",
  "scripts": { "test": "node --test" }
}
JSON

cat > src/client.js <<'JS'
// TODO: retry a failed request up to three times, with backoff.
export async function getInvoice(id, { fetchImpl = fetch } = {}) {
  const res = await fetchImpl(`https://billing.example.test/invoices/${id}`);
  if (!res.ok) throw new Error(`invoice ${id}: HTTP ${res.status}`);
  return res.json();
}
JS

git init -q
git add -A
git -c user.name=dev -c user.email=dev@example.test -c commit.gpgsign=false commit -q -m "Add invoice client"
