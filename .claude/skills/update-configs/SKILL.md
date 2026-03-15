---
name: update-configs
description: Update shell/system config files — aliases, functions, env vars, PATH, packages, git config, etc. — then apply via chezmoi, commit, and push. Use when the user wants to add or modify shell aliases, functions, environment variables, PATH entries, packages, tool config, or any other config file. Trigger on phrases like "add alias", "add function", "update my zshrc", "add to PATH", "install package", "change my git config", or any request that would normally require editing a config file.
allowed-tools: Read, Edit, Write, Bash, Glob, Grep
---

You are a dotfiles editor. All managed dotfiles live under `~/dotfiles/home/` and are deployed to the home directory via chezmoi.

**Input**: $ARGUMENTS

## File routing

Route changes to the correct source file based on the type of change:

| Change type | Source file in `~/dotfiles/home/` |
|---|---|
| Shell aliases | `dot_config/shell/aliases.sh` |
| Shell functions | `dot_config/shell/functions.sh` |
| Environment variables / exports | `dot_config/shell/env.sh` |
| PATH modifications | `dot_config/shell/path.sh` |
| Tool setup (nvm, starship init, atuin, etc.) | `dot_config/shell/tooling.sh` |
| Zsh interactive (plugins, completion, keybindings) | `dot_config/zsh/interactive.zsh` |
| Bash interactive | `dot_config/bash/interactive.bash` |
| Package list (Homebrew, apt, etc.) | `.chezmoidata/packages.yaml` |
| Top-level zshrc (should stay thin) | `dot_zshrc` |
| Git config | `dot_gitconfig.tmpl` |
| SSH config | `private_dot_ssh/config.tmpl` |
| Starship prompt | `dot_config/starship.toml` |
| Tmux config | `dot_tmux.conf` |
| Finicky (macOS browser router) | `dot_finicky.js` |

If the change is machine-specific or secret (tokens, personal paths, work repo paths), tell the user that it belongs in the unmanaged `.local` file (e.g. `~/.zshrc.local`, `~/.gitconfig.local`) and do not edit dotfiles.

## Steps

### 1. Read before editing

Always read the target file first so you place the change in the right spot and match the existing style.

### 2. Make the edit

Edit only the specific file(s) needed. Keep changes minimal and focused on what was asked.

### 3. Apply with chezmoi

```bash
cd ~/dotfiles && chezmoi apply
```

If this fails, stop and show the user the error. Do not attempt to commit.

### 4. Commit

Stage only the files you changed:

```bash
cd ~/dotfiles && git add <file(s)>
```

Write a concise commit message that describes the change (e.g. `add ll alias for long listing`, `export GOPATH in env.sh`, `add fzf git log function`):

```bash
cd ~/dotfiles && git commit -m "<message>"
```

### 5. Push

```bash
cd ~/dotfiles && git push
```

- **Never use `--force` or `-f`.**
- If the push fails for any reason, report the error to the user and stop. Do not retry or attempt workarounds.

## Rules

- Never edit files in `~/dotfiles/profiles/` — that is the legacy path, not the chezmoi source.
- Never commit secrets, tokens, or machine-specific paths.
- Match the existing code style and conventions in whatever file you're editing.
- If the requested change is ambiguous about which file it belongs in, pick the most specific file and briefly note why.
