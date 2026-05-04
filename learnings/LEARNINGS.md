# Cumulative Learnings

Auto-extracted patterns and insights from dotfiles sessions. Updated after each session.

## Nix Config

### Binary Cache Setup
- Add Cachix + nix-community cache to both `home.nix` and `darwin.nix`
- Wire `cachix/cachix-action@v15` into CI after `install-nix-action`
- Skip push on PRs: `skipPush: ${{ github.event_name == 'pull_request' }}`
- Requires `nix.package = pkgs.nix` when using `nix.settings` in home-manager

### Store Health
- GC: weekly, `--delete-older-than 30d`
- `auto-optimise-store = true`
- `min-free = "2G"`, `max-free = "10G"`
- `max-jobs = 4` (match CPU cores)

### Platform Guards
- Always guard both `enable` and `package` with `pkgs.stdenv.isLinux` for nixGL-wrapped apps
- `nix.package` in home-manager: only set on Linux (`lib.mkIf pkgs.stdenv.isLinux pkgs.nix`). On macOS, nix-darwin propagates its system `nix.package` into home-manager — setting it in home.nix too causes a duplicate definition error.

### nix.gc Across Platforms
- **nix-darwin** (macOS): use `nix.gc.interval` (e.g. `{ Weekday = 0; Hour = 0; Minute = 0; }`)
- **home-manager** (Linux): use `nix.gc.dates` (e.g. `"weekly"`)
- `nix.gc.dates` was removed from nix-darwin; using it there causes: "The option definition `nix.gc.dates' no longer has any effect; please remove it"

### Build Targets
- `homeConfigurations.<name>.activationPackage` (not the bare output)

## Sops Setup

### Cross-Platform Secrets
- Add both age (Linux) and GPG (macOS YubiKey) recipients via:
  ```bash
  sops --add-pgp <fingerprint> --rotate secrets.yaml
  ```
- Create `.sops.yaml` at repo root to document key config for new secrets
- Prettier + sops don't mix — always exclude `secrets.yaml` from YAML formatters

### Age Key Generation (No SSH Required)
- Simpler than `ssh-to-age`, works without SSH keys:
  ```bash
  mkdir -p ~/.config/sops/age
  nix shell nixpkgs#age -c age-keygen > ~/.config/sops/age/keys.txt
  ```
- Remove the first "Public key:" line — it's not valid in an age identity file

## Pre-Commit

### Required Setup Step
- `pre-commit install` must be run once after cloning — hooks don't run until installed

### Pre-Commit + Nix
- Use `- repo: local` with `language: system` for tools in your devShell
- Combined with `.envrc` (direnv + flake devShell), tools are always in PATH

### Hook Config
```yaml
- repo: local
  hooks:
    - id: nixfmt
      name: nixfmt
      entry: nixfmt   # no --check — auto-fixes before commit
      language: system
      files: '\.nix$'
```
- Use bare `nixfmt` (not `--check`) so files are auto-formatted before commit
- Exclude `secrets.yaml` from prettier (sops-encrypted files are not valid YAML for formatters)
- gitleaks detects hardcoded secrets before they reach the repo

## CI/CD

### nixfmt with Recursive Globs
- `modules/*.nix` only matches top-level files (misses `modules/dev/*`, `modules/shell/*`, etc.)
- macOS bash 3.x doesn't support `shopt -s globstar` — use `find` instead:
  ```yaml
  run: nix run nixpkgs#nixfmt -- --check flake.nix home.nix linux.nix darwin.nix $(find modules -name '*.nix') overlays/*.nix
  ```

### Shellcheck
- Add `shellcheck scripts/*.sh` as a CI step
- Style-only warnings (SC2001) don't fail the build — safe to suppress inline
- macOS runners don't have shellcheck pre-installed — use `nix run nixpkgs#shellcheck -- scripts/*.sh`

### Dependabot
- Weekly checks for GitHub Actions updates
- Auto-creates PRs — still need manual review/merge

### GITHUB_TOKEN for API Calls
- Pass `${{ secrets.GITHUB_TOKEN }}` to steps calling GitHub API
- Unauthenticated: 60 req/hr → Authenticated: 5000 req/hr

## Scripts

- Pass `GITHUB_TOKEN` env var to scripts that call GitHub API
- Use `|| exit` after `pushd`/`popd` in bash scripts (SC2164)

## See Also

Detailed session learnings:
- `learnings/2026-05-04-nix-caching-and-ci.md`
- `learnings/2026-05-04-full-audit.md`
