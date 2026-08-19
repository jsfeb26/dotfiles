#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title GitHub Permalink to Claude Ref
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🔗
# @raycast.packageName Claude Scripts

# Documentation:
# @raycast.description Converts a GitHub blob permalink with line anchors from clipboard into a Claude Code @file#L reference and pastes it at the cursor.
# @raycast.author jsfeb26
# @raycast.authorURL https://raycast.com/jsfeb26

clipboard=$(pbpaste)

# Match: https://github.com/{org}/{repo}/blob/{ref}/{path}#L{start}[-L{end}]
if [[ "$clipboard" =~ ^https://github\.com/[^/]+/[^/]+/blob/[^/]+/(.+)#L([0-9]+)(-L([0-9]+))?$ ]]; then
    filepath="${BASH_REMATCH[1]}"
    start_line="${BASH_REMATCH[2]}"
    end_line="${BASH_REMATCH[4]}"

    if [[ -n "$end_line" ]]; then
        ref="@${filepath}#L${start_line}-${end_line}"
    else
        ref="@${filepath}#L${start_line}"
    fi

    printf '%s' "$ref" | pbcopy

    # Brief pause for Raycast to dismiss, then paste at cursor
    sleep 0.5
    osascript -e 'tell application "System Events" to keystroke "v" using {command down}'

    echo "Pasted: $ref"
else
    preview=$(printf '%s' "$clipboard" | cut -c1-80)
    echo "Not a valid GitHub permalink: $preview"
    exit 1
fi
