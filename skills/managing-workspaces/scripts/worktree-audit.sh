#!/usr/bin/env bash
# List every Git worktree of a repository with the facts that decide whether
# it can be removed. Read-only: it removes, fetches, and changes nothing.
#
# Usage: worktree-audit.sh [-b|--base <ref>] [repo-path]
#   repo-path  The repository to audit. Default: the one holding the current
#              directory.
#   -b <ref>   The branch that MERGED is checked against. Default: origin/HEAD,
#              then origin/main, origin/master, main, master.
#
# Run `git fetch` first when MERGED and PR should be current.
#
# Columns, one row per worktree, largest first:
#   SIZE       Disk use of the worktree directory.
#   AGE        Days since the commit at its HEAD.
#   BRANCH     The checked-out branch, or (detached).
#   MERGED     yes when the base contains HEAD. A squash merge shows no here,
#              so read PR as well.
#   PR         #number/state of a pull request from a branch of this name: an
#              open or draft one first, then a merged one whose head commit
#              contains this HEAD. outdated means a merged one exists and
#              does not contain HEAD: the branch moved on, or the pull
#              request came from another repository. - when there is none, ?
#              when gh cannot tell or its listing was cut off before reaching
#              the branch. With ?, an open pull request cannot hold a row:
#              look before removing a candidate.
#   UNPUSHED   Commits on HEAD that no remote-tracking branch contains.
#   TRACKED    Tracked files with uncommitted changes. ? when `git status`
#              failed there; the row is then marked review.
#   UNTRACKED  Untracked entries; a new directory counts once. Ignored files
#              are not counted. ? when `git status` failed.
#   SUGGEST    main, missing, hold-locked, hold-changes, hold-open-pr,
#              hold-unpushed, candidate, or review. A candidate is merged, or
#              a merged pull request contains its HEAD, and it has no
#              uncommitted or untracked files. hold-locked means someone ran
#              `git worktree lock` on it.
#              Advice only: a worktree another session is using stays,
#              whatever this column says.
#   WORKTREE   The path.
set -uo pipefail

# Keep Git from refreshing an index while it reads one: `git status` would
# otherwise rewrite the index file of each worktree it looks at.
export GIT_OPTIONAL_LOCKS=0

usage() { sed -n '2,/^set -uo/p' "$0" | sed '$d; s/^# \{0,1\}//'; }

base=""
while [ $# -gt 0 ]; do
  case "$1" in
    -b | --base)
      [ $# -ge 2 ] || { echo "error: $1 needs a ref" >&2; exit 2; }
      base="$2"
      shift 2
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    -*)
      echo "error: unknown option: $1" >&2
      exit 2
      ;;
    *) break ;;
  esac
done

[ $# -le 1 ] || { echo "error: expected one repository path, got $#" >&2; exit 2; }
repo="${1:-.}"
# Command substitution drops every trailing newline, and a path may end in
# one. The x keeps them; then remove the x and the one newline Git added.
repo="$(git -C "$repo" rev-parse --show-toplevel 2>/dev/null && printf x)" || {
  echo "error: not a Git repository: ${1:-.}" >&2
  exit 1
}
repo="${repo%x}"
repo="${repo%$'\n'}"
cd "$repo" || exit 1

if [ -z "$base" ]; then
  for candidate in "$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)" \
    origin/main origin/master main master; do
    if [ -n "$candidate" ] && git rev-parse --verify --quiet "$candidate^{commit}" >/dev/null; then
      base="$candidate"
      break
    fi
  done
  [ -n "$base" ] || {
    echo "error: no base branch found; pass -b <ref>" >&2
    exit 1
  }
fi
# Resolve the base to one commit here. A name such as HEAD means a different
# commit inside each worktree.
base_commit="$(git rev-parse --verify --quiet "$base^{commit}")" || {
  echo "error: base not found: $base" >&2
  exit 1
}

# Pull request state per branch, newest first, from one gh call. A listing
# that fills the limit may have left older pull requests out, so a branch it
# does not name is then unknown, not free of pull requests.
pr_limit=1000
prs="$(mktemp)"
trap 'rm -f "$prs"' EXIT
pr_known=no
pr_capped=no
if command -v gh >/dev/null 2>&1 &&
  gh pr list --state all --limit "$pr_limit" --json number,state,isDraft,headRefName,headRefOid \
    --jq '.[] | [.headRefName, .number, (if .isDraft then "draft" else (.state | ascii_downcase) end), .headRefOid] | @tsv' \
    >"$prs" 2>/dev/null; then
  pr_known=yes
  [ "$(wc -l <"$prs")" -ge "$pr_limit" ] && pr_capped=yes
fi
pr_source=unknown
[ "$pr_known" = yes ] && pr_source=gh
[ "$pr_capped" = yes ] && pr_source="gh, newest $pr_limit only"

now="$(date +%s)"
# Records end in NUL, so a path may hold any other character.
worktrees() {
  git worktree list --porcelain -z | while IFS= read -r -d '' field; do
    case "$field" in worktree\ *) printf '%s\0' "${field#worktree }" ;; esac
  done
}
main_worktree=""
while IFS= read -r -d '' worktree; do
  main_worktree="$worktree"
  break
done < <(worktrees)

# A locked worktree is one someone asked Git to keep.
locked_worktrees=()
current=""
while IFS= read -r -d '' field; do
  case "$field" in
    worktree\ *) current="${field#worktree }" ;;
    locked | locked\ *) locked_worktrees+=("$current") ;;
  esac
done < <(git worktree list --porcelain -z)
is_locked() {
  local path
  for path in ${locked_worktrees[@]+"${locked_worktrees[@]}"}; do
    [ "$path" = "$1" ] && return 0
  done
  return 1
}

echo "# repository: $(printf '%s' "$repo" | tr '\t\r\n' '   ')"
echo "# base: $base (pull requests: $pr_source)"
printf 'SIZE\tAGE\tBRANCH\tMERGED\tPR\tUNPUSHED\tTRACKED\tUNTRACKED\tSUGGEST\tWORKTREE\n'

worktrees | while IFS= read -r -d '' worktree; do
  # One row per worktree: show a tab or a line break in a path as a space.
  shown="$(printf '%s' "$worktree" | tr '\t\r\n' '   ')"
  if [ ! -d "$worktree" ]; then
    printf -- '-\t-\t-\t-\t-\t-\t-\t-\tmissing\t%s\n' "$shown"
    continue
  fi

  size="$(du -sh "$worktree" 2>/dev/null | awk 'NR == 1 { print $1 }')"
  head_time="$(git -C "$worktree" log -1 --format=%ct HEAD 2>/dev/null || echo "")"
  if [ -n "$head_time" ]; then age="$(((now - head_time) / 86400))d"; else age="?"; fi

  # Read the full ref and cut the prefix. The short form turns "topic" into
  # "heads/topic" when a tag has the same name, and no pull request matches.
  if branch="$(git -C "$worktree" symbolic-ref --quiet HEAD 2>/dev/null)"; then
    branch="${branch#refs/heads/}"
  else
    branch="(detached)"
  fi

  if git -C "$worktree" merge-base --is-ancestor HEAD "$base_commit" 2>/dev/null; then
    merged=yes
  else
    merged=no
  fi

  pr="?"
  if [ "$pr_known" = yes ]; then
    pr="-"
    if [ "$branch" != "(detached)" ]; then
      [ "$pr_capped" = yes ] && pr="?"
      # A branch name is not unique: a fork can open a pull request from a
      # branch of the same name, and a branch can gain commits after its pull
      # request merged. So read every row for the name. An open one holds the
      # row. A merged one counts only when its head commit contains this HEAD.
      head_commit="$(git -C "$worktree" rev-parse --verify --quiet HEAD 2>/dev/null || echo "")"
      pr_open=""
      pr_merged=""
      pr_outdated=""
      pr_closed=""
      while IFS="$(printf '\t')" read -r _ pr_number pr_state pr_head; do
        case "$pr_state" in
          open | draft) [ -n "$pr_open" ] || pr_open="#$pr_number/$pr_state" ;;
          merged)
            if [ -n "$head_commit" ] && [ -n "$pr_head" ] &&
              { [ "$pr_head" = "$head_commit" ] ||
                git -C "$worktree" merge-base --is-ancestor "$head_commit" "$pr_head" 2>/dev/null; }; then
              [ -n "$pr_merged" ] || pr_merged="#$pr_number/merged"
            else
              [ -n "$pr_outdated" ] || pr_outdated="#$pr_number/outdated"
            fi
            ;;
          *) [ -n "$pr_closed" ] || pr_closed="#$pr_number/$pr_state" ;;
        esac
      done < <(awk -F '\t' -v b="$branch" '$1 == b' "$prs")
      if [ -n "$pr_open" ]; then
        pr="$pr_open"
      elif [ -n "$pr_merged" ]; then
        pr="$pr_merged"
      elif [ -n "$pr_outdated" ]; then
        pr="$pr_outdated"
      elif [ -n "$pr_closed" ]; then
        pr="$pr_closed"
      fi
    fi
  fi

  unpushed="$(git -C "$worktree" rev-list --count HEAD --not --remotes 2>/dev/null || echo "?")"

  # A status that fails proves nothing about the worktree, so its counts are
  # unknown and it is never a candidate.
  if ! status="$(git -C "$worktree" status --porcelain 2>/dev/null)"; then
    tracked="?"
    untracked="?"
  elif [ -z "$status" ]; then
    tracked=0
    untracked=0
  else
    untracked="$(printf '%s\n' "$status" | grep -c '^??')"
    tracked="$(printf '%s\n' "$status" | grep -vc '^??')"
  fi

  if [ "$worktree" = "$main_worktree" ]; then
    suggest=main
  elif is_locked "$worktree"; then
    suggest=hold-locked
  elif [ "$tracked" = "?" ]; then
    suggest=review
  elif [ "$tracked" != 0 ]; then
    suggest=hold-changes
  else
    case "$pr" in
      */open | */draft) suggest=hold-open-pr ;;
      *)
        if [ "$merged" = yes ]; then
          suggest=candidate
        elif [ "$unpushed" != 0 ]; then
          suggest=hold-unpushed
        elif [ "${pr##*/}" = merged ]; then
          suggest=candidate
        else
          suggest=review
        fi
        ;;
    esac
  fi

  # Removing a worktree discards its untracked files, so someone looks first.
  if [ "$suggest" = candidate ] && [ "$untracked" != 0 ]; then
    suggest=review
  fi

  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$size" "$age" "$branch" "$merged" "$pr" "$unpushed" \
    "$tracked" "$untracked" "$suggest" "$shown"
done | sort -t "$(printf '\t')" -k1,1 -rh
