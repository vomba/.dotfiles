# Nix Configuration Rules

## Module Structure

- `imports` MUST be at the top level of a module, never inside `config`, `options`, or any `lib.mkIf` wrapper
- Each module group SHOULD have an `enable` option via `lib.mkEnableOption` in a shared `options.nix`
- Wrap all module content inside `lib.mkIf config.dotfiles.<group>.<module>.enable`
- Keep modules focused (under 200 lines). Split larger ones using sub-directory structure

## Secrets

- NEVER hardcode secrets in `.nix` files (no API keys, tokens, passwords, emails, project IDs)
- ALWAYS use sops-nix with encrypted `secrets.yaml` for any credential
- Before committing, check: `rg '(sk-|-----BEGIN|GCP_PROJECT|api_key|password)' --include='*.nix' .`

## Formatting & Validation

- Run `nixfmt` on all `.nix` files before committing
- Validate with `nix flake check` after every logical change
- Never batch move/rename more than one module group at a time
- Run `nixfmt --check` in CI before any build step

## Overlays

- Split by domain (languages, python, tools), not by target
- Compose via set merge (`//`), not semicolons
- One overlay file per domain under `overlays/`, with `default.nix` as compositor

## Relative Paths

- When moving files, grep for `./` and `../` in moved files
- After any file move, run `nix flake check` immediately

## Editor Integration

- Place `.nixd.json` at repo root for Nix LSP support
- Wire all installed LSP servers in editor config
- Enable auto-format to match CI expectations
