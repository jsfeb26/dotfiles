#!/usr/bin/env bash

set -euo pipefail

if [[ -s "${HOME}/.nvm/nvm.sh" ]]; then
  # shellcheck disable=SC1090
  . "${HOME}/.nvm/nvm.sh"
  nvm install --lts
  nvm alias default 'lts/*'
fi

if command -v npm >/dev/null 2>&1; then
  npm install -g @openai/codex@latest ccusage
fi

cat <<'EOF'
Optional manual follow-up tasks:

- Run `atuin login -u jsfeb26` if you want Atuin sync on this machine.
- Review `.claude/` setup manually if you want Claude-specific hooks or commands on this machine.
- Open Raycast and confirm its Script Commands directory points at `~/.config/raycast/script-commands`.
- Open a new shell after Node or npm changes so completions and PATH are refreshed.
EOF
