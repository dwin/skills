#!/usr/bin/env bash
set -euo pipefail

mkdir -p src

cat > package.json <<'JSON'
{
  "name": "storefront",
  "version": "2.8.0",
  "private": true,
  "type": "module",
  "scripts": { "test": "node --test" }
}
JSON

cat > src/pricing.js <<'JS'
export function total(items, customer, code) {
  let t = 0;
  for (let i = 0; i < items.length; i++) {
    let p = items[i].price * items[i].qty;
    if (items[i].category == "book") {
      if (customer && customer.tier == "gold") {
        p = p * 0.9;
      } else if (customer && customer.tier == "silver") {
        p = p * 0.95;
      }
    } else {
      if (customer && customer.tier == "gold") {
        p = p * 0.95;
      }
    }
    if (items[i].qty >= 10) {
      p = p - p * 0.02;
    }
    t = t + p;
  }
  if (code == "WELCOME") {
    if (t > 50) {
      t = t - 5;
    }
  } else if (code == "FREESHIP") {
    t = t;
  }
  if (t < 0) t = 0;
  return Math.round(t * 100) / 100;
}
JS

cat > src/checkout.js <<'JS'
import { total } from "./pricing.js";

export function summary(cart, customer) {
  return { lines: cart.items.length, due: total(cart.items, customer, cart.code) };
}
JS

git init -q
git add -A
git -c user.name=dev -c user.email=dev@example.test -c commit.gpgsign=false commit -q -m "Add pricing"
