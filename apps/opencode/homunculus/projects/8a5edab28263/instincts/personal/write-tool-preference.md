---
id: write-tool-preference
trigger: when creating or modifying files in the project
confidence: 0.85
domain: workflow
source: session-observation
scope: project
project_id: 8a5edab28263
project_name: /
---

# Use Write Tool Directly for File Operations Instead of Read+Edit Cycles

## Action
When creating or modifying files, use the Write tool directly to produce the final content rather than reading files first and then applying edits with the Edit tool.

## Evidence
- Observed 64 times in session opencode
- Pattern: Write tool used for 84% of all tool calls (64/76); Edit tool used 0 times; Read tool used only 1 time
- The agent consistently writes complete file content in a single Write call instead of reading and incrementally editing
- Last observed: 2026-05-25
