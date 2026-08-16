#!/usr/bin/env bash

set -euo pipefail

marketplace_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
temp_parent="${TMPDIR:-/tmp}"
validation_root="$(mktemp -d "$temp_parent/dwin-skills-validation.XXXXXX")"

cleanup() {
  case "$validation_root" in
    "$temp_parent"/dwin-skills-validation.*)
      rm -rf -- "$validation_root"
      ;;
    *)
      printf 'Refusing to remove unexpected path: %s\n' "$validation_root" >&2
      ;;
  esac
}
trap cleanup EXIT

for skill in "$marketplace_root"/skills/*; do
  if grep -Eq '^(disable-model-invocation|argument-hint):' "$skill/SKILL.md"; then
    skill_name="$(basename "$skill")"
    normalized_skill="$validation_root/$skill_name"
    mkdir -p "$normalized_skill"
    sed -E '/^(disable-model-invocation|argument-hint):/d' \
      "$skill/SKILL.md" >"$normalized_skill/SKILL.md"
    uvx --from skills-ref==0.1.1 agentskills validate "$normalized_skill"
    printf 'Validated %s with its client invocation extensions normalized.\n' \
      "$skill_name"
  else
    uvx --from skills-ref==0.1.1 agentskills validate "$skill"
  fi
done
