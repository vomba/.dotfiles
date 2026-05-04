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

### Pre-Commit
- nixfmt auto-fix hook:
  ```yaml
  - repo: local
    hooks:
      - id: nixfmt
        name: nixfmt
        entry: nixfmt
        language: system
        files: '\.nix$'
  ```

### Build Targets
- `homeConfigurations.<name>.activationPackage` (not the bare output)

## See Also

Detailed session learnings:
- `learnings/2026-05-04-nix-caching-and-ci.md`
