# ~/.bashrc.d/gentle-ai.sh — keep local patches after Gentle AI rewrites its files.
# The gentle-ai TUI, install, sync, upgrade and restore regenerate CLAUDE.md and
# settings.json. Re-apply this repo's patches right after they succeed.
# Hooks and agents call other subcommands (review, version...) and are untouched.
# Set AGENTIC_SETUP_DIR if the repo is not in the default location.
gentle-ai() {
  command gentle-ai "$@"
  local rc=$?
  [ "$rc" -eq 0 ] || return "$rc"
  case "${1:-}" in
    ""|install|sync|upgrade|restore) ;;
    *) return 0 ;;
  esac
  local arg
  for arg in "$@"; do
    case "$arg" in --dry-run|--help|-h) return 0 ;; esac
  done
  local repo="${AGENTIC_SETUP_DIR:-$HOME/Projects/repositories/agentic-dev-setup}"
  if [ -r "$repo/scripts/apply-patches.sh" ]; then
    echo "→ re-applying local patches ($repo)"
    bash "$repo/scripts/apply-patches.sh" || echo "⚠ apply-patches.sh failed; rerun it manually" >&2
  fi
  return 0
}
