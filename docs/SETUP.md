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
```

In Claude Code (inside herdr): `echo $HERDR_ENV` → `1`, `/mcp` → engram connected. Then ask it to write a test **without mentioning herdr**: it should delegate to OpenCode and review the diff.

In the OmniRoute dashboard: test each combo with ▶ and confirm it resolves on the first step.

---

## Daily routine

1. `pkill voxtype` if it is running (frees ~3 GB of VRAM)
2. Pane 1: `omniroute`
3. Pane 2: `ollama-up`
4. Claude Code and OpenCode in your project
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
