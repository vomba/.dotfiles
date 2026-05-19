#!/usr/bin/env bash
set -euo pipefail

# ECC Skill Explorer — list upstream skills and compare against loaded set
# Usage:
#   scripts/ecc-skills.sh                        # list all upstream skills
#   scripts/ecc-skills.sh -u                     # show only unloaded skills
#   scripts/ecc-skills.sh -u <keyword>           # unloaded skills matching keyword
#   scripts/ecc-skills.sh <keyword>              # all skills matching keyword

ECC_VERSION="1.10.0"
MODE="all"
KEYWORD=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -u) MODE="unloaded"; shift ;;
    -v) ECC_VERSION="$2"; shift 2 ;;
    *) KEYWORD="$1"; shift ;;
  esac
done

echo "Fetching ECC v${ECC_VERSION} skill catalog..." >&2

SKILLS=$(curl -sL "https://registry.npmjs.org/ecc-universal/-/ecc-universal-${ECC_VERSION}.tgz" \
  | tar tzf - \
  | grep 'package/skills/[^/]*/SKILL\.md$' \
  | sed 's|package/skills/||;s|/SKILL\.md||' \
  | sort)

TOTAL=$(echo "$SKILLS" | wc -l | tr -d ' ')

if [ "$MODE" = "unloaded" ]; then
  LOADED=$(
    grep -A200 'neededSkills = \[' "$(dirname "$0")/../modules/dev/ai.nix" \
    | grep '"' \
    | sed 's/.*"\(.*\)".*/\1/' \
    | head -n -1
  )
  SKILLS=$(comm -23 <(echo "$SKILLS") <(echo "$LOADED" | sort))
fi

[ -n "$KEYWORD" ] && SKILLS=$(echo "$SKILLS" | grep -i "$KEYWORD" || true)

echo ""
while IFS= read -r skill; do
  [ -z "$skill" ] && continue
  desc=$(curl -sL "https://registry.npmjs.org/ecc-universal/-/ecc-universal-${ECC_VERSION}.tgz" \
    | tar xzO "package/skills/${skill}/SKILL.md" 2>/dev/null \
    | grep '^description:' \
    | sed 's/^description: *//')
  echo "  $skill${desc:+ — }${desc:-}"
done <<< "$SKILLS"

COUNT=$(echo "$SKILLS" | wc -l | tr -d ' ')
echo ""
echo "$COUNT skills $([ "$MODE" = "unloaded" ] && echo "unloaded (of $TOTAL total)" || echo "loaded or available")"
