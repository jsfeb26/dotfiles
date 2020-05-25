# Dev Setup

1. Download [zip](https://github.com/jsfeb26/dotfiles) and put in `~/dotfiles`
2. Run `~/dotfiles/osx-install.sh`

## Customize Settings

1. iCloud
   - Sync Desktop and Documents
2. 1password
    - Open 1password and Sign into account
3. Dropbox
4. Magnet Settings
![Magnet Settings](settings/magnet-settings.png)
5. Alfred Settings and Snippets
6. iTerm2 Sync Settings
    - Preferences -> General -> Preferences
    - Check both checkboxes and set path to `/Users/jasonstinson/dotfiles/profiles/iterm`
7. Brave
8. Chrome
9. hyperswitch
10. Iris
11. Kindle
12. Evernote
13. VSCode
    - Install "Settings Sync" in VSCode
    - In 1Password go to Github and copy token `vs-code-setting-sync-token` and gistID `vscode-sync-gist`
    - In VSCode open command palette (`command + shift + p`) and then type `Sync: Download Settings`
    - Enter token and gistId
    - Restart VSCode
14. Atom
15. Bear
16. Todoist
17. Home Inventory
18. Github
    - Add SSH Key
      - Go to https://github.com/settings/keys
      - Click "New SSH Key"
      - Get SSH Key by running `pbcopy < ~/.ssh/id_rsa.pub`
