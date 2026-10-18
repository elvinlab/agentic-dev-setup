#!/usr/bin/env bash
# Applies YOUR additions on top of what Gentle AI generates.
# Run AFTER: gentle-ai install --agent claude-code,opencode
# Idempotent: you can run it as many times as you want.
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
OC="$HOME/.config/opencode/opencode.json"
CM="$HOME/.claude/CLAUDE.md"
AG="$HOME/.codex/AGENTS.md"

# Install Codex profile layers and its separately managed shell helpers.
bash "$REPO/scripts/install-codex-profiles.sh"

command -v jq >/dev/null || { echo "Missing jq: sudo pacman -S jq"; exit 1; }

# Keep only the 5 most recent timestamped backups of a file.
prune_backups() { ls -1t "$1".bak.* 2>/dev/null | tail -n +6 | xargs -r rm -f; }

# 1) OmniRoute provider in OpenCode (deep merge, does not overwrite Gentle AI's config)
if [ -f "$OC" ]; then
  cp "$OC" "$OC.bak.$(date +%Y%m%d%H%M%S)"
  jq -s '.[0] * .[1]' "$OC" "$REPO/patches/opencode-provider.json" > /tmp/oc.json
  mv /tmp/oc.json "$OC"
  prune_backups "$OC"
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
prune_backups "$CM"
echo "✔ CLAUDE.md: delegation block applied ($(grep -c '<!-- elvinlab:delegation -->' "$CM") block)"

# 2b) Slim CLAUDE.md: move the review contract and defect handoff to on-demand
#     files (loaded every session and subagent otherwise). gentle-ai sync
#     restores them, so this runs on every apply.
bash "$REPO/scripts/slim-claude-md.sh"

# 3) Codex peer delegation block in AGENTS.md (outside gentle-ai managed regions)
if [ -f "$AG" ]; then
  cp "$AG" "$AG.bak.$(date +%Y%m%d%H%M%S)"
  sed -i '/<!-- elvinlab:delegation-codex -->/,/<!-- \/elvinlab:delegation-codex -->/d' "$AG"
  tail -n1 "$AG" | grep -q . && printf '\n' >> "$AG"
  cat "$REPO/home/.codex/delegation-block.md" >> "$AG"
  prune_backups "$AG"
  echo "✔ AGENTS.md: Codex delegation block applied ($(grep -c '<!-- elvinlab:delegation-codex -->' "$AG") block)"
else
  echo "✘ $AG does not exist — install Codex first, then rerun"
fi

# 4) Re-apply the orchestrator settings gentle-ai can clobber (idempotent):
#    Gentleman style, auto-compact window, the herdr tier-routing UserPromptSubmit
#    hook, and the opencode permission ceiling (caveman and RTK are opt-in).
#    Guarded so a missing settings.json only warns instead of failing the patch.
# Use the repo copy so a freshly pulled version runs, not a possibly stale
# installed one.
bash "$REPO/home/.config/agent-routing/restore.sh" || echo "⚠ restore.sh did not complete (see its output above); rerun it after 'gentle-ai install'"

echo "Restart Claude Code, Codex and OpenCode so they load the changes."
