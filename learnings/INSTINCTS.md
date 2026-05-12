# Instincts — Auto-Acting Patterns

Actionable patterns extracted from session learnings. These fire automatically when the trigger context is detected.

## Nix Config

### When setting up nix.settings in home-manager
- **Action**: Set `nix.package = lib.mkIf pkgs.stdenv.isLinux pkgs.nix` — on macOS, nix-darwin propagates its own `nix.package` into home-manager; setting it unconditionally causes a duplicate definition error

### When adding binary caches
- **Action**: Add substituters + trusted-public-keys to both `home.nix` and `darwin.nix`, wire `cachix/cachix-action@v17` (or latest bumped by Dependabot) into CI after `install-nix-action`, skip push on PRs

### When wrapping GUI apps with nixGL
- **Action**: Guard both `enable` and `package` with `pkgs.stdenv.isLinux` — nixGL evaluates on macOS even if `enable = false`

### When setting up GC or store settings
- **Action**:
  - **home-manager** (Linux): `nix.gc.dates = "weekly"`, options `--delete-older-than 30d`
  - **nix-darwin** (macOS): `nix.gc.interval = { Weekday = 0; Hour = 0; Minute = 0; }` — `nix.gc.dates` was removed from nix-darwin
  - Both: `nix.settings` with `min-free = "2G"`, `max-free = "10G"`, `auto-optimise-store = true`, `max-jobs = 4`

## CI

### When running nixfmt in CI
- **Action**: Use `$(find modules -name '*.nix')` instead of `modules/**/*.nix` — macOS bash 3.x doesn't support `shopt -s globstar`

### When running shellcheck in CI
- **Action**: Use `nix run nixpkgs#shellcheck -- scripts/*.sh` — shellcheck isn't pre-installed on macOS runners
- Style suggestions (SC2001) don't fail the build — safe to suppress inline with `# shellcheck disable=SC2001`

### When calling GitHub API in scripts
- **Action**: Pass `GITHUB_TOKEN` env var for 5000 req/hr instead of 60

## Pre-Commit

### When adding nixfmt to pre-commit
- **Action**: Use `entry: nixfmt` (not `nixfmt --check`) so it auto-fixes files before stage. Use `- repo: local` with `language: system`

### When setting up pre-commit
- **Action**: Run `pre-commit install` after cloning — hooks don't run until installed

### When sops-encrypted files exist
- **Action**: Exclude `secrets.yaml` from all YAML formatters with `exclude: "secrets\\.yaml$"` — prettier will corrupt the encryption

## Sops

### When setting up age key for sops
- **Action**: Use `nix shell nixpkgs#age -c age-keygen` — but strip the first "Public key:" line from the output (not a valid identity line)

### When adding cross-platform support
- **Action**: Start with age key for Linux, then `sops --add-pgp <fingerprint> --rotate secrets.yaml` to add GPG for macOS YubiKey

### When creating a new sops secret in home-manager
- **Action**: Just use `sops.secrets.<name> = {};` — `neededForUsers` doesn't exist in home-manager (that's NixOS only)

### When adding a CLI script from a managed directory to PATH
- **Action**: Use `pkgs.writeShellScriptBin "<name>" ''exec <path-to-script> "$@"''` and add to `home.packages` — avoids manual symlinks and survives rebuilds

### When a skill is on disk but not Nix-managed
- **Action**: Check if it's in `neededSkills` in `modules/dev/ai.nix` — if not, add it. Skills outside `neededSkills` exist unmanaged and won't track flake version bumps

### When a skill symlink from eccRepo would replace a local improved copy
- **Action**: Don't keep a divergent local copy — contribute improvements upstream to ECC. The flake input is the single source of truth for all skills (except obsidian-brain which is project-specific)
