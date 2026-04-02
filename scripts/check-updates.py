#!/usr/bin/env python3
"""
Check and apply updates for Nix overlay packages.

Usage:
    check-updates.py [--apply] [--dry-run] [--yes] [--apply-force-rev]
"""
import re
import json
import urllib.request
import os
import sys
import argparse
import subprocess

EXIT_SUCCESS = 0
EXIT_UPDATES_AVAILABLE = 1
EXIT_ERROR = 2

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

def prefetch_url(url):
    if not re.match(r'^https://github\.com/[a-zA-Z0-9_-]+/[a-zA-Z0-9_-]+/releases/download/', url):
        return None
    try:
        result = subprocess.run(
            ['nix-prefetch-url', '--print-hash', '--type', 'sha256', url],
            capture_output=True, text=True, timeout=60
        )
        if result.returncode == 0:
            for line in result.stdout.split('\n'):
                if line.startswith('hash:'):
                    return line.replace('hash:', '').strip()
    except subprocess.TimeoutExpired:
        print(f"Timeout while prefetching {url}")
    except Exception:
        pass
    return None

def parse_overlay_metadata(content):
    github_matches = re.findall(r'owner = "(.*?)";\s+repo = "(.*?)";', content)
    if github_matches:
        owner, repo = github_matches[0]
        version_match = re.search(r'version = "(.*?)";', content)
        rev_match = re.search(r'rev = "(.*?)";', content)
        has_multihash = bool(re.search(r'sha256\s*=\s*\{', content))
        return {
            'owner': owner,
            'repo': repo,
            'version': version_match.group(1) if version_match else None,
            'rev': rev_match.group(1) if rev_match else None,
            'has_multihash': has_multihash,
        }

    url_match = re.search(r'url = "https://github\.com/([^/]+)/([^/]+)/releases/download/', content)
    if url_match:
        owner, repo = url_match.group(1), url_match.group(2)
        version_match = re.search(r'version = "(.*?)";', content)
        has_multihash = bool(re.search(r'sha256\s*=\s*\{', content))
        return {
            'owner': owner,
            'repo': repo,
            'version': version_match.group(1) if version_match else None,
            'rev': None,
            'has_multihash': has_multihash,
        }
    return None

def update_version_with_rev_template(file_path, content, metadata, latest_version, dry_run=False):
    filename = os.path.basename(file_path)
    current_version = metadata['version']
    if latest_version != current_version:
        print(f"[{filename}] UPDATE AVAILABLE: {current_version} -> {latest_version}")
        if not dry_run:
            new_content = re.sub(
                r'(version = ")(.*?)(";)',
                f'\\g<1>{latest_version}\\g<3>',
                content
            )
            with open(file_path, "w") as f:
                f.write(new_content)
            print(f"[{filename}] Applied version update: {current_version} -> {latest_version}")
        return True
    return False

def update_multihash_template(file_path, content, metadata, latest_version, dry_run=False):
    filename = os.path.basename(file_path)
    owner = metadata['owner']
    repo = metadata['repo']
    current_version = metadata['version']

    new_lines = []
    lines = content.split('\n')
    i = 0
    hashes_updated = []
    while i < len(lines):
        line = lines[i]
        old_url_match = re.search(
            r'(https://github\.com/' + re.escape(owner) + r'/' + re.escape(repo) +
            r'/releases/download/v)\$\{version\}/([^\s"\']+)',
            line
        )
        if old_url_match:
            url_prefix = old_url_match.group(1)
            url_filename = old_url_match.group(2)

            new_line = line.replace(
                f"v${{version}}/{url_filename}",
                f"v{latest_version}/{url_filename}"
            )
            new_lines.append(new_line)

            i += 1
            if i < len(lines):
                next_line = lines[i]
                if re.match(r'\s*\{', next_line):
                    new_lines.append(next_line)
                    i += 1
                    platform_hashes = {}
                    while i < len(lines):
                        hash_line = lines[i]
                        if re.match(r'\s*\}', hash_line) or re.match(r'\s*\.\$\{system\}', hash_line):
                            break
                        hash_match = re.search(r'"([^"]+)"\s*=\s*"([^"]+)"', hash_line)
                        if hash_match:
                            platform = hash_match.group(1)
                            old_hash = hash_match.group(2)
                            test_url = f"{url_prefix}v{latest_version}/{url_filename.replace('${system}', platform)}"
                            print(f"[{filename}] Prefetching hash for {url_filename.replace('${system}', platform)}...")
                            new_hash = prefetch_url(test_url)
                            if new_hash:
                                platform_hashes[platform] = (old_hash, new_hash)
                                new_hash_line = re.sub(
                                    r'("[^"]+"\s*=\s*")[^"]+(")',
                                    f'\\g<1>{new_hash}\\g<2>',
                                    hash_line
                                )
                                new_lines.append(new_hash_line)
                            else:
                                new_lines.append(hash_line)
                        else:
                            new_lines.append(hash_line)
                        i += 1
                    for platform, (old_h, new_h) in platform_hashes.items():
                        print(f"[{filename}] Updating hash for {platform}: {old_h[:16]}... -> {new_h[:16]}...")
                    if i < len(lines):
                        new_lines.append(lines[i])
                else:
                    new_lines.append(next_line)
        else:
            new_lines.append(line)
        i += 1

    new_content = '\n'.join(new_lines)
    new_content = re.sub(
        r'(version = ")(.*?)(";)',
        f'\\g<1>{latest_version}\\g<3>',
        new_content
    )

    if not dry_run:
        with open(file_path, "w") as f:
            f.write(new_content)
    print(f"[{filename}] Applied version and hash update: {current_version} -> {latest_version}")
    return True

def update_version_with_url_template(file_path, content, metadata, latest_version, dry_run=False):
    filename = os.path.basename(file_path)
    owner = metadata['owner']
    repo = metadata['repo']
    current_version = metadata['version']

    new_lines = []
    lines = content.split('\n')
    i = 0
    while i < len(lines):
        line = lines[i]
        old_url_match = re.search(
            r'(https://github\.com/' + re.escape(owner) + r'/' + re.escape(repo) +
            r'/releases/download/)v\$\{version\}/([^\s"\']+)',
            line
        )
        if old_url_match:
            url_prefix = old_url_match.group(1)
            url_filename = old_url_match.group(2)
            new_url = f"{url_prefix}v{latest_version}/{url_filename}"

            print(f"[{filename}] Prefetching hash for {url_filename}...")
            new_hash = prefetch_url(new_url)

            new_line = line.replace(
                f"v${{version}}/{url_filename}",
                f"v{latest_version}/{url_filename}"
            )
            new_lines.append(new_line)

            if new_hash:
                i += 1
                if i < len(lines):
                    next_line = lines[i]
                    hash_match = re.search(r'(sha256 = ")([^"]+)(")', next_line)
                    if hash_match:
                        print(f"[{filename}] Updating hash for {url_filename}: {hash_match.group(2)} -> {new_hash}")
                        next_line = f'{hash_match.group(1)}{new_hash}{hash_match.group(3)}'
                    new_lines.append(next_line)
                else:
                    new_lines.append(lines[i])
            else:
                new_lines.append(lines[i])
        else:
            new_lines.append(line)
        i += 1

    new_content = '\n'.join(new_lines)
    new_content = re.sub(
        r'(version = ")(.*?)(";)',
        f'\\g<1>{latest_version}\\g<3>',
        new_content
    )

    if not dry_run:
        with open(file_path, "w") as f:
            f.write(new_content)
    print(f"[{filename}] Applied version update: {current_version} -> {latest_version}")
    return True

def check_version_update(file_path, metadata, apply_updates=False, dry_run=False):
    current_version = metadata['version']
    owner = metadata['owner']
    repo = metadata['repo']
    rev_match = metadata.get('rev')
    filename = os.path.basename(file_path)
    has_multihash = metadata.get('has_multihash', False)

    latest_version = get_latest_github_release(owner, repo)
    if not latest_version:
        return False

    if latest_version == current_version:
        print(f"[{filename}] Up to date ({current_version})")
        return False

    has_rev_template = rev_match and "${version}" in rev_match

    if has_multihash:
        return update_multihash_template(file_path, metadata.get('_content', ''), metadata, latest_version, dry_run)
    elif has_rev_template:
        return update_version_with_rev_template(file_path, metadata.get('_content', ''), metadata, latest_version, dry_run)
    elif not rev_match:
        return update_version_with_url_template(file_path, metadata.get('_content', ''), metadata, latest_version, dry_run)

    return False

def check_rev_update(file_path, metadata, apply_updates=False, dry_run=False, force_rev=False):
    current_rev = metadata['rev']
    owner = metadata['owner']
    repo = metadata['repo']
    filename = os.path.basename(file_path)

    latest_rev = get_latest_github_commit(owner, repo)
    if not latest_rev:
        print(f"[{filename}] Up to date ({current_rev[:7]})")
        return False

    if current_rev.startswith(latest_rev) or latest_rev.startswith(current_rev):
        print(f"[{filename}] Up to date ({current_rev[:7]})")
        return False

    short_current = current_rev[:7]
    short_latest = latest_rev[:7]
    print(f"[{filename}] UPDATE AVAILABLE: {short_current} -> {short_latest}")

    if apply_updates and force_rev:
        content = metadata.get('_content', '')
        new_content = re.sub(
            r'(rev = ")(.*?)(";)',
            f'\\g<1>{latest_rev}\\g<3>',
            content
        )
        with open(file_path, "w") as f:
            f.write(new_content)
        print(f"[{filename}] Applied rev update: {short_current} -> {short_latest}")
        return True
    elif apply_updates:
        print(f"[{filename}] Rev update NOT auto-applied (use --apply-force-rev to force): {short_current} -> {short_latest}")
    elif dry_run:
        print(f"[{filename}] Would update rev: {short_current} -> {short_latest}")

    return False

def check_file(file_path, apply_updates=False, dry_run=False, force_rev=False):
    with open(file_path, "r") as f:
        content = f.read()

    metadata = parse_overlay_metadata(content)
    if not metadata:
        return False

    metadata['_content'] = content
    filename = os.path.basename(file_path)
    owner = metadata['owner']
    repo = metadata['repo']

    if metadata['version']:
        latest_version = get_latest_github_release(owner, repo)
        if latest_version and latest_version != metadata['version']:
            print(f"[{filename}] UPDATE AVAILABLE: {metadata['version']} -> {latest_version} (https://github.com/{owner}/{repo})")

        if latest_version:
            return check_version_update(file_path, metadata, apply_updates, dry_run)
    elif metadata['rev']:
        return check_rev_update(file_path, metadata, apply_updates, dry_run, force_rev)

    return False

def parse_args():
    parser = argparse.ArgumentParser(description="Check for updates in Nix overlay packages")
    parser.add_argument("--apply", action="store_true", help="Apply updates to overlay files")
    parser.add_argument("--dry-run", action="store_true", help="Show what would be updated without making changes")
    parser.add_argument("--yes", action="store_true", help="Skip confirmation prompt (for CI use)")
    parser.add_argument("--apply-force-rev", action="store_true", help="Force apply rev-based updates (unstable commits)")
    return parser.parse_args()

def confirm_apply():
    print("WARNING: This will modify overlay files. Use --yes to confirm or --dry-run to preview.")
    response = input("Apply updates? [y/N] ")
    return response.lower() == "y"

def run_updates(overlay_dir, apply_updates=False, dry_run=False, force_rev=False):
    any_updated = False
    for filename in sorted(os.listdir(overlay_dir)):
        if filename.endswith(".nix") and filename != "default.nix":
            file_path = os.path.join(overlay_dir, filename)
            updated = check_file(file_path, apply_updates, dry_run, force_rev)
            if updated:
                any_updated = True
    return any_updated

def main():
    args = parse_args()
    script_dir = os.path.dirname(os.path.abspath(__file__))
    overlay_dir = os.path.join(script_dir, "..", "overlays")
    overlay_dir = os.path.normpath(overlay_dir)

    if not os.path.isdir(overlay_dir):
        print(f"Error: {overlay_dir} directory not found")
        sys.exit(EXIT_ERROR)

    if args.apply and not args.yes:
        if not confirm_apply():
            print("Aborted.")
            sys.exit(EXIT_SUCCESS)

    print(f"Checking for updates in {overlay_dir}...")

    if args.dry_run:
        print("DRY RUN MODE - No changes will be made\n")

    any_updated = run_updates(overlay_dir, args.apply, args.dry_run, args.apply_force_rev)

    print()
    if args.dry_run:
        print("Dry run complete. No files were modified.")
        sys.exit(EXIT_UPDATES_AVAILABLE if any_updated else EXIT_SUCCESS)
    elif args.apply:
        print("Update complete.")
        sys.exit(EXIT_UPDATES_AVAILABLE if any_updated else EXIT_SUCCESS)
    else:
        sys.exit(EXIT_SUCCESS)

if __name__ == "__main__":
    main()
