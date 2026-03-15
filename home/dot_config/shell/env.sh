export OBSIDIAN_SECOND_BRAIN="$HOME/Dropbox/Obsidian Vaults/Agentic Second Brain"

export LANG="${LANG:-en_US.UTF-8}"
export LC_CTYPE="${LC_CTYPE:-en_US.UTF-8}"

if command -v nvim >/dev/null 2>&1; then
  export EDITOR="nvim"
else
  export EDITOR="vim"
fi

export VISUAL="$EDITOR"
export PAGER="less"

case "$(uname -s)" in
  Darwin)
    export DOTFILES_OS="darwin"
    ;;
  Linux)
    export DOTFILES_OS="linux"
    ;;
  *)
    export DOTFILES_OS="unknown"
    ;;
esac

if [ -f /proc/version ] && grep -qi microsoft /proc/version 2>/dev/null; then
  export DOTFILES_IS_WSL="1"
fi
