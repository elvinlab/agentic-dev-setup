#!/usr/bin/env bash
# Verifies scripts/doctor.sh: passes on a fully patched fixture and flags each regression.
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export HOME="$TMP/home"
fail() { echo "FAIL: $*" >&2; exit 1; }

build() { # a healthy fixture: every managed file in its patched state
  rm -rf "$HOME"; mkdir -p "$HOME/.claude/deferred" "$HOME/.config/opencode" "$HOME/.config/agent-routing" "$HOME/.codex" "$HOME/.bashrc.d"
  cat > "$HOME/.claude/CLAUDE.md" <<'MD'
claude/deferred/review-contract.md
claude/deferred/defect-handoff.md
<!-- elvinlab:delegation -->
block
<!-- /elvinlab:delegation -->
MD
  : > "$HOME/.claude/deferred/review-contract.md"; : > "$HOME/.claude/deferred/defect-handoff.md"
  echo '{"env":{"CLAUDE_CODE_AUTO_COMPACT_WINDOW":"250000"},"outputStyle":"Gentleman","hooks":{"UserPromptSubmit":[{"hooks":[{"command":"echo ROUTING CHECK (herdr)"}]}]}}' > "$HOME/.claude/settings.json"
  echo '{"permission":{"doom_loop":"deny"},"agent":{"build":{"steps":200},"gentle-ai-worker":{"steps":200},"gentle-orchestrator":{"steps":200}}}' > "$HOME/.config/opencode/opencode.json"
  echo '<!-- elvinlab:delegation-codex -->' > "$HOME/.codex/AGENTS.md"
  printf 'TIER1_MODEL=a\nTIER2_MODEL=b\n' > "$HOME/.config/agent-routing/active.env"
  : > "$HOME/.bashrc.d/gentle-ai.sh"
  # shellcheck disable=SC2016  # literal loader line, as bootstrap.sh writes it
  echo 'for f in ~/.bashrc.d/*.sh; do [ -r "$f" ] && . "$f"; done' > "$HOME/.bashrc"
}
doctor() { bash "$REPO/scripts/doctor.sh" 2>&1; }
expect_flag() { # <label> <text the report must contain>
  local out rc=0; out="$(doctor)" || rc=$?
  [ "$rc" != 0 ] || fail "$1: exit code 0 on a broken setup"
  grep -q "$2" <<<"$out" || fail "$1: report lacks '$2'"
}

build
out="$(doctor)" || fail "healthy fixture reported problems: $out"

build; echo 'no stubs' > "$HOME/.claude/CLAUDE.md";             expect_flag "unslimmed CLAUDE.md" "slim-claude-md"
build; jq 'del(.env)' "$HOME/.claude/settings.json" > "$TMP/s" && mv "$TMP/s" "$HOME/.claude/settings.json"; expect_flag "window missing" "AUTO_COMPACT_WINDOW"
build; jq 'del(.env)' "$HOME/.claude/settings.json" > "$TMP/s" && mv "$TMP/s" "$HOME/.claude/settings.json"; AUTO_COMPACT_WINDOW=0 doctor >/dev/null || fail "window=0 must not require the setting"
build; jq '.hooks.UserPromptSubmit += [{"hooks":[{"command":"codegraph prompt-hook"}]}]' "$HOME/.claude/settings.json" > "$TMP/s" && mv "$TMP/s" "$HOME/.claude/settings.json"; expect_flag "codegraph hook back" "codegraph"
build; jq '.permission.doom_loop="ask"' "$HOME/.config/opencode/opencode.json" > "$TMP/o" && mv "$TMP/o" "$HOME/.config/opencode/opencode.json"; expect_flag "doom_loop" "doom_loop"
build; jq 'del(.agent.build.steps)' "$HOME/.config/opencode/opencode.json" > "$TMP/o" && mv "$TMP/o" "$HOME/.config/opencode/opencode.json"; expect_flag "steps" "steps"
build; rm "$HOME/.bashrc.d/gentle-ai.sh";                       expect_flag "wrapper missing" "gentle-ai.sh"
build; sed -i 's/ROUTING CHECK/x/' "$HOME/.claude/settings.json"; expect_flag "routing hook" "tier-routing"

# The report must tell the user how to repair.
build; rm "$HOME/.bashrc.d/gentle-ai.sh"
grep -q 'apply-patches.sh' <<<"$(doctor || true)" || fail "no repair hint"

echo "doctor checks passed."
