---
id: verify-after-edit
trigger: after editing a file
confidence: 0.85
domain: workflow
source: session-observation
scope: global
project_id: b84d56efd4b5
project_name: .dotfiles
---

# Verify After Edit

## Action
After making edits, immediately run bash commands to verify the changes are correct before continuing to further edits.

## Evidence
- Observed 24+ times in session b84d56efd4b5
- Pattern: Every edit batch is followed by multiple sequential and parallel bash calls (up to 16 per cluster) to validate the modification before proceeding to the next change
- Verification phase includes both rapid short checks (git status, linter) and longer running build/check commands
- Last observed: 2026-05-25
