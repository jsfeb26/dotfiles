# wtree: Create a new worktree for each given branch.
# Usage: wtree [-n|--no-setup] [-r|--run] [--pm npm|pnpm] branch1 branch2 ...
#
# Flags:
#   -n, --no-setup  Skip .env copy and dependency install (setup runs by default)
#   -r, --run       Start dev server on port 3001 after setup (single branch only)
#   --pm <manager>  Package manager to use (npm or pnpm, default: pnpm)
#
# If the branch exists on origin it is checked out as-is (PR review flow).
# Otherwise a new branch is created from origin/main (or master).
# Creates worktrees as siblings to the repo: <repoName>-<branch>
# Slashes in the branch name are flattened to dashes in the directory name, so
# `wtree darshan/foo` in `product` creates `product-darshan-foo` (single level).
wtree() {
  local setup=true
  local run_app=false
  local package_manager="pnpm"
  local branches=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -n|--no-setup) setup=false; shift ;;
      -r|--run)      run_app=true; shift ;;
      --pm)          package_manager="$2"; shift 2 ;;
      *)             branches+=("$1"); shift ;;
    esac
  done

  if [[ ${#branches[@]} -eq 0 ]]; then
    echo "Usage: wtree [-n|--no-setup] [-r|--run] [--pm npm|pnpm] branch1 branch2 ..."
    return 1
  fi

  if $run_app && [[ ${#branches[@]} -gt 1 ]]; then
    echo "✗ --run only works with a single branch."
    return 1
  fi

  local repo_root repo_name
  repo_root=$(git rev-parse --show-toplevel) || { echo "✗ Not a git repository."; return 1; }
  repo_name=$(basename "$repo_root")
  local worktree_parent=$(dirname "$repo_root")

  local base_branch="main"
  if ! git rev-parse --verify "origin/${base_branch}" >/dev/null 2>&1; then
    git rev-parse --verify origin/master >/dev/null 2>&1 && base_branch="master"
  fi

  for branch in "${branches[@]}"; do
    # Flatten slashes so a branch like darshan/foo becomes <repo>-darshan-foo
    local dir_name="${repo_name}-${branch//\//-}"
    local target_path="$worktree_parent/${dir_name}"

    echo ""
    echo "🌿 Creating worktree ${dir_name} (branch ${branch})"

    if git worktree list | grep -q "^${target_path}[[:space:]]"; then
      echo "   ✗ Worktree already exists. Skipping."
      continue
    fi

    if ! git show-ref --verify --quiet "refs/heads/${branch}"; then
      if git ls-remote --exit-code --heads origin "${branch}" >/dev/null 2>&1; then
        echo "   ↳ pulling existing branch ${branch}"
        git fetch origin "${branch}" --quiet
        if ! git branch "${branch}" "origin/${branch}" >/dev/null 2>&1; then
          echo "   ✗ Failed to create tracking branch. Skipping."
          continue
        fi
      else
        echo "   ↳ creating branch ${branch} from origin/${base_branch}"
        git fetch origin "${base_branch}" --quiet
        if ! git branch "${branch}" "origin/${base_branch}" >/dev/null 2>&1; then
          echo "   ✗ Failed to create branch. Skipping."
          continue
        fi
      fi
    fi

    if ! git worktree add "$target_path" "${branch}" --quiet 2>/dev/null; then
      echo "   ✗ Failed to create worktree. Skipping."
      continue
    fi

    echo ""
    echo "➡  cd ${dir_name}"
    cd "$target_path"

    if $setup; then
      if [[ -f "$repo_root/.env" ]]; then
        echo ""
        echo "📄 copying .env from main repo"
        cp "$repo_root/.env" "$target_path/.env"
      fi

      echo ""
      echo "🛠  installing dependencies with ${package_manager}"
      $package_manager install

      if $run_app; then
        echo ""
        echo "🚀 starting dev server on port 3001"
        $package_manager start -- --port 3001
      fi
    fi

    echo ""
    echo "✅ done"
  done
  echo ""
}
