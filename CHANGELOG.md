# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `scripts/doctor.sh`: read-only check that the patches survived an update (exit 1 on regression), documented in `docs/SETUP.md` and `docs/SETUP.en.md`.
- `scripts/slim-claude-md.sh`: moves the review contract and defect handoff out of `~/.claude/CLAUDE.md` into on-demand files (about 26% smaller), applied by `apply-patches.sh`
- `restore.sh` sets `CLAUDE_CODE_AUTO_COMPACT_WINDOW` (default 250000, `AUTO_COMPACT_WINDOW` overrides, `0` skips) to cap per-turn cache reads
- `home/.bashrc.d/gentle-ai.sh`: `gentle-ai` shell wrapper that reruns `apply-patches.sh` after the TUI, `install`, `sync`, `upgrade` and `restore` succeed
- OpenCode loop guards in `patches/opencode-provider.json`: `permission.doom_loop = deny` and `steps: 200` for `build`, `gentle-ai-worker` and `gentle-orchestrator`
- Watchdog rule in both delegation blocks: always `--wait --timeout` (max 15 min), read, interrupt and re-brief once on a stall

### Changed

- `restore.sh` removes the codegraph `UserPromptSubmit` hook (about 16 KB of context injected on every prompt); `KEEP_CODEGRAPH_HOOK=1` keeps it.
- Codex delegation block follows the same moderate policy as the Claude one.
- `restore.sh` no longer re-adds the caveman and RTK hooks by default; opt in with `RESTORE_CAVEMAN=1` / `RESTORE_RTK=1`
- Claude delegation block: moderate delegation policy that overrides the ODD inline-writer rule for Tier 1-2 (delegate when the spec is precise and the work takes about 3+ inline turns or 30+ lines; read-only mapping goes to OpenCode too) and a cheap review (`git diff --stat`, rerun checks, read only risky hunks)

## [1.0.0] - 2026-09-30

### Added

- **Claude Code** as primary orchestrator with **Codex** as an independent peer brain
- **Delegation to OpenCode via herdr**, routed by **OmniRoute** across free cloud providers (NVIDIA NIM, Mistral, Gemini, Groq) with a local `qwen3:14b` fallback
- **Engram** shared memory across all agents and sessions
- **Multi-distro bootstrap** supporting Arch/pacman, Debian-Ubuntu/apt, Fedora/dnf, and Windows via WSL2
- **Documentation**: SETUP, OMNIROUTE, LESSONS, REQUIREMENTS, COMPATIBILITY
- **Contribution surface**: CONTRIBUTING, issue/PR templates, CI (shellcheck + tests), SECURITY, CODE_OF_CONDUCT

[1.0.0]: https://github.com/elvinlab/agentic-dev-setup/releases/tag/v1.0.0