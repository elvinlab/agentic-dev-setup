# Setup guide

How to back up the environment and rebuild it on a fresh [Omarchy](https://omarchy.org) install.

**This repository contains no secrets.** Secrets and data live in a separate encrypted backup.

---

## Before reinstalling (or once a week)

Create the encrypted backup:

```bash
sudo pacman -S --needed age sqlite
./scripts/backup.sh
```

It generates `~/ai-backup-YYYYMMDD-HHMM.tar.gz.age` containing:

- `~/.omniroute/.env` and `storage.sqlite`: providers, combos, filters and the key that decrypts them
- `~/.engram/engram.db`: your agents' memory
- `~/.config/secrets/`: your OmniRoute key
- The herdr configuration, plus reference copies of `opencode.json`, `CLAUDE.md` and `.bashrc`

The backup does **not** include anything Codex-related. The repo-managed Codex additions (profiles, `codex.sh` launchers and the `AGENTS.md` delegation block) are reproduced by rerunning `./scripts/apply-patches.sh`. Your own `~/.codex` auth and config stay user-managed: this repo never copies them, so sign in to Codex again on a fresh machine.

**Copy that file off the machine** (USB drive or cloud) and store the password in your password manager. Without it there is no restore.

---

## Rebuild on a fresh Omarchy

### 1. Get the repo and the backup

Clone the repo and copy the `.age` file to your `$HOME`.

### 2. Install and configure

```bash
chmod +x scripts/*.sh
./scripts/bootstrap.sh
```

It installs the packages, OpenCode, Node and OmniRoute, copies the configuration (creating `~/.config/agent-routing/*.env` from the `.example` files when they don't exist yet), sets up Ollama on demand and pulls `qwen3:14b`.

At the end it lists what must be installed manually: **Claude Code**, **Gentle AI** and **herdr**. Install them following their official documentation.

Review `~/.config/agent-routing/cloud.env` and `local.env` and adjust the model names if your combos differ.

### 3. Restore the data

With OmniRoute and OpenCode closed:

```bash
./scripts/restore-data.sh ~/ai-backup-YYYYMMDD-HHMM.tar.gz.age
```

Without a backup, recreate OmniRoute manually following [`OMNIROUTE.md`](OMNIROUTE.md).

### 4. Gentle AI (also installs Engram)

```bash
gentle-ai install --agent claude-code,opencode --dry-run   # review first
gentle-ai install --agent claude-code,opencode
```

### 5. Apply the custom additions

```bash
./scripts/apply-patches.sh
```

Adds the OmniRoute provider to OpenCode and the delegation block to `CLAUDE.md` without overwriting Gentle AI's configuration. Safe to rerun after every `gentle-ai install`.

It also sets up **Codex** as an independent peer orchestrator (a fallback brain next to Claude Code, not a delegated agent):

- Installs the profiles `~/.codex/elvinlab-cloud.config.toml` and `elvinlab-local.config.toml` (OmniRoute at `127.0.0.1:20128`, `wire_api = "responses"`, key from `OMNIROUTE_API_KEY`) through `scripts/install-codex-profiles.sh`.
- Installs the launchers `~/.bashrc.d/codex.sh`: `codex-cloud` (`codex --profile elvinlab-cloud`, combo `elvinlabCode`) and `codex-local` (`codex --profile elvinlab-local`, combo `elvinlabLocal`).
- Injects the tier delegation block into `~/.codex/AGENTS.md`, outside Gentle AI's managed regions (markers `<!-- elvinlab:delegation-codex -->`). Codex must be installed and have created `AGENTS.md` first; otherwise the script says so, and you rerun it afterwards.

Your own `~/.codex` config and auth are never touched. If a profile or launcher already exists with different content, the installer refuses to overwrite it: move it aside or compare it manually, then rerun.

Codex shares Engram and `~/.config/agent-routing/active.env` with Claude Code, so `agent-profile cloud|local` switches both brains, and Codex delegates trivial and bounded work to OpenCode with the same tiers.

### 6. herdr skill for Claude Code

```bash
npx skills add herdrdev/herdr --skill herdr -g
```

### 7. Open a new terminal

So it loads `~/.bashrc.d/ai.sh` and your secrets.

---

## Verification

```bash
# OmniRoute
omniroute                                   # in its own pane
ss -tlnp | grep 20128                       # → 127.0.0.1:20128
curl -s http://localhost:20128/v1/models    # → Authentication required

# Ollama
ollama-up                                   # in its own pane
ollama run qwen3:14b "hello" && ollama ps   # → 100% GPU, context 16384

# OpenCode
echo ${#OMNIROUTE_API_KEY}                  # → number > 0
opencode models omniroute                   # → elvinlabCode, elvinlabFast, elvinlabLocal

# Delegation
agent-profile                               # → Active: cloud
grep -c '<!-- elvinlab:delegation -->' ~/.claude/CLAUDE.md   # → 1

# Codex (peer orchestrator; OmniRoute must be running, plus Ollama for codex-local)
ls ~/.codex/elvinlab-*.config.toml          # → elvinlab-cloud… and elvinlab-local…
grep -c '<!-- elvinlab:delegation-codex -->' ~/.codex/AGENTS.md   # → 1
codex-cloud "reply pong"                    # → pong (via elvinlabCode)
codex-local "reply pong"                    # → pong (via elvinlabLocal)
```

In Claude Code (inside herdr): `echo $HERDR_ENV` → `1`, `/mcp` → engram connected. Then ask it to write a test **without mentioning herdr**: it should delegate to OpenCode and review the diff.

In the OmniRoute dashboard: test each combo with ▶ and confirm it resolves on the first step.

---

## Daily routine

1. `pkill voxtype` if it is running (frees ~3 GB of VRAM)
2. Pane 1: `omniroute`
3. Pane 2: `ollama-up`
4. Claude Code and OpenCode in your project (or `codex-cloud` / `codex-local` as the fallback brain)
5. When done: Ctrl+C in both panes and `ollama-down`

Delegation profiles: `agent-profile` (show), `agent-profile cloud` / `agent-profile local` (switch).

Monitoring in OmniRoute: *Combos → elvinlabCode* (success per step), *Combo Studio* (live), *Logs* (errors), *Provider Quota* (usage).

---

## Roadmap

- Configure voxtype to use the CPU or a smaller model
- herdr script that opens the whole layout with one command
- Evaluate a lighter Gentle AI preset for OpenCode (~50k tokens per request)
- Report the `_omnirouteInternalRequest` / `_omnirouteSkipContextRelay` bug to OmniRoute

Known problems and fixes: [`LESSONS.md`](LESSONS.md).
