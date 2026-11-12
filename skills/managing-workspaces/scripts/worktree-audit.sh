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
#   PR         #number/state of a pull request from a branch of this name, in
#              the repository gh resolves from this one's remotes. The
#              header line names it. An open or draft one comes first, then
#              a merged one. merged means its head commit contains this HEAD
#              and the base contains its merge commit. not-in-base means the
#              head matches and the base does not contain the merge commit:
#              it merged into another branch, or the base needs a fetch.
#              outdated means a merged one exists and does not contain HEAD:
#              the branch moved on, or the pull request came from another
#              repository. A detached worktree shows an open pull request
#              whose head commit is its HEAD. - when there is none, ? when
#              gh cannot tell or a listing was cut off. With ?, an open pull
#              request cannot hold a row: look before removing a candidate.
#   UNPUSHED   Commits on HEAD that no remote-tracking branch contains.
#   TRACKED    Tracked files with uncommitted changes. ? when `git status`
#              failed there, or when the index hides files from it: an entry
#              marked assume-unchanged or skip-worktree can hold a change
#              that status never shows. The row is then marked review.
#   UNTRACKED  Untracked entries; a new directory counts once. Ignored files
#              are not counted. ? when `git status` failed.
#   SUGGEST    main, missing, hold-locked, hold-changes, hold-open-pr,
#              hold-unpushed, candidate, or review. A candidate is merged, or
#              PR says merged, and it has no uncommitted or untracked files.
#              hold-locked means someone ran
#              `git worktree lock` on it.
#              Advice only: a worktree another session is using stays,
#              whatever this column says.
#   WORKTREE   The path.
set -uo pipefail

# Keep Git from refreshing an index while it reads one: `git status` would
# otherwise rewrite the index file of each worktree it looks at.
export GIT_OPTIONAL_LOCKS=0
# GH_REPO points gh at whatever repository it names. Without it, gh reads the
# remotes of the repository being audited.
unset GH_REPO

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

# Pull request state per branch, from two gh listings of one repository: the
# open ones, then every state, newest first. A listing that fills the limit
# may have left pull requests out. Open ones are listed apart so that a
# merged one is not read as the whole story while an open one sits past the
# cut.
pr_limit=1000
prs="$(mktemp)"
prs_open="$(mktemp)"
trap 'rm -f "$prs" "$prs_open"' EXIT
pr_fields=number,state,isDraft,headRefName,headRefOid,mergeCommit
# Name, number, state, head commit, merge commit. A pull request closed as a
# draft is closed, so draft is read only from an open one.
pr_rows='.[] | [.headRefName, .number,
  (if .state == "OPEN" and .isDraft then "draft" else (.state | ascii_downcase) end),
  .headRefOid, (.mergeCommit.oid // "-")] | @tsv'
pr_known=no
pr_capped=no
open_capped=no
pr_repo=""
if command -v gh >/dev/null 2>&1 &&
  pr_repo="$(gh repo view --json url --jq .url 2>/dev/null)" && [ -n "$pr_repo" ] &&
  gh pr list --repo "$pr_repo" --state open --limit "$pr_limit" \
    --json "$pr_fields" --jq "$pr_rows" >"$prs_open" 2>/dev/null &&
  gh pr list --repo "$pr_repo" --state all --limit "$pr_limit" \
    --json "$pr_fields" --jq "$pr_rows" >"$prs" 2>/dev/null; then
  pr_known=yes
  [ "$(wc -l <"$prs_open")" -ge "$pr_limit" ] && open_capped=yes
  [ "$(wc -l <"$prs")" -ge "$pr_limit" ] && pr_capped=yes
fi
pr_source=unknown
[ "$pr_known" = yes ] && pr_source="gh, $pr_repo"
[ "$pr_capped" = yes ] && pr_source="$pr_source, newest $pr_limit only"
[ "$open_capped" = yes ] && pr_source="$pr_source, open ones cut at $pr_limit"

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
    # A branch name is not unique: a fork can open a pull request from a
    # branch of the same name, and a branch can gain commits after its pull
    # request merged. So read every row for the name. An open one holds the
    # row. A merged one counts only when its head commit contains this HEAD
    # and the base contains its merge commit: one merged into another branch
    # says nothing about the base. A detached worktree has no name to match,
    # so it is matched to an open pull request by its head commit.
    head_commit="$(git -C "$worktree" rev-parse --verify --quiet HEAD 2>/dev/null || echo "")"
    pr_open=""
    pr_merged=""
    pr_elsewhere=""
    pr_outdated=""
    pr_closed=""
    while IFS="$(printf '\t')" read -r _ pr_number pr_state pr_head pr_merge; do
      case "$pr_state" in
        open | draft) [ -n "$pr_open" ] || pr_open="#$pr_number/$pr_state" ;;
        merged)
          if [ -z "$head_commit" ] || [ -z "$pr_head" ] ||
            { [ "$pr_head" != "$head_commit" ] &&
              ! git -C "$worktree" merge-base --is-ancestor "$head_commit" "$pr_head" 2>/dev/null; }; then
            [ -n "$pr_outdated" ] || pr_outdated="#$pr_number/outdated"
          elif [ "${pr_merge:--}" != "-" ] &&
            git -C "$worktree" merge-base --is-ancestor "$pr_merge" "$base_commit" 2>/dev/null; then
            [ -n "$pr_merged" ] || pr_merged="#$pr_number/merged"
          else
            [ -n "$pr_elsewhere" ] || pr_elsewhere="#$pr_number/not-in-base"
          fi
          ;;
        *) [ -n "$pr_closed" ] || pr_closed="#$pr_number/$pr_state" ;;
      esac
    done < <(
      if [ "$branch" != "(detached)" ]; then
        awk -F '\t' -v b="$branch" '$1 == b' "$prs_open" "$prs"
      elif [ -n "$head_commit" ]; then
        awk -F '\t' -v h="$head_commit" '$4 == h' "$prs_open"
      fi
    )
    if [ -n "$pr_open" ]; then
      pr="$pr_open"
    elif [ "$open_capped" = yes ]; then
      # An open pull request may sit past the cut, whatever else is listed.
      pr="?"
    elif [ -n "$pr_merged" ]; then
      pr="$pr_merged"
    elif [ -n "$pr_elsewhere" ]; then
      pr="$pr_elsewhere"
    elif [ -n "$pr_outdated" ]; then
      pr="$pr_outdated"
    elif [ -n "$pr_closed" ]; then
      pr="$pr_closed"
    elif [ "$pr_capped" = yes ] && [ "$branch" != "(detached)" ]; then
      pr="?"
    else
      pr="-"
    fi
  fi

  unpushed="$(git -C "$worktree" rev-list --count HEAD --not --remotes 2>/dev/null || echo "?")"

  # A status that fails proves nothing about the worktree, so its counts are
  # unknown and it is never a candidate.
  # Ask for untracked files and submodule changes outright: the settings
  # status.showUntrackedFiles=no and submodule.<name>.ignore would otherwise
  # hide them.
  if ! status="$(git -C "$worktree" status --porcelain --untracked-files=normal \
    --ignore-submodules=none 2>/dev/null)"; then
    tracked="?"
    untracked="?"
  elif [ -z "$status" ]; then
    tracked=0
    untracked=0
  else
    untracked="$(printf '%s\n' "$status" | grep -c '^??')"
    tracked="$(printf '%s\n' "$status" | grep -vc '^??')"
  fi
  # An entry marked assume-unchanged (a lower-case tag from ls-files -v) or
  # skip-worktree (S) can hold a change that status never shows, and removing
  # the worktree would delete it unseen. grep -c prints the count and fails
  # when it is 0, so its status is not read.
  hidden="$(git -C "$worktree" ls-files -v 2>/dev/null | grep -c '^[a-zS]' || true)"
  [ "${hidden:-0}" = 0 ] || tracked="?"

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
