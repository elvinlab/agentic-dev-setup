#!/usr/bin/env bash
# Verifies restore.sh: caveman/RTK are opt-in and the compaction window is set.
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export HOME="$TMP/home"
S="$HOME/.claude/settings.json"
fail() { echo "FAIL: $*" >&2; exit 1; }
fresh() { mkdir -p "$HOME/.claude"; echo '{"hooks":{"SessionStart":[],"PreToolUse":[]}}' > "$S"; }
run() { bash "$REPO/home/.config/agent-routing/restore.sh" >/dev/null 2>&1; }

fresh; run
! grep -q 'Caveman ULTRA' "$S" || fail "caveman added by default"
! grep -q 'rtk hook claude' "$S" || fail "rtk added by default"
[ "$(jq -r '.env.CLAUDE_CODE_AUTO_COMPACT_WINDOW' "$S")" = "250000" ] || fail "compact window not 250000"
[ "$(jq -r '.outputStyle' "$S")" = "Gentleman" ] || fail "output style lost"

before="$(sha256sum "$S")"; run
[ "$before" = "$(sha256sum "$S")" ] || fail "second run is not a no-op"

fresh; RESTORE_CAVEMAN=1 RESTORE_RTK=1 run
grep -q 'Caveman ULTRA' "$S" || fail "RESTORE_CAVEMAN=1 ignored"
grep -q 'rtk hook claude' "$S" || fail "RESTORE_RTK=1 ignored"

fresh; AUTO_COMPACT_WINDOW=180000 run
[ "$(jq -r '.env.CLAUDE_CODE_AUTO_COMPACT_WINDOW' "$S")" = "180000" ] || fail "window override ignored"

fresh; AUTO_COMPACT_WINDOW=0 run
[ "$(jq -r '.env.CLAUDE_CODE_AUTO_COMPACT_WINDOW // "unset"' "$S")" = "unset" ] || fail "window=0 should leave it unset"

echo "restore settings checks passed."
