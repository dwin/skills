#!/usr/bin/env bash
# Append one row to a work log (tab-separated values).
# Usage: work-log.sh <file> <phase> <decision> <why> <evidence> <result>
set -euo pipefail

if [ "$#" -ne 6 ]; then
  printf 'usage: work-log.sh <file> <phase> <decision> <why> <evidence> <result>\n' >&2
  exit 2
fi

log_file="$1"
shift

mkdir -p -- "$(dirname -- "$log_file")"

# Append the header rather than truncating: a filesystem that misreports an
# existing file as empty then costs one extra header line, not the rows.
if [ ! -s "$log_file" ]; then
  printf 'ts\tphase\tdecision\twhy\tevidence\tresult\n' >>"$log_file"
fi

# Flatten tabs and line breaks so each cell stays on one line, and quote a
# leading =, +, -, or @ so a spreadsheet reads the cell as text, not a formula.
clean() {
  local value
  value="$(printf '%s' "$1" | tr '\t\r\n' '   ')"
  case "$value" in
    [=+@-]*) printf "'%s" "$value" ;;
    *) printf '%s' "$value" ;;
  esac
}

timestamp="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
  "$timestamp" "$(clean "$1")" "$(clean "$2")" "$(clean "$3")" \
  "$(clean "$4")" "$(clean "$5")" >>"$log_file"
