#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Jira Create Branch - Raycast Script
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🪄
# @raycast.packageName Ambient Scripts

# Documentation:
# @raycast.description Create a new git branch from the Jira key in the current Chrome tab.
# @raycast.author jsfeb26
# @raycast.authorURL https://raycast.com/jsfeb26

chrome_url=$(osascript <<EOF
tell application "Google Chrome"
    set currentURL to URL of active tab of front window
end tell
return currentURL
EOF
)

if [[ "$chrome_url" =~ ambient-ai\.atlassian\.net/browse/([A-Z]+-[0-9]+) ]]; then
  jira_key="${BASH_REMATCH[1]}"
  echo -n "$jira_key" | pbcopy
else
  osascript -e "display notification \"Not a Jira issue tab.\" with title \"Create Branch from Jira\""
  exit 1
fi

cd ~/dev/ambient/product || {
  osascript -e "display notification \"Failed to cd to the product directory\" with title \"Create Branch from Jira\""
  exit 1
}

git fetch origin main

output=$(git checkout -b "$jira_key" origin/main 2>&1)
if echo "$output" | grep -q "already exists"; then
  output2=$(git checkout "$jira_key" 2>&1)
  output="$output\n$output2"
fi

notify_text=$(echo "$output" | head -c 200 | tr -d '\n')
echo -e "$output"
osascript -e "display notification \"$notify_text\" with title \"Create Branch from Jira\""
