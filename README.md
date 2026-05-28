# dotfiles

Nix-based dotfiles managed via [home-manager](https://github.com/nix-community/home-manager), supporting both Linux and macOS (nix-darwin).

## Structure

```
flake.nix              # Entry point — flake inputs, outputs, formatter
AGENTS.md              # Agent-essential facts for opencode sessions
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
│   ├── dev.nix        # Go, pre-commit, skopeo, parallel
│   ├── cloud.nix      # AWS, Azure, OpenStack, Terraform/OpenTofu
│   ├── kubernetes.nix # kubectl, helm, helmfile, kind, velero, krew, kubie, popeye, crossplane, OIDC
│   ├── lsp.nix        # LSP servers (nixd, gopls, terraform-ls, nix-tree, typos-lsp, etc.)
│   └── ai.nix         # OpenCode + Everything Claude Code + obsidian-second-brain
├── shell/
│   ├── zsh.nix        # Zsh, oh-my-zsh, aliases, env vars
│   ├── shell.nix      # fzf, bat, zoxide, eza, starship
│   ├── git.nix        # Git config, signing
│   └── gpg.nix        # GPG agent (macOS)
└── apps/
    ├── firefox.nix     # Firefox policies, extensions, search engines
    ├── editors.nix     # Helix
    ├── yazi.nix        # Yazi file manager
    ├── packages.nix    # Misc CLI packages (gh, direnv, sops, act, etc.)
    └── obsidian/
        ├── default.nix # Obsidian vault, Templater, plugins, templates
        ├── plugins/    # Plugin data files (quickadd, etc.)
        ├── templates/  # Note templates
        └── vault-dirs/ # Vault directory structure
apps/
└── opencode/
    ├── homunculus/     # Continuous-learning instincts (per-project + global)
    ├── skills/         # Local skills (crossplane-e2e, helmfile-contribution, etc.)
    └── plugins/        # OpenCode plugins (ECC, observe)
overlays/
├── default.nix        # Compositor — merges all overlays
├── cidr.nix           # CIDR CLI
├── openstack-tui.nix  # OpenStack TUI (Rust)
├── helm.nix           # Helm v4 + plugin builder
└── helmfile.nix       # Helmfile override
scripts/
├── check-updates.py   # Overlay version health checks
├── ecc-skills.sh      # ECC skill discovery helper
└── git-daily-summary.sh
```

> **Overlay cleanup**: `python.nix` and `languages.nix` removed — toolchains now come from nixpkgs directly. Only CIDR, OpenStack TUI, Helm, and Helmfile remain as local overrides.

> **Script changes**: `obsidian-weekly.sh` replaced by obsidian-second-brain command automation via opencode.

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
| `dotfiles.desktop.enable` | Kitty, Chromium, font config, kanshi |
| `dotfiles.desktop.hyprland.enable` | Hyprland WM, waybar, hypridle, fuzzel |
| `dotfiles.dev.enable` | Go, pre-commit, skopeo |
| `dotfiles.dev.kubernetes.enable` | kubectl, helm, helmfile, kind, velero, krew |
| `dotfiles.dev.cloud.enable` | AWS, Azure, OpenStack, Terraform/OpenTofu, OpenStack TUI |
| `dotfiles.dev.lsp.enable` | LSP servers (nixd, gopls, terraform-ls, marksman, typos-lsp, etc.) |
| `dotfiles.dev.ai.enable` | OpenCode + Everything Claude Code |
| `dotfiles.shell.enable` | fzf, bat, zoxide, eza, fd, starship |
| `dotfiles.shell.zsh.enable` | Zsh config |
| `dotfiles.shell.git.enable` | Git config |
| `dotfiles.shell.gpg.enable` | GPG agent |
| `dotfiles.apps.enable` | Misc packages (direnv, sops, gh, etc.) |
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

> **Note**: Overlays have been simplified. `python.nix` (OpenStack Python patches) and `languages.nix` (swift/dotnet/marksman version pins) were removed — those toolchains now come from the nixpkgs channel directly. Only CIDR, OpenStack TUI, Helm v4, and Helmfile remain as local overrides. Similarly, `pkgs-stable` usage was reduced: `packages.nix`, `cloud.nix`, and `lsp.nix` now use `pkgs` (nixpkgs unstable). The `nixpkgs-stable` input still exists for kubernetes and hyprland modules.

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

**Password manager entries (rbw, pass) are sacred** — never delete without asking. These are personal secrets stores, not cache files; deletion is irreversible.

See [AGENTS.md](AGENTS.md) for agent-essential facts, module rules, CI format, and secrets conventions used by opencode sessions.

## Obsidian Vault & Second Brain

The repo manages an [Obsidian](https://obsidian.md) vault with:

- **Templater templates** (Daily Note, Weekly Review, project, resource, snippet, wiki page)
- **Vault directory structure** (00-daily through 06-archive)
- **Templater system commands** enabled (`enable_system_commands = true`) for running shell commands from templates
- **obsidian-second-brain** ([v0.8.0](https://github.com/eugeniughelbur/obsidian-second-brain)) — 26 `/` slash commands for vault operations (read, write, search, manage notes) registered as opencode commands

### OpenCode / AI Integration

The vault is accessible from opencode via:
- **Obsidian MCP server** (`obsidian-mcp-server`) — connects via the Local REST API plugin (HTTPS-based, self-signed cert). Test with `curl -sk`.
- **`OBSIDIAN_API_KEY`** baked into a `writeShellScriptBin` wrapper (not via opencode `env` — `env` in MCP config doesn't pass to child processes)
- **obsidian-second-brain skill** — loaded on demand when vault operations are needed
- **`/obsidian-*` commands** — 26 vault ops registered alongside ECC commands

> The local `obsidian-brain` skill was removed in favor of the upstream `obsidian-second-brain` from the flake input. No more dual-maintenance.

### OpenCode Continuous Learning

The `apps/opencode/homunculus/` directory stores per-project and global instincts auto-extracted from sessions:
- `instincts/personal/` — auto-learned patterns with confidence scoring
- `projects/<hash>/` — project-scoped instincts (isolated per repo)
- `evolved/` — generated skills, commands, agents from instinct clusters

Machine-local paths and `project.json` metadata are `.gitignore`d. Instinct files and evolved artifacts are tracked for cross-machine portability.

## Maintenance

### CI Pipeline
`.github/workflows/ci.yml` runs on every push/PR to main:
1. **nixfmt** — format check (uses `find` for cross-platform compat — macOS bash 3.x lacks `globstar`)
2. **nix flake check** — evaluation validation
3. **shellcheck** — lint all `.sh` scripts (via `nix run nixpkgs#shellcheck` — macOS runners don't have it pre-installed)
4. **Build** — Linux (home-manager) + macOS (nix-darwin) configurations

CI ignores `.md` changes, overlay-only changes, and `flake.lock` changes.

`.github/workflows/update-check.yml` runs daily:
1. `nix flake update` + overlay version checks via `scripts/check-updates.py`
2. Builds updated config on both platforms
3. Pushes commits back to main if updates found

Builds are cached via Cachix (`vomba.cachix.org`). PRs pull from cache; pushes to main also push to cache.
Action versions: `cachix/install-nix-action@v31`, `cachix/cachix-action@v17` (auto-bumped by Dependabot).

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

### Nix GC Configuration
- **Linux (home-manager)**: `nix.gc.dates = "weekly"` — `dates` attr supported in home-manager
- **macOS (nix-darwin)**: `nix.gc.interval = { Weekday = 0; Hour = 0; Minute = 0; }` — `nix.gc.dates` removed from nix-darwin; use `interval` instead
- Both share the same `options = "--delete-older-than 30d"` and `nix.settings` for store health

### Updating Dependencies
- **Flake inputs**: `nix flake update`
- **GitHub Actions**: Dependabot checks weekly
- **Pre-commit hooks**: `pre-commit autoupdate`
- **Overlay packages**: `scripts/check-updates.py --apply --yes` (pass `GITHUB_TOKEN` for higher API rate limits)
