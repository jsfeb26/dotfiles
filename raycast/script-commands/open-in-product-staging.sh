#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open In Product Staging
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🌐
# @raycast.packageName Ambient Scripts

# Documentation:
# @raycast.description Opens the current localhost page in Product Staging
# @raycast.author jsfeb26
# @raycast.authorURL https://raycast.com/jsfeb26

# Check if Google Chrome is the frontmost app
front_app=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true')
if [ "$front_app" != "Google Chrome" ]; then
  echo "Google Chrome is not active."
  exit 1
fi

# Get the active tab's URL
chrome_url=$(osascript <<EOF
tell application "Google Chrome"
    set currentURL to URL of active tab of front window
end tell
return currentURL
EOF
)

# Only proceed if URL starts with localhost:3000
if [[ "$chrome_url" =~ ^http://localhost:3000(/.*)?$ ]]; then
  path="${chrome_url#http://localhost:3000}"
  staging_url="https://product-staging.ambient.ai$path"

  # Open in new Chrome tab
  osascript <<EOF
tell application "Google Chrome"
    tell front window
        make new tab with properties {URL:"$staging_url"}
    end tell
end tell
EOF
else
  echo "Not on localhost:3000 — skipping."
  exit 0
fi

