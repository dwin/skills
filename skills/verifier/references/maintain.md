# Maintain a verification skill

A feature map goes stale as soon as the app changes. This pass brings it back.
The unit of rigor is the feature: every feature file is read against the
source, and every feature is driven live at least once. Not every bullet
needs its own run.

## Outcomes

End with exactly one, and say which:

- **Clean**: every feature had source and live coverage, and nothing needed
  to change. No branch and no change.
- **Changed**: one change ships the proven corrections to the skill, its map,
  or its harness.
- **Blocked**: coverage could not finish, or a proven fix could not ship
  safely. Say exactly what blocked it.

## Edit scope

Edit only the verification skill's own directory: its `SKILL.md`, its
`features/`, and the scripts it owns. Leave product code alone. When the map
describes behavior the app no longer has, decide which it is: the map is out
of date (fix the map), or the app regressed (report it to the user, and leave
the map describing the intended behavior).

## The pass

1. **Find the target.** Find the verification skill in the project. When there
   are several, ask which one. When there is none, stop and offer the create
   mode.
2. **Check the index.** Read `features/README.md` and list the files beside
   it. Fix entries that are missing, extra, duplicated, or dead.
3. **Read each feature from source.** For each feature file, have a read-only
   reader explain how that feature works now, from the code: its entry points,
   any place the file no longer matches the code, with the file and line, and
   one recipe for driving it live. Readers never drive the app and never edit
   files. When your host can start agents, run one reader per feature at
   once; `swarm` says how. Otherwise read them one at a time.
4. **Reconcile.** Every feature file has a returned reading. Merge recipes
   that share an app state so the live pass needs as few states as it can.
   Spot-check each mismatch a reader reported before you act on it. Then look
   for user-facing surfaces the map lacks: read `git log` on the app's code
   since the skill last changed, and call a surface missing only with the path
   that adds it.
5. **Drive every feature live**, even when the source reading found nothing.
   You do all the driving. Follow the skill's own launch model: one
   long-lived instance driven in turn for a server or a UI, or a fresh
   isolated session per drive for a short-lived command. Hold three rules for
   the whole pass:
   - Run the doctor before the first drive, on every fresh session, and after
     any failed drive. When the doctor cannot see the problem, such as a UI
     stuck in a bad state while the process is healthy, reset to a known state
     or relaunch.
   - Evidence captured so far survives every cleanup. Check it at its named
     location.
   - Clean up what each drive started as soon as it stops being useful,
     whether the session is stuck, exited, or shared. On a shared instance,
     clean up the drive's leftovers, not the instance.

   A doctor failure caused by a stale skill is drift: fix it within the edit
   scope and retry once, restarting only what the fix invalidated, before you
   call the pass blocked. A feature you cannot reach is unreachable only with
   the missing prerequisite named (sign-in, an entitlement, an operating
   system, outside state) and the route you tried. When the map leaves that
   prerequisite out, that is drift too.

6. **Sort what you found.**
   - The map describes the feature wrongly or not at all: fix the map.
   - The feature works but the harness cannot drive it: fix the harness, make
     any script executable, and show its call in the skill. Drive the fixed
     path live again before it ships.
   - The app is broken: record it for the user, outside this change.
7. **Ship or stop.** For a changed outcome, reread every changed file. When
   the change touches a feature's steps or a helper they call, show those
   steps catching a broken change again before it ships, by "Run it broken"
   in step 4 of [create.md](create.md), with its record, isolation, and
   cleanup. Then ship one change the way the project takes changes. Tear down after the last
   drive, including the re-drives from step 6. For a clean or blocked outcome,
   ship nothing and report the outcome and the coverage.

Keep short run notes outside the repository: features covered, unreachable
prerequisites, confirmed drift, and the outcome. Leave them out of the
change.
