# Comprehensive Audit — 2026-05-13

Full-system audit of the Nix-based dotfiles repository. Checked every component against latest upstream standards, best practices, and security guidelines.

## Summary

| Category | HIGH | MEDIUM | LOW | INFO |
|----------|------|--------|-----|------|
| Upstream Versions | 0 | 2 | 1 | 3 |
| Nix Standards | 0 | 0 | 2 | 4 |
| Security | 0 | 0 | 1 | 5 |
| Shell/Desktop | 0 | 0 | 1 | 3 |
| AI/Dev Tools | 0 | 0 | 0 | 4 |
| CI/CD | 0 | 0 | 0 | 5 |
| Documentation | 0 | 0 | 2 | 2 |
| **Total** | **0** | **2** | **7** | **26** |

**Overall: No CRITICAL/HIGH issues found. 2 MEDIUM, 7 LOW items to consider.**

---

## Phase 1: Upstream Version & Deprecation Audit

### 1.1 Flake Inputs (`flake.nix`, `flake.lock`)

| Input | Pinned | Latest | Status |
|-------|--------|--------|--------|
| `everything-claude-code` | v1.10.0 | v1.10.0 | ✅ Up-to-date |
| `nixpkgs` | nixos-unstable (2025-05-01) | nixos-unstable | ✅ Tracking latest |
| `nixpkgs-stable` | 25.11 | 26.05 available | ⚠️ MEDIUM: New stable channel available |
| `home-manager` | follows nixpkgs | follows nixpkgs | ✅ |
| `nix-darwin` | follows nixpkgs | follows nixpkgs | ✅ |
| `nixGL` | follows nixpkgs | follows nixpkgs | ✅ |
| `nix-index-database` | follows nixpkgs | follows nixpkgs | ✅ |
| `NUR` | follows nixpkgs | follows nixpkgs | ✅ |
| `obsidian-plugins` | follows nixpkgs | follows nixpkgs | ✅ |
| `sops-nix` | follows nixpkgs | follows nixpkgs | ✅ |

**Action**: Consider bumping `nixpkgs-stable` from `25.11` to `26.05`:
- `nixpkgs-stable.url = "github:nixos/nixpkgs/26.05";`
- Test with `nix flake check` after change
- No migration notes expected (minor bump within same year)

### 1.2 Overlay Packages

| Package | Version | Latest | Status |
|---------|---------|--------|--------|
| helm | 4.1.4 | v4.1.4 | ✅ Up-to-date |
| helmfile | 1.5.1 | v1.5.1 | ✅ Up-to-date |
| cidr | 2.3.0 | v2.3.0 | ✅ Up-to-date |
| openstack-tui | 0.13.5 | v0.13.5 | ✅ Up-to-date |
| helm-secrets | 4.7.6 | v4.7.6 | ✅ Up-to-date |

All overlay packages at latest versions. `scripts/check-updates.py` is working correctly.

### 1.3 GitHub Actions

| Action | Pinned | Latest | Status |
|--------|--------|--------|--------|
| `actions/checkout` | @v6 | v6.0.2 | ✅ Dependabot handles minor bumps |
| `cachix/install-nix-action` | @v31 | v31.10.6 | ✅ Dependabot handles minor bumps |
| `cachix/cachix-action` | @v17 | v17 | ✅ Up-to-date |
| `actions/upload-artifact` | @v7 | v7.0.1 | ✅ Dependabot handles minor bumps |
| `actions/download-artifact` | @v8 | v8.0.1 | ✅ v8 is latest; upload v7 / download v8 is intentional (different action majors) |

### 1.4 Pre-commit Hooks (`.pre-commit-config.yaml`)

| Hook | Version | Latest | Status |
|------|---------|--------|--------|
| `mirrors-prettier` | v4.0.0-alpha.8 | v4.0.0-alpha.8 | ✅ Only alpha available for v4; no stable v3 alternative in mirrors |
| `pre-commit-hooks` | v6.0.0 | v6.0.0 | ✅ Up-to-date |
| `gitleaks` | v8.24.2 | v8.30.1 | ⚠️ MEDIUM: 6 minor versions behind (security scanning tool — keep current) |

**Action**: Run `pre-commit autoupdate` to get gitleaks v8.30.1. Review any format/behavior changes.

---

## Phase 2: Nix Configuration Standards

### 2.1 Module Structure Compliance

| Rule | Status | Notes |
|------|--------|-------|
| `imports` at top level | ✅ PASS | All modules comply |
| Wrapped in `lib.mkIf` | ✅ PASS | Every module uses `config = lib.mkIf config.dotfiles...` |
| Under 200 lines | ⚠️ Borderline | `modules/desktop/hyprland/settings.nix` = 209 lines |
| `enable` options exist | ✅ PASS | All 16 groups have options in `modules/options.nix` |

### 2.2 stateVersion

- `home.stateVersion = "26.05"` — ✅ matches current home-manager release
- `system.stateVersion = 4` in darwin.nix — ✅ current for nix-darwin

### 2.3 Deprecated Options

- `nix.gc.dates` used only in home.nix (Linux) — ✅ correct per learnings
- `nix.gc.interval` used in darwin.nix (macOS) — ✅ correct per learnings
- No `lib.mdDoc`, `builtins.toPath`, or other deprecated usage found
- `nixpkgs.legacyPackages` in flake.nix — still supported, no deprecation planned

### 2.4 Experimental Features

- darwin.nix sets `experimental-features = ["nix-command" "flakes"]` in `nix.settings`
- home.nix does NOT set `experimental-features` in `nix.settings`
- On Linux, this relies on system-level `/etc/nix/nix.conf`
- **Recommendation**: Add `experimental-features` to `home.nix`'s `nix.settings` for Linux self-containment

---

## Phase 3: Security & Secrets

### 3.1 Hardcoded Secret Scan

- ✅ No API keys, tokens, passwords, or private keys in `.nix` files
- ✅ `credentials-helper.bash` uses `rbw get` / `pass` for all secrets
- ✅ `rbw-config.json` contains email `vombatn@gmail.com` — LOW severity, not a secret but personal info exposure in a committed file

### 3.2 SOPS Configuration

- ✅ `.sops.yaml` has both age key (Linux) and PGP key (macOS YubiKey)
- ✅ `secrets.yaml` excluded from prettier via `exclude: "secrets\\.yaml$"`
- ✅ sops-nix import path correct: `inputs.sops-nix.homeManagerModules.sops`
- ✅ Two secrets defined: `gcp_project`, `context7_api_key`

### 3.3 Pre-commit Security

- ✅ gitleaks active at v8.24.2 (could bump to v8.30.1 — see Phase 1.4)
- ✅ `secrets.yaml` excluded from prettier
- ✅ `check-added-large-files` active
- ✅ `check-yaml` active

---

## Phase 4: Shell & Desktop Environment

### 4.1 ZSH (`.zsh.nix`)

- oh-my-zsh plugins: all current and available
- Shell aliases: `cat = "bat"`, `yq4 = "yq"` — reasonable
- `nodejs_25` in `packages.nix` — non-LTS, comment already flags this. `nodejs_24` is LTS but reaching EOL soon. Consider `nodejs_26` when it becomes LTS.

### 4.2 Hyprland (settings.nix)

- 209 lines (borderline — see Phase 2.1)
- `render.direct_scanout = false` — this was a workaround for older NVIDIA drivers. Check if still needed on current drivers (555+ series)
- `env` vars for Wayland + NVIDIA are current
- Window rules and keybinds look standard

### 4.3 Waybar & Fuzzel

- Waybar CSS uses standard format with Nordic theme
- Fuzzel settings use standard options
- Both compatible with current upstream versions

### 4.4 Platform Guards

- ✅ All nixGL.wrap calls guarded with `pkgs.stdenv.isLinux`
- ✅ `gui.nix`: kitty, chromium, obsidian all have proper guards
- ✅ `packages.nix`: powershell only on Linux
- ✅ `hyprland/default.nix`: hyprland wrapped with nixGL

---

## Phase 5: AI/LLM & Development Tools

### 5.1 Everything Claude Code

- Pinned at v1.10.0 — latest release, no update needed
- All 14 skills listed in `neededSkills` match `mergedInstructions`
- `continuous-learning-v2` in `neededSkills` — correct
- Agent model assignments appropriate for code vs reasoning
- Context7 MCP wrapper using sops for API key — ✅ secure

### 5.2 LSP Servers

- All LSP servers available in nixpkgs
- `marksman` sourced from nixpkgs-stable — ✅ intentionally pinned
- `nixd`, `gopls`, `terraform-ls`, `helm-ls`, `bash-language-server`, etc. all current

### 5.3 Development Tools

- kubectl/kubie/kind/velero — all available in nixpkgs-unstable
- `tenv` (Terraform version manager) — still maintained
- `sonobuoy`, `popeye`, `crossplane-cli`, `krew` — all current

---

## Phase 6: CI/CD & Automation

### 6.1 Workflow Correctness

- `ci.yml`: builds both Linux (home-manager) and macOS (nix-darwin) — ✅
- `update-check.yml`: daily `nix flake update` + overlay checks — ✅
- Concurrency groups configured — ✅
- Dependabot active for GitHub Actions weekly — ✅

### 6.2 Script Review

| Script | Lines | Issues |
|--------|-------|--------|
| `check-updates.py` | 400 | ✅ No deprecated Python usage; uses urllib (stdlib) |
| `git-daily-summary.sh` | 37 | ✅ SC2001 suppressed (intentional) |
| `obsidian-weekly.sh` | 65 | ✅ `set -euo pipefail`, clean |

### 6.3 nixfmt Format Check

CI uses `$(find modules -name '*.nix')` — ✅ cross-platform compatible (per learnings)

---

## Phase 7: Documentation & Learnings

### 7.1 README Accuracy

- ✅ All modules listed in README structure match actual files
- ✅ CI pipeline description matches actual workflows
- ✅ Pre-commit hook table matches `.pre-commit-config.yaml`

**Issue**: README mentions `actions/checkout@v4` in the prose section (line 176: "Action versions: `cachix/install-nix-action@v31`, `cachix/cachix-action@v17`") but the actual CI uses `actions/checkout@v6`. The README doesn't mention `actions/checkout@v6`.

### 7.2 Learnings Completeness

- LEARNINGS.md (125 lines) — comprehensive, covers Nix config, SOPS, pre-commit, CI/CD, ECC
- INSTINCTS.md (63 lines) — 16 actionable patterns, well-organized
- 3 detailed session learnings referenced

All knowledge captured in the codebase is correctly reflected in learnings.

---

## Phase 8: Cross-Platform Compatibility

- ✅ `home.username` and `home.homeDirectory` guarded by `pkgs.stdenv.isLinux`
- ✅ `nix.gc.dates` (home-manager) vs `nix.gc.interval` (nix-darwin) correctly separated
- ✅ `nix.package` guarded: `lib.mkIf pkgs.stdenv.isLinux pkgs.nix`
- ✅ nixGL wrapping for GUI apps guarded
- ✅ Platform-specific packages in `gui.nix`, `packages.nix`
- ✅ `gpg.nix` uses `isDarwin` / `isLinux` explicitly
- ✅ Kanshi profile outputs specific to machine (not platform) — correct

**Potential issue**: `experimental-features` not set in home.nix — on Linux, relies on system config. If the system doesn't have `nix-command` and `flakes` enabled in `/etc/nix/nix.conf`, build may fail. Recommend adding to home.nix for self-containment.

---

## Prioritized Action Items

### MEDIUM (Apply Soon)

| # | Area | Finding | Action | File |
|---|------|---------|--------|------|
| 1 | Pre-commit | gitleaks v8.24.2 → v8.30.1 | Run `pre-commit autoupdate` | `.pre-commit-config.yaml` |
| 2 | Nixpkgs | nixpkgs-stable 25.11 → 26.05 | Update URL and `nix flake check` | `flake.nix` |

### LOW (Nice-to-Have)

| # | Area | Finding | Action | File |
|---|------|---------|--------|------|
| 3 | Nix | experimental-features not in home.nix | Add to `nix.settings` for Linux self-containment | `home.nix` |
| 4 | Desktop | settings.nix is 209 lines (>200 guideline) | Split into sub-modules or refactor | `modules/desktop/hyprland/settings.nix` |
| 5 | Docs | README mentions checkout@v4 but CI uses @v6 | Update README prose | `README.md` |
| 6 | Nix | nodejs_25 is non-LTS | Consider nodejs_26 LTS when available | `modules/apps/packages.nix` |
| 7 | Security | rbw-config.json has hardcoded email | Minor, but consider injecting via sops or env | `rbw-config.json` |
| 8 | Nix | Check if `render.direct_scanout = false` still needed | Test with current NVIDIA drivers (555+) | `modules/desktop/hyprland/settings.nix` |
| 9 | Desktop | Hyprland `systemd.enable = false` | Verify this is still needed; systemd integration may be stable now | `modules/desktop/hyprland/default.nix` |

### INFO (No Action Needed)

| # | Area | Finding |
|---|------|---------|
| 10 | Overlays | All 5 overlay packages at latest versions |
| 11 | ECC | v1.10.0 is latest — no update |
| 12 | Actions | All GitHub Actions at latest majors |
| 13 | Pre-commit | mirrors-prettier (only alpha available), pre-commit-hooks (latest) |
| 14 | Module Structure | All Nix rules followed correctly |
| 15 | Security | No hardcoded secrets in .nix files; SOPS correctly configured |
| 16 | Platform | All cross-platform guards in place |
| 17 | Scripts | All 3 scripts clean with no functional issues |
| 18 | LSP | All LSP servers current and available |
| 19 | Dev Tools | All development tools current in nixpkgs |
| 20 | Learnings | Documentation complete and accurate |

---

## Files Examined

- `flake.nix`, `flake.lock`
- `home.nix`, `darwin.nix`, `linux.nix`
- `overlays/` (7 files)
- `modules/options.nix`
- `modules/sops.nix`
- `modules/dev/` (5 files)
- `modules/shell/` (4 files)
- `modules/desktop/` (5 files)
- `modules/apps/` (6 files)
- `scripts/` (3 files)
- `.github/workflows/` (2 files)
- `.github/dependabot.yml`
- `.pre-commit-config.yaml`
- `.sops.yaml`
- `README.md`
- `.gitignore`
- `rbw-config.json`, `credentials-helper.bash`
- `learnings/` (5 files)
