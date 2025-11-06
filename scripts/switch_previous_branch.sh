#!/usr/bin/env bash
# Switch back to the previous branch using git's built-in reference
set -euo pipefail

# Get the current branch name for error messages
current_branch=$(git rev-parse --abbrev-ref HEAD)

# Check if we're in a detached HEAD state
if [[ "$current_branch" == "HEAD" ]]; then
  printf 'Jason: Cannot switch from detached HEAD state\n' >&2
  exit 1
fi

# Get the previous branch using git's @{-1} reference
# This is git's built-in way to reference the previously checked out branch
previous_branch=$(git rev-parse --abbrev-ref @{-1} 2>/dev/null || echo "")

if [[ -z "$previous_branch" ]]; then
  printf 'Jason: No previous branch found in reflog\n' >&2
  exit 1
fi

# Check if the previous branch is the same as current (shouldn't happen, but just in case)
if [[ "$previous_branch" == "$current_branch" ]]; then
  printf 'Jason: Previous branch is the same as current branch (%s)\n' "$current_branch" >&2
  exit 1
fi

printf 'Switching from %s to %s\n' "$current_branch" "$previous_branch"
git checkout "$previous_branch"
