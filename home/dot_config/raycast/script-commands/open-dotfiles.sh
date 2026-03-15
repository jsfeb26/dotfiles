#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open Dotfiles in Cursor
# @raycast.mode silent
# @raycast.packageName System

# Optional parameters:
# @raycast.icon 📁
# @raycast.description Open the active chezmoi source directory in Cursor

dotfiles_dir="${HOME}/.local/share/chezmoi"
if command -v chezmoi &>/dev/null; then
  dotfiles_dir="$(chezmoi source-path 2>/dev/null || echo "$dotfiles_dir")"
fi

if command -v cursor &>/dev/null; then
  cursor "$dotfiles_dir"
else
  open -a "Cursor" "$dotfiles_dir"
fi
