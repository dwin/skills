---
name: rollout
description: Follow a merged change until it is applied, live, and observed. Use after merging a change that deploys, applies infrastructure, or changes runtime behavior, when the user asks whether something is deployed or live, or before stating what a merge will do.
---

# Rollout

**Merged**, **applied**, and **live** are three states. Each one is reported
only after it is observed, and the work is done when the last one is.

Use `verifying-claims` for every statement below. Following and observing a
rollout is read-only. A rerun, a rollback, or a fix forward needs the user's
authorization for that action, and so does anything that touches production.

## Before the merge

- **Label predictions.** What a merge will do is a prediction. Write "the plan
  shows X" and name what a plan cannot show. Common blind spots: a value whose
  type changes when applied, a resource that must already exist, a call across
  regions or through a network policy, an organization-level access setting,
  and a feature that needs an explicit opt-in. Read the repository's own list
  of these in its agent instructions, and add each new one you meet.
- **Exercise runtime behavior once.** When the change's effect is a behavior,
  such as a new workflow path or a broker, run one real use of it before the
  merge.
- **Get a run from someone other than the author.** An author checks what it
  meant to build. The Behavior axis of `code-review` is that independent run.

## At the merge

Read the pull request back after the merge command returns: its state, its
merge time, and its base branch. A queued pull request or an armed auto-merge
is still unmerged. Record the merged SHA.

## After the merge

1. **Find every run the merge started** for the merged SHA: apply, deploy, and
   release workflows. Wait for each through the host's wake, as `babysit`
   describes.
2. **Read each run per component.** Record its conclusion, the steps it
   skipped, and the resources it added, changed, or destroyed against the
   plan. A green workflow whose apply step was skipped applied nothing. When a
   change spans many components, count how many applied.
3. **Observe the target.** Compare the version or revision now running with
   the merged SHA. For infrastructure, read the resource's actual state. For a
   behavior, run the pre-merge check again against the deployed system.
4. **After a failed or timed-out apply, look before rerunning.** Objects can
   exist on the server after the client gave up. Read what exists, then
   propose the rerun, the fix, or the revert.

## Report

State the three states separately, each with its evidence:

- merged: the SHA and the pull request state;
- applied: each run, its conclusion, and the components applied or skipped;
- live: the version or behavior observed on the target.

List what you could not observe as unverified.
