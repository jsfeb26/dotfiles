# wtpr: Create a worktree for reviewing a PR branch
# Usage: wtpr <remote-branch-name>
#
# Fetches branch from origin, then calls wtree -r to create worktree,
# copy .env, install deps, and start dev server on port 3001.
wtpr() {
  local branch="$1"
  [[ -z "$branch" ]] && { echo "Usage: wtpr <branch-name>"; return 1; }

  # Fetch and create local tracking branch
  echo "Fetching branch '${branch}' from origin..."
  git fetch origin "${branch}" || { echo "Error: Failed to fetch branch"; return 1; }
  git branch "${branch}" "origin/${branch}" 2>/dev/null

  # Let wtree handle the rest
  wtree -r "${branch}"
}
