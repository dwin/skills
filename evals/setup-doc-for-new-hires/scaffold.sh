#!/usr/bin/env bash
set -euo pipefail

mkdir -p docs

cat > docs/setup.md <<'MD'
# Getting Started With The Development Environment

Setting up your environment is simply a matter of a few easy steps. First of
all, it's important to note that Node 22 is required, which can be installed
via `fnm install 22`. The dependencies should then be installed by running
`npm ci`, and the database is started with `docker compose up -d db`, after
which migrations are applied via `npm run db:migrate`. Note that on Apple
silicon machines `export DOCKER_DEFAULT_PLATFORM=linux/amd64` should be run
before the database is started, otherwise the image fails to pull. Finally,
the app can be quickly launched using `npm run dev`, and it will be available
at http://localhost:5173.
MD

git init -q
git add -A
git -c user.name=dev -c user.email=dev@example.test -c commit.gpgsign=false commit -q -m "Add setup doc"
