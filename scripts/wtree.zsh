# wtree: Create a new worktree for each given branch.
# Usage: wtree [-s|--setup] [-r|--run] [--pm npm|pnpm] branch1 branch2 ...
#
# Flags:
#   -s, --setup    Copy .env from main repo and install dependencies
#   -r, --run      Implies --setup, plus starts dev server on port 3001 (single branch only)
#   --pm <manager> Package manager to use (npm or pnpm, default: npm)
#
# Creates worktrees as siblings to the repo: <repoName>-<branch>
# Opens Cursor automatically after creating the worktree.
wtree() {
  # Flags
  local setup=false
  local run_app=false
  local package_manager="npm"
  local branches=()

  # Parse command-line arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -s|--setup)
        setup=true
        shift
        ;;
      -r|--run)
        run_app=true
        setup=true
        shift
        ;;
      --pm)
        package_manager="$2"
        shift 2
        ;;
      *)
        branches+=("$1")
        shift
        ;;
    esac
  done

  # Ensure at least one branch name is provided.
  if [[ ${#branches[@]} -eq 0 ]]; then
    echo "Usage: wtree [-s|--setup] [-r|--run] [--pm npm|pnpm] branch1 branch2 ..."
    return 1
  fi

  # -r/--run only works with a single branch
  if $run_app && [[ ${#branches[@]} -gt 1 ]]; then
    echo "Error: --run flag only works with a single branch."
    return 1
  fi

  # Determine the current branch; exit if not in a git repository.
  local current_branch
  current_branch=$(git rev-parse --abbrev-ref HEAD) || {
    echo "Error: Not a git repository."
    return 1
  }

  # Determine repository root and name.
  local repo_root repo_name
  repo_root=$(git rev-parse --show-toplevel) || {
    echo "Error: Cannot determine repository root."
    return 1
  }
  repo_name=$(basename "$repo_root")

  # TODO: Uncomment if you want a fixed parent directory for worktrees
  # # Set fixed parent directory for worktrees.
  # local worktree_parent="$HOME/dev"
  # # Ensure the worktree parent directory exists.
  # if [[ ! -d "$worktree_parent" ]]; then
  #   if ! mkdir -p "$worktree_parent"; then
  #     echo "Error: Failed to create worktree parent directory: $worktree_parent"
  #     return 1
  #   fi
  # fi

  # Set parent directory as the parent of the repo root. So the worktrees are in
  # the same directory and sibling to the repo.
  local repo_root repo_name
  repo_root=$(git rev-parse --show-toplevel) || {
    echo "Error: Cannot determine repository root."
    return 1
  }
  repo_name=$(basename "$repo_root")
  local worktree_parent=$(dirname "$repo_root")


  # Loop over each branch provided as argument.
  for branch in "${branches[@]}"; do
    # Define the target path using a naming convention: <repoName>-<branch>
    local target_path="$worktree_parent/${repo_name}-${branch}"
    
    echo "Processing branch: ${branch}"

    # Check if a worktree already exists at the target path.
    if git worktree list | grep -q "^${target_path}[[:space:]]"; then
      echo "Error: Worktree already exists at ${target_path}. Skipping branch '${branch}'."
      continue
    fi

    # If the branch does not exist, create it from origin/main.
    if ! git show-ref --verify --quiet "refs/heads/${branch}"; then
      echo "Branch '${branch}' does not exist. Creating it from 'origin/main'..."
      git fetch origin main --quiet
      if ! git branch "${branch}" origin/main; then
        echo "Error: Failed to create branch '${branch}'. Skipping."
        continue
      fi
    fi

    # Create the new worktree for the branch.
    echo "Creating worktree for branch '${branch}' at ${target_path}..."
    if ! git worktree add "$target_path" "${branch}"; then
      echo "Error: Failed to create worktree for branch '${branch}'. Skipping."
      continue
    fi

    # Open Cursor immediately (before install so you can start looking at code)
    if type cursor >/dev/null 2>&1; then
      cursor "$target_path"
    else
      echo "Worktree created at: ${target_path}"
    fi

    # Handle setup and run flags
    if $setup; then
      cd "$target_path" || return 1

      # Copy .env from main repo
      if [[ -f "$repo_root/.env" ]]; then
        echo "Copying .env from main repo..."
        cp "$repo_root/.env" "$target_path/.env"
      fi

      # Install dependencies
      echo "Installing dependencies using ${package_manager}..."
      $package_manager install

      # Start dev server if run flag is set
      if $run_app; then
        npm start -- --port 3001
      fi
    fi

    echo "Worktree for branch '${branch}' created successfully."
    echo "-----------------------------------------------------"
  done
}