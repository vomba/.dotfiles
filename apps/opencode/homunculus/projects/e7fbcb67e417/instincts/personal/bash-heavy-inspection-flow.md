---
id: bash-heavy-inspection-flow
trigger: when verifying state or checking results before making changes
confidence: 0.85
domain: workflow
source: session-observation
scope: project
project_id: b84d56efd4b5
project_name: .dotfiles
---

# Bash-Heavy Inspection Flow

## Action
Use bash tool as the primary mechanism for state inspection, verification, and validation before and after file edits.

## Evidence
- Observed 26 times in session opencode (dominant tool)
- Pattern: bash used for ~74% of all tool calls, primarily for checking state before edits and verifying results after
- Last observed: 2026-05-25
