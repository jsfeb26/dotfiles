#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title GitHub Checkout PR Branch - Raycast Script
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🔀
# @raycast.packageName Ambient Scripts

# Documentation:
# @raycast.description Extracts branch name from GitHub PR page, commits WIP changes, fetches and checks out the PR branch in the product directory. Shows notification and focuses Ghostty on the first tab.
# @raycast.author jsfeb26
# @raycast.authorURL https://raycast.com/jsfeb26

# Get current Chrome tab URL
chrome_url=$(osascript <<EOF
tell application "Google Chrome"
    set currentURL to URL of active tab of front window
    return currentURL
end tell
EOF
)

        # set branchName to execute active tab of front window javascript "document.querySelectorAll('clipboard-copy.js-copy-branch')[0].value"

# Get branch name - try multiple properties
branch_name=$(osascript <<EOF
tell application "Google Chrome"
    try

        set branchName to execute active tab of front window javascript "document.querySelectorAll('clipboard-copy.js-copy-branch')[0].getAttribute('value')"
        return branchName
    on error errorMessage
        return "APPLESCRIPT_ERROR: " & errorMessage
    end try
end tell
EOF
)

# Check for JavaScript disabled error
if [[ "$branch_name" == *"Executing JavaScript through AppleScript is turned off"* ]]; then
    echo "❌ JavaScript execution is disabled in Chrome"
    echo ""
    echo "🔧 TO FIX: Enable JavaScript execution in Chrome:"
    echo "   1. Go to Chrome menu bar"
    echo "   2. View > Developer > Allow JavaScript from Apple Events"
    echo "   3. Or visit: chrome://settings/content/javascript"
    echo ""
    osascript -e "display notification \"Enable JavaScript in Chrome: View > Developer > Allow JavaScript from Apple Events\" with title \"JavaScript Disabled\""
    exit 1
fi

# Check if it's a GitHub PR URL and we found a branch name
if [[ "$chrome_url" =~ github\.com/.+/pull/[0-9]+ ]]; then
    echo "✓ Valid GitHub PR URL detected"
    if [[ "$branch_name" != "NOT_FOUND" ]] && [[ -n "$branch_name" ]]; then
        # Copy the branch_name to the clipboard
        echo -n "$branch_name" | pbcopy
        echo "✓ Found branch: $branch_name"
    else
        osascript -e "display notification \"Couldn't extract branch name from PR page.\" with title \"Checkout GitHub PR Branch\""
        echo "✗ Couldn't extract branch name from PR page."
        echo "Try manually copying the branch name to clipboard and run a simpler checkout script."
        exit 1
    fi
else
    osascript -e "display notification \"Not a GitHub PR tab.\" with title \"Checkout GitHub PR Branch\""
    echo "✗ Not a GitHub PR tab."
    echo "Current URL: $chrome_url"
    exit 1
fi

cd ~/dev/ambient/product || { osascript -e "display notification \"Failed to cd to product directory\" with title \"Checkout GitHub PR Branch\""; echo "Failed to cd to product directory"; exit 1; }

# Check if we're already on the target branch
current_branch=$(git branch --show-current)
if [[ "$current_branch" == "$branch_name" ]]; then
    echo "✓ Already on branch: $branch_name"
    osascript -e "display notification \"Already on: $branch_name\" with title \"Checkout GitHub PR Branch\""
    exit 0
fi

# Check if there are any changes to commit
if [[ -n $(git status --porcelain) ]]; then
    echo "✓ Committing existing changes..."
    git add . && git commit -m "wip" --no-verify > /dev/null 2>&1
    sleep 0.5
fi

# Fetch and checkout the PR branch
git fetch origin "$branch_name" > /dev/null 2>&1
git checkout "$branch_name" > /dev/null 2>&1

echo "✓ Successfully checked out branch: $branch_name"

osascript -e "display notification \"Switched to: $branch_name\" with title \"Checkout GitHub PR Branch\""

# Focus Ghostty, switch to the first tab, and press Enter
osascript <<EOF
tell application "Ghostty" to activate
delay 0.2
tell application "System Events"
    key code 18 using {command down} -- Cmd+1 to go to first tab
    delay 0.1
    key code 36 -- Enter
end tell
