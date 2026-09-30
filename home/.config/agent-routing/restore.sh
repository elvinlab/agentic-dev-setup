#!/usr/bin/env bash
# Restore the token-optimization + caveman setup after a gentle-ai reinstall/update.
#
# gentle-ai owns ~/.claude/settings.json (persona + permissions components) and may
# overwrite the caveman SessionStart hook and the outputStyle on a full reinstall.
# This script re-applies everything that lives outside gentle-ai's control, plus the
# settings.json values gentle-ai can clobber (outputStyle, the caveman SessionStart
# hook, and the RTK PreToolUse hook). It is IDEMPOTENT: safe to run any
# time; it only changes what is missing or wrong and backs up settings.json first.
#
# Usage:  bash ~/.config/agent-routing/restore.sh
set -euo pipefail

SETTINGS="$HOME/.claude/settings.json"
ROUTING="$HOME/.config/agent-routing/active.env"
CAVEMAN_SKILL="$HOME/.claude/skills/caveman/SKILL.md"
OPENCODE="$HOME/.config/opencode/opencode.json"
MARKER="Caveman ULTRA mode is active"

CAVEMAN_TEXT="Caveman ULTRA mode is active for this entire session. Follow the caveman skill at ~/.claude/skills/caveman/SKILL.md, ultra intensity. Compress every response and every pre-tool status line: drop articles, filler, hedging, pleasantries; fragments OK; state each fact once; strip conjunctions only when cause-effect stays unambiguous. Never alter code, function or API names, CLI commands, error strings, numbers, or units, and never drop the words not, never, no, only, except. Drop caveman for security warnings, irreversible-action confirmations, and any multi-step sequence whose order could be misread, then resume. Keep the user language and the active output style language and rules; caveman compresses only, it never overrides safety, clarity, or language. Apply the style directly; do not call the Skill tool. Persist until the user says stop caveman or normal mode."

# 1) Model-routing file (herdr -> opencode tiers). Outside gentle-ai; recreate if missing.
mkdir -p "$(dirname "$ROUTING")"
if [ ! -f "$ROUTING" ]; then
  cat > "$ROUTING" <<'EOF'
# Active model routing for Claude Code -> opencode delegation (herdr).
# Read by the orchestrator before every delegation; used as: opencode -m <model>.
# Values are opencode model IDs (see ~/.config/opencode/opencode.json, provider "omniroute").
TIER1_MODEL=omniroute/elvinlabFast
TIER2_MODEL=omniroute/elvinlabCode
EOF
  echo "[restore] created $ROUTING"
else
  echo "[restore] active.env present"
fi

# 2) settings.json values gentle-ai can overwrite. Requires jq and an existing file.
if ! command -v jq >/dev/null 2>&1; then
  echo "[restore] ERROR: jq not found; cannot patch settings.json" >&2
  exit 1
fi
if [ ! -f "$SETTINGS" ]; then
  echo "[restore] ERROR: $SETTINGS not found; run 'gentle-ai install' first" >&2
  exit 1
fi
cp "$SETTINGS" "$SETTINGS.bak.$(date +%s)"
# Keep only the 5 most recent backups.
ls -1t "$SETTINGS".bak.* 2>/dev/null | tail -n +6 | xargs -r rm -f

# 2a) Keep the active output style on Gentleman.
jq '.outputStyle = "Gentleman"' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"

# 2b) Ensure the caveman ULTRA SessionStart hook is present (add only if missing).
if grep -q "$MARKER" "$SETTINGS"; then
  echo "[restore] caveman hook present"
else
  PAYLOAD=$(jq -nc --arg ctx "$CAVEMAN_TEXT" \
    '{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:$ctx}}')
  CMD="echo '$PAYLOAD'"
  jq --arg cmd "$CMD" \
    '.hooks.SessionStart += [ { "hooks":[ {"command":$cmd,"type":"command"} ], "matcher":"startup|resume|clear|compact" } ]' \
    "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
  echo "[restore] caveman hook re-added"
fi

# 2c) Ensure the RTK PreToolUse hook is present (compacts Bash output; add only if missing).
if grep -q 'rtk hook claude' "$SETTINGS"; then
  echo "[restore] rtk hook present"
else
  jq '.hooks.PreToolUse += [ { "hooks":[ {"command":"rtk hook claude","type":"command"} ], "matcher":"Bash" } ]' \
    "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
  echo "[restore] rtk hook re-added"
fi

# 3) Caveman skill files (independent of gentle-ai; cannot be regenerated here).
if [ -f "$CAVEMAN_SKILL" ]; then
  echo "[restore] caveman skill present"
else
  echo "[restore] WARN: caveman skill missing at $CAVEMAN_SKILL (reinstall the caveman skill)" >&2
fi

# 4) Autonomous opencode permission ceiling (top-level "permission"). gentle-ai manages
#    the "agent" block in opencode.json (__managed_by: gentle-ai/sdd) and a reinstall can
#    drop this top-level key, which would make delegated opencode work bounce on every
#    edit/bash. Re-inject the broad-safe ceiling if missing. --auto auto-approves anything
#    not explicitly "deny", so every dangerous rule is "deny" (never "ask").
if [ ! -f "$OPENCODE" ]; then
  echo "[restore] WARN: opencode config missing at $OPENCODE (install opencode)" >&2
elif jq -e '.permission' "$OPENCODE" >/dev/null 2>&1; then
  echo "[restore] opencode permission present"
else
  cp "$OPENCODE" "$OPENCODE.bak.$(date +%s)"
  ls -1t "$OPENCODE".bak.* 2>/dev/null | tail -n +6 | xargs -r rm -f
  jq '.permission = {
      "read":"allow","list":"allow","glob":"allow","grep":"allow",
      "edit":"allow","webfetch":"allow","websearch":"allow",
      "bash":{
        "*":"allow",
        "git push*":"deny","git push":"deny",
        "gh pr merge*":"deny","gh release*":"deny","gh auth*":"deny",
        "wrangler*":"deny",
        "pnpm deploy":"deny","pnpm run deploy":"deny","pnpm --filter web run deploy":"deny",
        "rm -rf *":"deny","rm -fr *":"deny",
        "ssh *":"deny","scp *":"deny","rsync *":"deny"
      }
    }' "$OPENCODE" > "$OPENCODE.tmp" && mv "$OPENCODE.tmp" "$OPENCODE"
  echo "[restore] opencode permission re-added"
fi

echo "[restore] done."
