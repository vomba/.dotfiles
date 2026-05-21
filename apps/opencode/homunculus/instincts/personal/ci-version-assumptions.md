---
id: ci-version-assumptions-verify-first
trigger: "about to flag CI action versions as outdated"
confidence: 0.8
domain: "ci-cd"
source: "session-extraction"
scope: global
---

# Verify Before Flagging CI Versions

## Action
Always verify with `git ls-remote --tags` before reporting a version as wrong. Major versions may have advanced further than expected (e.g., upload-artifact@v7, download-artifact@v8 when latest "known" is v4).

## Evidence
- Discovered during CI audit on 2026-05-18
- Initially assumed @v7/@v8 didn't exist based on stale knowledge
- Verification showed they are current and correct
