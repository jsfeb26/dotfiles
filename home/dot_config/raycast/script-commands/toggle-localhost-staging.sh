#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Toggle Localhost ↔ Product Staging - Raycast Script
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🌐
# @raycast.packageName Ambient Scripts

# Documentation:
# @raycast.description Toggle between localhost:3000 and product staging in a new Chrome tab.
# @raycast.author jsfeb26
# @raycast.authorURL https://raycast.com/jsfeb26

front_app=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true')
if [ "$front_app" != "Google Chrome" ]; then
  echo "Google Chrome is not active."
  exit 1
fi

chrome_url=$(osascript <<EOF
tell application "Google Chrome"
    set currentURL to URL of active tab of front window
end tell
return currentURL
EOF
)

if [[ "$chrome_url" =~ ^http://localhost:3000(/.*)?$ ]]; then
  path="${chrome_url#http://localhost:3000}"
  new_url="https://product.eng.ambient.ai$path"
elif [[ "$chrome_url" =~ ^http://localhost:3001(/.*)?$ ]]; then
  path="${chrome_url#http://localhost:3001}"
  new_url="https://product.eng.ambient.ai$path"
elif [[ "$chrome_url" =~ ^https://product-staging\.ambient\.ai(/.*)?$ ]]; then
  path="${chrome_url#https://product-staging.ambient.ai}"
  new_url="http://localhost:3000$path"
elif [[ "$chrome_url" =~ ^https://product\.eng\.ambient\.ai(/.*)?$ ]]; then
  path="${chrome_url#https://product.eng.ambient.ai}"
  new_url="http://localhost:3000$path"
else
  echo "Not on localhost:3000, localhost:3001, product-staging.ambient.ai, or product.eng.ambient.ai."
  exit 0
fi

osascript <<EOF
tell application "Google Chrome"
    tell front window
        make new tab with properties {URL:"$new_url"}
    end tell
end tell
EOF
