---
id: todowrite-progress-tracking
trigger: when working through a multi-step implementation or investigation task
confidence: 0.5
domain: workflow
source: session-observation
scope: project
project_id: 0aa0b223994f
project_name: compliantkubernetes-apps
---

# Todowrite for Task Progress Tracking

## Action
Use todowrite at each completed phase of a multi-step workflow to maintain an accurate visible task list for the user

## Evidence
- Observed 3 times in session opencode
- Pattern: todowrite called after completing a bash command or batch of commands to update task state
- Pattern: todowrite used at start, midpoint, and end of the session to track flow
- Pattern: each call followed active work (write, bash results) to reflect current completion state
- Last observed: 2026-05-26
