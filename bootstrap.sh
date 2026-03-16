#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./bootstrap.sh --profile personal|studio|devbox

Bootstraps this repo with chezmoi.

Examples:
  ./bootstrap.sh --profile personal
  ./bootstrap.sh --profile studio
  ./bootstrap.sh --profile devbox
EOF
}

check_xcode_tools() {
  if xcode-select -p &>/dev/null; then
    return 0
  fi

  echo "Xcode Command Line Tools are required but not installed." >&2
  echo "Run the following command, complete the installation, then re-run this script:" >&2
  echo "" >&2
  echo "  xcode-select --install" >&2
  exit 1
}

check_ssh_github() {
  if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    return 0
  fi

  # SSH check failed — try loading key from keychain and retry
  if [[ -f "${HOME}/.ssh/id_ed25519" ]]; then
    if [[ -z "${SSH_AUTH_SOCK:-}" ]]; then
      eval "$(ssh-agent -s)" >/dev/null 2>&1 || true
    fi
    ssh-add --apple-use-keychain "${HOME}/.ssh/id_ed25519" 2>/dev/null || true
    if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
      return 0
    fi
  fi

  echo "GitHub SSH access is required but not configured." >&2
  echo "Set up SSH keys before running bootstrap. See docs/ssh-setup.md or:" >&2
  echo "" >&2
  echo "  1. ssh-keygen -t ed25519 -C \"your-github-email@example.com\"" >&2
  echo "  2. eval \"\$(ssh-agent -s)\"" >&2
  echo "  3. ssh-add --apple-use-keychain ~/.ssh/id_ed25519" >&2
  echo "  4. Add the public key to https://github.com/settings/keys" >&2
  echo "  5. Verify: ssh -T git@github.com" >&2
  exit 1
}

ensure_homebrew_in_path() {
  if command -v brew >/dev/null 2>&1; then
    return 0
  fi

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv bash)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv bash)"
  fi
}

ensure_dependencies() {
  local os
  os="$(uname -s)"

  case "$os" in
    Darwin)
      check_xcode_tools
      check_ssh_github

      # Install Homebrew if missing
      if ! command -v brew >/dev/null 2>&1; then
        ensure_homebrew_in_path
      fi
      if ! command -v brew >/dev/null 2>&1; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        ensure_homebrew_in_path
      fi

      # Install chezmoi if missing
      if ! command -v chezmoi >/dev/null 2>&1; then
        brew install chezmoi
      fi
      ;;
    Linux)
      if command -v chezmoi >/dev/null 2>&1; then
        return 0
      fi

      local apt_installed=false
      if command -v apt-get >/dev/null 2>&1; then
        if command -v sudo >/dev/null 2>&1; then
          sudo apt-get update
          if sudo apt-get install -y chezmoi; then
            apt_installed=true
          fi
        else
          apt-get update
          if apt-get install -y chezmoi; then
            apt_installed=true
          fi
        fi
      fi

      if [[ "$apt_installed" == false ]]; then
        sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "${HOME}/.local/bin"
        export PATH="${HOME}/.local/bin:${PATH}"
      fi
      ;;
    *)
      echo "Unsupported OS: ${os}" >&2
      exit 1
      ;;
  esac
}

main() {
  local profile=""
  local repo_root

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --profile)
        profile="${2:-}"
        shift 2
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        echo "Unknown argument: $1" >&2
        usage >&2
        exit 1
        ;;
    esac
  done

  if [[ -z "$profile" ]]; then
    echo "Error: --profile is required." >&2
    echo "Valid values: personal, studio, devbox" >&2
    echo "" >&2
    usage >&2
    exit 1
  fi

  case "$profile" in
    personal|studio|devbox) ;;
    *)
      echo "Error: invalid profile '${profile}'." >&2
      echo "Valid values: personal, studio, devbox" >&2
      exit 1
      ;;
  esac

  repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  ensure_dependencies

  # Write chezmoi config with the selected profile
  local chezmoi_config_dir="${HOME}/.config/chezmoi"
  mkdir -p "$chezmoi_config_dir"
  cat > "${chezmoi_config_dir}/chezmoi.toml" <<TOML
[data]
    profile = "${profile}"
TOML

  # Remove stale chezmoi source so init always copies the current repo
  local chezmoi_source="${HOME}/.local/share/chezmoi"
  if [[ -d "$chezmoi_source" ]]; then
    rm -rf "$chezmoi_source"
  fi

  chezmoi init --apply "$repo_root"

  echo ""
  echo "Bootstrap complete! Start a new shell session to pick up all changes:"
  echo ""
  echo "  exec zsh -l"
}

main "$@"
