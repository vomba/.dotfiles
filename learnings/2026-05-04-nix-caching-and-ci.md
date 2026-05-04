# Session Learnings: Nix Caching, CI, and Pre-Commit

## Patterns Discovered

### Pattern: Nix binary cache bootstrap for dotfiles
- **Context**: When setting up a Nix-based dotfiles repo with custom overlays that rebuild from source on every `home-manager switch`
- **Implementation**:
  1. Create a Cachix cache for your org
  2. Add `nix.settings.substituters` + `trusted-public-keys` to both `home.nix` (Linux) and `darwin.nix` (macOS)
  3. Wire `cachix/cachix-action@v15` into CI workflows after `install-nix-action`
  4. Skip push on PRs with `skipPush: ${{ github.event_name == 'pull_request' }}`
  5. Push custom overlay builds: `cachix push <cache> $(nix build <target> --print-out-paths --no-link)`
- **Example**:
  ```nix
  nix.settings = {
    substituters = [ "https://mycache.cachix.org" "https://cache.nixos.org" ];
    trusted-public-keys = [ "mycache.cachix.org-1:KEY" "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
  };
  ```

### Pattern: Pre-commit with nixfmt auto-fix
- **Context**: Ensuring `.nix` files are formatted before every commit
- **Implementation**: Use a `local` hook in `.pre-commit-config.yaml` that runs `nixfmt` (without `--check`) and passes `language: system`. Combined with `direnv` + devShell, `nixfmt` is always in PATH.
- **Example**:
  ```yaml
  - repo: local
    hooks:
      - id: nixfmt
        name: nixfmt
        entry: nixfmt
        language: system
        files: '\.nix$'
  ```

### Pattern: Platform-conditional nixGL wrapping
- **Context**: When wrapping GUI apps with `nixGL` on Linux but not macOS
- **Implementation**: Guard both `enable` and `package` with `pkgs.stdenv.isLinux` to avoid evaluation errors on macOS where nixGL may not be configured.
- **Example**:
  ```nix
  programs.chromium = {
    enable = pkgs.stdenv.isLinux;
    package = if pkgs.stdenv.isLinux then config.lib.nixGL.wrap pkgs.chromium else pkgs.chromium;
  };
  ```

### Pattern: Nix store health management
- **Context**: Preventing disk-full issues and keeping the Nix store performant
- **Implementation**: Configure `nix.gc` for weekly cleanup and `nix.settings` for `auto-optimise-store`, `min-free`, and `max-free`.
- **Example**:
  ```nix
  nix.settings = {
    min-free = "2G";
    max-free = "10G";
    auto-optimise-store = true;
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  ```

## Best Practices Applied

1. **nix.settings over nix.extraOptions**
   - The newer `nix.settings` attrset is type-checked and composable; `nix.extraOptions` is a raw string that bypasses validation
   - Always prefer `nix.settings` in both nix-darwin and home-manager

2. **Free binary caches for Nix community projects**
   - `nix-community.cachix.org` provides pre-built binaries for `home-manager`, `nix-index-database`, and other community projects — always worth adding
   - Determinate Nix ships with FlakeHub cache pre-configured

3. **Deduplicate packages across modules**
   - `nodejs_25` was in both `packages.nix` and `ai.nix` — check for duplicates when adding new packages, especially when multiple modules might depend on the same runtime

4. **Cachix skipPush on PRs**
   - Use `skipPush: ${{ github.event_name == 'pull_request' }}` to avoid pushing untrusted PR builds to your cache

## Mistakes to Avoid

1. **Forgetting `nix.package` when using `nix.settings` in home-manager**
   - Home-manager requires `nix.package = pkgs.nix` to generate `nix.conf`
   - Error: `Failed assertions: - A corresponding Nix package must be specified via 'nix.package' for generating nix.conf.`

2. **Using `nix build` on home-manager flake output directly**
   - `homeConfigurations.<name>` is an attrset, not a derivation
   - Must use `homeConfigurations.<name>.activationPackage` as the build target
   - `nix build .#homeConfigurations.hani.activationPackage --print-out-paths`

3. **Conditional nixGL wrapping without platform guard**
   - `config.lib.nixGL.wrap` evaluates on both platforms — if nixGL isn't configured on macOS, it will fail at eval time even if `enable = false`

4. **nixfmt --check vs nixfmt in pre-commit**
   - `--check` only reports failures, it doesn't auto-fix
   - Pre-commit hooks should use bare `nixfmt` (no `--check`) so modified files are automatically staged

## Suggested Skill Updates

### `rules/nix-configuration.md`
Add section on Nix binary cache setup and store health configuration patterns.

### `skills/coding-standards/SKILL.md`
Consider adding a "Platform-conditional code" pattern for multi-platform Nix configs.
