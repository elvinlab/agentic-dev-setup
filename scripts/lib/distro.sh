#!/usr/bin/env bash
# Distro detection and package management helpers
# Source-only: no side effects at source time.

distro_detect_manager() {
  if command -v pacman >/dev/null; then
    printf 'pacman'
  elif command -v apt-get >/dev/null; then
    printf 'apt'
  elif command -v dnf >/dev/null; then
    printf 'dnf'
  fi
}

distro_is_wsl() {
  local file
  for file in /proc/sys/kernel/osrelease /proc/version; do
    if [[ -f "$file" ]] && grep -qi microsoft "$file"; then
      return 0
    fi
  done
  return 1
}

distro_resolve_pkg() {
  local manager="$1"
  local logical="$2"
  case "$manager:$logical" in
    apt:sqlite)        printf 'sqlite3' ;;
    pacman:sqlite)     printf 'sqlite' ;;
    dnf:sqlite)        printf 'sqlite' ;;
    pacman:ollama)     printf 'ollama' ;;
    pacman:ollama-cuda) printf 'ollama-cuda' ;;
    apt:git|pacman:git|dnf:git)           printf 'git' ;;
    apt:jq|pacman:jq|dnf:jq)              printf 'jq' ;;
    apt:age|pacman:age|dnf:age)           printf 'age' ;;
    *) return 1 ;;
  esac
}

distro_install_cmd() {
  local manager="$1"
  case "$manager" in
    pacman) printf 'sudo pacman -S --needed --noconfirm' ;;
    apt)    printf 'sudo apt-get install -y' ;;
    dnf)    printf 'sudo dnf install -y' ;;
    *) return 1 ;;
  esac
}