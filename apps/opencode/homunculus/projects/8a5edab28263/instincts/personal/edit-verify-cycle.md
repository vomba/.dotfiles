---
id: edit-verify-cycle
trigger: when making modifications to existing files in the project
confidence: 0.7
domain: workflow
source: session-observation
scope: project
project_id: 8a5edab28263
project_name: /
---

# Use Edit Tool Then Verify With Bash After Each Change

## Action
After each edit or cluster of 1-3 edits to existing files, run bash commands immediately to verify the change compiles, passes checks, or produces the expected output before making further modifications.

## Evidence
- Observed 4 times in session opencode
- Pattern: edit → bash sequence; after making targeted changes with the Edit tool, the agent runs verification commands (nix builds, compiles, or inspection) before the next edit cycle
- Occurrences: edit (line 5) → bash (line 7), edit (line 9) → bash (line 11), edit (line 13)+edit (line 15) → bash (line 17), edit (line 21)+edit (line 23) → bash (line 25)
- Contrasts with the write-tool-preference pattern from other sessions — Edit is preferred for modifying existing files, with bash verifying each change before proceeding
- Last observed: 2026-05-25
