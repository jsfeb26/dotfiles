#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Switch Ambient Env - Raycast Script
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖
# @raycast.argument1 { "type": "text", "placeholder": "Environment (app, beta, main, prerelease, internal, product-beta, localhost)" }

# Documentation:
# @raycast.description Switch between Ambient environments (app, beta, main, prerelease, internal, product-beta, localhost) keeping the same path.
# @raycast.author jsfeb26
# @raycast.authorURL https://raycast.com/jsfeb26

target_env="$1"

# Map the requested environment to its base URL
case "$target_env" in
    "app")               base_url="https://app.ambient.ai" ;;
    "beta")              base_url="https://beta.ambient.ai" ;;
    "main")              base_url="https://main.ambient.ai" ;;
    "prerelease")        base_url="https://prerelease.ambient.ai" ;;
    "internal")          base_url="https://product.prod.ambient.ai" ;;
    "product-beta")      base_url="https://product-beta.ambient.ai" ;;
    "localhost"|"local") base_url="http://localhost:3000" ;;
    *)
        echo "Invalid environment: $target_env"
        echo "Valid environments: app, beta, main, prerelease, internal, product-beta, localhost"
        exit 1
        ;;
esac

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

# Extract the path from the current URL, keeping it intact.
# Matches ANY *.ambient.ai subdomain (app, beta, product.prod, product-staging,
# product.eng, etc.) so switching works from any environment, plus localhost.
if [[ "$chrome_url" =~ ^https?://[^/]*\.ambient\.ai(/.*)?$ ]]; then
    path="${BASH_REMATCH[1]}"
elif [[ "$chrome_url" =~ ^https?://localhost(:[0-9]+)?(/.*)?$ ]]; then
    path="${BASH_REMATCH[2]}"
else
    echo "Not an Ambient/localhost URL: $chrome_url"
    exit 0
fi

# Construct the new URL and open it in a new tab
new_url="$base_url$path"
echo "Switching to $target_env: $new_url"

osascript <<EOF
tell application "Google Chrome"
    tell front window
        make new tab with properties {URL:"$new_url"}
    end tell
end tell
EOF
