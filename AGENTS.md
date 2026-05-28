# Dotfiles — Home Manager + nix-darwin

Cross-platform Nix config for Linux (home-manager) and macOS (nix-darwin). Opinionated setup with Hyprland, dev tooling, opencode/ECC, and Obsidian vault management.

## Quick Reference

```bash
nix run home-manager -- switch --flake .#hani   # Linux activation
nix run nix-darwin -- switch --flake .#Mac       # macOS activation
nix flake check                                    # Validate (after git add)
nix fmt                                            # Format all Nix files
nix run nixpkgs#nixfmt -- --check flake.nix home.nix linux.nix darwin.nix $(find modules -name '*.nix') overlays/*.nix
nix run nixpkgs#shellcheck -- scripts/*.sh        # ShellCheck
```

## Architecture

### Module Structure

`imports` MUST be at the top level of a module, never inside `config`, `options`, or any `lib.mkIf` wrapper.

- `modules/options.nix` — unified options with `lib.mkEnableOption`
- `modules/dev/` — development tools, LSP, cloud, kubernetes, opencode/ECC
- `modules/shell/` — zsh, git, GPG, shell utilities
- `modules/desktop/` — Hyprland, kanshi, GUI packages
- `modules/apps/` — Obsidian, editors, firefox, yazi, misc packages
- `overlays/` — split by domain (helm, openstack-tui, etc.), composed via `default.nix`
- `scripts/` — utility scripts (ecc-skills.sh, check-updates.py)

### Module Pattern

```nix
{ lib, config, pkgs, ... }: {
  imports = [ ./options.nix ];    # imports at top level only
  config = lib.mkIf config.dotfiles.<group>.<module>.enable {
    # module content
  };
}
```

### Platform Guards

- GUI apps wrapped with nixGL: guard both `enable` and `package` with `pkgs.stdenv.isLinux`
- `nix.package` in home-manager: `lib.mkIf pkgs.stdenv.isLinux pkgs.nix` (macOS uses nix-darwin's)
- macOS vs Linux: use `pkgs.stdenv.isLinux` / `pkgs.stdenv.isDarwin`

### Build Targets

- Linux: `.#homeConfigurations.hani.activationPackage`
- macOS: `.#darwinConfigurations.Mac.system`

## Secrets (sops-nix)

- NEVER hardcode secrets in `.nix` files (no API keys, tokens, passwords, emails, project IDs)
- ALWAYS use sops-nix with encrypted `secrets.yaml`
- Before committing: check `rg '(sk-|-----BEGIN|GCP_PROJECT|api_key|password)' --include='*.nix' .`
- Password manager entries (rbw, pass) are sacred — never delete without asking
- `.sops.yaml` at repo root documents key config
- Exclude `secrets.yaml` from all YAML formatters

### Adding a Secret

```bash
sops secrets.yaml
```

Then in a module:
```nix
sops.secrets.<name> = {};
```

Access via `config.sops.secrets.<name>.path`.

## CI/CD

- `.github/workflows/ci.yml` — builds Linux + macOS, runs nixfmt check, flake check, shellcheck
- `.github/workflows/update-check.yml` — automated flake update PRs
- Cachix push on main (skip on PRs): `vomba.cachix.org`
- nixfmt with recursive globs: use `$(find modules -name '*.nix')` (macOS bash 3.x)

## Pre-Commit

```bash
pre-commit install   # must be run once after cloning
```

Hooks: prettier (YAML, excluding secrets.yaml), trailing-whitespace, end-of-file-fixer, gitleaks, nixfmt (auto-fixes).

## OpenCode / ECC Integration

- Config in `modules/dev/ai.nix`
- OpenCode declarative config at `programs.opencode.settings`
- ECC tarball from npm: `ecc-universal-2.0.0-rc.1.tgz`
- Agent model overrides: reviewers → deepseek-v4-pro, builders → deepseek-v4-flash
- MCP servers: context7, codegraph, obsidian-mcp-server
- Plugin hooks: ECC compiled hooks + observation plugin for continuous-learning
- Skills: 43 loaded (tdd-workflow, golang-patterns, postgres-patterns, etc.) + obsidian-second-brain (on-demand)
- Commands: 62 total (36 ECC + 26 obsidian vault ops)

### MCP Gotchas

- opencode.json `env` config does NOT pass env vars to child processes — bake env vars into wrapper scripts via `pkgs.writeShellScriptBin`
- obsidian-mcp-server v3+ uses HTTPS (self-signed cert), test with `curl -sk`

## Obsidian Vault

- Path: `~/.vault`
- MCP via `obsidian-mcp-server` (v3.2.2, 14 tools)
- AI-first rules in `.vault/_CLAUDE.md`
- Vault ops via obsidian-second-brain skill + 26 `/obsidian-*` commands

## Git Conventions

- Separate commits for separate changes — commit each logical change individually
- Conventional commits: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`, `perf:`
- GPG-signed commits; if signing fails with "gpg-agent is older than us": `gpgconf --kill all`

## Overlays

- Split by domain (helm, openstack-tui, etc.), not by target
- Compose via set merge (`//`) in `overlays/default.nix`
- One overlay file per domain

## Flake

- `inputs`: nixpkgs (unstable), nixpkgs-stable (25.11), home-manager, nix-darwin, nixGL, nix-index-database, NUR, ecc-universal, obsidian-plugins, obsidian-second-brain (v0.8.0), sops-nix
- `allowUnfree = true`
- Dedicated `devShells` with nixfmt + pre-commit + shellcheck for Linux and macOS
