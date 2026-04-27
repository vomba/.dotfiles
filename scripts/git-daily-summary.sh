#!/usr/bin/env bash
# Git Daily Summary Script
# Gathers commits from the last 24 hours across dotfiles and vault.

DOTFILES_DIR="$HOME/.dotfiles"
VAULT_DIR="$HOME/.vault"

echo "### Git Activity (Last 24h)"

# Function to list commits for a repo
list_commits() {
	local dir=$1
	local name=$2
	if [ -d "$dir/.git" ]; then
		pushd "$dir" >/dev/null
		# Get commits in the last 24 hours
		commits=$(git log --since="24 hours ago" --oneline --no-merges)
		if [ -n "$commits" ]; then
			echo "#### $name"
			echo "$commits" | sed 's/^/- /'
		fi
		popd >/dev/null
	fi
}

list_commits "$DOTFILES_DIR" "Dotfiles"
list_commits "$VAULT_DIR" "Vault"

# Also check for Nix updates via check-updates.py
if [ -f "$DOTFILES_DIR/scripts/check-updates.py" ]; then
	updates=$("$DOTFILES_DIR/scripts/check-updates.py" --dry-run 2>&1 | grep "UPDATE AVAILABLE")
	if [ -n "$updates" ]; then
		echo ""
		echo "#### 📦 Pending Updates"
		echo "$updates" | sed 's/\[.*\] //' | sed 's/^/- /'
	fi
fi
