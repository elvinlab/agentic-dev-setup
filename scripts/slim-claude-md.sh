#!/usr/bin/env bash
# Moves rarely-used sections of ~/.claude/CLAUDE.md into on-demand files under
# ~/.claude/deferred/, leaving a short mandatory-read stub in their place.
# CLAUDE.md is loaded on every session and subagent; these sections only matter
# when a native review runs or a Gentle AI defect is being handed off.
# Idempotent: gentle-ai regenerates the full text, so run it after every sync.
set -euo pipefail

CM="$HOME/.claude/CLAUDE.md"
DEF="$HOME/.claude/deferred"

[ -f "$CM" ] || { echo "✘ $CM does not exist — nothing to slim"; exit 0; }

# defer_section <name> <start-regex> <end-regex> <stub-text>
# Cuts from the first line matching start up to (not including) the next line
# matching end. Skips quietly when the start heading is absent (already slimmed
# or a different gentle-ai version).
defer_section() {
  local name="$1" start_re="$2" end_re="$3" stub="$4" s e
  s="$(grep -n -m1 -E "$start_re" "$CM" | cut -d: -f1 || true)"
  [ -n "$s" ] || { echo "• $name: already slim or heading not found, skipped"; return 0; }
  e="$(awk -v s="$s" -v re="$end_re" 'NR > s && $0 ~ re { print NR; exit }' "$CM")"
  [ -n "$e" ] || { echo "⚠ $name: end heading not found, skipped"; return 0; }

  mkdir -p "$DEF"
  [ -n "${backed_up:-}" ] || { cp "$CM" "$CM.bak.$(date +%Y%m%d%H%M%S)"; backed_up=1; }
  sed -n "${s},$((e - 1))p" "$CM" > "$DEF/$name.md"
  {
    head -n "$((s - 1))" "$CM"
    printf '%s\n\n' "$stub"
    tail -n "+$e" "$CM"
  } > "$CM.slim.tmp"
  mv "$CM.slim.tmp" "$CM"
  printf '%s\n' "$CM".bak.* | sort -r | tail -n +6 | xargs -r rm -f
  echo "✔ $name: moved $((e - s)) lines to $DEF/$name.md"
}

# shellcheck disable=SC2016  # the stub text is literal markdown with backticks
defer_section review-contract \
  '^#### Review Execution Contract$' '^#### Cost and Context Balance$' \
'#### Review Execution Contract (deferred)

Native review runs only when `gentle-ai review assess` returns `review_due: true` or the user explicitly asks for a review. Before ANY review step (START, STATUS, capture, correction, acknowledgement, or relaying a consent envelope), read `~/.claude/deferred/review-contract.md` in full and follow it exactly. Never run review commands from memory.'

# shellcheck disable=SC2016
defer_section defect-handoff \
  '^#### Gentle AI Provider Defect Handoff \(MANDATORY\)$' '^### Language Domain Contract$' \
'#### Gentle AI Provider Defect Handoff (deferred)

Before relaying any blocking choice envelope that a Gentle AI invocation produced (non-zero exit, typed envelope, refusal), read `~/.claude/deferred/defect-handoff.md` in full and follow it. Failures from the model provider, the client runtime, the environment or the repository are never reported.'
