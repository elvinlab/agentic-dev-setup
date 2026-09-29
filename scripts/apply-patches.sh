#!/usr/bin/env bash
# Applies YOUR additions on top of what Gentle AI generates.
# Run AFTER: gentle-ai install --agent claude-code,opencode
# Idempotent: you can run it as many times as you want.
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
OC="$HOME/.config/opencode/opencode.json"
CM="$HOME/.claude/CLAUDE.md"

# Install Codex profile layers and its separately managed shell helpers.
bash "$REPO/scripts/install-codex-profiles.sh"

command -v jq >/dev/null || { echo "Missing jq: sudo pacman -S jq"; exit 1; }

# 1) OmniRoute provider in OpenCode (deep merge, does not overwrite Gentle AI's config)
if [ -f "$OC" ]; then
  cp "$OC" "$OC.bak.$(date +%Y%m%d%H%M%S)"
  jq -s '.[0] * .[1]' "$OC" "$REPO/patches/opencode-provider.json" > /tmp/oc.json
  mv /tmp/oc.json "$OC"
  echo "✔ OpenCode: OmniRoute provider applied"
else
  echo "✘ $OC does not exist — run gentle-ai install --agent opencode first"
fi

# 2) Delegation block in CLAUDE.md (replaces a previous version if present)
mkdir -p "$(dirname "$CM")"
touch "$CM"
cp "$CM" "$CM.bak.$(date +%Y%m%d%H%M%S)"
sed -i '/<!-- elvinlab:delegation -->/,/<!-- \/elvinlab:delegation -->/d' "$CM"
tail -n1 "$CM" | grep -q . && printf '\n' >> "$CM"
cat "$REPO/home/.claude/delegation-block.md" >> "$CM"
echo "✔ CLAUDE.md: delegation block applied ($(grep -c '<!-- elvinlab:delegation -->' "$CM") block)"

echo "Restart Claude Code and OpenCode so they load the changes."
