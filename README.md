# dotfiles

Nix-based dotfiles managed via [home-manager](https://github.com/nix-community/home-manager), supporting both Linux (NixOS/nixpkgs) and macOS (nix-darwin).

## Structure

```
flake.nix           # Entry point — flake inputs, outputs, platform configs
home.nix            # Shared home-manager module imports
linux.nix           # Linux-specific: Hyprland, kanshi
darwin.nix          # macOS-specific: nix-darwin system config
modules/            # Home-manager modules
  zsh.nix           # Zsh, oh-my-zsh, aliases, env vars
  git.nix           # Git config, signing
  gpg.nix           # GPG agent
  firefox.nix       # Firefox policies
  editors.nix       # Helix, VS Code
  shell.nix         # General shell tools (bat, eza, fd, ripgrep, etc.)
  dev.nix           # Dev tooling (Go, Docker, Terraform, etc.)
  kubernetes.nix    # kubectl, helm, krew plugins
  hyprland.nix      # Hyprland WM, waybar, keybinds (Linux only)
  kanshi.nix        # Autorandr-style display management (Linux only)
  gui.nix           # GUI apps (keepassxc, slack, spotify, etc.)
  yazi.nix          # Yazi file manager
  packages.nix      # Misc CLI packages
  cloud.nix         # Cloud CLIs (gcloud, azure, aws, openstack)
  lsp.nix           # LSP servers
  ai.nix            # OpenCode config + ECC upstream integration
  obsidian.nix      # Obsidian vault, plugins, templates
  sops.nix          # sops-nix pre-configuration
  obsidian/         # Obsidian skill overrides, quickadd data, templates
overlays/           # Nixpkgs overlays for custom packages
  default.nix       # Overlay compositor
  helm.nix          # helm plugins (secrets, diff, etc.)
  helmfile.nix      # helmfile
  cidr.nix          # cidr CLI
  openstack-tui.nix # OpenStack TUI
scripts/            # Utility scripts
  git-daily-summary.sh
  obsidian-weekly.sh
  check-updates.py
```

## Usage

### First-time setup

```bash
# Linux
home-manager switch --flake .#hani

# macOS
nix run nix-darwin -- switch --flake .#Mac
```

### Subsequent updates

```bash
home-manager switch --flake .#hani
```

### Update flake inputs

```bash
nix flake update
```

## Secrets

[sops-nix](https://github.com/Mic92/sops-nix) is pre-configured for managing secrets. To use it:

```bash
# Generate an age key from your SSH key
mkdir -p ~/.config/sops/age
ssh-to-age < ~/.ssh/id_ed25519.pub > ~/.config/sops/age/keys.txt

# Create an encrypted secrets file
sops secrets.yaml

# Add secrets to modules/sops.nix:
#   sops.secrets.my-key = { };
#
# Reference in other modules:
#   config.sops.secrets.my-key.path
```

Secrets are decrypted at build time — no plaintext secrets in the repo.

## Modules

Modules are imported from `home.nix`. Each module is self-contained and handles a specific domain. The `ai.nix` module pulls in [Everything Claude Code](https://github.com/affaan-m/everything-claude-code) as an upstream for OpenCode skills, agents, and config.
