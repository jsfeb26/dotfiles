echo "Installing X-Code"
xcode-select --install

echo "Installing Homebrew"
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew update
brew tap homebrew/bundle
brew tap homebrew/cask
brew tap homebrew/core

echo "Installing Git"
brew install git

echo "Install node via NVM"
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
nvm install stable
nvm alias default stable

echo "Install Tmux"
brew install tmux
brew install reattach-to-user-namespace

echo "Installing and setting zsh and OhMyZsh stuff"
brew install zsh
chsh -s /bin/zsh # make zsh default shell
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
brew install zsh-syntax-highlighting
git clone git://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/plugins/zsh-autosuggestions
npm install -g spaceship-prompt

echo "Installing Docker"
brew install docker
brew install docker-machine
brew cask install virtualbox
brew install docker-compose

echo "Installing Misc"
brew install mongodb
brew install bash-completion
brew install diff-so-fancy
brew install python
brew install wget
brew install hub
brew install ack
brew install tree
brew install tldr
# installing yarn with curl because brew get's latest node and I'm using nvm for that
curl -o- -L https://yarnpkg.com/install.sh | bash

# brew install fzf
# brew install highlight
# brew install markdown
# brew install grep, args: ["with-default-names"]

echo "Installing Programs"
brew cask install iterm2
brew cask install alfred
brew cask install firefox
brew cask install brave-browser
brew cask install google-chrome
brew cask install hyperswitch
brew cask install iris
brew cask install 1password
brew cask install slack
brew cask install atom
brew cask install kindle
brew cask install evernote
brew cask install dropbox
brew cask install visual-studio-code

echo "Installing Atom Setting Sync"
apm install sync-settings

echo "Installing Mac App Store Package Manager and Apps"
brew install mas
mas install 1091189122 # Bear
mas install 585829637  # Todoist
mas install 441258766  # Magnet
mas install 413564952  # Home Inventory

echo "Installing Fonts"
cp -R ~/dotfiles/fonts/. ~/Library/Fonts/

echo "Creating dev Directory"
mkdir ~/dev

echo "Symlinking Profiles"
ln -s ~/dotfiles/profiles/.zshrc ~/
ln -s ~/dotfiles/profiles/.vimrc ~/
ln -s ~/dotfiles/profiles/.gitconfig ~/
ln -s ~/dotfiles/profiles/.tmux.conf ~/
ln -s ~/dotfiles/profiles/.tmux.conf.local ~/
ln -s ~/dotfiles/profiles/iterm ~/
