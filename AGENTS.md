# Repository Guidelines

## Project Structure & Module Organization

This repository captures macOS setup and installation. Shell installers `osx-install.sh` and `post-install.sh` live at the root for first-pass provisioning. Automation guides live in `agents/`. Persistent configs and exports are grouped by type: `profiles/` for app profiles (iTerm, Iris, etc.), `settings/` for reference screenshots, `fonts/` for bundled typefaces, `raycast/` for Raycast preferences, and `installers/` for local DMG workflows. Utility scripts that manipulate git worktrees and clean branches live in `scripts/`; treat them as the primary code surface.

## Build, Test, and Development Commands

Run `bash osx-install.sh <username>` to bootstrap a fresh machine; it links dotfiles and installs core tools. Follow with `bash post-install.sh` for post-setup automation. Git maintenance helpers are sourced via `source scripts/wtree.zsh` and `source scripts/wtmerge.zsh`; once loaded, call `wtree feature-branch` to spin up worktrees and `wtmerge feature-branch "chore: merge feature"` to merge and tidy. Use `zsh scripts/deleteOldBranches.sh` and `zsh scripts/deleteOldStashes.sh` when cleaning local git history.

## Coding Style & Naming Conventions

Shell utilities target macOS; prefer `bash` for standalone scripts and `zsh` functions when extending the interactive shell. Indent by two spaces inside blocks and guard commands with explicit error messages, matching current files. Name new scripts with kebab-case suffixed by `.sh` or `.zsh`. When editing configuration exports, keep them minimal and ASCII; binary assets belong in `installers/` or `settings/`.

## Testing Guidelines

There is no automated CI; validate changes manually. Dry-run git helpers with non-destructive targets before merging (e.g., `wtree demo-branch`). Run `shellcheck scripts/*.sh` and `zsh -n scripts/*.zsh` locally to catch syntax issues. If modifying installers or profiles, confirm the generated app behavior on a spare user account and update any affected screenshots in `settings/`.

## Commit & Pull Request Guidelines

Follow the existing history by writing short, imperative commit subjects ≤ 60 characters (e.g., `Add zsh scripts`, `Fix starship prompt styling`). Group related file updates per commit and avoid bundling installers with script tweaks. PR descriptions should list the setup steps exercised, link related issues or tasks, and note any macOS version assumptions. Include screenshots when altering `settings/` assets or significant UI instructions so future runs stay accurate.

## Security & Configuration Tips

Never commit secrets pulled from 1Password or app licenses; reference their vault items instead. Treat `installers/` as read-only binaries—replace them only with vetted sources and document checksum verification in the PR. When recording new preferences, scrub usernames from paths (`{username}`) to keep the repository portable.
