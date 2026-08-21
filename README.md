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

---

## Headless Linux Install (EC2, containers, remote dev boxes)

`headless-install.sh` is the Linux counterpart to `osx-install.sh` — terminal
workflow only. No GUI apps, Finicky, Raycast, fonts, iTerm profiles, or
Docker/Postgres/Mongo. Supports Debian/Ubuntu (apt) and Amazon Linux/RHEL/Fedora
(dnf/yum).

```bash
git clone git@github.com:jsfeb26/dotfiles.git ~/dotfiles   # must be ~/dotfiles
bash ~/dotfiles/headless-install.sh
exec zsh -l
```

The box gets the `amber` starship palette instead of `blue`, so it can't be
mistaken for the Mac at a glance. Switch schemes by changing the single
`palette = ...` line in `.config/starship.toml`; the per-machine override lives
in the generated `~/.zshenv`.

Still worth doing by hand afterwards: `gh auth login` (separate from your SSH
key — `gh` needs its own API token).

## Troubleshooting — Headless Linux

### Autosuggestions aren't showing

**Symptom:** typing `git` no longer shows the rest of your most recent matching
command as grey ghost text, and right-arrow doesn't fill it in. Confirm with:

```bash
type _zsh_autosuggest_start   # "not found" means the plugin never loaded
antigen list                  # "You don't have any bundles" is the tell
```

**Cause:** antigen installs its plugins by running `git clone` on the first
interactive zsh login. If git is broken or the network fails at that moment,
every clone fails, antigen leaves partial state in `~/.antigen`, and it never
retries. Later logins then come up silently with no plugins — no error at all,
which makes it look unrelated to whatever originally failed.

**Fix:**

```bash
rm -rf ~/.antigen
zsh -lic 'antigen list'    # should list 11 bundles and exit in ~10s
exec zsh -l
```

Antigen has no self-repair: once its state is partial it stays partial. Any
"plugin is installed but isn't loading" symptom starts here.

### Every git command fails with `bad boolean config value 'simple'`

**Symptom:** `fatal: bad boolean config value 'simple' for 'branch.autosetupmerge'`
on *every* git command — which also silently breaks antigen (above), since its
bundle installs are git clones.

**Cause:** `profiles/.gitconfig` sets `branch.autoSetupMerge = simple`, which
requires git >= 2.37. Ubuntu 22.04 ships 2.34 and 20.04 ships 2.25.

Overriding the value in `~/.gitconfig` does **not** work. Git runs its config
callback on every occurrence of a key in file order, so it dies parsing `simple`
from the include before it ever reaches a later override. The key has to be
absent, not overridden.

**Fix — upgrade git:**

```bash
sudo add-apt-repository -y ppa:git-core/ppa
sudo NEEDRESTART_MODE=a apt-get update -y
sudo NEEDRESTART_MODE=a apt-get install -y git
git config --global --unset branch.autoSetupMerge   # if a workaround was added
```

On distros without the `git-core` PPA, `headless-install.sh` writes
`~/.gitconfig.compat` — a snapshot of `profiles/.gitconfig` with the unsupported
keys stripped — and includes that instead. It does not track later edits to the
repo config, so upgrade git and rerun the script to get rid of it.

### `command not found: starship` / `fzf` on login

**Symptom:** `.zshrc:21: command not found: starship`, `.zshrc:22: command not
found: fzf`, and the default zsh prompt instead of the powerline one.

**Cause:** `.zshrc` calls `starship init` and `fzf --zsh` near the top but only
adds `~/.local/bin` to `PATH` around line 148. On macOS that's fine — brew's bin
is already on `PATH` via `.zprofile` — but on Linux these tools live in
`~/.local/bin`, so they're invisible for the first ~127 lines.

**Fix:** `PATH` has to be set before `.zshrc` runs. `headless-install.sh`
generates `~/.zshenv` for this; if it's missing:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshenv
```

Related: distro `fzf` is too old for `fzf --zsh` (needs >= 0.48 — Ubuntu 22.04
ships 0.29), so the script installs it from git into `~/.fzf`.

### Antigen clones in an endless loop and you can't get a usable login shell

**Symptom:** every SSH login floods with `Cloning into '~/.antigen/bundles/...'`
over and over, Ctrl-C doesn't escape, and new SSH sessions do the same thing
immediately.

**Cause:** a corrupt antigen cache that re-triggers a full install on every
startup and never records success. Running `antigen bundle` / `antigen apply` by
hand in an interactive shell is one way to get there.

**Fix — first get a shell that never sources `.zshrc`:**

```bash
ssh <host> -t "bash --noprofile --norc"
```

Then, from that bash shell:

```bash
pkill -9 -u "$(id -un)" zsh
pkill -9 -f 'git clone'
sudo chsh -s /bin/bash "$(id -un)"              # make logins safe while fixing
rm -rf ~/.antigen
timeout 300 zsh -lic 'antigen list'             # timeout so it can't run away
sudo chsh -s "$(command -v zsh)" "$(id -un)"    # switch back when it's clean
```

### apt opens a purple "Which services should be restarted?" dialog

**Symptom:** a `Daemons using outdated libraries` dialog blocks the install.

**Cause:** apt upgraded a shared library and `needrestart` wants to restart the
affected services. It has its own frontend and ignores `DEBIAN_FRONTEND`.

**Fix:** press `<Ok>` with the defaults unchanged. The risky services (`dbus`,
`docker`, `getty`, `systemd-logind`, `user@`) are already unchecked, and
restarting `ssh.service` will not drop your session — Ubuntu ships it with
`KillMode=process`, so only the listener is replaced.

To avoid the prompt entirely, pass `NEEDRESTART_MODE=a` (restart automatically)
or `NEEDRESTART_SUSPEND=1` (skip restarts, reboot on your own schedule). These
must go through `sudo env ...` or be set inline on the `sudo` command — `sudo`
resets the environment, so an exported var never reaches apt.

### Atuin asks to sync history during install

Not a bug, but a decision worth making deliberately. An Atuin account is a
single shared history pool — logging in with the same account as the Mac merges
both machines' history in both directions.

Choose `3) Skip sync for now`. Atuin is fully functional offline (local history,
search, up-arrow), and you can `atuin login` later. For a Linux fleet, register
a *separate* account from the Mac one and save the encryption key
(`atuin key`) — you need it to log in on a second box.
