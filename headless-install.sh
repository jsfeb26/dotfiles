#!/bin/bash
#
# headless-install.sh
#
# Terminal-only setup for a headless Linux box (EC2, container, remote dev
# machine). This is the Linux counterpart to osx-install.sh — same shell
# workflow, none of the GUI: no app installs, no Finicky, no Raycast, no fonts,
# no iTerm profiles, no Docker/Postgres/Mongo.
#
# Distros: Debian/Ubuntu (apt) and Amazon Linux/RHEL/Fedora (dnf/yum).
# Assumes this repo is cloned to ~/dotfiles.
#
# Usage: bash ~/dotfiles/headless-install.sh
#

set -uo pipefail

DOTFILES="$HOME/dotfiles"
LOCAL_BIN="$HOME/.local/bin"   # .zshrc already puts this on PATH

banner() { printf "\e[42m %s \e[0m\n" "$1"; }
warn() { printf "\e[43m %s \e[0m\n" "$1"; }

if [ ! -d "$DOTFILES" ]; then
  echo "Error: expected dotfiles repo at $DOTFILES"
  exit 1
fi

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "Error: this script is for Linux. On macOS use osx-install.sh."
  exit 1
fi

mkdir -p "$LOCAL_BIN"
export PATH="$LOCAL_BIN:$PATH"

# Most boxes run as a sudo-capable non-root user; containers often run as root.
if [ "$(id -u)" -eq 0 ]; then
  SUDO=""
else
  SUDO="sudo"
fi

# uname -m -> the two naming conventions used by release tarballs
case "$(uname -m)" in
  x86_64|amd64) ARCH_GNU="x86_64"; ARCH_GO="amd64" ;;
  aarch64|arm64) ARCH_GNU="arm64"; ARCH_GO="arm64" ;;
  *) echo "Error: unsupported architecture $(uname -m)"; exit 1 ;;
esac

# =========================== Distro packages ================================

banner "Installing base packages"

# Common set. Names below are overridden per-distro where they differ.
PKGS=(zsh git curl wget tmux vim tree jq unzip tar gzip less perl python3 \
      ca-certificates figlet xclip bat)

if command -v apt-get >/dev/null 2>&1; then
  PKG_MGR="apt"
  export DEBIAN_FRONTEND=noninteractive
  $SUDO apt-get update -y
  $SUDO apt-get install -y build-essential python3-pip neovim ack "${PKGS[@]}"
elif command -v dnf >/dev/null 2>&1 || command -v yum >/dev/null 2>&1; then
  PKG_MGR="$(command -v dnf >/dev/null 2>&1 && echo dnf || echo yum)"
  $SUDO "$PKG_MGR" install -y gcc make python3-pip "${PKGS[@]}"
  # Not in the default Amazon Linux repos — skip rather than fail the install.
  $SUDO "$PKG_MGR" install -y neovim ack || warn "neovim/ack unavailable in repos — skipped"
else
  echo "Error: no supported package manager found (need apt, dnf, or yum)"
  exit 1
fi

# Debian/Ubuntu ship bat as `batcat` to avoid a name clash
if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
  ln -sf "$(command -v batcat)" "$LOCAL_BIN/bat"
fi

# =========================== GitHub release binaries ========================

# Download a GitHub release tarball and drop a single binary into ~/.local/bin.
#   install_gh_release <repo> <binary> <asset-name-template>
# The template may use {v} for the version (no leading "v").
install_gh_release() {
  local repo="$1" bin="$2" template="$3"
  local version asset tmp found

  version="$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" \
    | grep -m1 '"tag_name"' | sed -E 's/.*"v?([^"]+)".*/\1/')"
  if [ -z "$version" ]; then
    warn "Could not resolve latest version for $repo — skipping $bin"
    return 1
  fi

  asset="${template//\{v\}/$version}"
  tmp="$(mktemp -d)"
  if ! curl -fsSL "https://github.com/$repo/releases/download/v$version/$asset" \
       | tar -xz -C "$tmp"; then
    warn "Failed to download $asset — skipping $bin"
    rm -r "$tmp"
    return 1
  fi

  found="$(find "$tmp" -type f -name "$bin" | head -1)"
  if [ -z "$found" ]; then
    warn "Binary '$bin' not found in $asset — skipping"
    rm -r "$tmp"
    return 1
  fi

  install -m 755 "$found" "$LOCAL_BIN/$bin"
  rm -r "$tmp"
  echo "  installed $bin $version"
}

banner "Installing gh (GitHub CLI)"
command -v gh >/dev/null 2>&1 || \
  install_gh_release cli/cli gh "gh_{v}_linux_${ARCH_GO}.tar.gz"

banner "Installing gum (interactive prompts used by scripts/*.zsh)"
command -v gum >/dev/null 2>&1 || \
  install_gh_release charmbracelet/gum gum "gum_{v}_Linux_${ARCH_GNU}.tar.gz"

banner "Installing diff-so-fancy (git pager configured in .gitconfig)"
if ! command -v diff-so-fancy >/dev/null 2>&1; then
  curl -fsSL -o "$LOCAL_BIN/diff-so-fancy" \
    https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy
  chmod +x "$LOCAL_BIN/diff-so-fancy"
fi

# =========================== Prompt / history / fuzzy find ==================

banner "Installing starship prompt"
command -v starship >/dev/null 2>&1 || \
  curl -sS https://starship.rs/install.sh | sh -s -- --yes --bin-dir "$LOCAL_BIN"

# Distro fzf is usually too old for `fzf --zsh` (needs >= 0.48), which .zshrc
# calls unconditionally — so install from source and link the binary.
banner "Installing fzf"
if [ ! -d "$HOME/.fzf" ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
fi
"$HOME/.fzf/install" --bin
ln -sf "$HOME/.fzf/bin/fzf" "$LOCAL_BIN/fzf"

banner "Installing atuin for terminal history"
# The official installer creates ~/.atuin/bin/env, which .zshrc sources.
command -v atuin >/dev/null 2>&1 || \
  curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh

banner "Installing Antigen for managing zsh plugins"
[ -f "$HOME/antigen.zsh" ] || curl -fsSL git.io/antigen > "$HOME/antigen.zsh"

# =========================== Node + npm globals =============================

banner "Installing node via NVM"
if [ ! -d "$HOME/.nvm" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
fi
export NVM_DIR="$HOME/.nvm"
# shellcheck disable=SC1091
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install stable
nvm alias default stable

banner "Installing npm global tools"
# pnpm and bun go through npm rather than their curl installers: the official
# scripts append PATH lines to ~/.zshrc, which is a symlink into this repo.
npm install -g pnpm bun tldr ccusage @openai/codex@latest

banner "Installing uv (python package manager)"
# INSTALLER_NO_MODIFY_PATH keeps it from editing shell rc files (see above)
command -v uv >/dev/null 2>&1 || \
  curl -LsSf https://astral.sh/uv/install.sh | INSTALLER_NO_MODIFY_PATH=1 sh

banner "Installing Claude Code"
# native install to avoid multiple instances based on which node version
command -v claude >/dev/null 2>&1 || curl -fsSL https://claude.ai/install.sh | bash
# Create the config dir up front so the custom-commands symlink below works
mkdir -p "$HOME/.claude"

# =========================== vim-plug =======================================

banner "Installing vim-plug"
curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# =========================== Symlinks =======================================
# Done last, so that any installer above that appends to ~/.zshrc writes to a
# throwaway file instead of dirtying profiles/.zshrc in the repo.

banner "Symlinking profiles"
mkdir -p "$HOME/.config"

link() {
  local src="$1" dest="$2"
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    rm -r "$dest"
  fi
  ln -s "$src" "$dest"
}

link "$DOTFILES/profiles/.zshrc"            "$HOME/.zshrc"
link "$DOTFILES/profiles/.vimrc"            "$HOME/.vimrc"
link "$DOTFILES/profiles/.gitignore_global" "$HOME/.gitignore_global"
link "$DOTFILES/profiles/.tmux.conf"        "$HOME/.tmux.conf"
link "$DOTFILES/profiles/.tmux.conf.local"  "$HOME/.tmux.conf.local"
link "$DOTFILES/.config/starship.toml"      "$HOME/.config/starship.toml"
link "$DOTFILES/claude/custom-commands"     "$HOME/.claude/custom-commands"

cp "$DOTFILES/claude/custom-commands/.labs.example" "$HOME/.claude/custom-commands/.labs"

# Scripts are sourced by .zshrc and referenced by .gitconfig aliases via
# absolute path, so they only need to be executable — no symlink required.
chmod +x "$DOTFILES"/scripts/*

# ~/.gitconfig is a real file that includes the repo one, then overrides the two
# macOS-only settings. A plain symlink would break commits (the commit template
# points at /Users/jasonstinson) and auth (osxkeychain doesn't exist on Linux).
banner "Writing ~/.gitconfig (includes profiles/.gitconfig)"
cat > "$HOME/.gitconfig" <<GITCONFIG
# Generated by headless-install.sh — edit profiles/.gitconfig instead.
[include]
	path = ~/dotfiles/profiles/.gitconfig

# Linux overrides for macOS-specific values in profiles/.gitconfig
[credential]
	# credential.helper is a list, so the empty value is required to drop
	# osxkeychain — otherwise git still tries to run it and errors out
	helper =
	helper = cache --timeout=86400
[commit]
	template = ~/dotfiles/profiles/.gitmessage
GITCONFIG

# =========================== Default shell ==================================

ZSH_PATH="$(command -v zsh)"
if [ -n "$ZSH_PATH" ]; then
  banner "Setting zsh as default shell"
  grep -qs "^$ZSH_PATH$" /etc/shells || echo "$ZSH_PATH" | $SUDO tee -a /etc/shells >/dev/null
  # sudo form avoids the password prompt on cloud images where the login user
  # has no password set
  $SUDO chsh -s "$ZSH_PATH" "$(id -un)" \
    || warn "chsh failed — set your login shell to $ZSH_PATH manually"
fi

# =========================== Post-install notes =============================

# The repo .zshrc hardcodes a few /Users/jasonstinson paths. They're all in
# guarded blocks or unused functions on Linux, but flag the ones that matter.
echo
banner "Remaining manual steps"
echo "  - Open a new shell — antigen installs the zsh plugins on first run"
echo "  - atuin login -u jsfeb26     (prompts for password + key)"
echo "  - gh auth login"
echo "  - git credentials use 'cache'; swap for a PAT or SSH key if you prefer"
echo
echo "Known no-ops on Linux (harmless, only fail if invoked):"
echo "  - dotfiles / ccbrain / design-starter aliases (need cursor, Dropbox)"
echo "  - PNPM_HOME, ANDROID_HOME, .zfunctions paths in .zshrc"

command -v figlet >/dev/null 2>&1 && figlet "Great Success!!!"
