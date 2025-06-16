#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Toggle Localhost ↔ Product Staging - Raycast Script
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🌐
# @raycast.packageName Ambient Scripts

# Documentation:
# @raycast.description Toggles between localhost:3000 and product-staging.ambient.ai
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

# Check if URL is localhost:3000 and convert to staging
if [[ "$chrome_url" =~ ^http://localhost:3000(/.*)?$ ]]; then
  path="${chrome_url#http://localhost:3000}"
  new_url="https://product-staging.ambient.ai$path"
  echo "Opening staging: $new_url"
  
# Check if URL is product-staging and convert to localhost
elif [[ "$chrome_url" =~ ^https://product-staging\.ambient\.ai(/.*)?$ ]]; then
  path="${chrome_url#https://product-staging.ambient.ai}"
  new_url="http://localhost:3000$path"
  echo "Opening localhost: $new_url"
  
else
  echo "Not on localhost:3000 or product-staging.ambient.ai — skipping."
  exit 0
fi

# Open in new Chrome tab
osascript <<EOF
tell application "Google Chrome"
    tell front window
        make new tab with properties {URL:"$new_url"}
    end tell
end tell
EOF

