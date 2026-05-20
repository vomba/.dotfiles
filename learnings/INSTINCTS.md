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

### When a skill symlink from the ECC source would replace a local improved copy
- **Action**: Don't keep a divergent local copy — contribute improvements upstream to ECC. The npm tarball is the single source of truth for all skills (except obsidian-brain which is project-specific)

### When bumping the ECC version
- **Action**: Edit the version in the tarball URL in `flake.nix`, run `nix flake update ecc-universal`, then diff the upstream `.opencode/opencode.json` for new agents. Add any new agents to `agentModels` if they need non-default model assignments. New agents default to `reasoningModel` (safe fallback). Run `scripts/ecc-skills.sh -u -v <new-version>` to discover new unloaded skills.

### When processing upstream agent config in ai.nix
- **Action**: Use `agentModels.${name} or reasoningModel` instead of `agentModels.${name}` — gives new upstream agents a safe fallback instead of breaking the build.

### When wondering what ECC skills exist but aren't loaded
- **Action**: Run `scripts/ecc-skills.sh -u <keyword>` to search unloaded skills by keyword. Use `scripts/ecc-skills.sh` alone to see all 149 upstream skills.

### When ECC command agents fail with "everything-claude-code:agent not found"
- **Action**: The command `.md` files have `agent: everything-claude-code:<name>` in YAML frontmatter. Strip it via: `sed '/^---$/,/^---$/ { /^agent:/d; }'`. Also ensure the plugin's `opencode.json` is not loaded (it registers namespaced agents).

### When an ECC plugin's opencode.json pollutes agent namespace
- **Action**: Don't symlink the `.opencode/` directory from the npm package. Define agents and commands solely in the main `opencode.json`. Keep `plugin = []` in the OpenCode config.

### When splitting a Nix module that exceeds 200 lines
- **Action**: Extract self-contained sections into sub-module files. Parent uses `imports = [ ./submodule.nix ];`. Nix merges duplicate attr paths from multiple modules, so they can all write to the same `wayland.windowManager.hyprland.settings` target.

### When adding a new .nix file to a flake module
- **Action**: Run `git add <file>` before `nix flake check` — flakes refuse to evaluate untracked files.

### When setting up Hyprland on a system with a display manager
- **Action**: Set `hyprland.systemd.enable = true` — safe with DM (SDDM/GDM), provides env propagation and clean shutdown. Only keep `false` for TTY-start without DM.

### When removing deprecated Hyprland workarounds
- **Action**: Check upstream changelogs first. `render.direct_scanout = false` is no longer needed with NVIDIA 555+ drivers. Remove and observe before committing.

### When Hyprland errors on removed dispatchers (togglesplit/swapsplit)
- **Action**: Replace with `layoutmsg` — e.g. `togglesplit,` → `layoutmsg, togglesplit` (no trailing comma, the old name becomes the arg). These dispatchers were removed in 0.44+.

### When Hyprland errors on removed config option (dwindle:pseudotile)
- **Action**: Remove the `pseudotile = true/false;` line entirely. There is no replacement config option — use the `pseudo` dispatcher per-window instead.

## Git

### When committing multiple separate changes
- **Action**: Stage and commit each logical change individually. Use `git restore --staged <file>` to unstage, then add+commit one group at a time. Avoid parallel commits when pre-commit hooks are active.

### When gpg signing fails with "gpg-agent is older than us"
- **Action**: Run `gpgconf --kill all` to restart the stale gpg-agent. Happens after system upgrades where gpg binary is updated but agent process lingers.
