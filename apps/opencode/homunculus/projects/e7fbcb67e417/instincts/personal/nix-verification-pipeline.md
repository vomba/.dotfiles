---
id: nix-verification-pipeline
trigger: when editing nix files in the dotfiles project
confidence: 0.5
domain: workflow
source: session-observation
scope: project
project_id: b84d56efd4b5
project_name: .dotfiles
---

# Nix Verification Pipeline

## Action
After editing .nix files, run git status, nixfmt, and nix flake check in sequence before proceeding to further edits or committing.

## Evidence
- Observed 3 times in session b84d56efd4b5
- Pattern: Each edit batch is followed by an extended bash verification cluster (8-16 calls) including both rapid status checks and a long-running (~46s) nix build/check command
- Verification commands include git status checks and nix build/check operations
- Last observed: 2026-05-25
