# Cross-platform usability (multi-distro Linux + Windows via WSL2)

Repository locator: `odd/tasks/cross-platform-usability.md`

## Objective
Make the repo usable by anyone on Linux (Arch / Debian-Ubuntu / Fedora) and on
Windows through WSL2, and add the onboarding context a newcomer needs — without
duplicating maintenance. Documentation stays English for now; a separate
`*.es.md` set is a deliberate future task.

## Problem
- `scripts/bootstrap.sh` is Arch-only (`pacman`, `yay`/AUR, `ollama-cuda`). It
  crashes on any non-Arch distro, including the default WSL2 Ubuntu.
- No Windows path exists; the whole core is bash + systemd + Omarchy.
- Docs assume the author's exact machine (Omarchy, RTX 3060 12 GB) and never
  address other distros, other GPUs/VRAM, or a WSL2 environment.

## Why
User wants this public dotfile usable by "anyone on Linux or Windows". A fragile
`uname` branch would rot; a full PowerShell port would double maintenance
forever. Decisions taken with the user:
- Windows → **WSL2 documented path** (no native port).
- Bilingual → **separate files, future task**; now English only.
- Bootstrap → **full multi-distro detection** (apt/dnf/pacman), built testable.

## Scope (authorized)
- New sourceable detection lib with unit test.
- Refactor `bootstrap.sh` to consume it; per-manager installs + graceful
  fallbacks to official installers; WSL2 detection and guards.
- Update `README.md` and `docs/SETUP.md`: multi-distro + WSL2, generalized
  hardware/OS assumptions, prerequisites/"who is this for", GPU sizing note.

## Out of scope
- Spanish translations (`README.es.md`, `docs/*.es.md`) — future task.
- Native Windows (PowerShell) port.
- Touching backup/restore/apply-patches logic beyond doc references.

## TDD mode
- Source: global "Strict TDD Mode: enabled"; prior per-task dotfile exception
  does not apply to the new detection logic, which is cheaply unit-testable.
- Resolved: **TDD ON** for the detection lib (RED → GREEN → REFACTOR).
  Runner: plain bash test script (matches existing `tests/test-codex-*.sh`).
- Installs (sudo package managers, systemd, GPU) are not unit-testable →
  functional checks (shellcheck, sourcing, manual verification notes).

## Delivery
- Strategy: `ask-on-risk` (default). Forecast well under ~400 authored lines.

## Tasks
- [x] CPU-1 — `scripts/lib/distro.sh`: pure detection (pkg manager, WSL2 flag) +
      package-name resolution map + install-command builder.
      Route: DELEGATED to opencode elvinlabCode (spec-tight), Claude-reviewed.
      Done: matches spec; 16/16 tests green; shellcheck clean.
- [x] CPU-2 — `tests/test-distro.sh`: asserts manager detection and package
      mapping across pacman/apt/dnf using fake execs on PATH.
      Route: DELEGATED (paired under TDD). RED observed (missing lib), then GREEN.
- [x] CPU-3 — Refactor `scripts/bootstrap.sh` to source `distro.sh`: per-manager
      installs, official-installer fallbacks (opencode any distro, idempotent;
      ollama on non-Arch), WSL2 systemctl guard, header/message generalization.
      Route: DELEGATED + Claude inline fix (opencode auto-install on non-Arch).
      Verified: `bash -n` OK, shellcheck clean, codex tests still green.
- [ ] CPU-4 — Docs: `README.md` + `docs/SETUP.md` multi-distro + WSL2 sections,
      generalize Omarchy/RTX-3060 assumptions, add prerequisites and GPU sizing
      note. Route: delegated writer (Tier 2, elvinlabCode) — code now settled.
- [ ] CPU-5 — Verify: shellcheck bootstrap.sh + distro.sh, run tests/*.sh, doc
      anchor/link sanity. Route: inline + per-action workers as needed.

## Acceptance criteria
- `bootstrap.sh` runs its detection on a non-Arch distro without crashing and
  selects the right package manager (or fails with an actionable message).
- Detection lib has a passing test that covers pacman/apt/dnf.
- Docs let a newcomer on Ubuntu, Fedora, Arch, or WSL2 get to the verification
  checklist without guessing.
- Existing `tests/test-codex-*.sh` still pass; shellcheck clean.

## Applicable checks
- `shellcheck scripts/bootstrap.sh scripts/lib/distro.sh`
- `bash tests/test-distro.sh` (and the existing codex tests)
- Markdown link/anchor review of README.md and docs/SETUP.md

## Progress
- Feature document created after exploration.
- CPU-1/2/3 done (delegated to elvinlabCode, Claude-reviewed + fixed).
  Verified: `bash tests/test-distro.sh` 16/16, shellcheck clean on all three,
  `bash -n scripts/bootstrap.sh` OK, existing codex tests still pass.
- Claude fix on top of delegation: OpenCode now auto-installs via official
  script on non-Arch (was echo-only), idempotent guard added.

## Next step
CPU-4: docs (README.md + docs/SETUP.md) — delegate to elvinlabCode.
