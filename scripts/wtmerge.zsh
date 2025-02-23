# wtmerge: Merge changes from a specified worktree branch into main,
# then clean up all worktrees and delete their branches.
#
# Usage: wtmerge <branch-to-keep>
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
  # Ensure exactly one argument is passed: the branch to merge.
  if [ $# -ne 1 ]; then
    echo "Usage: wtmerge <branch-to-keep>"
    return 1
  fi

  local branch_to_keep="$1"

  # Determine the repository root and its name.
  local repo_root repo_name
  repo_root=$(git rev-parse --show-toplevel) || {
    echo "Error: Not a git repository."
    return 1
  }
  repo_name=$(basename "$repo_root")

  # Fixed parent directory where worktrees are located.
  local worktree_parent="$HOME/dev"

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

  # Check that the target branch worktree exists.
  local target_worktree=""
  for wt in "${worktrees[@]}"; do
    if [[ "$wt" == "$worktree_parent/${repo_name}-${branch_to_keep}" ]]; then
      target_worktree="$wt"
      break
    fi
  done

  if [[ -z "$target_worktree" ]]; then
    echo "Error: No active worktree found for branch '${branch_to_keep}' under ${worktree_parent}."
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

  # Step 2: Switch to the main worktree (assumed to be the current directory) and check out main.
  echo "Switching to 'main' branch in the main worktree..."
  if ! git checkout main; then
    echo "Error: Failed to switch to 'main' branch."
    return 1
  fi

  # Step 3: Merge the target branch into main.
  echo "Merging branch '${branch_to_keep}' into 'main'..."
  if ! git merge "${branch_to_keep}" -m "feat: merge changes from '${branch_to_keep}'"; then
    echo "Error: Merge failed. Please resolve conflicts and try again."
    return 1
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

  echo "Merge complete: Branch '${branch_to_keep}' merged into 'main', and all worktrees cleaned up."
}