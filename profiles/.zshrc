ZSH_DISABLE_COMPFIX="true"                                           # Disable zsh compinit warning 
# ZSH_TMUX_AUTOSTART='true'                                            # make tmux start every time shell starts  
DEFAULT_USER="jasonstinson"                                              # need to set to use to get rid of long prompt

export ZSH=/Users/jasonstinson/.oh-my-zsh                                # Path to your oh-my-zsh installation.
export LANG=en_US.UTF-8                                              # Set language environment

if [[ -n $SSH_CONNECTION ]]; then                                    # Set editor for ZSH and local
  export EDITOR='vim'
else
  export EDITOR='vim'
fi

# ============================================================================================================

# =========================== Homebrew =======================================================================

eval "$(starship init zsh)"                                          # Set prompt to Starship
eval "$(fzf --zsh)"


if type brew &>/dev/null                                             # Brew shell completion
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

  autoload -Uz compinit
  compinit
fi

# ============================================================================================================

# =========================== Antigen =======================================================================

# Uncomment there is an error installing oh-my-zsh
# ANTIGEN_LOG=~/antigen.log
source ~/antigen.zsh

antigen use oh-my-zsh
antigen bundle zsh-users/zsh-syntax-highlighting                     # Syntax Highlighting
antigen bundle zsh-users/zsh-autosuggestions                         # Autosuggestions
antigen bundle zsh-users/zsh-completions                             # More zsh completions
antigen bundle gezalore/zsh-prioritize-cwd-history                   # Prioritize history based on current dir
antigen bundle Aloxaf/fzf-tab                                        # Fuzzy tab completion
antigen bundle sudo
antigen bundle git
antigen bundle history
antigen bundle tmux
antigen bundle taskwarrior
antigen bundle tmuxinator
antigen apply

# ============================================================================================================

# =========================== nvm ============================================================================

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                     # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"   # This loads nvm bash_completion

autoload -U add-zsh-hook                                             # automatically switch node version if .nvmrc exists
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

# ============================================================================================================

# =========================== React-Native Android Configs ===================================================

export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export JAVA_HOME=/Library/Java/JavaVirtualMachines/adoptopenjdk-11.jdk/Contents/Home
fpath=($fpath "/Users/jasonstinson/.zfunctions")

# ============================================================================================================

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"


# ================= Remove these after everything is working  ==================

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# plugins=(sudo git history taskwarrior tmux tmuxinator zsh-autosuggestions)

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
# alias gl='git log --graph --pretty=format:'\''%Cred%h%Creset - %Cgreen[%an]%Creset%C(yellow)%d%Creset: %s %Cgreen(%cr)%Creset'\'' --abbrev-commit --date=relative'
alias alias-list='cat ~/.zshrc | grep "alias" | grep -v "^#"'
alias gitd="$HOME/dotfiles/scripts/deleteOldBranches.sh"
alias gitstashd="$HOME/dotfiles/scripts/deleteOldStashes.sh"

# Add syntax highlighting
# source /Users/jasonstinson/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# source $ZSH/oh-my-zsh.sh
# pnpm
export PNPM_HOME="/Users/jasonstinson/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Load custom functions
fpath=(~/dotfiles/scripts $fpath)
for func in ~/dotfiles/scripts/*.zsh; do
  source $func
done

dotfiles() {
  cursor ~/dotfiles
}

# For Cursor Agent
export PATH="$HOME/.local/bin:$PATH"

# bun completions
[ -s "/Users/jasonstinson/.bun/_bun" ] && source "/Users/jasonstinson/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Alias for claude with opus model
alias opus='ENABLE_BACKGROUND_TASKS=1 claude --model opus'

# The "$@" is a zsh thing that allows you to pass all the arguments to the function
dopus() {
  opus --dangerously-skip-permissions "$@"
}

popus() {
  opus "$(pbpaste) --- $@"
}

. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"

# Prevent accidental global Claude Code installs via npm because they go in nvm
# which means if I change node versions it won't work
npm() {
  if [[ "$1" == "install" && ( "$2" == "-g" || "$2" == "--global" ) && "$3" == "@anthropic-ai/claude-code"* ]]; then
    echo "🚫 Global Claude Code install blocked!"
    echo "Use your local install at ~/.claude/local instead."
    echo "Run 'claude-install' to install locally."
    return 1
  fi
  command npm "$@"
}

claude-install() {
  echo "📦 Installing Claude Code locally (safe, NVM-proof)..."

  # Step 1: Create install directory
  mkdir -p "$HOME/.claude/local"

  # Step 2: Install latest Claude Code into it
  npm install --prefix "$HOME/.claude/local" @anthropic-ai/claude-code@latest

  # Step 3: Create bin directory + symlink
  mkdir -p "$HOME/.claude/bin"
  ln -sf "$HOME/.claude/local/node_modules/.bin/claude" "$HOME/.claude/bin/claude"

  # Step 4: Ensure PATH contains ~/.claude/bin
  if ! echo "$PATH" | grep -q "$HOME/.claude/bin"; then
    echo 'export PATH="$HOME/.claude/bin:$PATH"' >> "$HOME/.zshrc"
    echo 'export PATH="$HOME/.claude/bin:$PATH"' >> "$HOME/.zprofile"
    echo "✅ Added ~/.claude/bin to PATH (restart your shell to apply)"
  fi

  # Step 5: Done
  echo "✅ Claude Code installed locally."
  echo "   Version: $(claude --version)"
  echo "   Path: $(which claude)"
  echo "   Run: claude doctor"
}

claude-update() {
  echo "🔧 Updating Claude Code Version: $(claude --version)"
  npm install --prefix "$HOME/.claude/local" @anthropic-ai/claude-code@latest
  echo "✅ Updated Claude Code to Version: $(claude --version)"
}

export PATH="$HOME/.claude/bin:$PATH"

