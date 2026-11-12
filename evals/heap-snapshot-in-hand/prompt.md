---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [whats-next, router]
---

Our Node worker's memory climbs until the container is killed, about every six hours. I took a heap snapshot at 2 GB and saved it as worker.heapsnapshot. Tell me how you'd find the cause before you do anything.
