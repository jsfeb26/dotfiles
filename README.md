# Dev Setup

1. Install xcode run `xcode-select --install`
2. [Create a Rosetta version of terminal](https://osxdaily.com/2020/11/18/how-run-homebrew-x86-terminal-apple-silicon-mac/)
3. Clone dotfiles in home directory `git clone https://github.com/jsfeb26/dotfiles.git`
4. Sign into App Store
5. Run `~/dotfiles/osx-install.sh`
6. Run `~/dotfiiles/post-install.sh`
7. If you get `Zsh detects insecure completion-dependent directories` errors then run:
```
chmod 755 /usr/local/share/zsh
chmod 755 /usr/local/share/zsh/site-functions
```

## Customize Settings

---

### iCloud

- Sync Desktop and Documents

### Sign In To Accounts

- 1password
- Dropbox
- Chrome
- Bear
- Todoist
- Kindle
- Evernote

### Magnet Settings

![Magnet Settings](settings/magnet-halves-and-quarters.png)
![Magnet Settings](settings/magnet-thirds-and-sixths.png)
![Magnet Settings](settings/magnet-others.png)

### Alfred Settings and Snippets

- Open Alfred and Skip Setup
- Open System Preferences -> Keyboard -> Shortcuts -> Spotlight
  - Unheck both checkboxes
- Go back to Alfred and set hotkey to cmd+space
- Click on Powerpack and then "Activate License"
  - Find license key in email
- Go to Advanced and under Syncing click 'Set prefences folder..."
  - Choose `~/Dropbox/Alfred/`
- Go to Features -> Clipboard and check all of the clipboard history options

### Mac Settings

- Install Flipqlo Clock Screen Saver `~/dotfiles/installers/Fliqlo.dmg`
- Install TrackballWorks `~/dotfiles/installers/TrackballWorks.dmg`
  ![TrackballWorks Settings](settings/trackballworks.png)
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

### iTerm2 Sync Settings

- Preferences -> General -> Preferences
- Check both checkboxes and set path to `/Users/{username}/dotfiles/profiles/iterm`

### hyperswitch

![Hyperswitch Settings](settings/hyperswitch-settings.png)

### Iris

- Buy new license or transfer license by signing in to [User Panel](https://iristech.co/custom-code/user-panel/pages/my_licenses.php)
- Use installer for in specific iris version in `/installers/*`
  ![Iris Settings](settings/iris-blue-light.png)
  ![Iris Settings](settings/iris-brightness.png)
  ![Iris Settings](settings/iris-location.png)
  ![Iris Settings](settings/iris-sleep.png)
  ![Iris Settings](settings/iris-fonts.png)
- ~~Go to Advanced -> Hidden Features~~
- ~~Type in `import` and choose `/Users/{username}/dotfiles/profiles/iris.iris_settings`~~

### VSCode

- Install "Settings Sync" in VSCode
- In 1Password go to Github and copy token `vs-code-setting-sync-token` and gistID `vscode-sync-gist`
- In VSCode open command palette (`command + shift + p`) and then type `Sync: Download Settings`
- Enter token and gistId
- Restart VSCode

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

- Run `ssh-add -K ~/.ssh/id_rsa` to asdd your SSH private key to the ssh-agent and store your passphrase in the keychain
- Get SSH Key by running `pbcopy < ~/.ssh/id_rsa.pub`
- Paste in Github SSH Key field

### Vim

- Open vim and run `:PlugInstall`

### Brave

- Import from Chrome

### Home Inventory

- Open `iCloud Drive/Home Inventory/My_Stuff.hi3`
- Update Backup Settings
  ![Home Inventory Settings](settings/home-inventory-settings.png)
- Run by double clicking `~/dotfiles/installers/Send-to-Home-Inventory.workflow`
- Run `git co settings`

### Atom

- In 1Password go to Github and copy token `atom-setting-sync-personal-token` and gistID `atom-setting-sync-gist`
- Edit `Config.json` by adding

```json
    "sync-settings":
    gistId: "{your_gist_id}"
    personalAccessToken: "{your_token}"
```

- Open Command Palette and run `sync-settings:restore`
