#!/usr/bin/env bash
set -euo pipefail

mkdir -p src fixtures

cat > package.json <<'JSON'
{
  "name": "orders",
  "version": "1.4.0",
  "private": true,
  "type": "module",
  "scripts": { "test": "node --test" }
}
JSON

cat > src/dates.js <<'JS'
// Parse a "YYYY-M-D" date string into a Date at UTC midnight.
export function parseDate(text) {
  const [y, m, d] = text.trim().split("-").map(Number);
  return new Date(Date.UTC(y, m - 1, d));
}
JS

cat > src/import.js <<'JS'
import { readFileSync } from "node:fs";
import { parseDate } from "./dates.js";

// Load orders exported by the old billing system.
export function importOrders(path) {
  return readFileSync(path, "utf8")
    .trim()
    .split("\n")
    .slice(1)
    .map((line) => {
      const [id, placed, total] = line.split(",");
      return { id, placed: parseDate(placed), total: Number(total) };
    });
}
JS

cat > src/report.js <<'JS'
import { parseDate } from "./dates.js";

export function ordersBetween(orders, from, to) {
  const start = parseDate(from);
  const end = parseDate(to);
  return orders.filter((o) => o.placed >= start && o.placed <= end);
}
JS

cat > fixtures/legacy-orders.csv <<'CSV'
id,placed,total
A-100,2024-1-5,19.99
A-101,2024-01-17,5.00
A-102,2024-2-3,42.50
CSV

git init -q
git add -A
git -c user.name=dev -c user.email=dev@example.test -c commit.gpgsign=false commit -q -m "Add order import and reports"

cat > src/dates.js <<'JS'
const ISO_DATE = /^\d{4}-\d{2}-\d{2}$/;

// Parse a "YYYY-MM-DD" date string into a Date at UTC midnight.
export function parseDate(text) {
  if (!ISO_DATE.test(text)) throw new RangeError(`not an ISO date: ${text}`);
  const [y, m, d] = text.split("-").map(Number);
  return new Date(Date.UTC(y, m - 1, d));
}
JS

git add -A
git -c user.name=dev -c user.email=dev@example.test -c commit.gpgsign=false commit -q -m "Make parseDate strict about ISO dates"
