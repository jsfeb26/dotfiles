# GitHub SSH Key Setup

> Run all terminal commands below on the **new machine** you're setting up. The GitHub steps are done in your browser.
> Full reference: [GitHub SSH setup docs](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)

**On the new machine** (Terminal):

- Generate a new key (use your GitHub account email):

  ```bash
  ssh-keygen -t ed25519 -C "your-github-email@example.com"
  ```

- Follow default prompts (accept default file location, set a passphrase)
- Start the SSH agent:

  ```bash
  eval "$(ssh-agent -s)"
  ```

- Add your key to the agent and store the passphrase in macOS Keychain:

  ```bash
  ssh-add --apple-use-keychain ~/.ssh/id_ed25519
  ```

  > `~/.ssh/config` is already in place — chezmoi generated it during bootstrap, so no need to create it manually.

- Copy the public key to clipboard:

  ```bash
  pbcopy < ~/.ssh/id_ed25519.pub
  ```

> **Note on `~/.ssh/config`:** This file is managed by chezmoi (`home/private_dot_ssh/config.tmpl`). It contains no sensitive data — just SSH behavior defaults (auto-add keys to agent, use macOS Keychain, default identity file) and an optional personal server entry. The `private_` prefix just means chezmoi sets the folder permissions to `700`. Any machine-specific or sensitive host entries should go in `~/.ssh/config.local`, which is included by the managed config but not committed to this repo.

**On GitHub** (browser):

- Go to [Github keys settings](https://github.com/settings/keys)
- Click "New SSH Key", paste the public key, save

**Back on the new machine** (Terminal):

- Verify it works:

  ```bash
  ssh -T git@github.com
  ```

- You should see: `Hi username! You've successfully authenticated...`
