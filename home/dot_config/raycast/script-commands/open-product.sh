#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open Product in Cursor
# @raycast.mode silent
# @raycast.packageName System

# Optional parameters:
# @raycast.icon 📦
# @raycast.description Open the product repo in Cursor and Ghostty

PRODUCT_DIR="$HOME/dev/ambient/product"

ghostty_running=$(osascript -e 'application "Ghostty" is running' 2>/dev/null)
if [[ "$ghostty_running" != "true" ]]; then
  open -na Ghostty.app --args --working-directory="$PRODUCT_DIR"
  sleep 1.5
fi

echo -n "cursor \"$PRODUCT_DIR\"" | pbcopy
osascript <<EOF
tell application "Ghostty" to activate
delay 0.2
tell application "System Events"
  key code 18 using {command down}
  delay 0.1
  keystroke "v" using {command down}
  delay 0.1
  key code 36
end tell
EOF
