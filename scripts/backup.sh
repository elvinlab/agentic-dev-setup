#!/usr/bin/env bash
# ENCRYPTED backup of secrets and data that do NOT go in git.
# Usage: ./scripts/backup.sh   → creates ~/ai-backup-YYYYMMDD-HHMM.tar.gz.age
# Requires: age (sudo pacman -S age) and, optionally, sqlite3 (sudo pacman -S sqlite)
#
# Store the resulting file OFF this machine (USB drive, cloud) and the password
# in your password manager. Without the password it cannot be restored.
set -euo pipefail

command -v age >/dev/null || { echo "Missing age: sudo pacman -S age"; exit 1; }

STAMP="$(date +%Y%m%d-%H%M)"
WORK="$(mktemp -d)"
DEST="$HOME/ai-backup-$STAMP.tar.gz.age"
trap 'rm -rf "$WORK"' EXIT

copy() {  # copy <source> <relative-destination>
  if [ -e "$1" ]; then
    mkdir -p "$WORK/$(dirname "$2")"
    cp -a "$1" "$WORK/$2"
    echo "  ✔ $1"
  else
    echo "  – (missing) $1"
  fi
}

sqlite_copy() {  # consistent copy even while the program is running
  if [ -f "$1" ]; then
    mkdir -p "$WORK/$(dirname "$2")"
    if command -v sqlite3 >/dev/null; then
      sqlite3 "$1" ".backup '$WORK/$2'"
    else
      echo "  ⚠ no sqlite3: copying directly (better stop the program first)"
      cp -a "$1" "$WORK/$2"
    fi
    echo "  ✔ $1"
  else
    echo "  – (missing) $1"
  fi
}

echo "Collecting…"
# OmniRoute: .env (includes STORAGE_ENCRYPTION_KEY) + database (providers, combos, filters)
copy        "$HOME/.omniroute/.env"             omniroute/.env
sqlite_copy "$HOME/.omniroute/storage.sqlite"   omniroute/storage.sqlite

# Engram: your agents' memory
sqlite_copy "$HOME/.engram/engram.db"           engram/engram.db

# Shell secrets
copy "$HOME/.config/secrets"                    secrets

# References (regenerated, but useful for comparison)
copy "$HOME/.config/opencode/opencode.json"     reference/opencode.json
copy "$HOME/.claude/CLAUDE.md"                  reference/CLAUDE.md
copy "$HOME/.bashrc"                            reference/bashrc

# herdr (VERIFY the real path of its configuration on your machine)
copy "$HOME/.config/herdr"                      herdr

echo "Encrypting (it will ask for a password)…"
tar -C "$WORK" -czf - . | age -p -o "$DEST"
chmod 600 "$DEST"
echo "✔ Backup ready: $DEST"
echo "  Copy it off this machine and store the password in your password manager."
