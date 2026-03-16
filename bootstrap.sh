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

  chezmoi init --apply "$repo_root"

  echo ""
  echo "Bootstrap complete! Start a new shell session to pick up all changes:"
  echo ""
  echo "  exec zsh -l"
}

main "$@"
