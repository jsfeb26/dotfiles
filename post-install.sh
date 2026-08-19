printf "\e[42m Installing Additional Things \e[0m\n"

# sourcing nvm
. ~/.nvm/nvm.sh

nvm install stable
nvm alias default stable

printf "\e[42m Setting up additional Claude Code tools \e[0m\n"
# Note: Using native install of Claude Code to avoid multiple instances based on which node version
# npm install -g @anthropic-ai/claude-code
npm install -g ccusage
git -C ~/dev clone https://github.com/contains-studio/agents.git
cp -rn ~/dev/agents/* ~/.claude/agents/
# Remove README.md because it's getting copied over with the actual agents
[ -f ~/.claude/agents/README.md ] && rm ~/.claude/agents/README.md
npx -y @owloops/claude-powerline --install-fonts

# Install Codex
npm install -g @openai/codex@latest

printf "\e[42m Login to atuin will be prompted for password and key \e[0m\n"
atuin login -u jsfeb26


# TODO: Remove if antigen handles this
# sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
# brew install zsh-syntax-highlighting
# git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Adding spaceship prompt
# git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
# ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
# Issues with doing this now so switching to using OH_MY_ZSH theme
# npm install -g spaceship-prompt
