if [ -s "$HOME/.nvm/nvm.sh" ]; then
  # shellcheck disable=SC1090
  . "$HOME/.nvm/nvm.sh"
fi

if [ -s "$HOME/.nvm/bash_completion" ]; then
  # shellcheck disable=SC1090
  . "$HOME/.nvm/bash_completion"
fi

if command -v atuin >/dev/null 2>&1; then
  if [ -n "${ZSH_VERSION:-}" ]; then
    eval "$(atuin init zsh)"
  elif [ -n "${BASH_VERSION:-}" ]; then
    eval "$(atuin init bash)"
  fi
fi

if command -v starship >/dev/null 2>&1; then
  if [ -n "${ZSH_VERSION:-}" ]; then
    eval "$(starship init zsh)"
  elif [ -n "${BASH_VERSION:-}" ]; then
    eval "$(starship init bash)"
  fi
fi

if command -v fzf >/dev/null 2>&1; then
  if [ -n "${ZSH_VERSION:-}" ]; then
    eval "$(fzf --zsh 2>/dev/null || true)"
  elif [ -n "${BASH_VERSION:-}" ]; then
    eval "$(fzf --bash 2>/dev/null || true)"
  fi
fi
