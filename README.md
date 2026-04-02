# Dotfiles

Nix-based dotfiles for Home Manager and Nix-Darwin.

## Structure

```
.
├── flake.nix              # Flake configuration
├── home.nix               # Home Manager configuration
├── darwin.nix              # Nix-Darwin configuration
├── linux.nix              # Linux-specific configuration
├── hosts/                 # Host-specific configurations
│   ├── darwin/
│   └── linux/
├── modules/               # Configuration modules
│   ├── ai/               # AI tools (Claude, etc.)
│   ├── cli/              # CLI utilities
│   ├── cloud/            # Cloud provider configs
│   ├── core/             # Core system (shell, packages, etc.)
│   ├── desktop/           # Desktop environment (Hyprland, etc.)
│   ├── dev/              # Development tools
│   ├── profiles/         # User profiles (personal settings)
│   └── security/         # Security (GPG, secrets)
├── lib/                   # Shared library functions
├── scripts/               # Utility scripts
└── overlays/              # Nix overlays
```

## Quick Start

### Apply Home Manager Config (Linux)
```bash
nix build .#homeConfigurations.hani.activationPackage
./result/activate
```

### Apply Darwin Config (macOS)
```bash
darwin-rebuild switch --flake .#Mac
```

## Security

### Credentials
- **NEVER** commit credentials or secrets to git
- Use `rbw-config.json.example` as a template
- Use `sops-nix` for encrypted secrets management

### Password Manager Integration
The `scripts/credentials-helper.bash` script retrieves cloud credentials from:
- `pass` (https://www.passwordstore.org/)
- `rbw` (https://git.zx2c4.com/rbw)

See `modules/security/secrets.md` for sops-nix setup.

## Module Organization

### Profiles (`modules/profiles/`)
User-specific configuration (email, name, GPG key, etc.):
```nix
profiles.user = {
  enable = true;
  email = "you@example.com";
  name = "Your Name";
  gpgKeyId = "YOUR_GPG_KEY_ID";
};
```

### Core (`modules/core/`)
Essential system configuration:
- `packages.nix` - System packages
- `shell.nix` - Shell configuration (fzf, bat, eza, starship)
- `zsh.nix` - Zsh configuration

### Dev (`modules/dev/`)
Development tools:
- `git.nix` - Git configuration
- `editors.nix` - Editor settings
- `lsp.nix` - LSP configuration
- `dev.nix` - Development environment

### Desktop (`modules/desktop/`)
Desktop environment:
- `hyprland/` - Hyprland window manager (split into submodules)
- `gui.nix` - GUI applications
- `firefox.nix` - Firefox configuration
- `kanshi.nix` - Display configuration

### Security (`modules/security/`)
Security tools:
- `gpg.nix` - GPG configuration
- `secrets.md` - SOPS setup guide

## Hyprland Desktop

The Hyprland configuration is split into logical modules:
- `core.nix` - Keybinds, window rules, general settings
- `waybar.nix` - Status bar configuration
- `applications.nix` - Swaylock, hypridle, fuzzel
- `environment.nix` - Theme, GTK, portals

## Adding New Modules

1. Create module file in appropriate category directory
2. Update category `default.nix` to import the new module
3. Restart home manager or rebuild

## Host-Specific Configuration

Create `hosts/linux/<hostname>.nix` or `hosts/darwin/<hostname>.nix` for machine-specific settings.
