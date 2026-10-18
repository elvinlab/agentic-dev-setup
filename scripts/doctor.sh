#!/usr/bin/env bash
# Read-only check that the local patches are still in place after updating
# gentle-ai, Claude Code, OpenCode or Engram. Exit 1 when something regressed.
# Honors the same knobs as restore.sh: AUTO_COMPACT_WINDOW (0 = not managed),
# KEEP_CODEGRAPH_HOOK=1.
# shellcheck disable=SC2317,SC2329  # the predicates below are called through check()
set -uo pipefail

CM="$HOME/.claude/CLAUDE.md"
ST="$HOME/.claude/settings.json"
OC="$HOME/.config/opencode/opencode.json"
AG="$HOME/.codex/AGENTS.md"
bad=0

ok()   { echo "✔ $1"; }
warn() { echo "⚠ $1"; }
nok()  { echo "✘ $1"; bad=1; }

# check <description> <fix hint> <command...>: ok when the command succeeds.
check() { local d="$1" h="$2"; shift 2; if "$@" >/dev/null 2>&1; then ok "$d"; else nok "$d — $h"; fi; }

deferred_ok() {
  grep -q 'claude/deferred/review-contract.md' "$CM" && grep -q 'claude/deferred/defect-handoff.md' "$CM" &&
    [ -f "$HOME/.claude/deferred/review-contract.md" ] && [ -f "$HOME/.claude/deferred/defect-handoff.md" ]
}
no_codegraph_hook() { ! grep -q 'codegraph prompt-hook' "$ST"; }
tiers_ok() {
  local f="$HOME/.config/agent-routing/active.env"
  grep -q '^TIER1_MODEL=.' "$f" && grep -q '^TIER2_MODEL=.' "$f"
}
wrapper_ok() { [ -f "$HOME/.bashrc.d/gentle-ai.sh" ] && grep -q 'bashrc.d' "$HOME/.bashrc"; }

# CLAUDE.md: delegation block present once, review contract and handoff deferred.
if [ -f "$CM" ]; then
  check "CLAUDE.md: delegation block present once" "run scripts/apply-patches.sh" \
    test "$(grep -c '<!-- elvinlab:delegation -->' "$CM")" = 1
  check "CLAUDE.md: review contract and defect handoff deferred ($(wc -c < "$CM") bytes)" \
    "gentle-ai restored them; run scripts/slim-claude-md.sh (or apply-patches.sh)" \
    deferred_ok
else
  nok "CLAUDE.md missing — run scripts/apply-patches.sh"
fi

# settings.json: output style, compact window, routing hook, no codegraph prompt hook.
if [ -f "$ST" ]; then
  check "settings: output style is Gentleman" "run home/.config/agent-routing/restore.sh" \
    test "$(jq -r '.outputStyle // empty' "$ST")" = Gentleman
  if [ "${AUTO_COMPACT_WINDOW:-250000}" = "0" ]; then
    warn "settings: auto-compact window not managed (AUTO_COMPACT_WINDOW=0)"
  else
    check "settings: auto-compact window = ${AUTO_COMPACT_WINDOW:-250000}" \
      "set AUTO_COMPACT_WINDOW via restore.sh; if it is set, this Claude Code version may have renamed CLAUDE_CODE_AUTO_COMPACT_WINDOW" \
      test "$(jq -r '.env.CLAUDE_CODE_AUTO_COMPACT_WINDOW // empty' "$ST")" = "${AUTO_COMPACT_WINDOW:-250000}"
  fi
  check "settings: herdr tier-routing hook present" "run restore.sh" grep -q 'ROUTING CHECK (herdr)' "$ST"
  if [ "${KEEP_CODEGRAPH_HOOK:-0}" = "1" ]; then
    warn "settings: codegraph prompt-hook kept (KEEP_CODEGRAPH_HOOK=1)"
  else
    check "settings: codegraph prompt-hook absent" "gentle-ai re-added it; run restore.sh" \
      no_codegraph_hook
  fi
else
  nok "settings.json missing — run gentle-ai install, then scripts/apply-patches.sh"
fi

# OpenCode: loop guards.
if [ -f "$OC" ]; then
  check "opencode: permission.doom_loop = deny" "run scripts/apply-patches.sh; OpenCode may have renamed the key" \
    test "$(jq -r '.permission.doom_loop // empty' "$OC")" = deny
  for a in build gentle-ai-worker gentle-orchestrator; do
    # shellcheck disable=SC2016  # $a is a jq variable, not a shell expansion
    check "opencode: agent $a has steps" "run scripts/apply-patches.sh" \
      jq -e --arg a "$a" '.agent[$a].steps | numbers' "$OC"
  done
else
  nok "opencode.json missing — run gentle-ai install --agent opencode, then scripts/apply-patches.sh"
fi

# Codex is optional.
if [ -f "$AG" ]; then
  check "codex: delegation block present" "run scripts/apply-patches.sh" grep -q '<!-- elvinlab:delegation-codex -->' "$AG"
else
  warn "codex: AGENTS.md not found, skipped"
fi

# Model routing and the gentle-ai wrapper.
check "routing: active.env defines TIER1_MODEL and TIER2_MODEL" "restore ~/.config/agent-routing/active.env" \
  tiers_ok
check "shell: ~/.bashrc.d/gentle-ai.sh wrapper installed and loaded" "run scripts/bootstrap.sh" \
  wrapper_ok

if [ "$bad" = 0 ]; then echo "All checks passed."; else echo "Something regressed. To repair: bash scripts/apply-patches.sh"; fi
exit "$bad"
