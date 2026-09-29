#!/usr/bin/env bash
# Verifies apply-patches.sh injects the Codex delegation block into AGENTS.md
# idempotently, without touching gentle-ai managed regions or user content.
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

command -v jq >/dev/null || { echo "SKIP: jq not installed"; exit 0; }

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
export HOME="$tmp/home"
export CODEX_HOME="$HOME/.codex"
mkdir -p "$CODEX_HOME" "$HOME/.bashrc.d"

# A realistic AGENTS.md: user content + gentle-ai managed regions.
cat > "$CODEX_HOME/AGENTS.md" <<'EOF'
## Rules
- User rule that must survive.

<!-- gentle-ai:agent-routing -->
Managed routing content.
<!-- /gentle-ai:agent-routing -->

<!-- gentle-ai:codegraph-guidance -->
Managed codegraph content.
<!-- /gentle-ai:codegraph-guidance -->
EOF

bash "$REPO/scripts/apply-patches.sh" >/dev/null

# Exactly one Codex block was added.
[[ "$(grep -c '<!-- elvinlab:delegation-codex -->' "$CODEX_HOME/AGENTS.md")" == "1" ]]
# gentle-ai managed regions are intact.
grep -q '<!-- gentle-ai:agent-routing -->' "$CODEX_HOME/AGENTS.md"
grep -q '<!-- gentle-ai:codegraph-guidance -->' "$CODEX_HOME/AGENTS.md"
grep -q 'Managed routing content.' "$CODEX_HOME/AGENTS.md"
# User content is preserved.
grep -q 'User rule that must survive.' "$CODEX_HOME/AGENTS.md"
# The tier table made it in.
grep -q 'TIER1_MODEL' "$CODEX_HOME/AGENTS.md"

# Idempotence: a second run keeps exactly one block.
bash "$REPO/scripts/apply-patches.sh" >/dev/null
[[ "$(grep -c '<!-- elvinlab:delegation-codex -->' "$CODEX_HOME/AGENTS.md")" == "1" ]]
[[ "$(grep -c '<!-- /elvinlab:delegation-codex -->' "$CODEX_HOME/AGENTS.md")" == "1" ]]

# A missing AGENTS.md does not abort the patch run.
rm -f "$CODEX_HOME/AGENTS.md"
bash "$REPO/scripts/apply-patches.sh" >/dev/null
[[ ! -e "$CODEX_HOME/AGENTS.md" ]]

echo 'Codex delegation injection checks passed.'
