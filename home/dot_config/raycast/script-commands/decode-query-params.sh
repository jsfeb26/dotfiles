#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Decode Query Params - Raycast Script
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🔍
# @raycast.packageName Ambient Scripts

# Documentation:
# @raycast.description Extract and decompress LZ-string encoded query parameters from the current URL.
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

script_dir=$(cd "$(dirname "$0")" && pwd)

allowed_urls=(
  "localhost:3000"
  ".*\.ambient\.ai"
)

is_valid_url=false
for allowed_pattern in "${allowed_urls[@]}"; do
  if [[ "$chrome_url" =~ ^https?://$allowed_pattern ]]; then
    is_valid_url=true
    break
  fi
done

if [ "$is_valid_url" = false ]; then
  echo "URL must match one of the allowed patterns:"
  printf "  - %s\n" "${allowed_urls[@]}"
  echo
  echo "Current URL: $chrome_url"
  exit 1
fi

query_string=$(echo "$chrome_url" | grep -o '?.*' | sed 's/^?//')
if [ -z "$query_string" ]; then
  echo "No query parameters found in URL"
  exit 1
fi

node_path=""
for path in /usr/local/bin/node /opt/homebrew/bin/node /usr/bin/node ~/.nvm/versions/node/*/bin/node; do
  if [ -x "$path" ]; then
    node_path="$path"
    break
  fi
done

if [ -z "$node_path" ]; then
  node_path=$(which node 2>/dev/null || echo "")
fi

if [ -z "$node_path" ]; then
  echo "Node.js not found. Install Node.js or ensure it is in PATH."
  exit 1
fi

if [ ! -d "$script_dir/../nodeScripts/node_modules/lz-string" ]; then
  echo "Node dependencies are not installed in $script_dir/../nodeScripts"
  echo "Run: cd ~/.config/raycast/nodeScripts && npm ci"
  exit 1
fi

temp_output=$(mktemp)
temp_error=$(mktemp)

"$node_path" "$script_dir/../nodeScripts/decode-query-params.js" "$query_string" > "$temp_output" 2> "$temp_error"
exit_code=$?

decoded_json=$(cat "$temp_output")
error_output=$(cat "$temp_error")

if [ -n "$error_output" ]; then
  echo "$error_output"
  echo
fi

if [ $exit_code -eq 0 ] && [ -n "$decoded_json" ]; then
  echo "$decoded_json"
  echo "$decoded_json" | pbcopy
else
  echo "Failed to decode query parameters (exit code: $exit_code)"
fi

rm -f "$temp_output" "$temp_error"
