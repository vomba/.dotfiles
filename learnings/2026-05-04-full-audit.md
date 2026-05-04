# Session Learnings: Full Dotfiles Audit (Phases 1-8)

## Patterns Discovered

### Pattern: Pre-commit hook for sops-encrypted files
- **Context**: sops-encrypted `secrets.yaml` gets mangled by YAML formatters (prettier)
- **Fix**: Add `exclude: "secrets\\.yaml$"` to the prettier hook in `.pre-commit-config.yaml`
- **Root cause**: sops encryption produces valid YAML/JSON, but reformatting changes line lengths and indentation, corrupting the encrypted values

### Pattern: Recursive CI globs for Nix modules
- **Context**: `modules/*.nix` only matches direct children
- **Fix**: Use `shopt -s globstar; nixfmt --check modules/**/*.nix` to match all nesting levels
- **Why it matters**: `modules/dev/ai.nix`, `modules/shell/zsh.nix`, etc. were all unchecked

### Pattern: GPG + age dual-key sops setup
- **Context**: Dotfiles managed across Linux (age) and macOS (YubiKey/GPG)
- **Implementation**: Create initially with age, then `sops --add-pgp <fp> --rotate` to add GPG
- **Config**: `.sops.yaml` at repo root documents both keys for future `sops` usage

### Pattern: Pre-commit service vs hook distinction
- **Context**: `.pre-commit-config.yaml` exists but hooks don't run
- **Root cause**: `pre-commit install` must be called to register the git hook
- **Fix**: Run `pre-commit install` once after clone/setup

## Best Practices Applied

1. **Fail early in CI** — formatting check before flake check before build
2. **One concern per commit** — phases were committed separately for clean history
3. **Auto-fix over fail in pre-commit** — nixfmt without `--check` means the hook fixes the issue and the dev just re-stages

## Mistakes to Avoid

1. **Running `pre-commit run --all-files` before `secrets.yaml` is excluded**
   - Prettier corrupted the sops-encrypted file
   - Fix: `git checkout secrets.yaml` to restore, then add the exclude

2. **Age keygen first line confusion**
   - `age-keygen` outputs `Public key: ...` on stdout alongside the secret key
   - The first line is not a valid identity — sops fails to parse it
   - Fix: remove the first line or redirect to file which only captures the last 3 lines

3. **Shellcheck style warnings in CI**
   - SC2001 (sed over parameter expansion) is only style-level — doesn't fail CI
   - Can suppress with `# shellcheck disable=SC2001` if the sed version is more readable

4. **`neededForUsers` doesn't exist in home-manager sops module**
   - The option is only available in NixOS, not home-manager
   - In home-manager, just use `sops.secrets.<name> = {};` — secrets are available at activation time without the flag

## Instinct Entries

```json
{
  "trigger": "adding sops secret to home-manager",
  "action": "just use sops.secrets.<name> = {}; without neededForUsers — that flag doesn't exist in home-manager",
  "confidence": 0.9,
  "source": "session-extraction",
  "timestamp": "2026-05-04T12:00:00Z"
}
```

```json
{
  "trigger": "excluding sops files from formatters",
  "action": "add exclude: 'secrets\\\\.yaml$' to prettier and any YAML formatting hook — sops files break when reformatted",
  "confidence": 0.95,
  "source": "session-extraction",
  "timestamp": "2026-05-04T12:00:00Z"
}
```

```json
{
  "trigger": "running nixfmt in CI on nested modules",
  "action": "use shopt -s globstar and modules/**/*.nix — plain modules/*.nix misses all subdirectory files",
  "confidence": 0.95,
  "source": "session-extraction",
  "timestamp": "2026-05-04T12:00:00Z"
}
```

```json
{
  "trigger": "setting up age key for sops",
  "action": "use 'nix shell nixpkgs#age -c age-keygen' — simpler than ssh-to-age, works without SSH keys, but strip the first 'Public key:' line from the output",
  "confidence": 0.85,
  "source": "session-extraction",
  "timestamp": "2026-05-04T12:00:00Z"
}
```
