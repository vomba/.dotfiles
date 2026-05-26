---
id: bash-first-exploration
trigger: when exploring or navigating the codebase to understand structure or find relevant files
confidence: 0.85
domain: workflow
source: session-observation
scope: project
project_id: 0aa0b223994f
project_name: compliantkubernetes-apps
---

# Bash-First Codebase Exploration

## Action
Use bash commands as the primary exploration tool for codebase navigation, discovery, and file searching before resorting to read, glob, or grep tools

## Evidence
- Observed 16 times in session opencode
- Pattern: bash used 16 calls vs glob 4 calls and read 4 calls — bash dominates 2:1 over all other exploration tools combined
- Pattern: bash calls clustered in sequences of 2-4 consecutive calls, suggesting shell-based exploration loops
- Pattern: glob used sparingly for targeted file discovery, always preceded or followed by bash
- Pattern: read used only after bash commands identified specific files of interest
- Pattern: parallel bash calls executed simultaneously for independent investigations
- Last observed: 2026-05-26
