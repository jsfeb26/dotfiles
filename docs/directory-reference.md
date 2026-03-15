# Directory Reference

| Directory / File | Purpose |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `home/`              | **Chezmoi source tree.** All managed dotfiles for new machines live here. Chezmoi maps these to `~/` using its naming conventions (`dot_zshrc` → `~/.zshrc`, `private_dot_ssh/` → `~/.ssh/`, etc.). |
| `claude/`            | **Claude Code config source.** Contains `settings.json` and `custom-commands/`. `settings.json` is symlinked to `~/.claude/settings.json` by the dotfiles setup. This is where you edit Claude Code permissions, hooks, plugins, and the status line. |
| `.claude/`           | **Claude Code skills for this repo.** Skills scoped to working inside the dotfiles project (e.g. `update-configs`). Not symlinked — Claude Code picks these up automatically when you open the repo. |
| `agents/`            | **Claude Code custom agents.** Agent definition files (`.md`) that get installed into `~/.claude/agents/`. |
| `docs/`              | **Internal documentation.** Notes that aren't home files. Currently contains `chezmoi-migration.md` — the full audit and migration plan from the old symlink setup to chezmoi. |
| `fonts/`             | **Font files to install.** Copied to `~/Library/Fonts/` during setup. Includes Dank Mono, FiraCode Nerd Font, Meslo Powerline, and a few display fonts. |
| `installers/`        | **Offline installers for apps that can't be automated.** DMG and ZIP files for Iris, Fliqlo, TrackballWorks, Bartender, CleanShot X, and Hyperkey. Referenced in the manual setup steps below. |
| `profiles/`          | **Legacy symlink setup (old track).** Contains the original `osx-install.sh` bootstrap, `post-install.sh`, and dotfiles (`.zshrc`, `.gitconfig`, `.vimrc`, `.tmux.conf`, Finicky, iTerm and Iris exports) that are still the live targets on the current Mac via symlinks. New machines should use `home/` instead. |
| `raycast/`           | **Raycast scripts (legacy copy).** Kept as a reference during transition. New machines pull Raycast scripts from the managed `~/.config/raycast/` path via `home/`. |
| `scripts/`           | **Git and worktree helper scripts.** Standalone shell scripts for branch management, worktree workflows (`wtree`, `wtmerge`, `wtdel`, `wtpr`), and other git utilities. Installed to `~/.local/bin/` via chezmoi. |
| `settings/`          | **Reference screenshots for manual Mac settings.** PNG images used in the setup guide below — Keyboard, Mouse, Dock, Mission Control, Bartender, Hyperkey, Iris, etc. Not managed files; just documentation assets. |
| `bootstrap.sh`       | **Entry point for new machines.** Installs Homebrew (if needed), installs chezmoi, and runs `chezmoi apply` with the given profile (`personal`, `studio`, or `devbox`). |
| `AGENTS.md`          | **Claude Code agent instructions.** Top-level agent context file that Claude Code reads when working in this repo. |
| `.chezmoi.toml.tmpl` | **Chezmoi config template.** Sets the profile and any machine-specific variables used during `chezmoi apply`. |
| `.chezmoiroot`       | **Tells chezmoi that `home/` is the source root.** Without this, chezmoi would treat the repo root as the source tree. |
