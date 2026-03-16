# Dev Setup

This repo manages dotfiles and machine setup using [chezmoi](https://chezmoi.io). It has two tracks:

- `home/` — the chezmoi-managed source tree for new machines (the active path).
- `profiles/` — the legacy safety net keeping the current symlinked Mac working until cutover.
- See [docs/directory-reference.md](docs/directory-reference.md) for a full breakdown of every directory and file in this repo.

The practical migration notes are in [docs/chezmoi-migration.md](docs/chezmoi-migration.md).


## Bootstrap

For any new machine:

1. Install Xcode Command Line Tools and wait for it to complete:

```bash
xcode-select --install
```

2. Set up GitHub SSH keys (see [docs/ssh-setup.md](docs/ssh-setup.md) for full guide):

```bash
ssh-keygen -t ed25519 -C "your-github-email@example.com"
eval "$(ssh-agent -s)"
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
pbcopy < ~/.ssh/id_ed25519.pub
# Add the key at https://github.com/settings/keys
ssh -T git@github.com  # verify it works
```

3. Clone this repo and run the bootstrap script with your profile (`personal`, `studio`, or `devbox`):

```bash
git clone git@github.com:jsfeb26/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh --profile personal   # or studio, devbox
```

The script will install Homebrew (if needed), install chezmoi, and apply all dotfiles. It checks for Xcode tools and GitHub SSH access before proceeding.

4. Open a new shell after it completes (`exec zsh -l`).

5. If you get `Zsh detects insecure completion-dependent directories` errors:

```bash
chmod 755 /usr/local/share/zsh
chmod 755 /usr/local/share/zsh/site-functions
```

## Day-to-day Workflow

### Updating shell configs (aliases, functions, env vars, etc.)

The fastest way is to open Claude Code in the dotfiles directory:

```bash
ccdotfiles
```

Then just describe what you want — "add an alias for X", "add a function that does Y", "export Z as an env var". The `update-configs` skill will route the change to the right file, run `chezmoi apply`, commit, and push automatically.

The file routing:


| What you want to change                 | File                                  |
| --------------------------------------- | ------------------------------------- |
| Shell aliases                           | `home/dot_config/shell/aliases.sh`    |
| Shell functions                         | `home/dot_config/shell/functions.sh`  |
| Environment variables / exports         | `home/dot_config/shell/env.sh`        |
| PATH modifications                      | `home/dot_config/shell/path.sh`       |
| Tool setup (nvm, starship, atuin, etc.) | `home/dot_config/shell/tooling.sh`    |
| Zsh plugins / completion / keybindings  | `home/dot_config/zsh/interactive.zsh` |
| Git config                              | `home/dot_gitconfig.tmpl`             |
| Starship prompt                         | `home/dot_config/starship.toml`       |
| Tmux config                             | `home/dot_tmux.conf`                  |


Machine-specific things (personal paths, work tokens, SDK locations) belong in the unmanaged `.local` files (`~/.zshrc.local`, `~/.gitconfig.local`, etc.) and should not be committed here.

### Adding or removing packages

Edit `home/.chezmoidata/packages.yaml`. Packages are grouped by package manager and profile:

- `brew.common` — installed on all Mac profiles
- `brew.personal` / `brew.studio` — profile-specific brew formulae
- `casks.personal` / `casks.studio` — GUI apps
- `mas.personal` / `mas.studio` — Mac App Store apps (by ID)
- `apt.common` / `apt.devbox` — Linux packages

After editing, apply and sync:

```bash
chezmoi apply
git add home/.chezmoidata/packages.yaml
git commit -m "add <package-name>"
git push
```

### Applying changes to the current machine

```bash
chezmoi apply
```

To preview what will change before applying:

```bash
chezmoi diff
```

### Pulling updates from another machine

```bash
cd ~/dotfiles && git pull && chezmoi apply
```

## Current Machine Note

The current Mac can keep using the legacy `profiles/` files until you explicitly cut it over. New machines should ignore that path and use chezmoi-managed files from `home/`.

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

- Install Flipqlo Clock Screen Saver `~/.local/share/chezmoi/installers/Fliqlo.dmg`
- Install TrackballWorks `~/.local/share/chezmoi/installers/TrackballWorks.dmg`
TrackballWorks Settings
- [Install Logitech Options](https://support.logi.com/hc/en-us/articles/360025297893)
  - Installer is located in Dropbox/Installers
  - Make bottom button open Mission Control
- Keyboard Settings
Keyboard Settings
Keyboard Modifier Keys Settings
Keyboard Shortcuts Settings
- Mouse Settings
Mouse Settings
- Energy Saver
Energy Saver Settings
- Hot Corners
Hot Corners Settings
- Mission Control
Mission Control Settings
- General
General Settings
- Dock
Dock Settings
- [Optional] set key repeat
  - macOS Tahoe and newer: `defaults write -g ApplePressAndHoldEnabled -bool false`
  - Older macOS: `defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false`
  - (`-g` is shorthand for `NSGlobalDomain`; both should work, but `-g` is the more modern form)

### Iris

- Buy new license or transfer license by signing in to [User Panel](https://iristech.co/custom-code/user-panel/pages/my_licenses.php)
  - 1.1.2 NOT USED
  - 1.1.5 Macbook Pro (Personal)
  - 1.2.0 Macbook Pro (Ambient)
- Use installer for in specific iris version in `/installers/*`
Iris Settings
Iris Settings
Iris Settings
Iris Settings
Iris Settings
- ~~Go to Advanced -> Hidden Features~~
- ~~Type in `import` and choose `~/.local/share/chezmoi/profiles/iris.iris_settings`~~

### VSCode

- Click Settings Icon in bottom left and turn `Settings Sync`
- Check all checkboxes and sign in with GitHub
- ~~Install "Settings Sync" in VSCode~~
- ~~In 1Password go to Github and copy token `vs-code-setting-sync-token` and gistID `vscode-sync-gist`~~
- ~~In VSCode open command palette (`command + shift + p`) and then type `Sync: Download Settings`~~
- ~~Enter token and gistId~~
- ~~Restart VSCode~~

### Github add SSH Key

See [docs/ssh-setup.md](../docs/ssh-setup.md) for the full setup guide.

### Warp

- Click on Settings Icon in top right
- Go to Appearance Tab
  - Change Text to FiraCode Nerd Font Mono
  - Click on Prompt and select `Shell prompt (PS1)`
  - Turn on `Dim inactive panes`

### Vim

- Open vim and run `:PlugInstall`

### Claude Code

#### Install Claude Code Damage Control

- Run `cd ~/dev/claude-code-damage-control && claude`
- Run `/install`
- Choose Global Install
- Choose to Merge into Existing Settings
- Choose Typescript and Bun setup
- Continue accepting defaults

#### Install Claude Code Agents

- Run `cd ~/dev/agents && claude`
- Run `/install` and follow the steps

### Configure Raycast

- Integrate with 1Password CLI
  - 1Password -> Settings -> Developer
- Set the Script Commands directory to `~/.config/raycast/script-commands`
- Raycast helper node scripts live in `~/.config/raycast/nodeScripts`
- Fill in `~/.config/raycast/.env` if you want the ACS login helper to work

### Configure iStat Menu

- Get License Key from 1Password
- Add Memory, Sensors, and Battery/Power
iState Menu Settings

### Configure Bartender 5

- Get License Key from 1Password
- Go to Settings -> General
  - Turn on `Start at login`
  - Turn on `Click on empty menu bar space`
  - Turn on `Show items in bar below menu bar (Bartender Bar)`
  - Change `Bartender menu bar icon` to `Bartender`
- Go to Settings -> Menu Bar Items
Bartender Menu Bar Items Settings

### Configure CleanShotX

- Get License Key from 1Password
- 

### Configure Hyperkey

Hyperkey Settings

### Configure CleanMyMac

- Sign into MacPaw account to Activate

### Configure Meeting Bar

- TODO: Add this

### iTerm2 Sync Settings

- Preferences -> General -> Preferences
- Check both checkboxes and set path to `~/.local/share/chezmoi/profiles/iterm`

### Home Inventory

- Open `iCloud Drive/Home Inventory/My_Stuff.hi3`
- Update Backup Settings
Home Inventory Settings
- Run by double clicking `~/.local/share/chezmoi/installers/Send-to-Home-Inventory.workflow`
- Run `git co settings`

