# Module Reference

Detailed documentation for each module category.

## Profiles (`modules/profiles/`)

### user.nix
User-specific configuration that was previously hardcoded in modules.

**Options:**
- `enable` - Enable user profile
- `email` - Primary email for git commits
- `name` - Full name for git commits
- `gpgKeyId` - GPG key ID for commit signing
- `githubUsername` - GitHub username
- `workEmail` - Work email address
- `workGcpProject` - GCP project ID

**Usage:**
Set in `home.nix` or host-specific config:
```nix
profiles.user = {
  enable = true;
  email = "you@example.com";
  name = "Your Name";
  gpgKeyId = "ABC123DEF456";
};
```

## Core (`modules/core/`)

### packages.nix
System packages installed via Home Manager.

### shell.nix
Shell utilities configuration:
- fzf - Fuzzy finder
- bat - Cat clone
- zoxide - Smarter cd
- eza - Modern ls
- starship - Prompt

### zsh.nix
Zsh configuration including:
- Oh-My-Zsh setup
- Session variables (GOPATH, KREW_ROOT)
- Shell aliases

## Dev (`modules/dev/`)

### git.nix
Git configuration using profile settings:
- GPG signing
- User identity
- SSH URL rewriting

### editors.nix
Editor configurations (Neovim, Helix, etc.)

### lsp.nix
Language Server Protocol configurations.

### dev.nix
Development environment settings.

## Desktop (`modules/desktop/`)

### hyprland/
Hyprland window manager configuration split into:

#### hyprland/default.nix
Main entry point. Imports all submodules.

#### hyprland/core.nix
- Keybinds (window management, workspaces, screenshots)
- Window rules
- General settings
- Input configuration
- Environment variables

#### hyprland/waybar.nix
Status bar configuration with modules:
- Workspaces
- Clock
- Network
- Battery
- Audio
- Backlight

#### hyprland/applications.nix
- Swaylock (screen lock)
- Hypridle (idle management)
- Fuzzel (application launcher)

#### hyprland/environment.nix
- GTK theme (Nordic)
- Cursor theme
- XDG portal configuration

### gui.nix
GUI applications configuration.

### firefox.nix
Firefox user.js and extension configuration.

### kanshi.nix
Display configuration for multi-monitor setups.

## Security (`modules/security/`)

### gpg.nix
GPG agent configuration:
- SSH integration
- Pinentry settings
- Shell initialization

### secrets.md
Guide for setting up sops-nix for secrets management.

## Cloud (`modules/cloud/`)

### kubernetes.nix
Kubernetes configuration (kubectl, kubie, etc.)

### cloud.nix
Cloud provider CLI configurations.

## AI (`modules/ai/`)

### ai.nix
AI tool configurations (Claude CLI, Gemini CLI, etc.)

## CLI (`modules/cli/`)

### yazi.nix
Yazi file manager configuration.
