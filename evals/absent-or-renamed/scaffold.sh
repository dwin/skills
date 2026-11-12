#!/usr/bin/env bash
set -euo pipefail

mkdir -p src/middleware src/routes test

cat > package.json <<'JSON'
{
  "name": "orders-api",
  "version": "1.4.0",
  "private": true,
  "type": "module",
  "scripts": { "start": "node src/server.js", "test": "node --test" }
}
JSON

cat > src/server.js <<'JS'
import http from "node:http";
import { auth } from "./middleware/auth.js";
import { throttle } from "./middleware/throttle.js";
import { orders } from "./routes/orders.js";
import { health } from "./routes/health.js";

const chain = [auth, throttle({ capacity: 60, refillPerSecond: 1 })];

http
  .createServer((req, res) => {
    if (req.url === "/health") return health(req, res);
    for (const step of chain) {
      if (step(req, res) === false) return;
    }
    orders(req, res);
  })
  .listen(process.env.PORT ?? 8080);
JS

cat > src/middleware/auth.js <<'JS'
export function auth(req, res) {
  if (!req.headers.authorization) {
    res.writeHead(401).end();
    return false;
  }
  return true;
}
JS

cat > src/middleware/throttle.js <<'JS'
const buckets = new Map();

// One TokenBucket per client address. A request spends one token; an empty
// bucket answers 429 until it refills.
export function throttle({ capacity, refillPerSecond }) {
  return function (req, res) {
    const key = req.socket.remoteAddress;
    const now = Date.now();
    const bucket = buckets.get(key) ?? { tokens: capacity, at: now };
    bucket.tokens = Math.min(
      capacity,
      bucket.tokens + ((now - bucket.at) / 1000) * refillPerSecond,
    );
    bucket.at = now;
    if (bucket.tokens < 1) {
      buckets.set(key, bucket);
      res.writeHead(429, { "retry-after": "1" }).end();
      return false;
    }
    bucket.tokens -= 1;
    buckets.set(key, bucket);
    return true;
  };
}
JS

cat > src/routes/orders.js <<'JS'
export function orders(req, res) {
  res.writeHead(200, { "content-type": "application/json" });
  res.end(JSON.stringify({ orders: [] }));
}
JS

cat > src/routes/health.js <<'JS'
export function health(req, res) {
  res.writeHead(200).end("ok");
}
JS

cat > README.md <<'MD'
# orders-api

Small HTTP service for order lookups. `npm start` runs it on `PORT`.
MD
