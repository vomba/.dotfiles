---
id: search-then-read-exploration
trigger: when exploring or investigating an unfamiliar codebase area
confidence: 0.7
domain: workflow
source: session-observation
scope: project
project_id: 0aa0b223994f
project_name: compliantkubernetes-apps
---

# Search-then-Read Exploration Workflow

## Action
Use grep to search for relevant patterns first, then read matching files to understand the code

## Evidence
- Observed multiple times across opencode sessions
- Pattern: grep search to locate relevant code, followed immediately by read to inspect results
- Pattern: codegraph_context used once at start for high-level orientation, then grep/read iteration
- Pattern: glob used to find file paths, then grep/read for detailed understanding
- Pattern: batch parallel reads after search tools identify multiple relevant files
- Pattern: progressive search refinement — starts with content grep, broadens to glob for filesystem discovery
- Last observed: 2026-05-26
