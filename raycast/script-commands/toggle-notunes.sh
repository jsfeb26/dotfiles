#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Toggle NoTunes - Raycast Script
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🔇

# Documentation:
# @raycast.description Enables or Disables NoTunes which prevents Apple Music from auto opening
# @raycast.author jsfeb26
# @raycast.authorURL https://raycast.com/jsfeb26

APP_NAME="NoTunes"
if osascript -e 'application "NoTunes" is running' | grep true > /dev/null; then
  osascript -e 'quit app "NoTunes"'
  echo "NoTunes turned off"
else
  open -a "$APP_NAME"
  echo "NoTunes turned on"
fi