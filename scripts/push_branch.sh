#!/usr/bin/env bash
# Push current branch to origin; offer force-with-lease fallback with a clear prompt.
set -euo pipefail

branch=$(git rev-parse --abbrev-ref HEAD)
if [[ "$branch" == "HEAD" ]]; then
  printf 'Jason: Refusing to push from detached HEAD\n' >&2
  exit 1
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
