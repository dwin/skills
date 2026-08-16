#!/usr/bin/env bash

set -euo pipefail

marketplace_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
marketplace_name="$(jq -r '.name' "$marketplace_root/.agents/plugins/marketplace.json")"
temp_parent="${TMPDIR:-/tmp}"
codex_test_root="$(mktemp -d "$temp_parent/dwin-skills-codex.XXXXXX")"

cleanup() {
  case "$codex_test_root" in
    "$temp_parent"/dwin-skills-codex.*)
      rm -rf -- "$codex_test_root"
      ;;
    *)
      printf 'Refusing to remove unexpected path: %s\n' "$codex_test_root" >&2
      ;;
  esac
}
trap cleanup EXIT

mkdir -p "$codex_test_root/home"

CODEX_HOME="$codex_test_root/home" \
  codex plugin marketplace add "$marketplace_root" --json >/dev/null

while IFS= read -r plugin_name; do
  CODEX_HOME="$codex_test_root/home" \
    codex plugin add "$plugin_name@$marketplace_name" --json >/dev/null
done < <(jq -r '.plugins[].name' \
  "$marketplace_root/.agents/plugins/marketplace.json")

printf 'Installed every Codex marketplace entry from %s in an isolated config.\n' \
  "$marketplace_name"
