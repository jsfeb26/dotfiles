#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Switch Ambient Env - Raycast Script
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖
# @raycast.argument1 { "type": "text", "placeholder": "Environment (beta, app, staging, localhost)" }

# Documentation:
# @raycast.description Switch between Ambient environments in a new Chrome tab.
# @raycast.author jsfeb26
# @raycast.authorURL https://raycast.com/jsfeb26

ambient_domains=(
    "app.ambient.ai"
    "beta.ambient.ai"
    "main.ambient.ai"
    "prerelease.ambient.ai"
    "product.prod.ambient.ai"
    "product-beta.ambient.ai"
)

target_env="$1"

case "$target_env" in
    "app") base_url="https://app.ambient.ai" ;;
    "beta") base_url="https://beta.ambient.ai" ;;
    "main") base_url="https://main.ambient.ai" ;;
    "prerelease") base_url="https://prerelease.ambient.ai" ;;
    "internal") base_url="https://product.prod.ambient.ai" ;;
    "product-beta") base_url="https://product-beta.ambient.ai" ;;
    *)
        echo "Invalid environment: $target_env"
        exit 1
        ;;
esac

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

path=""
is_ambient_env=false

for domain in "${ambient_domains[@]}"; do
    if [[ "$chrome_url" =~ ^https?://${domain//./\.}(/.*)?$ ]]; then
        path="${chrome_url#https://$domain}"
        is_ambient_env=true
        break
    fi
done

if [ "$is_ambient_env" = false ]; then
    echo "Current tab is not on a known Ambient environment."
    exit 0
fi

new_url="$base_url$path"
osascript <<EOF
tell application "Google Chrome"
    tell front window
        make new tab with properties {URL:"$new_url"}
    end tell
end tell
EOF
