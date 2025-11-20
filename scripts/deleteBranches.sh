#!/bin/bash

# If there is a permission error, run this command:
# chmod +x scripts/deleteOldBranches.sh

# Validate wildcard pattern
validate_pattern() {
  local pattern="$1"
  
  # Count asterisks in the pattern
  asterisk_count=$(echo "$pattern" | tr -cd '*' | wc -c)
  
  # If no asterisks, it's a valid exact match pattern
  if [ $asterisk_count -eq 0 ]; then
    return 0
  fi
  
  # If more than 2 asterisks, invalid
  if [ $asterisk_count -gt 2 ]; then
    return 1
  fi
  
  # Check for valid wildcard positions
  first_char="${pattern:0:1}"
  last_char="${pattern: -1}"
  
  # Single asterisk cases
  if [ $asterisk_count -eq 1 ]; then
    if [ "$first_char" = "*" ] || [ "$last_char" = "*" ]; then
      return 0
    else
      return 1  # Asterisk in middle is invalid
    fi
  fi
  
  # Double asterisk case - must be at beginning and end
  if [ $asterisk_count -eq 2 ]; then
    if [ "$first_char" = "*" ] && [ "$last_char" = "*" ]; then
      return 0
    else
      return 1  # Invalid placement
    fi
  fi
  
  return 1
}

# Match branch against wildcard pattern
match_pattern() {
  local branch="$1"
  local pattern="$2"
  
  # Exact match (no wildcards)
  if [[ "$pattern" != *"*"* ]]; then
    [ "$branch" = "$pattern" ]
    return $?
  fi
  
  # Leading wildcard only (*suffix)
  if [[ "$pattern" =~ ^\*[^*]+$ ]]; then
    suffix="${pattern#\*}"
    [[ "$branch" == *"$suffix" ]]
    return $?
  fi
  
  # Trailing wildcard only (prefix*)
  if [[ "$pattern" =~ ^[^*]+\*$ ]]; then
    prefix="${pattern%\*}"
    [[ "$branch" == "$prefix"* ]]
    return $?
  fi
  
  # Both leading and trailing wildcards (*middle*)
  if [[ "$pattern" =~ ^\*[^*]+\*$ ]]; then
    middle="${pattern#\*}"
    middle="${middle%\*}"
    [[ "$branch" == *"$middle"* ]]
    return $?
  fi
  
  return 1
}

# variables from command line arguments
specific_mode=false
exclude_mode=false
old_mode=false
verbose_mode=false
target_patterns=()
exclude_patterns=()
current_collection_mode="none"

# 
total_branches=0

# Step 1: Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
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
      # -o does not take arguments, so we don't change collection mode
      # forcing users to put patterns immediately after -s or -e
      current_collection_mode="none" 
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [OPTIONS] [patterns...]"
      echo ""
      echo "OPTIONS:"
      echo "  -s, --specific    Delete branches matching specified patterns"
      echo "  -e, --exclude     Exclude branches matching specified patterns"
      echo "  -o, --old         Only delete branches older than 1 month"
      echo "  -v, --verbose     Show detailed matching reasons"
      echo "  -h, --help        Show this help message"
      echo ""
      echo "MODES:"
      echo "  No flags          Delete ALL branches except main/master"
      echo "  -o                Delete branches older than 1 month (except main/master)"
      echo "  -s pattern1 ...   Delete branches matching patterns (any age)"
      echo "  -e pattern1 ...   Exclude branches matching patterns"
      echo "  -s -o pattern1 ... Delete branches matching patterns AND older than 1 month"
      echo ""
      echo "Pattern examples:"
      echo "  \"AMB*\"      - matches branches starting with 'AMB'"
      echo "  \"*AMB\"      - matches branches ending with 'AMB'"
      echo "  \"*AMB*\"     - matches branches containing 'AMB'"
      echo "  \"AMB\"       - matches branch named exactly 'AMB'"
      echo ""
      echo "Examples:"
      echo "  $0                      # Delete all branches except main/master"
      echo "  $0 -o                   # Delete old branches except main/master"
      echo "  $0 -s \"AMB*\"          # Delete branches starting with AMB"
      echo "  $0 -e \"important*\"    # Delete all except main/master and important*"
      echo "  $0 -s \"AMB*\" -o       # Delete old branches starting with AMB"
      exit 0
      ;;
    -*)
      echo "Unknown option: $1"
      echo "Use -h or --help for usage information"
      exit 1
      ;;
    *)
      # This is a pattern argument
      if [ "$current_collection_mode" = "specific" ]; then
          target_patterns+=("$1")
          shift
      elif [ "$current_collection_mode" = "exclude" ]; then
          exclude_patterns+=("$1")
          shift
      else
          echo "Error: Pattern '$1' provided but no -s or -e flag is currently active."
          echo "Put patterns immediately after the -s or -e flag."
          echo "Use -h for help"
          exit 1
      fi
      ;;
  esac
done


echo "Analyzing branches..."

# Calculate month ago timestamp if needed
if [ "$old_mode" = true ]; then
  month_ago=$(date -j -v-1m +%s)  # macOS way to get date from 1 month ago
fi

# Validate all patterns first (target and exclude)
invalid_patterns=()

# Check target patterns
for pattern in "${target_patterns[@]}"; do
  if ! validate_pattern "$pattern"; then
    invalid_patterns+=("$pattern")
  fi
done

# Check exclude patterns
for pattern in "${exclude_patterns[@]}"; do
  if ! validate_pattern "$pattern"; then
    invalid_patterns+=("$pattern")
  fi
done

# If any patterns are invalid, show error and exit
if [ ${#invalid_patterns[@]} -gt 0 ]; then
  echo "Error: Invalid wildcard patterns detected!"
  echo "Wildcards (*) can only be at the beginning and/or end of patterns."
  echo "Invalid patterns:"
  for invalid in "${invalid_patterns[@]}"; do
    echo "  $invalid"
  done
  echo ""
  echo "Valid examples:"
  echo "  AMB*     - matches branches starting with 'AMB'"
  echo "  *AMB     - matches branches ending with 'AMB'"
  echo "  *AMB*    - matches branches containing 'AMB'"
  echo "  AMB      - matches branch named exactly 'AMB'"
  exit 1
fi

# ---------------------------------------------------------
# PIPELINE STEP 1, 2, 3: Build list of branches to delete
# ---------------------------------------------------------
branches_to_delete=()
branches_to_delete_info=() # Store display info

while IFS=' ' read -r branch date; do
  ((total_branches++))

  # Always protect main and master
  if [ "$branch" = "main" ] || [ "$branch" = "master" ]; then
    continue
  fi

  # STEP 1: SELECTION
  # If -s is set, branch must match one of the target patterns
  # If -s is NOT set, all branches are candidates (except main/master)
  is_candidate=false
  
  if [ "$specific_mode" = true ]; then
    for pattern in "${target_patterns[@]}"; do
      if match_pattern "$branch" "$pattern"; then
        is_candidate=true
        selection_reason="(matches: $pattern)"
        break
      fi
    done
  else
    is_candidate=true
    selection_reason=""
  fi

  if [ "$is_candidate" = false ]; then
    continue
  fi

  # STEP 2: EXCLUSION
  # If -e is set, remove branch if it matches any exclude pattern
  should_exclude=false
  if [ "$exclude_mode" = true ]; then
    for pattern in "${exclude_patterns[@]}"; do
      if match_pattern "$branch" "$pattern"; then
        should_exclude=true
        break
      fi
    done
  fi

  if [ "$should_exclude" = true ]; then
    continue
  fi

  # STEP 3: AGE FILTER
  # If -o is set, remove branch if it is not old enough
  if [ "$old_mode" = true ]; then
    if [ $date -ge $month_ago ]; then
      # Branch is too new, skip it
      continue
    fi
  fi

  # If we got here, the branch is selected for deletion
  display_date=$(date -j -r $date '+%Y-%m-%d')
  
  branches_to_delete+=("$branch")
  
  # Format info string
  info_str="Will delete: $branch"
  details=""
  
  if [ "$verbose_mode" = true ] && [ -n "$selection_reason" ]; then
    details="$selection_reason"
  fi
  
  if [ "$old_mode" = true ]; then
     if [ -n "$details" ]; then details="$details, "; fi
     details="${details}age: $display_date"
  else
     if [ -n "$details" ]; then details="$details, "; fi
     details="${details}last updated: $display_date"
  fi
  
  if [ -n "$details" ]; then
    info_str="$info_str ($details)"
  fi
  
  branches_to_delete_info+=("$info_str")

done < <(git branch --format="%(refname:short) %(committerdate:unix)")

# ---------------------------------------------------------
# PIPELINE STEP 4: User Confirmation
# ---------------------------------------------------------

# Display what will be deleted
for info in "${branches_to_delete_info[@]}"; do
  echo "$info"
done

echo -e "\nFound ${#branches_to_delete[@]} out of $total_branches branches to delete."
read -p "Do you want to proceed? (y/n) " -n 1 -r
echo

# ---------------------------------------------------------
# PIPELINE STEP 5: Deletion
# ---------------------------------------------------------

if [[ $REPLY =~ ^[Yy]$ ]]; then
  for branch in "${branches_to_delete[@]}"; do
     git branch -D "$branch"
  done
fi
