#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Decode Query Params
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🔍
# @raycast.packageName Ambient Scripts

# Documentation:
# @raycast.description Extracts and decompresses LZ-string encoded query parameters from current URL
# @raycast.author jsfeb26
# @raycast.authorURL https://raycast.com/jsfeb26

# Check if Google Chrome is the frontmost app
front_app=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true')
if [ "$front_app" != "Google Chrome" ]; then
  echo "❌ Google Chrome is not active."
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

# Get the directory where this script is located
script_dir=$(dirname "$0")

# Array of allowed URL patterns (supports both specific URLs and regex patterns)
# Examples:
#   "localhost:3000" - matches exactly localhost:3000
#   ".*\.ambient\.ai" - matches any subdomain of ambient.ai (app.ambient.ai, staging.ambient.ai, etc.)
#   "dev\.example\.com" - matches exactly dev.example.com
allowed_urls=(
  "localhost:3000"
  ".*\.ambient\.ai"
)

# Check if URL matches any allowed pattern
is_valid_url=false
for allowed_pattern in "${allowed_urls[@]}"; do
  if [[ "$chrome_url" =~ ^https?://$allowed_pattern ]]; then
    is_valid_url=true
    break
  fi
done

if [ "$is_valid_url" = false ]; then
  echo "❌ URL must match one of the allowed patterns:"
  printf "  - %s\n" "${allowed_urls[@]}"
  echo ""
  echo "Current URL: $chrome_url"
  exit 1
fi

# Extract query string
query_string=$(echo "$chrome_url" | grep -o '?.*' | sed 's/^?//')

if [ -z "$query_string" ]; then
  echo "❌ No query parameters found in URL"
  exit 1
fi

# Get the directory where this script is located
script_dir=$(dirname "$0")


# Find Node.js executable
node_path=""
for path in /usr/local/bin/node /opt/homebrew/bin/node /usr/bin/node ~/.nvm/versions/node/*/bin/node; do
  if [ -x "$path" ]; then
    node_path="$path"
    break
  fi
done

# If not found in common locations, try to find it in PATH
if [ -z "$node_path" ]; then
  node_path=$(which node 2>/dev/null || echo "")
fi

if [ -z "$node_path" ]; then
  echo "❌ Node.js not found. Please install Node.js or ensure it's in your PATH."
  echo "Common installation methods:"
  echo "  - brew install nvm && nvm install --lts"
  echo "  - brew install node"
  echo "  - Download from https://nodejs.org"
  exit 1
fi

# Check if lz-string is installed locally in nodeScripts
if [ ! -d "$script_dir/../nodeScripts/node_modules/lz-string" ]; then
  echo "❌ lz-string package not installed locally!"
  echo ""
  echo "Please install dependencies by running:"
  echo "  cd ~/dotfiles/raycast/nodeScripts && npm i"
  echo ""
  echo "Or install the specific package:"
  echo "  npm install lz-string"
  exit 1
fi

# Run the decompression script
echo "🔍 Decoding query parameters..."
echo "📋 URL: $chrome_url"
echo ""
echo "🔧 Running Node.js decoder (using: $node_path)..."

# Capture both output and errors separately
temp_output=$(mktemp)
temp_error=$(mktemp)

# "$node_path" "$script_dir/decode-query-params.js" "$query_string" > "$temp_output" 2> "$temp_error"
"$node_path" "$script_dir/../nodeScripts/decode-query-params.js" "$query_string" > "$temp_output" 2> "$temp_error"
exit_code=$?

# Read the outputs
decoded_json=$(cat "$temp_output")
error_output=$(cat "$temp_error")

# Show errors if any
if [ -n "$error_output" ]; then
  echo "⚠️  Node.js output/errors:"
  echo "$error_output"
  echo ""
fi

if [ $exit_code -eq 0 ] && [ -n "$decoded_json" ]; then
  echo "✅ Decoded Parameters:"
  echo "$decoded_json"
  
  # Copy to clipboard
  echo "$decoded_json" | pbcopy
  echo ""
  echo "📋 JSON copied to clipboard!"
else
  echo "❌ Failed to decode query parameters (exit code: $exit_code)"
  echo "Raw query string: $query_string"
  
  if [ -z "$decoded_json" ] && [ -z "$error_output" ]; then
    echo "No output received from Node.js script"
  fi
fi

# Clean up temp files
rm -f "$temp_output" "$temp_error"

 