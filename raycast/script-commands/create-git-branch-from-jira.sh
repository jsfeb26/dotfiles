#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Jira Create Branch - Raycast Script
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🪄
# @raycast.packageName Ambient Scripts

# Documentation:
# @raycast.description Creates a new git branch from the Jira key in the current Chrome tab, based on origin/main, in the product directory. If the branch exists, switches to it. Shows a notification with the result and focuses Ghostty on the first tab.
# @raycast.author jsfeb26
# @raycast.authorURL https://raycast.com/jsfeb26

# Get current Chrome tab URL
chrome_url=$(osascript <<EOF
tell application "Google Chrome"
    set currentURL to URL of active tab of front window
end tell
return currentURL
EOF
)

# Check if it's a Jira issue URL and extract the key
if [[ "$chrome_url" =~ ambient-ai\.atlassian\.net/browse/([A-Z]+-[0-9]+) ]]; then
  jira_key="${BASH_REMATCH[1]}"
  # Copy the jira_key to the clipboard
  echo -n "$jira_key" | pbcopy
else
  osascript -e "display notification \"Not a Jira issue tab.\" with title \"Create Branch from Jira\""
  echo "Not a Jira issue tab."
  exit 1
fi

cd ~/dev/ambient/product || { osascript -e "display notification \"Failed to cd to product directory\" with title \"Create Branch from Jira\""; echo "Failed to cd to product directory"; exit 1; }

# Fetch latest main before creating the branch
git fetch origin main

# Run the git command and capture output
output=$(git checkout -b "$jira_key" origin/main 2>&1)
if echo "$output" | grep -q "already exists"; then
  output2=$(git checkout "$jira_key" 2>&1)
  output="$output\n$output2"
fi

# Show notification (truncate to 200 chars for notification)
notify_text=$(echo "$output" | head -c 200 | tr -d '\n')

echo -e "$output"

osascript -e "display notification \"$notify_text\" with title \"Create Branch from Jira\""

# Focus Ghostty, switch to the first tab, and press Enter
osascript <<EOF
tell application "Ghostty" to activate
delay 0.2
tell application "System Events"
    key code 18 using {command down} -- Cmd+1 to go to first tab
    delay 0.1
    key code 36 -- Enter
end tell
EOF