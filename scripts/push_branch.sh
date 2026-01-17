#!/usr/bin/env bash
# Push current branch to origin; offer force-with-lease fallback with a clear prompt.
# Also checks if branch needs rebasing on the base branch before pushing.
set -euo pipefail

branch=$(git rev-parse --abbrev-ref HEAD)
if [[ "$branch" == "HEAD" ]]; then
  printf 'Jason: Refusing to push from detached HEAD\n' >&2
  exit 1
fi

# Determine the base branch (default to main, fall back to master if main doesn't exist)
base_branch="main"
if ! git rev-parse --verify "origin/$base_branch" &>/dev/null; then
  if git rev-parse --verify "origin/master" &>/dev/null; then
    base_branch="master"
  fi
fi

# Only need to check if we're rebased if we're on a different branch
if [[ "$branch" != "$base_branch" ]]; then
  # Fetch latest from origin to ensure we have up-to-date refs
  printf 'Fetching latest from origin...\n'
  git fetch origin "$base_branch" --quiet 2>/dev/null || true

  # Check if current branch is behind origin/base_branch
  behind_count=$(git rev-list --count "$branch..origin/$base_branch" 2>/dev/null || echo "0")

  if [[ "$behind_count" -gt 0 ]]; then
    printf '\n--------------------------------\n'
    printf 'Your branch is %s commit(s) behind origin/%s.\n' "$behind_count" "$base_branch"
    printf 'Do you want to rebase on origin/%s before pushing? (y/N): ' "$base_branch"
    read -r rebase_answer
    case "$rebase_answer" in
      [Yy]*)
        printf 'Rebasing on origin/%s...\n' "$base_branch"
        if ! git rebase "origin/$base_branch"; then
          printf '\nRebase failed. Resolve conflicts and run: git rebase --continue\n' >&2
          printf 'Or abort with: git rebase --abort\n' >&2
          exit 1
        fi
        printf 'Rebase successful!\n\n'
        ;;
      *)
        printf 'Continuing without rebase...\n\n'
        ;;
    esac
  fi
fi

if git push origin "$branch"; then
  exit 0
fi


printf '\n--------------------------------\n\n'
printf 'Push to origin/%s failed!' "$branch"
printf '\n'
printf 'Do you want to force push to origin/%s? (y/N): ' "$branch"

read -r answer
case "$answer" in
  [Yy]*)
    git push --force-with-lease origin "$branch"
    ;;
  *)
    printf 'Push aborted.\n'
    exit 1
    ;;
esac
