# dotfiles

Nix-based dotfiles managed via [home-manager](https://github.com/nix-community/home-manager), supporting both Linux and macOS (nix-darwin).

## Structure

```
flake.nix              # Entry point — flake inputs, outputs, formatter
home.nix               # Shared home-manager module imports
linux.nix              # Linux-specific: Hyprland, kanshi
darwin.nix             # macOS-specific: nix-darwin system config
modules/
├── options.nix        # Enable/disable toggles for every module group
├── sops.nix           # sops-nix pre-configuration (infrastructure)
├── desktop/
│   ├── gui.nix        # Kitty, Chromium, font config
│   ├── kanshi.nix     # Display profiles (dock/undock)
│   └── hyprland/
│       ├── default.nix # WM enable, theme, portal, hypridle, fuzzel
│       ├── settings.nix # Env, keybinds, decoration, input, window rules
│       └── waybar.nix  # Waybar style + modules
├── dev/
│   ├── dev.nix        # Go, pre-commit, skopeo
│   ├── cloud.nix      # AWS, Azure, Terraform, OpenStack
│   ├── kubernetes.nix # kubectl, helm, krew, kind
│   ├── lsp.nix        # LSP servers (nixd, gopls, terraform-ls, etc.)
│   └── ai.nix         # OpenCode + Everything Claude Code upstream
├── shell/
│   ├── zsh.nix        # Zsh, oh-my-zsh, aliases, env vars
│   ├── shell.nix      # fzf, bat, zoxide, eza, starship
│   ├── git.nix        # Git config, signing
│   └── gpg.nix        # GPG agent (macOS)
└── apps/
    ├── firefox.nix     # Firefox policies, extensions, search engines
    ├── editors.nix     # Helix
    ├── yazi.nix        # Yazi file manager
    ├── packages.nix    # Misc CLI packages (gh, direnv, sops, etc.)
    └── obsidian/
        ├── default.nix # Obsidian vault, plugins, templates
        ├── plugins/    # Plugin data files (quickadd, etc.)
        ├── templates/  # Note templates
        └── vault-dirs/ # Vault directory structure
overlays/
├── default.nix        # Compositor — merges all overlays
├── languages.nix      # Language toolchain pins (swift, dotnet, marksman)
├── python.nix         # Python package patches (magnumclient, etc.)
├── cidr.nix           # CIDR CLI
├── openstack-tui.nix  # OpenStack TUI (Rust)
├── helm.nix           # Helm v4 + plugin builder
└── helmfile.nix       # Helmfile override
scripts/
├── git-daily-summary.sh
├── obsidian-weekly.sh
└── check-updates.py
```

## Usage

```bash
# Linux
home-manager switch --flake .#hani

# macOS
nix run nix-darwin -- switch --flake .#Mac

# Update all inputs
nix flake update
```

## Toggling Modules

Every module group has an enable flag in `modules/options.nix`. To disable a group, override anywhere in your config:

```nix
dotfiles.dev.cloud.enable = false;      # skip AWS, Azure, Terraform CLIs
dotfiles.apps.obsidian.enable = false;   # skip Obsidian
```

All flags default to `true`. Flags are grouped by domain:

| Option | Controls |
|--------|----------|
| `dotfiles.desktop.enable` | GUI apps, kanshi |
| `dotfiles.desktop.hyprland.enable` | Hyprland WM, waybar, hypridle |
| `dotfiles.dev.enable` | Go, pre-commit |
| `dotfiles.dev.kubernetes.enable` | kubectl, helm, kind |
| `dotfiles.dev.cloud.enable` | AWS, Azure, Terraform |
| `dotfiles.dev.lsp.enable` | LSP servers |
| `dotfiles.dev.ai.enable` | OpenCode, ECC |
| `dotfiles.shell.enable` | fzf, bat, zoxide, eza, starship |
| `dotfiles.shell.zsh.enable` | Zsh config |
| `dotfiles.shell.git.enable` | Git config |
| `dotfiles.shell.gpg.enable` | GPG agent |
| `dotfiles.apps.enable` | Misc packages (direnv, sops, etc.) |
| `dotfiles.apps.firefox.enable` | Firefox |
| `dotfiles.apps.editors.enable` | Helix |
| `dotfiles.apps.yazi.enable` | Yazi |
| `dotfiles.apps.obsidian.enable` | Obsidian |

## Adding a New Module

1. **Create the file** in the appropriate subdirectory:
   ```
   modules/dev/example.nix
   ```

2. **Wrap with its enable flag** (always use `mkIf`):
   ```nix
   { pkgs, config, lib, ... }:
   {
     config = lib.mkIf config.dotfiles.dev.example.enable {
       home.packages = [ pkgs.example ];
     };
   }
   ```

3. **Register the flag** in `modules/options.nix`:
   ```nix
   dev = {
     example = {
       enable = lib.mkEnableOption "example tool" // {
         default = true;
       };
     };
   };
   ```

4. **Add the import** to `home.nix`:
   ```nix
   ./modules/dev/example.nix
   ```

5. Run `nix flake check` and `home-manager switch --flake .#hani`.

## Adding an Overlay Package

1. Create the package file in `overlays/` (e.g. `overlays/my-tool.nix`)
2. Add it to `overlays/default.nix`:
   ```nix
   my-tool = super.callPackage ./my-tool.nix { };
   ```
3. `nix flake check` to verify.

## Secrets

[sops-nix](https://github.com/Mic92/sops-nix) is pre-configured:

```bash
mkdir -p ~/.config/sops/age
nix shell nixpkgs#age -c age-keygen > ~/.config/sops/age/keys.txt
sops secrets.yaml
```

Then add to `modules/sops.nix`:
```nix
sops.secrets.my-key = { };
```

Reference in other modules via `config.sops.secrets.my-key.path`.

## Maintenance

### CI Pipeline
`.github/workflows/ci.yml` runs on every push/PR to main:
1. **nixfmt** — format check on all `.nix` files
2. **nix flake check** — evaluation validation
3. **shellcheck** — lint all `.sh` scripts
4. **Build** — Linux (home-manager) + macOS (nix-darwin) configurations

`.github/workflows/update-check.yml` runs daily:
1. `nix flake update` + overlay version checks via `scripts/check-updates.py`
2. Builds updated config on both platforms
3. Pushes commits back to main if updates found

Builds are cached via Cachix (`vomba.cachix.org`). PRs pull from cache; pushes to main also push to cache.

### Pre-Commit Hooks
Hook management via [pre-commit](https://pre-commit.com):
```bash
# Install hooks (run once after cloning)
pre-commit install

# Run on all files to verify
pre-commit run --all-files
```

Hooks configured in `.pre-commit-config.yaml`:
| Hook | Purpose |
|------|---------|
| prettier | YAML formatting (excludes `secrets.yaml`) |
| trailing-whitespace | Trim trailing whitespace |
| end-of-file-fixer | Ensure files end with newline |
| check-yaml | Validate YAML syntax |
| check-added-large-files | Block oversized commits |
| gitleaks | Detect hardcoded secrets |
| nixfmt | Auto-format Nix files |

### Updating Dependencies
- **Flake inputs**: `nix flake update`
- **GitHub Actions**: Dependabot checks weekly
- **Pre-commit hooks**: `pre-commit autoupdate`
- **Overlay packages**: `scripts/check-updates.py --apply --yes` (pass `GITHUB_TOKEN` for higher API rate limits)
