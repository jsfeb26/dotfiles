if command -v brew >/dev/null 2>&1; then
  brew_prefix="$(brew --prefix)"
  if [ -d "${brew_prefix}/share/zsh/site-functions" ]; then
    FPATH="${brew_prefix}/share/zsh/site-functions:${FPATH}"
  fi
fi

autoload -Uz compinit
compinit

source_first_match() {
  local candidate

  for candidate in "$@"; do
    if [ -r "$candidate" ]; then
      source "$candidate"
      return 0
    fi
  done

  return 1
}

source_first_match \
  "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  "/usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source_first_match \
  "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  "/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

autoload -U add-zsh-hook

load_nvmrc() {
  if ! command -v nvm >/dev/null 2>&1; then
    return 0
  fi

  local node_version
  local nvmrc_path
  local nvmrc_node_version

  node_version="$(nvm version)"
  nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    nvmrc_node_version="$(nvm version "$(cat "${nvmrc_path}")")"

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    nvm use default >/dev/null
  fi
}

add-zsh-hook chpwd load_nvmrc
load_nvmrc
