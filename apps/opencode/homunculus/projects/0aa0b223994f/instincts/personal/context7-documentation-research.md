---
id: context7-documentation-research
trigger: when researching external library APIs, configuration syntax, or framework documentation needed for the project
confidence: 0.5
domain: workflow
source: session-observation
scope: project
project_id: 0aa0b223994f
project_name: compliantkubernetes-apps
---

# Context7 Documentation Research Workflow

## Action
Use context7_resolve-library-id followed by parallel context7_query-docs calls to look up external library documentation instead of searching local code or guessing APIs

## Evidence
- Observed 4 times in session opencode
- Pattern: resolve-library-id used first to find the correct library ID, then multiple query-docs calls launched in parallel to cover different documentation aspects
- Pattern: employed specifically for Kubernetes-ecosystem libraries (Helm, Helmfile, Kubernetes Go client) where configuration syntax and API details are best found in official docs rather than inferred from local usage
- Pattern: replaces guesswork or local code-search for external library behavior — documentation is looked up directly from authoritative sources
- Pattern: queries sent in parallel batches (2 simultaneous queries), never sequentially
- Pattern: documentation lookup is integrated mid-session after local exploration, not as a separate phase
- Last observed: 2026-05-26
