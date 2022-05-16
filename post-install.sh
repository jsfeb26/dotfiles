printf "\e[42m Installing Additional Things \e[0m\n"

# sourcing nvm
. ~/.nvm/nvm.sh

nvm install stable
nvm alias default stable
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
brew install zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
npm install -g spaceship-prompt
