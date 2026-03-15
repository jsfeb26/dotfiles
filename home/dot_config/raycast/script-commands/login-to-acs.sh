#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Login to ACS - Raycast Script
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🛠️
# @raycast.packageName Developer Utils

# Documentation:
# @raycast.description Extract a JWT from a copied GraphQL curl command and open the SSO URL.
# @raycast.author jsfeb26
# @raycast.authorURL https://raycast.com/jsfeb26

ENV_FILE="$HOME/.config/raycast/.env"

if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
else
    echo ".env file not found at $ENV_FILE"
    echo "Create it with:"
    echo "SSO_BASE_URL="
    echo "GRAPHQL_DOMAIN="
    echo "LOGIN_URL="
    exit 1
fi

clipboard_content=$(pbpaste 2>/dev/null)

if echo "$clipboard_content" | grep -q "curl.*$GRAPHQL_DOMAIN"; then
    if echo "$clipboard_content" | grep -qi "authorization.*JWT"; then
        token=$(echo "$clipboard_content" | grep -oi "['\"]authorization[^'\"]*JWT [^'\"]*['\"]" | sed -E 's/.*JWT ([^'\''\"]*).*/\1/')

        if [ -z "$token" ]; then
            token=$(echo "$clipboard_content" | grep -o "JWT [a-zA-Z0-9._-]*" | sed 's/JWT //')
        fi

        if [ ! -z "$token" ]; then
            sso_url="$SSO_BASE_URL/$token"
            osascript -e "tell application \"Google Chrome\" to tell front window to make new tab with properties {URL:\"$sso_url\"}"
            exit 0
        fi
    fi
fi

echo "No GraphQL curl command for $GRAPHQL_DOMAIN was found in the clipboard."
echo "Log in to $LOGIN_URL, copy a GraphQL request as cURL, then run this script again."
