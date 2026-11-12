#!/usr/bin/env bash

set -euo pipefail

marketplace_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$marketplace_root"

./scripts/validate-agent-skills.sh

# Cursor and other hosts discover skills through .agents/skills. Every skill
# needs a link there, and every link has to resolve.
for skill_dir in skills/*/ plugins/*/skills/*/; do
  # A pattern that matches nothing stays as written. Skip it.
  [[ -d "$skill_dir" ]] || continue
  skill_name="$(basename "$skill_dir")"
  if [[ ! -L ".agents/skills/$skill_name" ]]; then
    echo "Missing discovery link: .agents/skills/$skill_name" >&2
    exit 1
  fi
  if [[ ! ".agents/skills/$skill_name" -ef "$skill_dir" ]]; then
    echo "Discovery link points elsewhere: .agents/skills/$skill_name" >&2
    exit 1
  fi
done
for link in .agents/skills/*; do
  [[ -L "$link" ]] || continue
  if [[ ! -e "$link" ]]; then
    echo "Broken discovery link: $link" >&2
    exit 1
  fi
done

markdownlint --config .markdownlint.yaml --dot \
  --ignore '.git/**' --ignore 'node_modules/**' --ignore '.agents/skills/**' \
  '**/*.md'
prettier --check . --ignore-path .gitignore

while IFS= read -r -d '' json_file; do
  jq empty "$json_file"
done < <(
  find . \
    -path './.git' -prune -o \
    -path './node_modules' -prune -o \
    -name '*.json' -type f -print0
)

shell_files=(scripts/*.sh)
while IFS= read -r -d '' shell_file; do
  shell_files+=("$shell_file")
done < <(find skills plugins evals -type f -name '*.sh' -print0)
bash -n "${shell_files[@]}"
shellcheck "${shell_files[@]}"
workflow_files=("$marketplace_root"/.github/workflows/*.yml)
go -C tools tool actionlint -color "${workflow_files[@]}"
uvx zizmor==1.29.0 .github/workflows

claude plugin validate . --strict
for plugin_root in plugins/*; do
  claude plugin validate "$plugin_root" --strict
done
