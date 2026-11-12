# Visual parity

Use this when two renderings must match pixel for pixel: migrating a styling
system, replacing a component library, or matching one implementation to
another.

The baseline is the specification. An image diff decides whether two
renderings match. Looking at them does not.

## Steps

1. **Capture the baseline before any migration.** Build a harness that
   screenshots each component in each of its states, at a fixed viewport,
   with animations off and fonts loaded. Without a baseline there is no
   parity claim. Check the harness by running it twice on unchanged code: the
   two runs must match exactly.
2. **Hold these rules for the whole task:**
   - the harness stays as it is;
   - the baseline images stay as they are;
   - a component is not restructured to make a diff pass.

   When a baseline looks wrong, stop and ask the user.

3. **Migrate shared primitives first.** Everything else waits for them.
4. **Migrate one component at a time.** With several workers, give each
   component one owner in its own workspace: use `swarm`.
5. **Diff each component against its baseline** on the surface the user sees:
   the same browser, the same device size. Any nonzero diff is a failure.
   Find the cause of the pixel difference, fix it, and diff again until the
   diff is zero.
6. **File a PR per component or per safe batch** with `file-pr`.

## Report

List the components migrated, the diff result for each, where the harness and
baselines live, and what is left.
