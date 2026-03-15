#!/usr/bin/env bash

set -euo pipefail

if [[ -s "${HOME}/.nvm/nvm.sh" ]]; then
  # shellcheck disable=SC1090
  . "${HOME}/.nvm/nvm.sh"
fi

if command -v npm >/dev/null 2>&1; then
  npm install -g @openai/codex@latest ccusage
fi
