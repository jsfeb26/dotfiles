# wtmerge: Merge changes from a specified worktree branch into main,
# then clean up all worktrees and delete their branches.
#
# Usage: wtmerge <branch-to-keep> <commit-message>
#
# This function does the following:
#   1. Verifies that the branch to merge (branch-to-keep) exists as an active worktree.
#   2. Checks for uncommitted changes in that worktree:
#        - If changes exist, it attempts to stage and commit them.
#        - It gracefully handles the situation where there are no changes.
#   3. Switches the current (main) worktree to the "main" branch.
#   4. Merges the specified branch into main, with proper error checking.
#   5. Uses "git worktree list" to retrieve all active worktrees (under ~/dev
#      and matching the naming pattern) and removes them.
#   6. Deletes each branch that was created for a worktree (skipping "main").
wtmerge() {
  # Allow zero args for cleanup-only mode
  if [ $# -eq 0 ]; then
    echo "Cleanup mode: removing all worktrees without merging..."
  elif [ $# -ne 2 ]; then
    echo "Usage: wtmerge [<branch-to-keep> <commit-message>]"
    echo "       wtmerge  (cleanup mode - no merging)"
    return 1
  fi

  # Determine the repository root and its name.
  local repo_root repo_name
  repo_root=$(git rev-parse --show-toplevel) || {
    echo "Error: Not a git repository."
    return 1
  }
  repo_name=$(basename "$repo_root")

  # TODO: Uncomment if you want a fixed parent directory for worktrees
  # Fixed parent directory where worktrees are located.
  # local worktree_parent="$HOME/dev"

  # Set parent directory as the parent of the repo root. So the worktrees are in
  # the same directory and sibling to the repo.
  local worktree_parent=$(dirname "$repo_root")


  # Retrieve all active worktrees (from git worktree list) that match our naming convention.
  local worktrees=()
  while IFS= read -r line; do
    # Extract the worktree path (first field)
    local wt_path
    wt_path=$(echo "$line" | awk '{print $1}')
    # Only consider worktrees under our fixed parent directory that match "<repo_name>-*"
    if [[ "$wt_path" == "$worktree_parent/${repo_name}-"* ]]; then
      worktrees+=("$wt_path")
    fi
  done < <(git worktree list)

  # Skip merge steps if in cleanup mode
  if [ $# -eq 2 ]; then
    local branch_to_keep="$1"
    local commit_message="$2"

    # Check target branch exists...
    local target_worktree=""
    for wt in "${worktrees[@]}"; do
      if [[ "$wt" == "$worktree_parent/${repo_name}-${branch_to_keep}" ]]; then
        target_worktree="$wt"
        break
      fi
    done

    if [[ -z "$target_worktree" ]]; then
      echo "Error: No active worktree found for branch '${branch_to_keep}'."
      return 1
    fi

    # Step 1: In the target worktree, check for uncommitted changes.
    echo "Checking for uncommitted changes in worktree for branch '${branch_to_keep}'..."
    if ! ( cd "$target_worktree" && git diff --quiet && git diff --cached --quiet ); then
      echo "Changes detected in branch '${branch_to_keep}'. Attempting auto-commit..."
      if ! ( cd "$target_worktree" &&
              git add . &&
              git commit -m "chore: auto-commit changes in '${branch_to_keep}' before merge" ); then
        echo "Error: Auto-commit failed in branch '${branch_to_keep}'. Aborting merge."
        return 1
      else
        echo "Auto-commit successful in branch '${branch_to_keep}'."
      fi
    else
      echo "No uncommitted changes found in branch '${branch_to_keep}'."
    fi

    # Step 3: Merge the target branch
    echo "Merging branch '${branch_to_keep}'..."
    if ! git merge "${branch_to_keep}" -m "${commit_message}"; then
      echo "Error: Merge failed. Please resolve conflicts and try again."
      return 1
    fi
  fi

  # Step 4: Remove all worktrees that were created via wtree().
  echo "Cleaning up worktrees and deleting temporary branches..."
  for wt in "${worktrees[@]}"; do
    # Extract branch name from worktree path.
    local wt_branch
    wt_branch=$(basename "$wt")
    wt_branch=${wt_branch#${repo_name}-}  # Remove the repo name prefix

    echo "Processing worktree for branch '${wt_branch}' at ${wt}..."
    # Remove the worktree using --force to ensure removal.
    if git worktree remove "$wt" --force; then
      echo "Worktree at ${wt} removed."
    else
      echo "Warning: Failed to remove worktree at ${wt}."
    fi

    # Do not delete the 'main' branch.
    if [[ "$wt_branch" != "main" ]]; then
      if git branch -D "$wt_branch"; then
        echo "Branch '${wt_branch}' deleted."
      else
        echo "Warning: Failed to delete branch '${wt_branch}'."
      fi
    fi
  done

  if [ $# -eq 0 ]; then
    echo "Cleanup complete: All worktrees removed."
  else
    echo "Merge complete: Branch '${branch_to_keep}' merged, and all worktrees cleaned up."
  fi
}