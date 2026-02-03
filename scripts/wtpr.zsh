# wtpr: Create a worktree for reviewing a PR branch
# Usage: wtpr [-n|--no-setup] <remote-branch-name>
#
# Flags:
#   -n, --no-setup   Skip .env copy, dependency install, and dev server
#
# Fetches branch from origin, then calls wtree to create worktree.
# By default runs wtree -r (setup + dev server on port 3001).
wtpr() {
  local no_setup=false
  local branch=""

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -n|--no-setup)
        no_setup=true
        shift
        ;;
      *)
        branch="$1"
        shift
        ;;
    esac
  done

  [[ -z "$branch" ]] && { echo "Usage: wtpr [-n|--no-setup] <branch-name>"; return 1; }

  # Fetch and create local tracking branch
  echo "Fetching branch '${branch}' from origin..."
  git fetch origin "${branch}" || { echo "Error: Failed to fetch branch"; return 1; }
  git branch "${branch}" "origin/${branch}" 2>/dev/null

  # Let wtree handle the rest
  if $no_setup; then
    wtree "${branch}"
  else
    wtree -r "${branch}"
  fi
}
