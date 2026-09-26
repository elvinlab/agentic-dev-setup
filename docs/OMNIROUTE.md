# OmniRoute configuration (reference)

If you restore `~/.omniroute/.env` + `storage.sqlite` from the backup, all of this is already included. This document is for **recreating it by hand** if you lost the backup, or for checking that everything matches.

Dashboard: `http://localhost:20128`

## Security

- `~/.omniroute/.env` with `OMNIROUTE_SERVER_HOST=127.0.0.1` and `REQUIRE_API_KEY=true` (see [`omniroute/env.additions.example`](../omniroute/env.additions.example)).
- Verify: `ss -tlnp | grep 20128` must show `127.0.0.1:20128`, and `curl -s http://localhost:20128/v1/models` without a key must answer `Authentication required`.
- **Endpoints → "OmniRoute cloud": disabled.** Do not use tunnels.
- **API manager:** one key for OpenCode, **without management access**. Store it in `~/.config/secrets/ai.env`.
- Change the dashboard password in Settings → Security.

## Providers (all with an official API key, "Import only free models" enabled)

| Provider | Key at | Notes |
|---|---|---|
| NVIDIA NIM | build.nvidia.com | Primary. Developer access ~40 req/min |
| Mistral | console.mistral.ai | Free tier with phone verification |
| Gemini (Google AI Studio) | aistudio.google.com → API keys | Choose the **API key** option, not Gemini CLI. **Never** enable billing |
| Groq | console.groq.com | Per-model limits |
| Ollama (local) | — | URL `http://localhost:11434` (or `/v1`). No key |

Discarded: **Cerebras** (402, requires payment), **OpenRouter** (50 req/day is too little), **Zhipu** (complicated sign-up; GLM is already on NIM). Avoid OAuth/session-based providers (Antigravity, Kiro, OpenCode Free via proxy, Gemini CLI): terms-of-service and account-suspension risk.

**Test each key in the provider's Playground**, not with "Check" (it can give false positives).

## Param Filters (essential!)

In **Providers → NVIDIA / Mistral / Groq → Param Filters → Blocked parameters**:

```
__managed_by, _omnirouteSkipContextRelay, _omnirouteInternalRequest
```

Without this, NVIDIA answers 400 and Mistral 422 to real OpenCode + Gentle AI requests.

## Combos (strategy: **Priority** on all)

### elvinlabCode — implementation, quality
1. NVIDIA → `nvidia/nemotron-3-ultra-550b-a55b`
2. Mistral → `codestral` (2508 / latest)
3. Gemini → `gemini-3-flash-preview`
4. Ollama → `qwen3:14b`

### elvinlabFast — short tasks, speed
1. Groq → `openai/gpt-oss-120b`
2. Groq → `openai/gpt-oss-20b` (separate per-model quota)
3. NVIDIA → `nvidia/nemotron-3.5-lightning-30b-a3b`
4. Ollama → `qwen3:14b`

### elvinlabLocal — local AI only
1. Ollama → `qwen3:14b`

When adding each step, make sure **ACCOUNT** is the right connection. If you change or recreate a connection, redo the combo steps that pointed to the old one.

Models that did NOT work (free tier, September 2026): Gemini 2.5 Flash / 2.5 Flash-Lite / Pro (retired for new accounts), Kimi K3 on NIM (works but ~30 s per response), and models marked "system" instead of "imported" are usually unavailable.

## Compression

**Compression Settings:**
- Main switch **Prompt Compression: ON**
- **RTK: ON** at **Minimal** level
- **Session Dedup: ON**
- Everything else off (Lite, CCR, Headroom, Relevance, Caveman…)

RTK: Tool results ON, Code blocks OFF, Assistant messages OFF, raw output retention "never".

## Leave disabled

- OmniRoute's own memory (Engram is already the memory)
- OmniRoute MCP server
- MITM / TPROXY
- Fusion and Auto Combo (for later)
