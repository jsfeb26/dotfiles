printf "\e[42m Installing Homebrew \e[0m\n"

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/jstinson/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

printf "\e[42m Installing Rust \e[0m\n"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

brew update
brew tap homebrew/bundle
brew tap homebrew/cask
brew tap homebrew/core
brew tap mongodb/brew

printf "\e[42m Installing Git \e[0m\n"
brew install git
brew install gh	

printf "\e[42m Install node via NVM \e[0m\n"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

printf "\e[42m Install Antigen for managing plugins \e[0m\n"
curl -L git.io/antigen > ~/antigen.zsh

printf "\e[42m Install Tmux \e[0m\n"
brew install tmux
brew install reattach-to-user-namespace

printf "\e[42m Installing Docker \e[0m\n"
brew install docker
brew install docker-machine
brew cask install virtualbox
brew install docker-compose

printf "\e[42m Installing Misc \e[0m\n"
brew install mongodb-community@5.0.8
brew install bash-completion
brew install diff-so-fancy
brew install python3
brew install wget
brew install hub
brew install ack
brew install tree
brew install tldr
brew install figlet
# installing yarn with curl because brew get's latest node and I'm using nvm for that
# TODO: Figure out how to install yarn 2+
# curl -o- -L https://yarnpkg.com/install.sh | bash

brew install fzf
# brew install highlight
# brew install markdown
# brew install grep, args: ["with-default-names"]

printf "\e[42m Installing Programs \e[0m\n"
brew install --cask iterm2
# brew install --cask alfred
brew install --cask raycast
brew install --cask warp
brew install --cask arc
brew install --cask firefox
brew install --cask brave-browser
brew install --cask google-chrome
brew install --cask hyperswitch
brew install --cask 1password/tap/1password-cli
# brew install --cask 1password
brew install --cask slack
brew install --cask kindle
brew install --cask evernote
brew install --cask dropbox
brew install --cask visual-studio-code
# Need to install specific version if transferring license
# brew install --cask iris

printf "\e[42m Installing Mac App Store Package Manager and Apps \e[0m\n"
brew install mas
mas install 1091189122 # Bear
# mas install 585829637  # Todoist
# mas install 441258766  # Magnet
mas install 413564952  # Home Inventory
mas install 904280696  # Things3
mas install 1485052491 # Dropzone 4

printf "\e[42m Installing Fonts \e[0m\n"
cp -R ~/dotfiles/fonts/. ~/Library/Fonts/

printf "\e[42m Creating dev Directory \e[0m\n"
mkdir ~/dev

printf "\e[42m Installing \e[0m\n"
brew install zsh
brew install starship

printf "\e[42m Installing Vim Plug \e[0m\n"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

printf "\e[42m Symlinking Profiles \e[0m\n"
[ ! -e ~/.zshrc ] || rm ~/.zshrc
[ ! -e ~/.vimrc ] || rm ~/.vimrc
[ ! -e ~/.gitconfig ] || rm ~/.gitconfig
[ ! -e ~/.gitconfig_global ] || rm ~/.gitconfig_global
[ ! -e ~/.tmux.conf ] || rm ~/.tmux.conf
[ ! -e ~/.tmux.conf.local ] || rm ~/.tmux.conf.local
[ ! -e ~/iterm ] || rm -rf ~/iterm
[ ! -e ~/.config/starship.toml ] || rm -rf ~/.config/starship.toml

ln -s ~/dotfiles/profiles/.zshrc ~/
ln -s ~/dotfiles/profiles/.vimrc ~/
ln -s ~/dotfiles/profiles/.gitconfig ~/
ln -s ~/dotfiles/profiles/.gitconfig_global ~/
ln -s ~/dotfiles/profiles/.tmux.conf ~/
ln -s ~/dotfiles/profiles/.tmux.conf.local ~/
ln -s ~/dotfiles/profiles/iterm ~/
ln -s ~/dotfiles/.config/starship.toml ~/.config/

figlet "Great Success!!!"

chsh -s /bin/zsh # make zsh default shell
