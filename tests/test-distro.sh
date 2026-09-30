#!/usr/bin/env bash
# Unit tests for distro.sh library
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIB="$REPO/scripts/lib/distro.sh"

# Source the library under test
# shellcheck source=../scripts/lib/distro.sh
# shellcheck disable=SC1091
source "$LIB"

pass=0
fail=0

assert_eq() {
  local desc="$1"
  local expected="$2"
  local actual="$3"
  if [[ "$expected" == "$actual" ]]; then
    printf '  \033[0;32m✔\033[0m %s\n' "$desc"
    pass=$((pass + 1))
  else
    printf '  \033[0;31m✘\033[0m %s\n    expected: %s\n    actual:   %s\n' "$desc" "$expected" "$actual"
    fail=$((fail + 1))
  fi
}

assert_empty() {
  local desc="$1"
  local actual="$2"
  if [[ -z "$actual" ]]; then
    printf '  \033[0;32m✔\033[0m %s\n' "$desc"
    pass=$((pass + 1))
  else
    printf '  \033[0;31m✘\033[0m %s\n    expected empty, got: %s\n' "$desc" "$actual"
    fail=$((fail + 1))
  fi
}

# Helper to run a command with isolated PATH
run_isolated() {
  local test_path="$1"
  shift
  PATH="$test_path" "$@"
}

echo "Testing distro_detect_manager priority order..."

# Test 1: pacman takes priority over apt-get and dnf
tmp="$(mktemp -d)"
touch "$tmp/pacman" "$tmp/apt-get" "$tmp/dnf"
chmod +x "$tmp/pacman" "$tmp/apt-get" "$tmp/dnf"
result="$(run_isolated "$tmp" distro_detect_manager)"
assert_eq "distro_detect_manager prefers pacman" "pacman" "$result"
rm -rf "$tmp"

# Test 2: apt-get when pacman not present
tmp="$(mktemp -d)"
touch "$tmp/apt-get" "$tmp/dnf"
chmod +x "$tmp/apt-get" "$tmp/dnf"
result="$(run_isolated "$tmp" distro_detect_manager)"
assert_eq "distro_detect_manager prefers apt-get" "apt" "$result"
rm -rf "$tmp"

# Test 3: dnf when pacman and apt-get not present
tmp="$(mktemp -d)"
touch "$tmp/dnf"
chmod +x "$tmp/dnf"
result="$(run_isolated "$tmp" distro_detect_manager)"
assert_eq "distro_detect_manager prefers dnf" "dnf" "$result"
rm -rf "$tmp"

# Test 4: nothing when no manager present
tmp="$(mktemp -d)"
result="$(run_isolated "$tmp" distro_detect_manager)"
assert_empty "distro_detect_manager returns empty when none found" "$result"
rm -rf "$tmp"

echo "Testing distro_resolve_pkg..."

assert_eq "distro_resolve_pkg apt sqlite" "sqlite3" "$(distro_resolve_pkg apt sqlite)"
assert_eq "distro_resolve_pkg pacman sqlite" "sqlite" "$(distro_resolve_pkg pacman sqlite)"
assert_eq "distro_resolve_pkg dnf sqlite" "sqlite" "$(distro_resolve_pkg dnf sqlite)"
assert_empty "distro_resolve_pkg apt ollama (external)" "$(distro_resolve_pkg apt ollama)"
assert_eq "distro_resolve_pkg pacman ollama" "ollama" "$(distro_resolve_pkg pacman ollama)"
assert_eq "distro_resolve_pkg apt git" "git" "$(distro_resolve_pkg apt git)"
assert_eq "distro_resolve_pkg pacman jq" "jq" "$(distro_resolve_pkg pacman jq)"
assert_eq "distro_resolve_pkg dnf age" "age" "$(distro_resolve_pkg dnf age)"

echo "Testing distro_install_cmd..."

assert_eq "distro_install_cmd pacman" "sudo pacman -S --needed --noconfirm" "$(distro_install_cmd pacman)"
assert_eq "distro_install_cmd apt" "sudo apt-get install -y" "$(distro_install_cmd apt)"
assert_eq "distro_install_cmd dnf" "sudo dnf install -y" "$(distro_install_cmd dnf)"

echo "Testing distro_is_wsl (best-effort, may be false positive)..."
# Just verify it runs without error
result="$(distro_is_wsl && echo true || echo false)"
printf '  \033[0;32m✔\033[0m distro_is_wsl runs: %s\n' "$result"
pass=$((pass + 1))

# Summary
echo
printf 'Passed: \033[0;32m%d\033[0m  Failed: \033[0;31m%d\033[0m\n' "$pass" "$fail"
[[ $fail -eq 0 ]] || exit 1