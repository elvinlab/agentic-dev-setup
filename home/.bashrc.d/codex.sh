# Codex as an independent peer orchestrator using repo-managed OmniRoute profiles.
codex-cloud() {
  command codex --profile elvinlab-cloud "$@"
}

codex-local() {
  command codex --profile elvinlab-local "$@"
}
