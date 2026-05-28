# Dotfiles

Cross-platform Nix config: Linux (home-manager) + macOS (nix-darwin).

## Activation

For evaluation to succeed, any new `.nix` file referenced by a module MUST be `git add`ed first — `nix flake check` silently rejects untracked files.

Always activate from the repo root (`~/.dotfiles`):

```bash
nix run home-manager -- switch --flake .#hani   # Linux
nix run nix-darwin -- switch --flake .#Mac       # macOS
nix build .#homeConfigurations.hani.activationPackage --no-link   # verify build
```

## Module Rules

- `imports` at the TOP of the module, never inside `config`/`options`/`lib.mkIf`
- Enable option: `lib.mkEnableOption` in `modules/options.nix`
- Content wraps: `lib.mkIf config.dotfiles.<group>.<module>.enable { ... }`
- Platform guard: `pkgs.stdenv.isLinux` / `pkgs.stdenv.isDarwin`
- nixGL GUI apps: guard both `enable` AND `package` with `pkgs.stdenv.isLinux`
- `nix.package` in home-manager: `lib.mkIf pkgs.stdenv.isLinux pkgs.nix` (macOS propagates from nix-darwin; setting both errors)
- `nix.gc` differs by platform: home-manager uses `dates = "weekly"`, nix-darwin uses `interval = { Weekday = 0; Hour = 0; Minute = 0; }`
- Git `add` every new `.nix` file before `nix flake check`

## Format & CI

```bash
nixfmt flake.nix home.nix linux.nix darwin.nix $(find modules -name '*.nix') overlays/*.nix
nix flake check
```

CI (`.github/workflows/ci.yml`):
- Ignores `.md` changes, overlay-only changes, and `flake.lock` changes
- Uses `$(find modules -name '*.nix')` (not `**/*.nix`) — macOS bash 3.x compat
- Cachix push on main, skip on PRs: `vomba.cachix.org`
- ShellCheck: `nix run nixpkgs#shellcheck -- scripts/*.sh`

Pre-commit: nixfmt (auto-fix), gitleaks, prettier (YAML excluding `secrets.yaml`). Run `pre-commit install` once after cloning.

## Secrets

- NEVER hardcode secrets in `.nix` files — use sops-nix + `secrets.yaml`
- `sops.secrets.<name> = {};` (not `neededForUsers` — that's NixOS only)
- Exclude `secrets.yaml` from all YAML formatters (prettier corrupts encryption)
- Before commit: `rg '(sk-|-----BEGIN|GCP_PROJECT|api_key|password)' --include='*.nix' .`
- Password manager entries (rbw, pass) are sacred — never delete without asking

## Overlays

Composed via `//` in `overlays/default.nix`, one file per domain. Never use semicolons for set merge.

## OpenCode / ECC

Config: `modules/dev/ai.nix` at `programs.opencode.settings`. MCP config:
- `env` in opencode.json MCP servers does NOT pass env vars to child processes — bake into `pkgs.writeShellScriptBin` wrappers instead
- obsidian-mcp-server uses HTTPS with self-signed cert; test with `curl -sk`

## Git

- Separate commits per logical change — commit before each unrelated edit
- GPG-signed; if `gpg-agent is older than us`: `gpgconf --kill all`
- Conventional commits: `feat|fix|refactor|docs|test|chore|perf`
