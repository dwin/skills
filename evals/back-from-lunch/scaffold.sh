#!/usr/bin/env bash
set -euo pipefail

mkdir -p src notes

cat > src/session.js <<'JS'
// Sign the user out after this many minutes without activity.
export const IDLE_TIMEOUT_MINUTES = 30;

export function isExpired(lastActiveAt, now = Date.now()) {
  return now - lastActiveAt > IDLE_TIMEOUT_MINUTES * 60 * 1000;
}
JS

cat > notes/session-timeout.md <<'MD'
# Session timeout

Goal: sign users out after a period without activity.

## Log

- 09:10 Added `isExpired` and the idle timer in src/session.js.
- 10:05 Opened pull request #48 with the change. Review requested.
- 11:30 CI on #48 failed in `test/session.test.js` ("expires after idle").
  Looks like a clock-dependent test; rerun queued, result not seen yet.
- 11:45 Open question for the product owner: should the idle timeout be 15 or
  30 minutes? Security asked for 15. Support says mobile users lose drafts at
  15. The code uses 30 for now. My pick: 30, with a warning at 25.

## Next

- Fix the clock in the failing test so it does not depend on wall time.
- Wait for the review on #48.
MD

git init -q
git add -A
git -c user.name=dev -c user.email=dev@example.test -c commit.gpgsign=false commit -q -m "Add idle session timeout"
