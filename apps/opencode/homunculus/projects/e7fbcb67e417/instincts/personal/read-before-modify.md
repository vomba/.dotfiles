---
id: read-before-modify
trigger: when modifying a file
confidence: 0.7
domain: workflow
source: session-observation
scope: global
project_id: b84d56efd4b5
project_name: .dotfiles
---

# Read Before Modify

## Action
Always read a file first with the Read tool before making any edits to it.

## Evidence
- Observed 4+ times in session <current>
- Pattern: Every edit operation is immediately preceded by one or more read operations on the same target files
- Last observed: 2026-05-21
