# 2026-05-12: ECC Skills Nix Integration

## Problem

`continuous-learning-v2` skill (containing the `instinct-cli.py` script) was manually placed at
`~/.config/opencode/skills/continuous-learning-v2/` — not managed by Nix, not in `neededSkills`,
not tracked by the ECC flake input version.

The `instinct` CLI was only callable via its full path — not in system PATH.

## Root Cause

The `neededSkills` list in `modules/dev/ai.nix` drives which skills get symlinked from the
`eccRepo` flake input. `continuous-learning-v2` was never added, so Nix didn't manage it.

The skill existed on disk because it was manually installed — a one-time copy that would
never update when ECC released a new version.

## Resolution

1. Added `"continuous-learning-v2"` to `neededSkills` — auto-symlinks from `${eccRepo}/skills/<name>`
2. Removed the separate `home.file` entry (redundant — `genAttrs` loop handles it)
3. Added to `mergedInstructions` so opencode loads the SKILL.md
4. Created `instinctWrapper` via `pkgs.writeShellScriptBin "instinct"` → added to `home.packages`
5. Removed the manual copy at `~/.config/opencode/skills/continuous-learning-v2/`

## Key Insight

The local copy had improvements over the upstream ECC version (XDG-based data directory,
Windows UTF-8 fix, URL normalization, legacy migration). Switching to the upstream
version means those improvements are lost. The upstream version uses `~/.claude/homunculus`
as data dir instead of `~/.local/share/ecc-homunculus`.

For future local improvements, they should be contributed upstream to ECC rather than
kept as a divergent local copy.

## Verification

- `nix flake check` passes
- Version tracked via `flake.nix`: `everything-claude-code` input with tag `v1.10.0`
- Bumping the tag updates all skills on next `home-manager switch`
