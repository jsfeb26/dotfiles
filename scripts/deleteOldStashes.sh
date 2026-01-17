#!/bin/bash

# Finds all stashes that are older than three months and ask the user to confirm the deletion
# If the script has permission errors make it executable by running:
# chmod +x scripts/deleteOldStashes.sh

# Calculate the Unix timestamp for three months ago (macOS compatible)
cutoff_timestamp=$(date -j -v-3m +%s)

declare -a stashes_to_delete

# Display the cutoff date using a format macOS `date` understands for output
echo "Checking for stashes older than $(date -r $cutoff_timestamp)"

# First pass: Identify stashes to delete
# Use %ct (committer timestamp) and %gs (subject) for easier parsing with macOS date
# Use process substitution to avoid subshell issues with the array
while IFS=' ' read -r stash_ref stash_timestamp stash_message; do
    # Check if stash_timestamp is a valid number
    if [[ "$stash_timestamp" =~ ^[0-9]+$ ]]; then
        # Compare timestamps
        if [ "$stash_timestamp" -lt "$cutoff_timestamp" ]; then
            # Get human-readable date for display
            stash_date_str=$(date -r "$stash_timestamp")
            echo "$stash_ref ($stash_date_str): $stash_message"
            stashes_to_delete+=("$stash_ref")
        fi
    else
        # Handle cases where the line might not parse correctly (e.g., unexpected format)
        echo "Warning: Could not parse timestamp from line starting with '$stash_ref'. Skipping."
    fi
done < <(git stash list --format='%gd %ct %gs')

# Check if any stashes were marked for deletion
if [ ${#stashes_to_delete[@]} -eq 0 ]; then
    echo "No stashes older than three months found."
    exit 0
fi

echo ""
read -p "Do you want to delete the ${#stashes_to_delete[@]} stash(es) listed above? (y/N): " confirm

if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "Deleting stashes..."
    
    # Sort the array numerically in reverse order based on the stash index {N}
    # This ensures we delete from highest index to lowest, avoiding re-indexing issues
    sorted_stashes=($(printf "%s\n" "${stashes_to_delete[@]}" | sed 's/stash@{//; s/}//' | sort -nr | sed 's/^/stash@{/; s/$/}/'))
    
    for stash_ref in "${sorted_stashes[@]}"; do
        echo "Deleting $stash_ref"
        git stash drop "$stash_ref"
    done
    echo "Finished deleting old stashes."
else
    echo "Aborted. No stashes were deleted."
fi

