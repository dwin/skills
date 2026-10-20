#!/usr/bin/env bash

set -euo pipefail

marketplace_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$marketplace_root"

./scripts/validate-agent-skills.sh

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
done < <(find skills plugins -type f -name '*.sh' -print0)
bash -n "${shell_files[@]}"
shellcheck "${shell_files[@]}"
workflow_files=("$marketplace_root"/.github/workflows/*.yml)
go -C tools tool actionlint -color "${workflow_files[@]}"
uvx zizmor==1.29.0 .github/workflows

claude plugin validate . --strict
for plugin_root in plugins/*; do
  claude plugin validate "$plugin_root" --strict
done
