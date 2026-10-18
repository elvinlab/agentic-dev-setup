#!/usr/bin/env bash
# Verifies scripts/slim-claude-md.sh moves rarely-used sections out of CLAUDE.md.
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export HOME="$TMP/home"
mkdir -p "$HOME/.claude"
CM="$HOME/.claude/CLAUDE.md"

cat > "$CM" <<'EOF'
# Orchestrator

#### Gentle AI Provider Defect Handoff (MANDATORY)

HANDOFF-BODY-LINE

### Language Domain Contract

LANGUAGE-BODY-LINE

#### Review Execution Contract

# Native Compact Review Orchestration

REVIEW-BODY-LINE

#### Cost and Context Balance

COST-BODY-LINE
EOF

fail() { echo "FAIL: $*" >&2; exit 1; }

bash "$REPO/scripts/slim-claude-md.sh" >/dev/null

D="$HOME/.claude/deferred"
grep -q 'REVIEW-BODY-LINE' "$D/review-contract.md" || fail "review body not saved"
grep -q 'HANDOFF-BODY-LINE' "$D/defect-handoff.md" || fail "handoff body not saved"
! grep -q 'REVIEW-BODY-LINE' "$CM" || fail "review body still in CLAUDE.md"
! grep -q 'HANDOFF-BODY-LINE' "$CM" || fail "handoff body still in CLAUDE.md"
grep -q 'LANGUAGE-BODY-LINE' "$CM" || fail "neighbouring section lost"
grep -q 'COST-BODY-LINE' "$CM" || fail "following section lost"
grep -q '~/.claude/deferred/review-contract.md' "$CM" || fail "review stub missing"
grep -q '~/.claude/deferred/defect-handoff.md' "$CM" || fail "handoff stub missing"

before="$(sha256sum "$CM" "$D"/*.md)"
bash "$REPO/scripts/slim-claude-md.sh" >/dev/null
[ "$before" = "$(sha256sum "$CM" "$D"/*.md)" ] || fail "second run is not a no-op"

# A file without the sections must be left untouched and not fail.
printf '# plain\n' > "$CM"
bash "$REPO/scripts/slim-claude-md.sh" >/dev/null
[ "$(cat "$CM")" = "# plain" ] || fail "plain file modified"

echo "slim-claude-md checks passed."
