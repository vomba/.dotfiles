# Cumulative Learnings

Auto-extracted patterns and insights from dotfiles sessions. Updated after each session.

## Nix Config

### Binary Cache Setup
- Add Cachix + nix-community cache to both `home.nix` and `darwin.nix`
- Wire `cachix/cachix-action@v17` into CI after `install-nix-action` (auto-bumped by Dependabot)
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
- This was an iterative discovery: first `modules/*.nix` (missed nested), then `modules/**/*.nix` via `globstar` (macOS bash 3.x broke), finally `$(find modules -name '*.nix')` (cross-platform)

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

### ECC Skills Sourced from Flake Input
- All skills referenced in `mergedInstructions` must be in `neededSkills` to be Nix-managed
- `neededSkills` skills (except `obsidian-brain`) are symlinked from `eccRepo` flake input via `lib.genAttrs`
- Adding a skill to `neededSkills` auto-wires both the symlink and version tracking
- Skills missing from `neededSkills` (like `continuous-learning-v2` was) exist on disk unmanaged

### writeShellScriptBin for CLI Wrappers
- Use `pkgs.writeShellScriptBin "<name>"` to create system-wide commands from scripts in managed paths
- Bakes the target path at build time, so `configDir` paths resolve correctly
- Add the wrapper to `home.packages` alongside other packages

### Local Skill Overrides
- Local-only skills (like `obsidian-brain`) use `source = ../relative/path` instead of `${eccRepo}/skills/...`
- To keep a skill tracking the upstream flake version, add to `neededSkills` — separate `home.file` is redundant
- When a skill has local improvements over upstream, they get lost when switching to the flake source; contribute upstream instead

### Nix Flake Version Bump
- `nix flake update --update-input everything-claude-code` or bump the tag in `flake.nix` (e.g. `v1.10.0` → `v1.11.0`)
- All skills sourced from `eccRepo` update automatically on rebuild

## Nix Flake + Git

### Flake Evaluation Requires Git-Tracked Files
- `nix flake check` errors with `Path '...' in the repository is not tracked by Git` for any file referenced by a flake module that isn't `git add`ed
- Fix: `git add <file>` before running `nix flake check`
- This includes new `.nix` files created during refactoring

## Pre-Commit

### nixfmt Auto-Format Loop
- When `entry: nixfmt` (not `--check`) is used in pre-commit, the hook modifies files in place
- If the commit is rejected, the staged files don't match the formatted files on disk
- Fix: `git add <modified-files>` and re-run the commit
- The second run passes because files are now properly formatted

## Module Refactoring

### Hyprland Sub-Module Split Pattern
- Extract self-contained sections (keybindings, env, window rules) into separate `.nix` files
- Parent module imports them via `imports = [ ./submodule.nix ]; `
- Both modules merge into the same `wayland.windowManager.hyprland.settings` attrset
- Nix merges duplicate attribute paths from multiple modules automatically

### Brace Matching After Section Removal
- Removing a large block from a Nix attrset can accidentally consume closing `};`
- After edits, verify each level's braces are balanced — especially when sections above and below the removed block both end with `};`

## Hyprland

### direct_scanout on Modern NVIDIA
- `render.direct_scanout = false` was a workaround for older NVIDIA drivers (pre-555)
- With NVIDIA 555+ and current Hyprland, explicit sync is properly supported
- Default (`true`) provides lower latency without issues
- Test by removing and observing for tearing

### systemd.enable with Display Managers
- `hyprland.systemd.enable = true` is safe when using a display manager (SDDM, GDM)
- Display managers initialize the user systemd session before Hyprland starts
- On TTY-start without a DM, systemd may not be initialized — then `enable = false` is safer
- Benefits of `true`: proper env propagation, session lifecycle, clean shutdown

## See Also

Detailed session learnings:
- `learnings/2026-05-04-nix-caching-and-ci.md`
- `learnings/2026-05-04-full-audit.md`
- `learnings/2026-05-12-ecc-skills-nix-integration.md`
- `learnings/2026-05-13-comprehensive-audit.md`
