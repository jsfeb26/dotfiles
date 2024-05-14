# Dev Setup

1. Install xcode run `xcode-select --install`
2. Download [1Password](https://1password.com/downloads/mac/) and setup another device on existing computer
3. ~~[Create a Rosetta version of terminal](https://osxdaily.com/2020/11/18/how-run-homebrew-x86-terminal-apple-silicon-mac/)~~
4. Clone dotfiles in home directory `git clone https://github.com/jsfeb26/dotfiles.git`
5. Sign into App Store
6. Run `bash ~/dotfiles/osx-install.sh {username}`
7. Change all settings from "jasonstinson" to `{username}
8. Run `bash ~/dotfiiles/post-install.sh`
9. If you get `Zsh detects insecure completion-dependent directories` errors then run:

```bash
chmod 755 /usr/local/share/zsh
chmod 755 /usr/local/share/zsh/site-functions
```

## Customize Settings

---

### Finicky Browser Redirect

- Use [Finicky Kickstart](https://finicky-kickstart.vercel.app/) to generate new settins for new types of links

### iCloud

- Sync Desktop and Documents

### Sign In To Accounts

- Dropbox
- Chrome
- Bear
- Things
- Kindle
- Evernote

### Mac Settings

- Install Flipqlo Clock Screen Saver `~/dotfiles/installers/Fliqlo.dmg`
- Install TrackballWorks `~/dotfiles/installers/TrackballWorks.dmg`
  ![TrackballWorks Settings](settings/trackballworks.png)
- [Install Logitech Options](https://support.logi.com/hc/en-us/articles/360025297893)
  - Installer is located in Dropbox/Installers
  - Make bottom button open Mission Control
- Keyboard Settings
  ![Keyboard Settings](settings/keyboard.png)
  ![Keyboard Modifier Keys Settings](settings/keyboard_modifier-keys.png)
  ![Keyboard Shortcuts Settings](settings/keyboard_shortcuts.png)
- Mouse Settings
  ![Mouse Settings](settings/mouse.png)
- Energy Saver
  ![Energy Saver Settings](settings/energy-saver.png)
- Hot Corners
  ![Hot Corners Settings](settings/hot-corners.png)
- Mission Control
  ![Mission Control Settings](settings/mission-control.png)
- General
  ![General Settings](settings/general.png)
- Dock
  ![Dock Settings](settings/dock.png)
- [Optional] set key repeat `defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false`

### Iris

- Buy new license or transfer license by signing in to [User Panel](https://iristech.co/custom-code/user-panel/pages/my_licenses.php)
  - 1.1.2 NOT USED
  - 1.1.5 Macbook Pro (Personal)
  - 1.2.0 Macbook Pro (Ambient)
- Use installer for in specific iris version in `/installers/*`
  ![Iris Settings](settings/iris-blue-light.png)
  ![Iris Settings](settings/iris-brightness.png)
  ![Iris Settings](settings/iris-location.png)
  ![Iris Settings](settings/iris-sleep.png)
  ![Iris Settings](settings/iris-fonts.png)
- ~~Go to Advanced -> Hidden Features~~
- ~~Type in `import` and choose `/Users/{username}/dotfiles/profiles/iris.iris_settings`~~

### VSCode

- Click Settings Icon in bottom left and turn `Settings Sync`
- Check all checkboxes and sign in with GitHub
- ~~Install "Settings Sync" in VSCode~~
- ~~In 1Password go to Github and copy token `vs-code-setting-sync-token` and gistID `vscode-sync-gist`~~
- ~~In VSCode open command palette (`command + shift + p`) and then type `Sync: Download Settings`~~
- ~~Enter token and gistId~~
- ~~Restart VSCode~~

### Github add SSH Key

- Go to [Github keys settings](https://github.com/settings/keys)
- Click "New SSH Key"
- Run `ssh-keygen -t rsa -b 4096 -C "jsfeb26@gmail.com"`
- Follow default prompts
- Run `eval "$(ssh-agent -s)"`
- Run `open ~/.ssh/config` to see if config file exists. It shouldn't
- Run `touch ~/.ssh/config` and then `code ~/.ssh/config`
- Paste in

```config
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_rsa
```

- Run `ssh-add --apple-use-keychain ~/.ssh/id_rsa` to add your SSH private key to the ssh-agent and store your passphrase in the keychain
- Get SSH Key by running `pbcopy < ~/.ssh/id_rsa.pub`
- Paste in Github SSH Key field

### Warp

- Click on Settings Icon in top right
- Go to Appearance Tab
  - Change Text to FiraCode Nerd Font Mono
  - Click on Prompt and select `Shell prompt (PS1)`
  - Turn on `Dim inactive panes`

### Vim

- Open vim and run `:PlugInstall`

### Configure Raycast

- Integrate with 1Password CLI
  - 1Password -> Settings -> Developer

### Configure iStat Menu

- Get License Key from 1Password
- Add Memory, Sensors, and Battery/Power
  ![iState Menu Settings](settings/istat-menu.png)

### Configure Bartender 5

- Get License Key from 1Password
- Go to Settings -> General
  - Turn on `Start at login`
  - Turn on `Click on empty menu bar space`
  - Turn on `Show items in bar below menu bar (Bartender Bar)`
  - Change `Bartender menu bar icon` to `Bartender`
- Go to Settings -> Menu Bar Items
  ![Bartender Menu Bar Items Settings](settings/bartender-menu-bar-items.png)

### Configure CleanShotX

- Get License Key from 1Password
-

### Configure Hyperkey

![Hyperkey Settings](settings/hyperkey.png)

### Configure CleanMyMac

- Sign into MacPaw account to Activate

### Configure Meeting Bar

- TODO: Add this

### iTerm2 Sync Settings

- Preferences -> General -> Preferences
- Check both checkboxes and set path to `/Users/{username}/dotfiles/profiles/iterm`

### Home Inventory

- Open `iCloud Drive/Home Inventory/My_Stuff.hi3`
- Update Backup Settings
  ![Home Inventory Settings](settings/home-inventory-settings.png)
- Run by double clicking `~/dotfiles/installers/Send-to-Home-Inventory.workflow`
- Run `git co settings`
