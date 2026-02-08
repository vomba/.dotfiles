#!/usr/bin/env python3
import re
import json
import urllib.request
import os

def get_latest_github_release(owner, repo):
    url = f"https://api.github.com/repos/{owner}/{repo}/releases/latest"
    try:
        req = urllib.request.Request(url)
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode())
            return data['tag_name'].lstrip('v')
    except Exception:
        return None

def get_latest_github_commit(owner, repo, branch="master"):
    url = f"https://api.github.com/repos/{owner}/{repo}/commits/{branch}"
    try:
        req = urllib.request.Request(url)
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode())
            return data['sha']
    except Exception:
        if branch == "master":
            return get_latest_github_commit(owner, repo, "main")
        return None

def check_file(file_path):
    with open(file_path, "r") as f:
        content = f.read()

    # Match fetchFromGitHub blocks
    # This is a simple regex that assumes a certain structure
    github_matches = re.findall(r'owner = "(.*?)";\s+repo = "(.*?)";', content)
    if not github_matches:
        return

    owner, repo = github_matches[0]
    
    version_match = re.search(r'version = "(.*?)";', content)
    rev_match = re.search(r'rev = "(.*?)";', content)

    if version_match and not rev_match:
        # Likely a tagged release
        current_version = version_match.group(1)
        latest_version = get_latest_github_release(owner, repo)
        if latest_version and latest_version != current_version:
            print(f"[{os.path.basename(file_path)}] UPDATE AVAILABLE: {current_version} -> {latest_version} (https://github.com/{owner}/{repo})")
        else:
            print(f"[{os.path.basename(file_path)}] Up to date ({current_version})")
    elif rev_match:
        # Likely a commit hash
        current_rev = rev_match.group(1)
        latest_rev = get_latest_github_commit(owner, repo)
        if latest_rev and not current_rev.startswith(latest_rev) and not latest_rev.startswith(current_rev):
            print(f"[{os.path.basename(file_path)}] UPDATE AVAILABLE: {current_rev[:7]} -> {latest_rev[:7]} (https://github.com/{owner}/{repo})")
        else:
            print(f"[{os.path.basename(file_path)}] Up to date ({current_rev[:7]})")

if __name__ == "__main__":
    overlay_dir = "overlays"
    print(f"Checking for updates in {overlay_dir}...")
    for filename in os.listdir(overlay_dir):
        if filename.endswith(".nix") and filename != "default.nix":
            check_file(os.path.join(overlay_dir, filename))