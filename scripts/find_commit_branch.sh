#!/bin/bash
# Find which remote branch(es) contain a given commit
# Usage: find_commit_branch.sh <commit-hash>
# Supports full or short (6-7 char) hashes

set -e

if [[ -z "$1" ]]; then
  echo "Usage: $0 <commit-hash>"
  exit 1
fi

commit="$1"

# Colors
bold='\033[1m'
green='\033[0;32m'
cyan='\033[0;36m'
dim='\033[2m'
reset='\033[0m'

# Try to resolve commit locally first
full_hash=$(git rev-parse --verify "$commit" 2>/dev/null) || full_hash=""

# Try to find branches locally first (skip fetch if we can)
if [[ -n "$full_hash" ]]; then
  branches=$(git branch -r --contains "$full_hash" 2>/dev/null)
fi

# If not found locally, fetch and retry
if [[ -z "$full_hash" || -z "$branches" ]]; then
  echo -e "${dim}Fetching latest refs...${reset}"
  
  remotes=$(git remote)
  remote_count=$(echo "$remotes" | wc -l | tr -d ' ')

  if [[ "$remote_count" -eq 1 ]]; then
    git fetch "$remotes" --prune --quiet
  else
    git fetch --all --prune --quiet
  fi

  # Try resolving again after fetch
  if [[ -z "$full_hash" ]]; then
    full_hash=$(git rev-parse --verify "$commit" 2>/dev/null) || {
      echo "Error: Commit '$commit' not found"
      exit 1
    }
  fi

  branches=$(git branch -r --contains "$full_hash" 2>/dev/null)
fi

if [[ -z "$branches" ]]; then
  echo "No remote branches contain commit $commit ($full_hash)"
  exit 0
fi

echo -e "${cyan}🔍 Commit:${reset} ${bold}$full_hash${reset}"
echo -e "${cyan}📦 Branches:${reset}"

echo ""
echo -e "--------------------------------"
echo ""

echo "$branches" | while read -r branch; do
  echo -e "🔀 ${green}${bold}$branch${reset}"
done
