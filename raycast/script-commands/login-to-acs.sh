#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Login to ACS - Raycast Script
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🛠️
# @raycast.packageName Developer Utils

# Documentation:
# @raycast.description Extract JWT from copied curl command (copy GraphQL request as curl from DevTools)
# @raycast.author jsfeb26
# @raycast.authorURL https://raycast.com/jsfeb26

# Load environment variables from dotfiles .env file
ENV_FILE="$HOME/dotfiles/.env"

# Load environment variables from .env file
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
else
    echo "❌ .env file not found at $ENV_FILE"
    echo "Please create .env file in your dotfiles directory with:"
    echo ""
    echo "SSO_BASE_URL="
    echo "GRAPHQL_DOMAIN="
    echo "LOGIN_URL="
    exit 1
fi

# Get current clipboard content
clipboard_content=$(pbpaste 2>/dev/null)

# Check if clipboard contains curl command for the GraphQL endpoint
if echo "$clipboard_content" | grep -q "curl.*$GRAPHQL_DOMAIN"; then
    echo "📋 Found curl command for $GRAPHQL_DOMAIN"
    
    # Look for Authorization header with JWT (case insensitive)
    if echo "$clipboard_content" | grep -qi "authorization.*JWT"; then
        # Extract the JWT token after "JWT " (case insensitive)
        token=$(echo "$clipboard_content" | grep -oi "['\"]authorization[^'\"]*JWT [^'\"]*['\"]" | sed -E 's/.*JWT ([^'\''\"]*).*/\1/')
        
        # If that doesn't work, try a simpler approach
        if [ -z "$token" ]; then
            token=$(echo "$clipboard_content" | grep -o "JWT [a-zA-Z0-9._-]*" | sed 's/JWT //')
        fi
        
        if [ ! -z "$token" ]; then
            echo "✅ Found JWT token: ${token:0:20}..."
            sso_url="$SSO_BASE_URL/$token"
            echo "🚀 Opening SSO URL: $sso_url"
            
            # Open new Chrome tab
            osascript -e "tell application \"Google Chrome\" to tell front window to make new tab with properties {URL:\"$sso_url\"}"
            
            echo "✨ Done!"
            exit 0
        else
            echo "❌ JWT token extraction failed"
        fi
    else
        echo "❌ No JWT Authorization header found in curl command"
    fi
else
    echo "❌ No curl command for $GRAPHQL_DOMAIN found in clipboard"
    echo ""
    echo "✨ To login to the ACS environment you need to get your JWT Token in Auth Header. You can get your JWT token, by logging in to $LOGIN_URL. Then getting one of the GraphQL requests from the Network tab in DevTools"
    echo ""
    echo "📝 Instructions:"
    echo "  1. Open Chrome DevTools (F12)"
    echo "  2. Go to Network tab"
    echo "  3. Click on one of your GraphQL requests to $GRAPHQL_DOMAIN"
    echo "  4. Right-click the GraphQL request → Copy → Copy as cURL"
    echo "  5. Run this script again"
fi 
