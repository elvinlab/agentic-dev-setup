# Codex as a Peer Orchestrator

## Objective
Add Codex CLI as an independent peer to Claude Code, with selectable OmniRoute cloud and local-model profiles and first-class documentation for operating and rebuilding the environment.

## Problem and Why
The setup currently documents Claude Code as its only top-level orchestrator. Codex CLI is installed on the current workstation but has no repo-managed OmniRoute profiles, launch shortcuts, or setup/recovery guidance. The user wants to open Codex and use it as an independent orchestrator, choosing cloud models or the local qwen model through OmniRoute.

## Scope and Constraints
- Authorized: update repository templates/scripts/docs and install the resulting Codex profiles on this workstation after requesting the required filesystem escalation.
- Codex is a peer orchestrator, not a target for Claude/herdr delegation.
- Reuse OmniRoute's existing `elvinlabCode`, `elvinlabFast`, and `elvinlabLocal` aliases; local inference remains behind OmniRoute, preserving the existing on-demand Ollama lifecycle.
- Preserve `~/.codex/config.toml`, Codex login/auth, plugins, MCP servers, user instructions, and unrelated profiles. Do not read, copy, back up, or modify credential files.
- Do not install/update Codex or start machine services without a separate approval if needed.
- No project test suite or TDD setting was found. User clarified this is dotfile/config work; TDD is not required. Run normal functional/syntax/config checks instead.
- No GitHub access is needed for this local integration.

## Workflow Evidence
- Feature branch: `feat/codex-orchestrator` (branched from `main` at `3c8aa85f319b49a6325a7bc5616aee3f33dfd435`).
- Route: delegated direct; mapping trigger fired because exploration spans 4+ files, and writer trigger fired because implementation changes multiple non-trivial files. A read-only mapping worker and primary-source compatibility research worker have already reported findings. One bounded writer will implement the repository change after reading this document.
- TDD: off for this dotfile task, per user clarification. Ordinary checks: shell syntax, TOML parsing, installer idempotence/preservation, and Codex profile parsing where feasible.
- RDD: global mode is on. Initial empty-candidate assessment was unassessable; `.atl/` and `.codegraph/` are user-created untracked paths and remain outside this feature. An interim workspace assessment with only intended files selected returned high risk (`shell_process` in the installer/shell integration), so review is due. Subsequent COD-1 edits changed the candidate; repeat assessment against its final snapshot. Native status/preflight failed once in the sandbox (`.git` read-only) and, after escalation, requested explicit intended-untracked selection. Do not infer low risk or bypass any gate. User approved the branch switch and review assessment/status commands; no review actor or commit has run yet.
- Delivery strategy: `ask-on-risk` (default). Forecast approximately 380 authored changed lines across two work units, including task tracking; monitor actual committed totals.

## Tasks

### COD-1 — Add Codex OmniRoute profiles and launch workflow
- [x] Add Codex profile templates for the cloud combo and local-only combo, using OmniRoute's Responses-compatible endpoint and environment-sourced API key.
- [x] Add a safe, idempotent installer/launcher workflow and shell commands that select profiles without replacing the user's base Codex configuration or auth.
- [x] Install both profiles and the separate launcher helper on this workstation with explicit escalation approval; no machine services were started.
- **Acceptance:** profile files are valid; installer preserves unrelated configuration and is idempotent; cloud selects `elvinlabCode` and local selects `elvinlabLocal`; no secrets are embedded or copied.
- **Checks:** PASS — `bash -n home/.bashrc.d/ai.sh home/.bashrc.d/codex.sh scripts/install-codex-profiles.sh scripts/apply-patches.sh tests/test-codex-profiles.sh`; `bash tests/test-codex-profiles.sh` (TOML assertions, profile/helper idempotence, preservation of base config/auth/unrelated profile, rejection of conflicting files/symlinks); Codex CLI accepted both `--profile ... --help` in isolated CODEX_HOME; `git diff --check`; confirmed `apply-patches.sh` invokes installer. Temporary CODEX_HOME caused expected PATH-helper warnings; commands exited successfully. Live request is pending because OmniRoute/Ollama were not listening at inspection time.
- **Route:** delegated direct. Trigger evidence: multiple non-trivial config/script files and preparation across the existing setup flow.
- **Commit/evidence:** pending.
- **RDD evidence:** interim workspace assessment high (`shell_process`), review due; re-assess final COD-1 snapshot and then committed-only outcome pending.

### COD-2 — Document Codex peer orchestration and recovery
- [ ] Add Codex orchestration instructions and update README, setup, OmniRoute, backup, and restore guidance to include Codex without implying it is Claude-delegated.
- [ ] Document profile selection, authentication/key sourcing, privacy/routing distinction, on-demand service checks, and verification/rebuild steps.
- **Acceptance:** a fresh-machine reader can set up and verify Codex as a peer orchestrator without overwriting existing Codex settings or confusing cloud/local routing; backup guidance does not include credentials.
- **Checks:** Markdown/link review; script/doc commands match actual implementation; focused full functional checks at task closure.
- **Route:** delegated direct. Trigger evidence: multiple non-trivial documentation and recovery files.
- **Commit/evidence:** pending.
- **RDD evidence:** pending.

## Progress and Next Step
- Exploration and upstream compatibility research completed. Existing Codex is `0.158.0`; OmniRoute is `3.8.50`; the current Codex config already enables native multi-agent support and is user-managed.
- Engram mirror was updated after COD-1 and read back in full; continue syncing after each task.
- COD-1 implementation and focused checks are complete. Escalated installer added `~/.codex/elvinlab-cloud.config.toml`, `~/.codex/elvinlab-local.config.toml`, and `~/.bashrc.d/codex.sh`, refusing conflicts and leaving the user's base config/auth in place by design. Both profiles use the existing OmniRoute aliases; no live inference was tested.
- Next: assess the final COD-1 workspace candidate through native RDD, obtain any required review consent after commit, and close COD-1 with a Conventional Commit. Then delegate COD-2 and keep this file and Engram mirror synchronized.

## Relevant Files
- `home/.bashrc.d/codex.sh` — separate `codex-cloud` and `codex-local` launch helpers.
- `home/.config/codex-profiles/` — repository-managed OmniRoute profile layers.
- `scripts/apply-patches.sh` — idempotent deployment of repo-managed additions.
- `scripts/backup.sh`, `scripts/restore-data.sh` — user configuration backup and rebuild boundary.
- `README.md`, `docs/SETUP.md`, `docs/OMNIROUTE.md` — architecture, setup, routing, and verification.
