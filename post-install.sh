printf "\e[42m Installing Additional Things \e[0m\n"

nvm install stable
nvm alias default stable
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
brew install zsh-syntax-highlighting
git clone git://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/plugins/zsh-autosuggestions
npm install -g spaceship-prompt