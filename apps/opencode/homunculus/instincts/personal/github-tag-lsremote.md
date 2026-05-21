---
id: github-tag-lsremote-verify
trigger: "checking if a GitHub Action version tag exists"
confidence: 0.9
domain: "ci-cd"
source: "session-extraction"
scope: global
---

# GitHub Tag Verification via git ls-remote

## Action
Use `git ls-remote --tags <repo-url>` instead of the GitHub REST API. It avoids rate limiting and returns the exact tag list.

## Evidence
- Discovered during CI audit on 2026-05-18
- GitHub API returned 403 with rate limit after ~20 requests
- git ls-remote worked immediately with no rate limiting
- Successfully verified upload-artifact@v7 and download-artifact@v8 tags exist
