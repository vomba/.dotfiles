---
id: bash-heavy-inspection-flow
trigger: when verifying state or checking results before making changes
confidence: 0.85
domain: workflow
source: session-observation
scope: project
project_id: e7fbcb67e417
project_name: .dotfiles
---

# Bash-Heavy Inspection Flow

## Action
Use bash tool as the primary mechanism for state inspection, verification, and validation before and after file edits.

## Evidence
- Observed 43+ times in session opencode (dominant tool)
- Pattern: bash used for ~74% of all tool calls, primarily for checking state before edits and verifying results after
- Additional 2026-05-25 session: 43 of 59 tool calls (73%) were bash, in dense post-edit verification clusters (10-11 calls each)
- Last observed: 2026-05-25
