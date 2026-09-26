#!/usr/bin/env bash
# Restores secrets and data from a backup created with backup.sh
# Usage: ./scripts/restore-data.sh ~/ai-backup-YYYYMMDD-HHMM.tar.gz.age
# IMPORTANT: with OmniRoute and OpenCode CLOSED.
set -euo pipefail

[ $# -eq 1 ] || { echo "Usage: $0 <file.tar.gz.age>"; exit 1; }
command -v age >/dev/null || { echo "Missing age: sudo pacman -S age"; exit 1; }

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

echo "Decrypting (it will ask for the password)…"
age -d "$1" | tar -C "$WORK" -xzf -

restore() {  # restore <relative-in-backup> <destination>
  if [ -e "$WORK/$1" ]; then
    mkdir -p "$(dirname "$2")"
    [ -e "$2" ] && mv "$2" "$2.pre-restore.$(date +%s)"
    cp -a "$WORK/$1" "$2"
    echo "  ✔ $2"
  else
    echo "  – (not in backup) $1"
  fi
}

restore omniroute/.env            "$HOME/.omniroute/.env"
restore omniroute/storage.sqlite  "$HOME/.omniroute/storage.sqlite"
restore engram/engram.db          "$HOME/.engram/engram.db"
restore secrets                   "$HOME/.config/secrets"
restore herdr                     "$HOME/.config/herdr"

chmod 700 "$HOME/.config/secrets" 2>/dev/null || true
chmod 600 "$HOME/.config/secrets/"* 2>/dev/null || true

echo "References (opencode.json, CLAUDE.md, bashrc) were intentionally not restored."
echo "If you need them, decrypt again and review them in: reference/"
echo "✔ Data restore complete."
