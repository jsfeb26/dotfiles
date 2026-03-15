clipboard_read() {
  if command -v pbpaste >/dev/null 2>&1; then
    pbpaste
    return
  fi

  if command -v wl-paste >/dev/null 2>&1; then
    wl-paste --no-newline
    return
  fi

  if command -v xclip >/dev/null 2>&1; then
    xclip -selection clipboard -o
    return
  fi

  if command -v xsel >/dev/null 2>&1; then
    xsel --clipboard --output
    return
  fi

  return 1
}

dotfiles() {
  if ! command -v chezmoi >/dev/null 2>&1; then
    echo "chezmoi is not installed."
    return 1
  fi

  local source_dir
  source_dir="$(chezmoi source-path)"

  if command -v cursor >/dev/null 2>&1; then
    cursor "$source_dir"
    return 0
  fi

  cd "$source_dir" || return 1
}

gitsb() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf is required for gitsb."
    return 1
  fi

  local branch
  branch="$(git br 2>/dev/null | sed 's/^[* ]*//' | fzf)" || return 0
  [ -n "$branch" ] && git checkout "$branch"
}

opus() {
  ENABLE_BACKGROUND_TASKS=1 claude --model opus "$@"
}

dopus() {
  ENABLE_BACKGROUND_TASKS=1 claude --model opus --dangerously-skip-permissions "$@"
}

popus() {
  local clipboard_contents
  clipboard_contents="$(clipboard_read)" || {
    echo "No supported clipboard command is available."
    return 1
  }

  opus "${clipboard_contents} --- $*"
}

ccdanger() {
  claude --dangerously-skip-permissions "$@"
}

ccbrain() {
  cd "$OBSIDIAN_SECOND_BRAIN" && claude --dangerously-skip-permissions "$@"
}

ccdotfiles() {
  cd "$HOME/dotfiles" && claude --dangerously-skip-permissions "$@"
}

tm() {
  local session_name
  session_name="${1:-main}"

  if ! command -v tmux >/dev/null 2>&1; then
    echo "tmux is not installed."
    return 1
  fi

  tmux new-session -A -s "$session_name"
}
