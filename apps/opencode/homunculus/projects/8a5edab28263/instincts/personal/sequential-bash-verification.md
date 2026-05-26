---
id: sequential-bash-verification
trigger: when verifying code changes, build output, or test results
confidence: 0.85
domain: workflow
source: session-observation
scope: project
project_id: 8a5edab28263
project_name: /
---

# Run Multiple Sequential Bash Commands for Verification After Changes

## Action
After writing or editing code, run multiple consecutive bash commands to verify build status, check linting, run tests, and confirm the changes work correctly before proceeding.

## Evidence
- Observed 18+ times across sessions (open code)
- Pattern: clusters of 3-4 consecutive bash tool calls after write/edit operations, used for build verification, test execution, and state inspection
- Session 2026-05-25: 10 bash calls in clusters (3-consecutive at lines 25-30, 2-consecutive at lines 43-46, 4 bash at lines 41-50)
- Session previous: 8 bash calls in verification clusters
- Last observed: 2026-05-25
