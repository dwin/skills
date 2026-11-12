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
#   BRANCH     The checked-out branch, or (detached), written as WORKTREE
#              writes a path. During a rebase or a
#              bisect, the branch it started from. While a rebase, bisect,
#              merge, cherry-pick, or revert is in progress the row is never
#              a candidate, because someone is working there.
#   MERGED     yes when the base contains HEAD. A squash merge shows no here,
#              so read PR as well.
#   PR         #number/state of a pull request from a branch of this name, or
#              of the name of the remote branch it tracks, in the repository
#              gh resolves from this one's remotes. The header line names
#              it. An open or draft one comes first, then
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
#   WORKTREE   The path. A backslash, tab, carriage return, or line break in
#              it is written as \\, \t, \r, or \n, and any other control
#              character as \x or \u00 and two hex digits, so each row is
#              one line, no two paths look alike, and nothing in a path can
#              redraw the terminal.
set -uo pipefail

# Start from known settings, whatever the caller's shell and environment
# hold. Each of these changed a row, wrote a file, or printed a raw path:
# - Shell options that reach a script through SHELLOPTS or a start-up file.
#   xtrace prints paths before they are escaped, errexit stops the report,
#   noclobber refuses the temporary files.
set +e +x +v +C
# - A changed IFS, which splits the fields this script reads differently.
{ IFS=$' \t\n'; } 2>/dev/null
# A start-up file can also make a variable read-only. Then it cannot be reset
# here, and the only safe report is none.
if [ "$IFS" != $' \t\n' ]; then
  printf 'error: IFS is read-only and not the default; cannot audit safely\n' >&2
  exit 1
fi
drop_var() {
  unset "$1" 2>/dev/null
  if [ -n "${!1+x}" ]; then
    printf 'error: cannot clear %s from the environment; cannot audit safely\n' "$1" >&2
    exit 1
  fi
}
# - Git's trace variables, which make Git write files or extra output.
for git_var in $(compgen -v GIT_TRACE); do
  drop_var "$git_var"
done
# - A Git variable left by a hook, such as GIT_DIR or GIT_INDEX_FILE, which
#   points every `git -C <worktree>` at one repository or one index.
while IFS= read -r git_var; do
  drop_var "$git_var"
done < <(git rev-parse --local-env-vars 2>/dev/null)
# - GREP_OPTIONS, which changes what the counts count.
drop_var GREP_OPTIONS
# - GH_REPO, which points gh at whatever repository it names. Without it, gh
#   reads the remotes of the repository being audited.
drop_var GH_REPO
# Keep Git from refreshing an index while it reads one: `git status` would
# otherwise rewrite the index file of each worktree it looks at.
{ export GIT_OPTIONAL_LOCKS=0; } 2>/dev/null
if [ "${GIT_OPTIONAL_LOCKS:-}" != 0 ]; then
  printf 'error: cannot set GIT_OPTIONAL_LOCKS=0; cannot audit without writing\n' >&2
  exit 1
fi

# Text from a path, a ref name, or an argument goes to a terminal, so write
# it on one line without losing what it was: a backslash becomes two, a tab,
# carriage return, or line break becomes \t, \r, or \n, any other control
# character becomes \x and its two hex digits, and a C1 control character in
# UTF-8 becomes \u00 and its two hex digits. Showing them as spaces would
# make two paths look the same, and printing them raw would let an escape
# sequence redraw the terminal. Other non-ASCII text is left as it is.
ctl_chars=()
ctl_names=()
for ctl_code in 1 2 3 4 5 6 7 8 11 12 14 15 16 17 18 19 20 21 22 23 24 25 26 \
  27 28 29 30 31 127; do
  # shellcheck disable=SC2059  # the format is the octal escape itself
  ctl_chars+=("$(printf "\\$(printf '%03o' "$ctl_code")")")
  ctl_names+=("$(printf 'x%02x' "$ctl_code")")
done
for ctl_code in 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 \
  143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159; do
  # shellcheck disable=SC2059  # the format is the two octal escapes
  ctl_chars+=("$(printf "\\302\\$(printf '%03o' "$ctl_code")")")
  ctl_names+=("$(printf 'u00%02x' "$ctl_code")")
done
show_path() {
  local text="$1" bs tab cr nl i
  bs="\\"
  tab="$(printf '\t')"
  cr="$(printf '\r')"
  nl='
'
  # No quotes around the whole expansion, and quotes around each
  # replacement: Bash 3.2 and Bash 5 agree on that form and on no other.
  text=${text//"$bs"/"$bs$bs"}
  text=${text//"$tab"/"${bs}t"}
  text=${text//"$cr"/"${bs}r"}
  text=${text//"$nl"/"${bs}n"}
  for i in "${!ctl_chars[@]}"; do
    text=${text//"${ctl_chars[$i]}"/"$bs${ctl_names[$i]}"}
  done
  # printf, not echo: with the xpg_echo option on, echo would read these
  # escapes and print the raw characters again.
  printf '%s' "$text"
}

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
      printf 'error: unknown option: %s\n' "$(show_path "$1")" >&2
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
  printf 'error: not a Git repository: %s\n' "$(show_path "${1:-.}")" >&2
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
  printf 'error: base not found: %s\n' "$(show_path "$base")" >&2
  exit 1
}
# The base's full ref name, such as refs/remotes/origin/main. Empty when the
# base is a commit id.
base_ref="$(git rev-parse --symbolic-full-name "$base" 2>/dev/null || echo "")"

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

printf '# repository: %s\n' "$(show_path "$repo")"
printf '# base: %s (pull requests: %s)\n' "$(show_path "$base")" "$pr_source"
printf 'SIZE\tAGE\tBRANCH\tMERGED\tPR\tUNPUSHED\tTRACKED\tUNTRACKED\tSUGGEST\tWORKTREE\n'

worktrees | while IFS= read -r -d '' worktree; do
  shown="$(show_path "$worktree")"
  if [ ! -d "$worktree" ]; then
    printf -- '-\t-\t-\t-\t-\t-\t-\t-\tmissing\t%s\n' "$shown"
    continue
  fi

  size="$(du -sh "$worktree" 2>/dev/null | awk 'NR == 1 { print $1 }')"
  head_time="$(git -C "$worktree" log -1 --format=%ct HEAD 2>/dev/null || echo "")"
  if [ -n "$head_time" ]; then age="$(((now - head_time) / 86400))d"; else age="?"; fi

  # Read the full ref and cut the prefix. The short form turns "topic" into
  # "heads/topic" when a tag has the same name, and no pull request matches.
  # The worktree's own Git directory, where an operation in progress keeps
  # its files. The x keeps a trailing newline in the path, as for the
  # repository above.
  git_dir="$(git -C "$worktree" rev-parse --absolute-git-dir 2>/dev/null && printf x)" || git_dir=""
  git_dir="${git_dir%x}"
  git_dir="${git_dir%$'\n'}"

  # A rebase, bisect, merge, cherry-pick, or revert in progress means someone
  # is working there, whether or not it detached HEAD. A Git directory that
  # cannot be found proves nothing, so that worktree counts as busy too.
  busy=yes
  if [ -n "$git_dir" ]; then
    busy=no
    for op_path in rebase-merge rebase-apply BISECT_START BISECT_LOG MERGE_HEAD \
      CHERRY_PICK_HEAD REVERT_HEAD sequencer; do
      [ -e "$git_dir/$op_path" ] && busy=yes
    done
  fi

  # on_branch says whether a branch was found. The text (detached) is only
  # what the column shows: a branch may be named exactly that.
  if branch="$(git -C "$worktree" symbolic-ref --quiet HEAD 2>/dev/null)"; then
    branch="${branch#refs/heads/}"
    on_branch=yes
  else
    branch="(detached)"
    on_branch=no
    # A rebase or a bisect detaches HEAD while the branch still exists, and
    # HEAD may then sit on a commit the base contains. The operation's own
    # files name the branch.
    for op_file in rebase-merge/head-name rebase-apply/head-name BISECT_START; do
      [ -n "$git_dir" ] && [ -f "$git_dir/$op_file" ] || continue
      op_branch=""
      IFS= read -r op_branch <"$git_dir/$op_file" || true
      # A rebase records the full ref. A bisect records the short name.
      case "$op_file" in rebase-*) op_branch="${op_branch#refs/heads/}" ;; esac
      if [ -n "$op_branch" ] &&
        git -C "$worktree" show-ref --verify --quiet "refs/heads/$op_branch"; then
        branch="$op_branch"
        on_branch=yes
      fi
      break
    done
  fi

  # A branch may track a remote branch of another name, and the pull request
  # is then listed under that name. Leave the name out when the tracked
  # branch is the base itself: it is where the branch started, not its head.
  upstream_name=""
  if [ "$on_branch" = yes ]; then
    up_ref=""
    up_remote=""
    up_name=""
    # remotename is the remote, or "." when the upstream is a local branch.
    # remoteref is the branch's name on that remote, whatever the remote is
    # called here and wherever its branches are fetched to.
    read -r up_ref up_remote up_name < <(git -C "$worktree" for-each-ref \
      --format='%(upstream) %(upstream:remotename) %(upstream:remoteref)' \
      "refs/heads/$branch" 2>/dev/null) || true
    up_name="${up_name#refs/heads/}"
    if [ -n "$up_name" ] && [ -n "$up_remote" ] && [ "$up_remote" != . ] &&
      [ "$up_name" != "$branch" ] && [ "$up_ref" != "$base_ref" ]; then
      upstream_name="$up_name"
    fi
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
      if [ "$on_branch" = yes ]; then
        # The "" makes awk compare text. Left alone, it compares two names
        # that look like numbers as numbers, and 10 equals 1e1 and 010.
        awk -F '\t' -v b="$branch" -v u="$upstream_name" \
          '($1 "") == (b "") || ((u "") != "" && ($1 "") == (u ""))' "$prs_open" "$prs"
      elif [ -n "$head_commit" ]; then
        awk -F '\t' -v h="$head_commit" '($4 "") == (h "")' "$prs_open"
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
    elif [ "$pr_capped" = yes ] && [ "$on_branch" = yes ]; then
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
  # when it is 0, so its status is not read. In some locales [a-z] also
  # matches upper-case letters, hence LC_ALL=C.
  hidden="$(git -C "$worktree" ls-files -v 2>/dev/null | LC_ALL=C grep -c '^[a-zS]' || true)"
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

  # An operation in progress means someone is working there.
  if [ "$suggest" = candidate ] && [ "$busy" = yes ]; then
    suggest=review
  fi

  # Removing a worktree discards its untracked files, so someone looks first.
  if [ "$suggest" = candidate ] && [ "$untracked" != 0 ]; then
    suggest=review
  fi

  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$size" "$age" "$(show_path "$branch")" "$merged" "$pr" "$unpushed" \
    "$tracked" "$untracked" "$suggest" "$shown"
done | sort -t "$(printf '\t')" -k1,1 -rh
