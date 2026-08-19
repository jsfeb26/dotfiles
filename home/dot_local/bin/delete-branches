#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: delete-branches [OPTIONS]

OPTIONS:
  -s, --specific PATTERN...  Delete branches matching the given patterns
  -e, --exclude PATTERN...   Exclude branches matching the given patterns
  -o, --old                  Delete only branches older than six months
  -v, --verbose              Show why each branch is selected
  -h, --help                 Show this help message
EOF
}

six_months_ago_epoch() {
  if date -d '6 months ago' +%s >/dev/null 2>&1; then
    date -d '6 months ago' +%s
  else
    date -v-6m +%s
  fi
}

format_epoch() {
  if date -d "@$1" '+%Y-%m-%d' >/dev/null 2>&1; then
    date -d "@$1" '+%Y-%m-%d'
  else
    date -r "$1" '+%Y-%m-%d'
  fi
}

validate_pattern() {
  local pattern="$1"
  local asterisk_count
  local first_char
  local last_char

  asterisk_count="$(printf '%s' "$pattern" | tr -cd '*' | wc -c | tr -d ' ')"
  first_char="${pattern:0:1}"
  last_char="${pattern: -1}"

  if [[ "$asterisk_count" -eq 0 ]]; then
    return 0
  fi

  if [[ "$asterisk_count" -gt 2 ]]; then
    return 1
  fi

  if [[ "$asterisk_count" -eq 1 ]]; then
    [[ "$first_char" == "*" || "$last_char" == "*" ]]
    return $?
  fi

  [[ "$first_char" == "*" && "$last_char" == "*" ]]
}

match_pattern() {
  local branch="$1"
  local pattern="$2"

  if [[ "$pattern" != *"*"* ]]; then
    [[ "$branch" == "$pattern" ]]
    return $?
  fi

  if [[ "$pattern" =~ ^\*[^*]+$ ]]; then
    [[ "$branch" == *"${pattern#\*}" ]]
    return $?
  fi

  if [[ "$pattern" =~ ^[^*]+\*$ ]]; then
    [[ "$branch" == "${pattern%\*}"* ]]
    return $?
  fi

  if [[ "$pattern" =~ ^\*[^*]+\*$ ]]; then
    local middle="${pattern#\*}"
    middle="${middle%\*}"
    [[ "$branch" == *"$middle"* ]]
    return $?
  fi

  return 1
}

specific_mode=false
exclude_mode=false
old_mode=false
verbose_mode=false
target_patterns=()
exclude_patterns=()
current_collection_mode="none"
total_branches=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -v|--verbose)
      verbose_mode=true
      shift
      ;;
    -s|--specific)
      specific_mode=true
      current_collection_mode="specific"
      shift
      ;;
    -e|--exclude)
      exclude_mode=true
      current_collection_mode="exclude"
      shift
      ;;
    -o|--old)
      old_mode=true
      current_collection_mode="none"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
    *)
      if [[ "$current_collection_mode" == "specific" ]]; then
        target_patterns+=("$1")
      elif [[ "$current_collection_mode" == "exclude" ]]; then
        exclude_patterns+=("$1")
      else
        echo "Pattern '$1' must follow -s or -e." >&2
        exit 1
      fi
      shift
      ;;
  esac
done

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "Not in a git repository." >&2
  exit 1
fi

if [[ "$old_mode" == true ]]; then
  six_months_ago="$(six_months_ago_epoch)"
fi

invalid_patterns=()
for pattern in ${target_patterns[@]+"${target_patterns[@]}"}; do
  validate_pattern "$pattern" || invalid_patterns+=("$pattern")
done
for pattern in ${exclude_patterns[@]+"${exclude_patterns[@]}"}; do
  validate_pattern "$pattern" || invalid_patterns+=("$pattern")
done

if [[ ${#invalid_patterns[@]} -gt 0 ]]; then
  echo "Invalid wildcard patterns:"
  printf '  %s\n' "${invalid_patterns[@]}"
  exit 1
fi

branches_to_delete=()
branch_details=()

while IFS=' ' read -r branch epoch; do
  total_branches=$((total_branches + 1))

  if [[ "$branch" == "main" || "$branch" == "master" ]]; then
    continue
  fi

  is_candidate=false
  selection_reason=""

  if [[ "$specific_mode" == true ]]; then
    for pattern in ${target_patterns[@]+"${target_patterns[@]}"}; do
      if match_pattern "$branch" "$pattern"; then
        is_candidate=true
        selection_reason="matches: $pattern"
        break
      fi
    done
  else
    is_candidate=true
  fi

  [[ "$is_candidate" == true ]] || continue

  should_exclude=false
  if [[ "$exclude_mode" == true ]]; then
    for pattern in ${exclude_patterns[@]+"${exclude_patterns[@]}"}; do
      if match_pattern "$branch" "$pattern"; then
        should_exclude=true
        break
      fi
    done
  fi

  [[ "$should_exclude" == false ]] || continue

  if [[ "$old_mode" == true && "$epoch" -ge "$six_months_ago" ]]; then
    continue
  fi

  display_date="$(format_epoch "$epoch")"
  branches_to_delete+=("$branch")

  details=()
  if [[ "$verbose_mode" == true && -n "$selection_reason" ]]; then
    details+=("$selection_reason")
  fi
  if [[ "$old_mode" == true ]]; then
    details+=("age: $display_date")
  else
    details+=("last updated: $display_date")
  fi

  branch_details+=("${details[*]}")
done < <(git branch --sort=committerdate --format='%(refname:short) %(committerdate:unix)')

if [[ ${#branches_to_delete[@]} -eq 0 ]]; then
  echo "No matching branches found."
  exit 0
fi

# Pad branch names so the details column lines up
max_branch_length=0
for branch in "${branches_to_delete[@]}"; do
  if [[ ${#branch} -gt $max_branch_length ]]; then
    max_branch_length=${#branch}
  fi
done

display_lines=()
for index in "${!branches_to_delete[@]}"; do
  display_lines+=("$(printf '%-*s  %s' "$max_branch_length" "${branches_to_delete[$index]}" "${branch_details[$index]}")")
done

if command -v fzf >/dev/null 2>&1; then
  # Live header: selected count updates as toggle keys are pressed
  header_command="echo \"Deleting \$FZF_SELECT_COUNT of $total_branches branches — space to toggle, enter to confirm\""

  # Pre-select every branch; space/tab deselects, enter confirms, esc cancels
  selected_lines="$(printf '%s\n' "${display_lines[@]}" | fzf --multi --sync \
    --layout=reverse \
    --height='~80%' \
    --marker='✓ ' \
    --bind "start:select-all+transform-header:$header_command" \
    --bind "space:toggle+down+transform-header:$header_command" \
    --bind "tab:toggle+down+transform-header:$header_command" \
    --bind "ctrl-a:select-all+transform-header:$header_command" \
    --bind "ctrl-d:deselect-all+transform-header:$header_command")" || true

  if [[ -z "$selected_lines" ]]; then
    echo "Cancelled."
    exit 0
  fi

  selected_branches=()
  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    selected_branches+=("${line%% *}")
  done <<< "$selected_lines"

  if command -v gum >/dev/null 2>&1; then
    if ! gum confirm "Delete ${#selected_branches[@]} branch(es)?"; then
      echo "Cancelled."
      exit 0
    fi
  else
    read -r -p "Delete ${#selected_branches[@]} branch(es)? (y/N) " reply
    if [[ ! "$reply" =~ ^[Yy]$ ]]; then
      echo "Cancelled."
      exit 0
    fi
  fi

  for branch in "${selected_branches[@]}"; do
    git branch -D "$branch"
  done
else
  printf '%s\n' "${display_lines[@]}"
  printf '\nFound %s out of %s branches to delete.\n' "${#branches_to_delete[@]}" "$total_branches"
  read -r -p "Do you want to proceed? (y/N) " reply

  if [[ "$reply" =~ ^[Yy]$ ]]; then
    for branch in "${branches_to_delete[@]}"; do
      git branch -D "$branch"
    done
  fi
fi
