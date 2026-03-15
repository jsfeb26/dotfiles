#!/usr/bin/env bash

set -euo pipefail

if [[ $# -gt 0 && "${1:-}" != --* ]]; then
  echo "Ignoring legacy username argument: $1"
  shift
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

exec "${repo_root}/bootstrap.sh" --profile personal "$@"
