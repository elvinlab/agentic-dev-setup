# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-09-30

### Added

- **Claude Code** as primary orchestrator with **Codex** as an independent peer brain
- **Delegation to OpenCode via herdr**, routed by **OmniRoute** across free cloud providers (NVIDIA NIM, Mistral, Gemini, Groq) with a local `qwen3:14b` fallback
- **Engram** shared memory across all agents and sessions
- **Multi-distro bootstrap** supporting Arch/pacman, Debian-Ubuntu/apt, Fedora/dnf, and Windows via WSL2
- **Documentation**: SETUP, OMNIROUTE, LESSONS, REQUIREMENTS, COMPATIBILITY
- **Contribution surface**: CONTRIBUTING, issue/PR templates, CI (shellcheck + tests), SECURITY, CODE_OF_CONDUCT

[1.0.0]: https://github.com/elvinlab/agentic-dev-setup/releases/tag/v1.0.0