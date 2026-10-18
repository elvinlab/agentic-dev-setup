#!/usr/bin/env bash
# Verifies patches/opencode-provider.json adds the loop guards without clobbering
# the existing OpenCode config (same deep merge apply-patches.sh uses).
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
fail() { echo "FAIL: $*" >&2; exit 1; }

BASE='{"permission":{"edit":"allow","bash":{"*":"allow","git push *":"ask"}},
       "agent":{"gentle-ai-worker":{"mode":"subagent","prompt":"keep me"},"build":{"model":"x"}}}'
OUT="$(jq -s '.[0] * .[1]' <(echo "$BASE") "$REPO/patches/opencode-provider.json")"
q() { jq -r "$1" <<<"$OUT"; }

[ "$(q '.permission.doom_loop')" = "deny" ] || fail "doom_loop is not deny"
for a in build gentle-ai-worker gentle-orchestrator; do
  s="$(q ".agent[\"$a\"].steps")"
  [[ "$s" =~ ^[0-9]+$ ]] && [ "$s" -ge 50 ] && [ "$s" -le 400 ] || fail "$a steps out of range: $s"
done
[ "$(q '.permission.edit')" = "allow" ] || fail "existing permission lost"
[ "$(q '.permission.bash["git push *"]')" = "ask" ] || fail "existing bash rule lost"
[ "$(q '.agent["gentle-ai-worker"].prompt')" = "keep me" ] || fail "agent prompt overwritten"
[ "$(q '.agent.build.model')" = "x" ] || fail "agent model overwritten"
[ "$(q '.model')" = "omniroute/elvinlabCode" ] || fail "provider patch lost"

echo "opencode patch checks passed."
