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

install_chezmoi() {
  local os
  os="$(uname -s)"

  case "$os" in
    Darwin)
      check_xcode_tools

      # Ensure Homebrew is in PATH (needed on fresh installs or new shells)
      if ! command -v brew >/dev/null 2>&1; then
        if [[ -x /opt/homebrew/bin/brew ]]; then
          eval "$(/opt/homebrew/bin/brew shellenv bash)"
        elif [[ -x /usr/local/bin/brew ]]; then
          eval "$(/usr/local/bin/brew shellenv bash)"
        else
          /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
          eval "$(/opt/homebrew/bin/brew shellenv bash 2>/dev/null || /usr/local/bin/brew shellenv bash 2>/dev/null)"
        fi
      fi

      brew install chezmoi
      ;;
    Linux)
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
  local source_path=""

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

  if ! command -v chezmoi >/dev/null 2>&1; then
    install_chezmoi
  fi

  export CHEZMOI_PROFILE="$profile"

  source_path="$(chezmoi source-path 2>/dev/null || true)"

  if [[ -n "$source_path" && -d "$source_path/.git" ]]; then
    chezmoi apply
  else
    chezmoi init --apply "$repo_root"
  fi

  echo ""
  echo "Bootstrap complete! Start a new shell session to pick up all changes:"
  echo ""
  echo "  exec zsh -l"
}

main "$@"
