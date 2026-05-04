# Instincts — Auto-Acting Patterns

Actionable patterns extracted from session learnings. These fire automatically when the trigger context is detected.

## Nix Config

### When setting up nix.settings in home-manager
- **Action**: Also set `nix.package = pkgs.nix` — without it, home-manager errors with "A corresponding Nix package must be specified"

### When adding binary caches
- **Action**: Add substituters + trusted-public-keys to both `home.nix` and `darwin.nix`, wire `cachix/cachix-action@v15` into CI after `install-nix-action`, skip push on PRs

### When wrapping GUI apps with nixGL
- **Action**: Guard both `enable` and `package` with `pkgs.stdenv.isLinux` — nixGL evaluates on macOS even if `enable = false`

### When setting up GC or store settings
- **Action**: Use `nix.gc` (automatic, weekly, `--delete-older-than 30d`), plus `nix.settings` with `min-free = "2G"`, `max-free = "10G"`, `auto-optimise-store = true`, `max-jobs = 4`

## CI

### When running nixfmt in CI
- **Action**: Use `shopt -s globstar` + `modules/**/*.nix` — `modules/*.nix` misses all subdirectory files

### When setting up Cachix in GitHub Actions
- **Action**: Add `cachix/cachix-action@v15` after `install-nix-action` with `skipPush: ${{ github.event_name == 'pull_request' }}`, set `CACHIX_AUTH_TOKEN` as repo secret

### When running shellcheck in CI
- **Action**: Style suggestions (SC2001) don't fail the build — safe to suppress inline with `# shellcheck disable=SC2001`

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
