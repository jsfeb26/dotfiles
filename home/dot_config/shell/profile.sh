if [ -n "${DOTFILES_PROFILE_LOADED:-}" ]; then
  return 0
fi

export DOTFILES_PROFILE_LOADED=1

shell_source() {
  [ -r "$1" ] && . "$1"
}

shell_source "$HOME/.config/shell/env.sh"
shell_source "$HOME/.config/shell/path.sh"

# Fixes the flicker issue in Claude Code
export CLAUDE_CODE_NO_FLICKER=1