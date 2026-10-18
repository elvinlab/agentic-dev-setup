#!/usr/bin/env bash
# Verifies the gentle-ai shell wrapper in home/.bashrc.d/gentle-ai.sh re-applies the
# local patches only after commands that rewrite Gentle AI managed files.
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export HOME="$TMP/home"
mkdir -p "$HOME" "$TMP/bin" "$TMP/setup/scripts"

cat > "$TMP/bin/gentle-ai" <<'EOF'
#!/usr/bin/env bash
echo "$*" >> "$TMP_LOG"
[ "${FAKE_RC:-0}" = "0" ] || exit "$FAKE_RC"
EOF
cat > "$TMP/setup/scripts/apply-patches.sh" <<'EOF'
#!/usr/bin/env bash
echo patched >> "$TMP_PATCHES"
EOF
chmod +x "$TMP/bin/gentle-ai"
export PATH="$TMP/bin:$PATH" TMP_LOG="$TMP/log" TMP_PATCHES="$TMP/patches"
export AGENTIC_SETUP_DIR="$TMP/setup"

# shellcheck disable=SC1091
. "$REPO/home/.bashrc.d/gentle-ai.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }
patches() { [ -f "$TMP_PATCHES" ] && wc -l < "$TMP_PATCHES" | tr -d ' ' || echo 0; }

expect() { # <expected patch count> <label> -- args...
  local want="$1" label="$2"; shift 3
  rm -f "$TMP_PATCHES"
  gentle-ai "$@" >/dev/null 2>&1 || true
  [ "$(patches)" = "$want" ] || fail "$label: expected $want patch run(s), got $(patches)"
}

expect 1 "TUI (no args)" --
expect 1 "sync"          -- sync
expect 1 "install"       -- install --agent claude-code
expect 1 "upgrade"       -- upgrade
expect 1 "restore"       -- restore
expect 0 "sync --dry-run" -- sync --dry-run
expect 0 "review"        -- review status --cwd .
expect 0 "version"       -- version
expect 0 "help"          -- --help

FAKE_RC=3; export FAKE_RC
rm -f "$TMP_PATCHES"
rc=0; gentle-ai sync >/dev/null 2>&1 || rc=$?
[ "$rc" = "3" ] || fail "exit code not propagated (got $rc)"
[ "$(patches)" = "0" ] || fail "patched after a failed command"
unset FAKE_RC

AGENTIC_SETUP_DIR="$TMP/missing"
rc=0; gentle-ai sync >/dev/null 2>&1 || rc=$?
[ "$rc" = "0" ] || fail "missing repo should not fail the command (got $rc)"

echo "gentle-ai wrapper checks passed."
