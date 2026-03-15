# Chezmoi Migration

## Audit summary

### Current structure

- `osx-install.sh` is the main bootstrap script today. It installs Homebrew, a large set of CLI tools and GUI apps, copies fonts, creates `~/dev`, clones a few repos, and then force-replaces existing dotfiles with symlinks into this repo.
- `post-install.sh` is a second-stage script for a few interactive and personal tasks: set a default Node version, install global npm tools, copy Claude agents, and log into Atuin.
- Runtime shell config lives mostly in [`profiles/.zshrc`](../profiles/.zshrc). It is monolithic and mixes prompt setup, plugin loading, path edits, aliases, local-machine exports, and sourcing of repo-local helper scripts.
- Git helpers live in [`scripts/`](../scripts/). Some are already portable, but several assume macOS `date`, `pbcopy`, or the repo existing at `~/dotfiles`.
- `profiles/` also mixes true app exports (`iterm`, `iris`) with actual runtime dotfiles (`.zshrc`, `.gitconfig`, `.vimrc`, `.tmux.conf`, `.finicky.js`).

### How symlinks are handled today

- `osx-install.sh` removes existing home files with `rm` and recreates them with `ln -s`.
- The current live home directory on this Mac is still using that model:
  - `~/.zshrc -> /Users/jasonstinson/dotfiles/profiles/.zshrc`
  - `~/.gitconfig -> /Users/jasonstinson/dotfiles/profiles/.gitconfig`
  - `~/.vimrc -> /Users/jasonstinson/dotfiles/profiles/.vimrc`
  - `~/.tmux.conf -> /Users/jasonstinson/dotfiles/profiles/.tmux.conf`
  - `~/.config/starship.toml -> /Users/jasonstinson/dotfiles/.config/starship.toml`
- There is already drift in the legacy setup: `~/.gitconfig_global` points at `profiles/.gitconfig_global`, but that source file no longer exists.

### Key shell and config files

- Shell: [`profiles/.zshrc`](../profiles/.zshrc), [`scripts/wtree.zsh`](../scripts/wtree.zsh), [`scripts/wtmerge.zsh`](../scripts/wtmerge.zsh), [`scripts/wtdel.zsh`](../scripts/wtdel.zsh), [`scripts/wtpr.zsh`](../scripts/wtpr.zsh)
- Git: [`profiles/.gitconfig`](../profiles/.gitconfig), [`profiles/.gitmessage`](../profiles/.gitmessage), [`profiles/.gitignore_global`](../profiles/.gitignore_global)
- Prompt and editor: [`.config/starship.toml`](../.config/starship.toml), [`profiles/.vimrc`](../profiles/.vimrc)
- Tmux: [`profiles/.tmux.conf`](../profiles/.tmux.conf), [`profiles/.tmux.conf.local`](../profiles/.tmux.conf.local)

### macOS-specific parts

- `osx-install.sh` is almost entirely macOS-specific.
- Direct Homebrew taps, `mas install`, `~/Library/Fonts`, `pbcopy`, `reattach-to-user-namespace`, and GUI casks are all Mac-only.
- `.gitconfig` uses `credential.helper = osxkeychain`.
- `.zshrc` includes Android SDK and Java paths under macOS locations.
- Finicky and iTerm exports are desktop-macOS only.

### Linux, EC2, or WSL failure points

- Hardcoded `/Users/jasonstinson/...` paths in shell and git config.
- Runtime dependence on `~/dotfiles` existing locally.
- Worktree cleanup scripts use macOS-only `date -j -v-1m`.
- Clipboard helpers and aliases assume `pbcopy` and `pbpaste`.
- The install flow assumes GUI apps, the App Store, and a personal laptop profile.
- `oh-my-zsh` is referenced from a hardcoded path that does not currently exist on this machine.

### Machine-specific assumptions to move out of shared config

- `OBSIDIAN_SECOND_BRAIN`
- `ANDROID_HOME`
- `JAVA_HOME`
- `TMPDIR=/tmp` convex workaround
- `maintenance.repo` and `coderabbit.machineId` in git config
- Any repo-specific or workstation-specific paths under `~/dev`

## Migration plan

### Keep as-is

- `profiles/iterm/`, `profiles/iris.iris_settings`, `installers/`, `settings/`, and `agents/` should stay repo assets, not home-managed dotfiles.
- `raycast/` can stay in the repo as a legacy/reference copy during transition, but new Macs should use the managed `~/.config/raycast/...` path from `home/`.
- The existing legacy `profiles/*.zshrc` / `scripts/*.zsh` surface stays in the repo during the transition so the current symlinked Mac does not break before cutover.

### Restructure for chezmoi

- All managed home files now live under [`home/`](../home/).
- Runtime shell and git helpers move to stable home paths such as `~/.config/...` and `~/.local/bin/...` instead of depending on `~/dotfiles`.
- Shared shell config is split into small fragments:
  - `~/.config/shell/env.sh`
  - `~/.config/shell/path.sh`
  - `~/.config/shell/aliases.sh`
  - `~/.config/shell/functions.sh`
  - `~/.config/shell/tooling.sh`
  - `~/.config/zsh/interactive.zsh`
  - `~/.config/bash/interactive.bash`
- Top-level shell files stay thin:
  - `~/.profile`
  - `~/.bashrc`
  - `~/.zprofile`
  - `~/.zshrc`
- Local overrides stay unmanaged:
  - `~/.profile.local`
  - `~/.bashrc.local`
  - `~/.zshrc.local`
  - `~/.gitconfig.local`
  - `~/.tmux.conf.local`

### Package/bootstrap approach

- Use chezmoi for file management.
- Use chezmoi run scripts for idempotent package install and base tool bootstrap.
- Keep a repo-level [`bootstrap.sh`](../bootstrap.sh) as the compatibility entrypoint for cloning this repo locally and initializing chezmoi.
- Keep [`osx-install.sh`](../osx-install.sh) as a wrapper so the old habit still lands on the new flow.

### Profile model

- Default `personal` profile on macOS.
- Optional `studio` profile on macOS for the Mac Studio / agentic-coding machine.
- Default `devbox` profile on Linux.
- Allow override with `CHEZMOI_PROFILE=...` when needed.
- `personal` and `studio` currently install the same Mac package set so they can diverge later without another repo restructure.
- `devbox` includes shell, git, prompt, tmux, editors, and useful CLI tools only.

## Safest migration path for the current Mac

1. Do not delete the old `profiles/*` files before cutover. They are still the live symlink targets today.
2. Install `chezmoi` and initialize this repo into the standard source dir with `./bootstrap.sh`.
3. Review `chezmoi diff` before applying any destructive changes.
4. Back up the existing symlinked files by recording their targets.
5. Remove only the legacy symlinks you intend to replace.
6. Run `chezmoi apply`.
7. Open a new shell and verify `zsh`, `git`, `starship`, and `tmux` still behave as expected.
8. After verification, retire the old symlink-only flow.

## What should stay managed vs local

### Manage with chezmoi

- `~/.zshrc`, `~/.bashrc`, `~/.profile`, `~/.zprofile`
- `~/.gitconfig`
- `~/.config/git/commit-template`
- `~/.config/git/ignore`
- `~/.config/starship.toml`
- `~/.vimrc`
- `~/.tmux.conf`
- `~/.ssh/config`
- `~/.config/raycast/script-commands/*`
- `~/.config/raycast/nodeScripts/*`
- `~/.local/bin/*` helper scripts
- Optional `~/.finicky.js` on macOS

### Leave local/unmanaged

- Host-specific paths and exports
- Work-specific repo paths
- Any machine-specific SDK locations
- Secrets, tokens, private app state
- `~/.ssh/config.local`
- `~/.config/raycast/.env`
- Optional shell overrides and tmux/git local config

## EC2/devbox profile

### Include

- `git`, `zsh`, `tmux`, `fzf`, `ripgrep`, `fd`, `bat`, `jq`, `tree`, `wget`, `curl`, `neovim`
- Shared shell config, aliases, prompt, git config, worktree helpers
- `nvm`, `starship`, `atuin`, and `uv` when available

### Exclude

- GUI apps
- App Store installs
- macOS-only tooling
- Finicky/iTerm setup
- Local-machine-only paths, fonts, and desktop app configs

## Tmux recommendation

- Keep the starter config small:
  - `C-a` prefix
  - split panes in the current directory
  - vi keys in copy mode
  - mouse on
  - easy reload
  - optional `~/.tmux.conf.local`
- For remote SSH use:
  - `tmux new -As main`
  - detach with `Ctrl-a d`
  - reattach after reconnecting
- Do not force auto-attach by default. Keep it as an optional local snippet.

## Migration checklist

### Cutover

- Install `chezmoi`.
- Run `./bootstrap.sh`.
- Run `chezmoi diff`.
- Back up current symlink targets:
  - `~/.zshrc`
  - `~/.gitconfig`
  - `~/.vimrc`
  - `~/.tmux.conf`
  - `~/.config/starship.toml`
  - `~/.finicky.js`
- Remove those legacy symlinks.
- Run `chezmoi apply`.
- Start a fresh shell and verify `which zsh`, `git config --list --show-origin`, `tmux`, and `starship`.

### Rollback

- Remove the chezmoi-managed replacement files you just applied.
- Restore the old symlinks to `~/dotfiles/profiles/*`.
- Reopen the shell.
- If needed, run the legacy repo files directly until the migration is fixed.
