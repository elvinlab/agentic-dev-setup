#!/usr/bin/env bash
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
export HOME="$tmp/home"
export CODEX_HOME="$HOME/.codex"
mkdir -p "$CODEX_HOME"
printf 'model = "user-model"\n' > "$CODEX_HOME/config.toml"
printf 'auth sentinel\n' > "$CODEX_HOME/auth.json"
printf 'model = "unrelated"\n' > "$CODEX_HOME/unrelated.config.toml"
mkdir -p "$HOME/.bashrc.d"

bash "$REPO/scripts/install-codex-profiles.sh"
cp "$CODEX_HOME/elvinlab-cloud.config.toml" "$tmp/cloud.before"
cp "$CODEX_HOME/elvinlab-local.config.toml" "$tmp/local.before"
cp "$HOME/.bashrc.d/codex.sh" "$tmp/helper.before"
bash "$REPO/scripts/install-codex-profiles.sh"
cmp "$tmp/cloud.before" "$CODEX_HOME/elvinlab-cloud.config.toml"
cmp "$tmp/local.before" "$CODEX_HOME/elvinlab-local.config.toml"
cmp "$tmp/helper.before" "$HOME/.bashrc.d/codex.sh"
[[ "$(cat "$CODEX_HOME/config.toml")" == 'model = "user-model"' ]]
[[ "$(cat "$CODEX_HOME/auth.json")" == 'auth sentinel' ]]
[[ "$(cat "$CODEX_HOME/unrelated.config.toml")" == 'model = "unrelated"' ]]
grep -q -- '--profile elvinlab-cloud' "$HOME/.bashrc.d/codex.sh"
grep -q -- '--profile elvinlab-local' "$HOME/.bashrc.d/codex.sh"

if python3 - "$CODEX_HOME" <<'PY'
import pathlib, sys, tomllib
root = pathlib.Path(sys.argv[1])
expected = {"elvinlab-cloud": "elvinlabCode", "elvinlab-local": "elvinlabLocal"}
for profile, model in expected.items():
    data = tomllib.loads((root / f"{profile}.config.toml").read_text())
    assert data["model"] == model
    assert data["model_provider"] == "omniroute"
    provider = data["model_providers"]["omniroute"]
    assert provider["wire_api"] == "responses"
    assert provider["env_key"] == "OMNIROUTE_API_KEY"
    assert "api_key" not in provider
    assert provider["base_url"] == "http://127.0.0.1:20128/v1"
PY
then :; else exit 1; fi

# A conflicting helper is preserved and causes a preflight failure before profiles are added.
export CODEX_HOME="$tmp/conflict-codex"
mkdir -p "$CODEX_HOME" "$tmp/conflict-home/.bashrc.d"
export HOME="$tmp/conflict-home"
printf 'user helper\n' > "$HOME/.bashrc.d/codex.sh"
if bash "$REPO/scripts/install-codex-profiles.sh" 2>"$tmp/error"; then
  echo 'Expected installer to reject a conflicting shell helper' >&2
  exit 1
fi
grep -q 'Refusing to replace existing Codex shell helper' "$tmp/error"
[[ "$(cat "$HOME/.bashrc.d/codex.sh")" == 'user helper' ]]
[[ ! -e "$CODEX_HOME/elvinlab-cloud.config.toml" ]]

# Conflicting symlinks are refused without modifying their target.
export HOME="$tmp/symlink-home"
mkdir -p "$HOME/.bashrc.d"
printf 'symlink target\n' > "$tmp/symlink-target"
ln -s "$tmp/symlink-target" "$HOME/.bashrc.d/codex.sh"
if bash "$REPO/scripts/install-codex-profiles.sh" 2>"$tmp/error"; then
  echo 'Expected installer to reject a conflicting shell-helper symlink' >&2
  exit 1
fi
grep -q 'Refusing to replace existing Codex shell helper' "$tmp/error"
[[ "$(cat "$tmp/symlink-target")" == 'symlink target' ]]
echo 'Codex profile installer checks passed.'
