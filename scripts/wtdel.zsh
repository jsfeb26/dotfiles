# wtdel: Delete worktrees
# Usage: wtdel [branch]     Delete specific worktree (or current if no arg)
#        wtdel -a|--all     Delete all worktrees
#
# If no argument is provided, deletes the current worktree you're in (with confirmation).
# Uses gum for interactive prompts.
# Automatically CDs back to the main repo after deletion.
#
# Branch names containing slashes are supported: wtree flattens them to dashes
# in the directory name, so the branch cannot be recovered from the path.
# The checked-out branch is read from git instead.

# _wt_branch_at: print the branch checked out in the worktree at $1.
# Prints nothing when the worktree is in a detached HEAD state.
_wt_branch_at() {
  git -C "$1" symbolic-ref --quiet --short HEAD 2>/dev/null
}

wtdel() {
  local delete_all=false
  local branch=""

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -a|--all)
        delete_all=true
        shift
        ;;
      *)
        branch="$1"
        shift
        ;;
    esac
  done

  # Get main repo info
  local git_common_dir repo_root repo_name worktree_parent
  git_common_dir=$(git rev-parse --git-common-dir 2>/dev/null) || {
    echo "Error: Not in a git repository."
    return 1
  }

  # The main repo root is the parent of .git (or the git-common-dir for worktrees)
  if [[ "$git_common_dir" == ".git" ]]; then
    repo_root=$(git rev-parse --show-toplevel)
  else
    # We're in a worktree; common dir is like /path/to/main/.git
    repo_root=$(dirname "$git_common_dir")
  fi
  repo_name=$(basename "$repo_root")
  worktree_parent=$(dirname "$repo_root")

  # Delete all worktrees
  if $delete_all; then
    echo "Deleting all worktrees..."
    local worktrees=()
    while IFS= read -r line; do
      local wt_path=$(echo "$line" | awk '{print $1}')
      # Only consider worktrees matching our naming convention (not the main repo)
      if [[ "$wt_path" == "$worktree_parent/${repo_name}-"* ]]; then
        worktrees+=("$wt_path")
      fi
    done < <(git -C "$repo_root" worktree list)

    if [[ ${#worktrees[@]} -eq 0 ]]; then
      echo "No worktrees found to delete."
      return 0
    fi

    # Build list of worktree names for selection
    local wt_names=()
    for wt in "${worktrees[@]}"; do
      wt_names+=("$(basename "$wt")")
    done

    # Multi-select which worktrees to delete
    echo "Select worktrees to delete:"
    local selected
    selected=$(printf '%s\n' "${wt_names[@]}" | gum choose --no-limit --header "Space to select, Enter to confirm")
    
    if [[ -z "$selected" ]]; then
      echo "Cancelled."
      return 0
    fi

    # Ask about branch deletion
    local delete_branches
    delete_branches=$(gum choose "Delete worktrees only" "Delete worktrees + branches")

    # CD to main repo first
    cd "$repo_root" || return 1

    # Delete selected worktrees
    while IFS= read -r wt_name; do
      [[ -z "$wt_name" ]] && continue
      local wt_path="$worktree_parent/$wt_name"
      # Read the branch from git; the path can't be reversed once slashes are flattened
      local wt_branch=$(_wt_branch_at "$wt_path")

      echo "Removing worktree: ${wt_name}..."
      git worktree remove "$wt_path" --force

      # Delete the branch if requested (but not main/master)
      if [[ "$delete_branches" == "Delete worktrees + branches" ]]; then
        if [[ -n "$wt_branch" && "$wt_branch" != "main" && "$wt_branch" != "master" ]]; then
          git branch -D "$wt_branch" 2>/dev/null && echo "Deleted branch: ${wt_branch}"
        fi
      fi
    done <<< "$selected"

    echo "Done."
    return 0
  fi

  # Delete specific or current worktree
  local target_path=""
  local target_branch=""

  if [[ -n "$branch" ]]; then
    # Specific branch provided - flatten slashes the same way wtree does.
    # Passing the flattened directory name works too, since flattening is idempotent.
    target_path="$worktree_parent/${repo_name}-${branch//\//-}"
  else
    # No branch provided - try to delete current worktree
    local current_root
    current_root=$(git rev-parse --show-toplevel 2>/dev/null)

    if [[ "$current_root" == "$repo_root" ]]; then
      echo "Error: You're in the main repository, not a worktree."
      echo "Usage: wtdel <branch-name> or wtdel --all"
      return 1
    fi

    # Check if current worktree matches our naming pattern
    if [[ "$current_root" != "$worktree_parent/${repo_name}-"* ]]; then
      echo "Error: Current directory doesn't appear to be a worktree."
      return 1
    fi

    target_path="$current_root"
  fi

  # Verify worktree exists
  if ! git -C "$repo_root" worktree list | grep -q "^${target_path}[[:space:]]"; then
    echo "Error: No worktree found at ${target_path}"
    return 1
  fi

  # Read the checked-out branch from git rather than the directory name
  target_branch=$(_wt_branch_at "$target_path")
  if [[ -z "$target_branch" ]]; then
    target_branch="$branch"
  fi

  # Confirm if deleting current worktree (no explicit branch provided)
  local delete_branch_choice="Delete worktrees only"
  if [[ -z "$branch" ]]; then
    echo "Worktree: $(basename "$target_path")"
    echo "Branch: ${target_branch}"
    echo ""
    
    delete_branch_choice=$(gum choose "Delete worktree only" "Delete worktree + branch" "Cancel")
    
    if [[ "$delete_branch_choice" == "Cancel" ]]; then
      echo "Cancelled."
      return 0
    fi
  else
    # Explicit branch provided - ask about branch deletion
    delete_branch_choice=$(gum choose "Delete worktree only" "Delete worktree + branch")
  fi

  # CD to main repo before deleting
  echo "Switching to main repo..."
  cd "$repo_root" || return 1

  # Remove worktree
  echo "Removing worktree: $(basename "$target_path")..."
  if git worktree remove "$target_path" --force; then
    echo "Worktree removed."
  else
    echo "Error: Failed to remove worktree."
    return 1
  fi

  # Delete the branch if requested (but not main/master)
  if [[ "$delete_branch_choice" == "Delete worktree + branch" ]]; then
    if [[ -n "$target_branch" && "$target_branch" != "main" && "$target_branch" != "master" ]]; then
      git branch -D "$target_branch" 2>/dev/null && echo "Deleted branch: ${target_branch}"
    fi
  fi

  echo "Done. You're now in: $(pwd)"
}
