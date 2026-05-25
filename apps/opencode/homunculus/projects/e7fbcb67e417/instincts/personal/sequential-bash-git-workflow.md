---
id: sequential-bash-git-workflow
trigger: when executing git operations for commits or verification
confidence: 0.7
domain: git
source: session-observation
scope: project
project_id: e7fbcb67e417
project_name: .dotfiles
---

# Sequential Bash Git Workflow

## Action
Chain sequential bash calls for git operations (status, diff, add, commit) rather than running them in parallel, since each depends on the previous command's result.

## Evidence
- Observed 6 times in session opencode
- Pattern: long chains of sequential bash calls for git status, diff, add, commit flow
- Last observed: 2026-05-25
