alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias gitd='delete-branches'
alias gitstashd='delete-old-stashes'

if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
  alias bat='batcat'
fi

if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
  alias fd='fdfind'
fi
