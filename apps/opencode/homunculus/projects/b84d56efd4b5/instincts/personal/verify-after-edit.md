---
id: verify-after-edit
trigger: after editing a file
confidence: 0.5
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
- Observed 3+ times in session <current>
- Pattern: Every edit is followed by at least one bash command (often multiple sequential or parallel bash calls) to validate the modification
- Last observed: 2026-05-21
