---
id: verify-after-edit
trigger: when finishing a block of edits to the codebase
confidence: 0.7
domain: workflow
source: session-observation
scope: project
project_id: 0aa0b223994f
project_name: compliantkubernetes-apps
---

# Read-Back Verification After Edits

## Action
After completing a batch of edits, read back the modified files and use glob/grep to verify changes are correct and consistent across the codebase

## Evidence
- Observed 3+ times in session opencode
- Pattern: 3 consecutive edit calls followed by 5 read + 1 glob + 1 grep calls to inspect results
- Pattern: batch reads of multiple files in parallel after editing to verify correctness
- Pattern: search tools (glob, grep) used after edits to check for consistency with related files
- Pattern: progressive verification — reads happen before and after search tools to confirm changes
- Last observed: 2026-05-26
