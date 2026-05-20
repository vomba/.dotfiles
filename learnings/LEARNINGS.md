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

### Plugin Namespace Poisoning
- OpenCode plugin configs (`opencode.json`) register agents under the plugin's package name as a namespace prefix (e.g., `everything-claude-code:code-reviewer`)
- Even if the main config defines agents without namespace, commands from the plugin or with frontmatter referencing the namespaced name will fail with "Agent not found"
- **Fix**: Symlink the plugin source to an isolated store path or disable plugins entirely; strip `agent:` frontmatter from command `.md` files

### Command Frontmatter Override
- ECC command `.md` files ship with `agent: everything-claude-code:<name>` in YAML frontmatter
- This frontmatter overrides the `agent` field in the main `opencode.json` command definition
- **Fix**: Strip `agent:` lines from frontmatter with `sed` during the Nix build:
  ```nix
  eccCommands = pkgs.runCommand "ecc-commands" { } ''
    for f in ${eccPkg}/.opencode/commands/*.md; do
      sed '/^---$/,/^---$/ { /^agent:/d; }' "$f" > "$out/$(basename "$f")"
    done
  '';
  ```

### Activation Cleanup Can Destroy User Data
- `home.activation` scripts that wipe `opencode-stable.db` or `snapshot` directories permanently destroy session history
- Only clean up files that are known to be stale or broken; never wipe user state
- **Better**: Leave OpenCode's state alone once things are working

### ECC Sourced from npm Tarball (not git repo)
- ECC is fetched as the `ecc-universal` npm tarball (1.3MB) instead of the full git repo (100MB+)
- Tarball URL: `https://registry.npmjs.org/ecc-universal/-/ecc-universal-${version}.tgz`
- Version is pinned in the URL string in `flake.nix` — self-documenting
- Only files published by npm are included (no git history, no `ecc2/`, `assets/`, `docs/`, etc.)
- `nix flake update ecc-universal` updates the hash in `flake.lock`

### Agent Model Override (Claude → DeepSeek)
- The upstream `.opencode/opencode.json` is read at build time with `builtins.fromJSON`
- Agent models are overridden: reviewers → `deepseek-v4-pro`, builders → `deepseek-v4-flash`
- New agents from upstream get a safe fallback (`reasoningModel`) via `agentModels.${name} or reasoningModel`
- The `{file:...}` paths in the upstream config are rewritten to absolute paths via `rewritePaths`

### Selective Skill Linking
- All skills referenced in `mergedInstructions` must be in `neededSkills` to be Nix-managed
- `neededSkills` skills (except `obsidian-brain`) are symlinked from npm package via `lib.genAttrs`
- Adding a skill to `neededSkills` auto-wires both the symlink and version tracking
- Skills missing from `neededSkills` (like `continuous-learning-v2` was) exist on disk unmanaged

### Plugin Source
- The plugin is symlinked from `${eccPkg}/.opencode/dist/plugins` (compiled JS, not TypeScript source)
- OpenCode plugin path: `"${configDir}/plugins"` (flat, no nested `.opencode/`)
- The old `.opencode/` directory was removed — no more dual `opencode.json` confusion

### CONTRIBUTING.md Not Included
- `CONTRIBUTING.md` is not shipped in the npm package (it's a root-level file excluded by `.npmignore`)
- It was removed from the `mergedInstructions` array — not agent-critical content
- AGENTS.md is the important system instruction and is included

### writeShellScriptBin for CLI Wrappers
- Use `pkgs.writeShellScriptBin "<name>"` to create system-wide commands from scripts in managed paths
- Bakes the target path at build time, so `configDir` paths resolve correctly
- Add the wrapper to `home.packages` alongside other packages

### Local Skill Overrides
- Local-only skills (like `obsidian-brain`) use `source = ../relative/path` instead of `${eccPkg}/skills/...`
- To keep a skill tracking the upstream version, add to `neededSkills` — separate `home.file` is redundant
- When a skill has local improvements over upstream, they get lost when switching to the npm source; contribute upstream instead

### ECC Version Bump
- Edit version in the tarball URL in `flake.nix` (e.g. `v1.10.0` → `v1.11.0`)
- Run `nix flake update ecc-universal` to update the lock file hash
- All components (plugin, commands, prompts, skills, rules) update automatically on rebuild
- After bumping, check upstream `.opencode/opencode.json` for new agents — add to `agentModels` if they need non-default models
- Run `scripts/ecc-skills.sh -u -v <new-version>` to see what new skills appeared

### Skill Discovery
- `scripts/ecc-skills.sh` is a standalone bash script that fetches the upstream npm tarball and diffs its skill catalog against local `neededSkills`
- Supports keyword filtering: `scripts/ecc-skills.sh -u kotlin` shows unloaded Kotlin skills
- No Nix dependency — uses curl + tar directly, works anywhere bash runs

### Safe Agent Model Fallback
- Use `agentModels.${name} or reasoningModel` instead of `agentModels.${name}` when processing upstream agents
- New agents added upstream get `reasoningModel` by default instead of breaking the build
- The `agentModels` attrset only needs entries for agents that should use a non-default model

### Single Source for Skill Symlinks + Instructions
- `neededSkills` drives both `home.file` symlinks and `mergedInstructions`
- Adding a skill to `neededSkills` auto-wires both the directory symlink and the instruction load path
- No need to maintain two separate lists — derive instructions from the same list

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

### Deprecated Dispatchers
- `togglesplit` and `swapsplit` dispatchers removed in Hyprland 0.44+
- Replace with `layoutmsg togglesplit` / `layoutmsg swapsplit` (pass old name as string arg)
- In home-manager hyprlang bind: `"${modifier}, T, layoutmsg, togglesplit"` (no trailing comma — it takes an arg)

### Removed Config Options
- `dwindle.pseudotile` is gone entirely — no replacement config option
- Use the `pseudo` dispatcher (e.g. bound to a keybind) to toggle pseudotile per-window instead

### Hyprlang Deprecation
- Since Hyprland 0.55, hyprlang is deprecated in favor of lua
- `configType = "hyprlang"` in home-manager still works for pre-0.55
- lua syntax: `hl.dsp.layout("togglesplit")` instead of `layoutmsg` dispatcher

## Git

### Separate Commits for Separate Changes
- Commit each logically distinct change separately, even if they're in the same area
- Use `git restore --staged <file>` to unstage, then add+commit one group at a time
- Avoid parallel commits when pre-commit hooks are active — serialize sequential operations

### GPG Agent Stale After Upgrade
- `gpg: signing failed: Invalid value` with "gpg-agent is older than us"
- Fix: `gpgconf --kill all` to restart agent
- Happens after system upgrades where gpg is updated but agent process lingers

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
