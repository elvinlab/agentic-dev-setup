#!/usr/bin/env bash
# Install repo-managed Codex profile layers without replacing user config/auth.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE="$REPO/home/.config/codex-profiles"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
SHELL_SOURCE="$REPO/home/.bashrc.d/codex.sh"
SHELL_DIR="$HOME/.bashrc.d"
SHELL_DEST="$SHELL_DIR/codex.sh"

mkdir -p "$CODEX_HOME"
mkdir -p "$SHELL_DIR"
for name in elvinlab-cloud elvinlab-local; do
  src="$SOURCE/$name.config.toml"
  dest="$CODEX_HOME/$name.config.toml"
  if [[ -e "$dest" || -L "$dest" ]]; then
    cmp -s "$src" "$dest" && continue
    printf 'Refusing to replace existing Codex profile: %s\n' "$dest" >&2
    printf 'Move it aside or compare it manually, then rerun this installer.\n' >&2
    exit 1
  fi
done
if [[ -e "$SHELL_DEST" || -L "$SHELL_DEST" ]] && ! cmp -s "$SHELL_SOURCE" "$SHELL_DEST"; then
  printf 'Refusing to replace existing Codex shell helper: %s\n' "$SHELL_DEST" >&2
  printf 'Move it aside or compare it manually, then rerun this installer.\n' >&2
  exit 1
fi

for name in elvinlab-cloud elvinlab-local; do
  src="$SOURCE/$name.config.toml"
  dest="$CODEX_HOME/$name.config.toml"
  if [[ -e "$dest" || -L "$dest" ]]; then
    printf 'Codex profile already current: %s\n' "$dest"
    continue
  fi
  install -m 600 "$src" "$dest"
  printf 'Installed Codex profile: %s\n' "$dest"
done

if [[ -e "$SHELL_DEST" || -L "$SHELL_DEST" ]]; then
  printf 'Codex shell helper already current: %s\n' "$SHELL_DEST"
else
  install -m 644 "$SHELL_SOURCE" "$SHELL_DEST"
  printf 'Installed Codex shell helper: %s\n' "$SHELL_DEST"
fi
