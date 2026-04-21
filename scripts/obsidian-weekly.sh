#!/usr/bin/env bash
# Weekly Obsidian maintenance script
# Run this once a week to keep the vault healthy.
# Usage: ~/.dotfiles/scripts/obsidian-weekly.sh

set -euo pipefail

VAULT_DIR="$HOME/.vault"
DOTFILES_DIR="$HOME/.dotfiles"

cd "$VAULT_DIR" || exit 1

echo "=== Obsidian Weekly Maintenance ==="
echo "Vault: $VAULT_DIR"
echo "Date: $(date)"
echo ""

# 1. Git status
echo "--- Git Status ---"
git status --short || echo "Not a git repo yet. Initialize with: git init"
echo ""

# 2. Push changes (if remote configured)
echo "--- Pushing Changes ---"
if git remote -v | grep -q origin; then
	git add -A
	git commit -m "weekly: maintenance $(date +%Y-%m-%d)" --allow-empty
	git push 2>/dev/null && echo "Pushed successfully" || echo "Push failed (check remote config)"
else
	echo "No remote configured. Add one with: git remote add origin <url>"
fi
echo ""

# 3. Find notes without tags
echo "--- Untagged Notes ---"
find . -name "*.md" -not -path "./Templates/*" -not -path "./.obsidian/*" | while read -r file; do
	if ! grep -q "^tags:" "$file" 2>/dev/null; then
		echo "  [ ] $file"
	fi
done
echo ""

# 4. Find notes without frontmatter
echo "--- Notes Missing Frontmatter ---"
find . -name "*.md" -not -path "./Templates/*" -not -path "./.obsidian/*" | while read -r file; do
	if ! head -1 "$file" | grep -q "^---"; then
		echo "  [ ] $file"
	fi
done
echo ""

# 5. Count notes by folder
echo "--- Vault Stats ---"
for dir in "00 - Daily" "01 - Weekly" "02 - Projects" "03 - Resources" "04 - Snippets" "05 - Wiki" "06 - Archive"; do
	count=$(find "$VAULT_DIR/$dir" -name "*.md" 2>/dev/null | wc -l)
	echo "  $dir: $count notes"
done
echo ""

# 6. Update nix flake (optional, uncomment if desired)
# echo "--- Updating Nix Flake ---"
# cd "$DOTFILES_DIR"
# nix flake update
# echo ""

echo "=== Maintenance Complete ==="
