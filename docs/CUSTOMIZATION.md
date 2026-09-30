# Customization guide

Everything here is an example — make it yours.

---

## Model routing profiles

Routing profiles live in `~/.config/agent-routing/*.env`. Each file sets:

- `TIER1_MODEL` — the combo for trivial work (renames, lint, i18n, commit messages)
- `TIER2_MODEL` — the combo for bounded work (tests, boilerplate, docs, simple components)

The repo ships two examples:

| File | TIER1_MODEL | TIER2_MODEL |
|------|-------------|-------------|
| `cloud.env.example` | `omniroute/elvinlabFast` | `omniroute/elvinlabCode` |
| `local.env.example` | `omniroute/elvinlabLocal` | `omniroute/elvinlabLocal` |

On first run, `bootstrap.sh` copies these to `cloud.env` and `local.env` (without the `.example` suffix) if they don't already exist. You can create additional profiles — `work.env`, `offline.env`, etc. — and switch between them with:

```bash
agent-profile          # show active profile and list all available
agent-profile cloud    # activate cloud.env
agent-profile local    # activate local.env
agent-profile work     # activate work.env (if you created it)
```

The `agent-profile` shell function (in `~/.bashrc.d/ai.sh`) **auto-discovers** every `*.env` file in `~/.config/agent-routing/`. No registration step is needed.

---

## OmniRoute combos & providers

The combo names `elvinlabFast`, `elvinlabCode`, and `elvinlabLocal` are just OmniRoute combo IDs. You are free to:

- Rename combos in the OmniRoute dashboard (see [`OMNIROUTE.md`](OMNIROUTE.md))
- Reorder or replace the provider steps inside a combo
- Add or remove providers entirely

**If you rename a combo**, update the matching `*.env` file so `TIER1_MODEL` and/or `TIER2_MODEL` point at the new name (e.g., `omniroute/myFastCombo`).

---

## Codex profiles

Codex profiles live in `~/.codex/elvinlab-*.config.toml` (installed from `home/.config/codex-profiles/*.toml`). Each file contains:

```toml
model = "<combo>"
model_provider = "omniroute"
```

The launcher aliases `codex-cloud` and `codex-local` are defined in `~/.bashrc.d/codex.sh`:

| Command | Profile | Combo |
|---------|---------|-------|
| `codex-cloud` | `elvinlab-cloud` | `elvinlabCode` |
| `codex-local` | `elvinlab-local` | `elvinlabLocal` |

The profile filenames, the internal `model` value, and the launcher alias names are all **yours to change**. Rename the `.toml` file, change the `model` field, update the alias in `codex.sh` — they just need to agree with each other.

---

## The local model & GPU tuning

`qwen3:14b` is a **default**, not a requirement. Any Ollama model works. Swap it by editing the `elvinlabLocal` combo in the OmniRoute dashboard (or whichever combo points to Ollama) to use your preferred model tag.

GPU/VRAM and context tuning lives in `system/etc/systemd/system/ollama.service.d/override.conf`:

| Setting | Example value | Purpose |
|---------|---------------|---------|
| `OLLAMA_CONTEXT_LENGTH` | `16384` | Context window size |
| `OLLAMA_KV_CACHE_TYPE` | `q8_0` | Quantization for KV cache (halves memory) |
| `OLLAMA_FLASH_ATTENTION` | `1` | Enable flash attention |
| `OLLAMA_NUM_PARALLEL` | `1` | One request at a time |
| `OLLAMA_MAX_LOADED_MODELS` | `1` | Never load two models simultaneously |
| `OLLAMA_KEEP_ALIVE` | `30m` | Keep model warm during a session |

Adjust these for your VRAM and model. You can also run Ollama your own way (manual `ollama serve`, Docker, etc.) and point the OmniRoute Ollama provider at your endpoint.

---

## What NOT to rename

The following **marker comments are functional** — scripts grep for them to achieve idempotency:

- `<!-- elvinlab:delegation -->` — marks the delegation block injected into `~/.claude/CLAUDE.md` by `scripts/apply-patches.sh`
- `<!-- elvinlab:delegation-codex -->` — marks the delegation block injected into `~/.codex/AGENTS.md` by `scripts/install-codex-profiles.sh`

**Do not change these markers** unless you also update the corresponding scripts (`apply-patches.sh` and `install-codex-profiles.sh`). They are the only thing that lets the patch scripts find the right place without overwriting your other configuration.

---

## See also

- [`SETUP.md`](SETUP.md) — install, rebuild, and verification
- [`OMNIROUTE.md`](OMNIROUTE.md) — providers, combos, filters, and compression