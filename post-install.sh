printf "\e[42m Installing Additional Things \e[0m\n"

# sourcing nvm
. ~/.nvm/nvm.sh

nvm install stable
nvm alias default stable


# TODO: Remove if antigen handles this
# sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
# brew install zsh-syntax-highlighting
# git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Adding spaceship prompt
# git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
# ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
# Issues with doing this now so switching to using OH_MY_ZSH theme
# npm install -g spaceship-prompt
