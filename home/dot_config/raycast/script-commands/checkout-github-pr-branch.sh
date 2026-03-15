#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title GitHub Checkout PR Branch - Raycast Script
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🔀
# @raycast.packageName Ambient Scripts

# Documentation:
# @raycast.description Extract branch name from the current GitHub PR, copy it to the clipboard, and check it out in the product repo.
# @raycast.author jsfeb26
# @raycast.authorURL https://raycast.com/jsfeb26

chrome_url=$(osascript <<EOF
tell application "Google Chrome"
    set currentURL to URL of active tab of front window
    return currentURL
end tell
EOF
)

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

if [[ "$branch_name" == *"Executing JavaScript through AppleScript is turned off"* ]]; then
    echo "JavaScript execution is disabled in Chrome"
    osascript -e "display notification \"Enable JavaScript in Chrome: View > Developer > Allow JavaScript from Apple Events\" with title \"JavaScript Disabled\""
    exit 1
fi

if [[ "$chrome_url" =~ github\.com/.+/pull/[0-9]+ ]]; then
    if [[ "$branch_name" != "NOT_FOUND" ]] && [[ -n "$branch_name" ]]; then
        echo -n "$branch_name" | pbcopy
        echo "Found branch: $branch_name"
    else
        osascript -e "display notification \"Couldn't extract branch name from the PR page.\" with title \"Checkout GitHub PR Branch\""
        exit 1
    fi
else
    osascript -e "display notification \"Not a GitHub PR tab.\" with title \"Checkout GitHub PR Branch\""
    exit 1
fi

cd ~/dev/ambient/product || {
  osascript -e "display notification \"Failed to cd to the product directory\" with title \"Checkout GitHub PR Branch\""
  exit 1
}

current_branch=$(git branch --show-current)
if [[ "$current_branch" == "$branch_name" ]]; then
    osascript -e "display notification \"Already on: $branch_name\" with title \"Checkout GitHub PR Branch\""
    exit 0
fi

if [[ -n $(git status --porcelain) ]]; then
    git add . && git commit -m "wip" --no-verify > /dev/null 2>&1
    sleep 0.5
fi

git fetch origin "$branch_name" > /dev/null 2>&1
git checkout "$branch_name" > /dev/null 2>&1

osascript -e "display notification \"Switched to: $branch_name\" with title \"Checkout GitHub PR Branch\""
