---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
tags: [visual-explainer, trigger]
---

We need to pick how engineers run occasional write queries against our three production Postgres clusters (`billing`, `orders`, `identity`). The candidates on the table are:

1. Direct IAM database logins from laptops over VPN (`dev_readwrite`).
2. A single shared web SQL proxy with 2-hour expiring directory group memberships.
3. Two isolated web SQL proxy deployments (one read-only, one write-only) behind an edge approval policy with a 2-hour session cap.
4. A CI pull-request runner where every `UPDATE` ships as a reviewed SQL migration file.

Compare them across per-user query attribution, blast-radius isolation across the three clusters, emergency turnaround time, and custom glue code we have to maintain, and help me pick one. `viz`
