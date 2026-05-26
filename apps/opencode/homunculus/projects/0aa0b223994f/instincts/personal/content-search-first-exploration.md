---
id: content-search-first-exploration
trigger: when the task requires finding specific code patterns, references, definitions, or usages across the codebase
confidence: 0.85
domain: workflow
source: session-observation
scope: project
project_id: 0aa0b223994f
project_name: compliantkubernetes-apps
---

# Content-Search-First Codebase Exploration

## Action
Use grep and glob tools as the primary search for content-based discovery, then read matched files in parallel batches to understand context

## Evidence
- Observed 16+ parallel read batches across sessions (11 in prior session, 5 in 2026-05-26 session)
- Pattern: grep and glob used first to locate relevant code by content pattern, not by filesystem navigation
- Pattern: matched files read simultaneously in parallel batches of 2-6 files per batch, with up to 6 reads at identical timestamps
- Pattern: this is the inversion of bash-first-exploration — bash only used for niche needs like checking file existence or running commands, not for exploration
- Pattern: content search tools (grep: 15+, glob: 11+) dominate over shell-based discovery
- Pattern: read calls (77+) across sessions, showing a read-heavy, execution-light exploration profile
- Pattern: exploration follows a phased cycle: search (grep/glob) → batch reads → more search → more batch reads
- Pattern: successive read batches deepen understanding, moving from surface discovery to detailed inspection
- Pattern: zero bash calls in 2026-05-26 session — all discovery done exclusively via grep/glob/read tools
- Last observed: 2026-05-26
