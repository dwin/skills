#!/usr/bin/env bash
set -euo pipefail

# Dates relative to today, so the sessions stay inside a 7-day window.
day() {
  date -v-"$1"d '+%Y-%m-%d' 2>/dev/null || date -d "$1 days ago" '+%Y-%m-%d'
}
stamp() {
  date -v-"$1"d '+%Y%m%d1200' 2>/dev/null || date -d "$1 days ago" '+%Y%m%d1200'
}

mkdir -p sessions src

write_session() {
  local ago="$1" id="$2" file
  file="sessions/$(day "$ago")-$id.md"
  cat > "$file"
  touch -t "$(stamp "$ago")" "$file"
}

write_session 6 a41c <<'MD'
# Session a41c

**User:** Start the CSV export for the reports page. Customers have big
reports, so don't build the whole file in memory.

**Agent:** Streaming rows with a generator in `src/export.js`, one row per
write. Branch `feat/csv-export`.

**User:** Good. Open the PR.

**Agent:** Opened PR #41, "Stream CSV export".
MD

write_session 5 b7e2 <<'MD'
# Session b7e2

**User:** PR #41 merged. Support says fields with commas break the columns.

**Agent:** Fields are not quoted. Added quoting for commas, quotes, and
newlines. PR #44.

**User:** Merge it.

**Agent:** PR #44 merged.
MD

write_session 4 c903 <<'MD'
# Session c903

**User:** Can you make the dark mode toggle remember the choice?

**Agent:** Saved it in localStorage. PR #45 merged.
MD

write_session 3 d118 <<'MD'
# Session d118

**User:** Customers opening the CSV in Excel see "Ã©" instead of "é".

**Agent:** Excel reads UTF-8 without a byte order mark as the legacy code
page. Added a UTF-8 BOM to the start of every export. PR #47.

**User:** Merge.

**Agent:** PR #47 merged.

**User:** The finance team's import script now fails on the first column
name. It sees the BOM as part of "date". Revert it.

**Agent:** Reverted in PR #48. The accent problem in Excel is back.
MD

write_session 2 e5d0 <<'MD'
# Session e5d0

**User:** Let's make the BOM opt in. Add `?bom=1` to the export URL, off by
default, so Excel users can turn it on and the finance import keeps working.

**Agent:** Agreed. Plan: read the flag in `src/export.js`, write the BOM only
when it is set, and add a test with "é" for both settings.

**User:** Do it next session. Out of time today.
MD

cat > src/export.js <<'JS'
const quote = (v) => (/[",\n]/.test(v) ? `"${String(v).replaceAll('"', '""')}"` : String(v));

export function* toCsv(rows, columns) {
  yield columns.map(quote).join(",") + "\n";
  for (const row of rows) yield columns.map((c) => quote(row[c] ?? "")).join(",") + "\n";
}
JS

git init -q
git add -A
git -c user.name=dev -c user.email=dev@example.test -c commit.gpgsign=false commit -q -m "Reports app with CSV export"
