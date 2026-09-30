# Requirements

[Español](REQUIREMENTS.md) · **English**

What you need before starting — accounts, hardware, OS, software, and knowledge. No surprises, no hidden costs.

---

## 💰 What it costs

**The ONLY paid thing is Claude Pro: US$20/month.**

Claude Code runs by logging in with that subscription — **no Anthropic API key, no usage billing**. Everything else is free: cloud providers are free tiers, the local model is free/open-source, and every tool is free/open-source.

**Why this architecture:** Claude Pro has usage limits. This environment delegates trivial and bounded work to free models (through OmniRoute + OpenCode) and keeps Claude's limited premium capacity for the hard, high-value work. That is the whole point.

---

## 🔑 Accounts you need

| Account | Cost | Why | Where |
|---------|------|-----|-------|
| **Claude Pro** | US$20/mo | Run Claude Code (the main brain) | [claude.ai](https://claude.ai) |
| **GitHub** | free | Clone this repo (and push your own fork) | [github.com](https://github.com) |
| **NVIDIA NIM** | free dev tier | Cloud model provider | [build.nvidia.com](https://build.nvidia.com) |
| **Mistral** | free tier (phone verification) | Cloud model provider | [console.mistral.ai](https://console.mistral.ai) |
| **Google AI Studio** | free (never enable billing) | Cloud model provider | [aistudio.google.com](https://aistudio.google.com) |
| **Groq** | free tier | Cloud model provider | [console.groq.com](https://console.groq.com) |

**Notes:**
- **NO OpenAI/ChatGPT account is needed:** Codex (the optional peer brain) routes through the local OmniRoute gateway, not OpenAI.
- **OmniRoute runs locally** (self-hosted, no account); you set a local dashboard password.
- For the exact provider key setup and combos, see [`OMNIROUTE.md`](OMNIROUTE.en.md).

---

## 🖥 Hardware

**Reference machine (tested on):** AMD Ryzen 5 5600X, NVIDIA GeForce RTX 3060 12 GB. (See [README's "My workstation"](../README.en.md#-my-workstation) table.)

**Generalize:** Any x86_64 Linux machine. An NVIDIA GPU is recommended to run the local model; ~12 GB VRAM fits `qwen3:14b` at 16k context. With less VRAM, use a smaller model or shorter context. With no NVIDIA GPU, the local model runs on CPU (much slower) and you can lean on the free cloud combos instead.

**Disk:** Enough for the Ollama model (`qwen3:14b` is ~9 GB) plus the tools.

**RAM:** A few GB of free RAM (no specific requirement known).

---

## 🐧 Operating system

The author's machine is Omarchy 4 (Arch + Hyprland), but it is **NOT required**.

**Supported:** Arch, Debian/Ubuntu, Fedora, or Windows via WSL2.

For install details and the Windows/WSL2 path, see [`SETUP.md`](SETUP.en.md).

---

## 🧰 Software

**Installed by `bootstrap.sh`:** git, jq, age, sqlite, Node LTS (via mise), Ollama.

**Installed manually** (per their official docs): **Claude Code**, **Gentle AI** (which also installs Engram), **herdr**, **OmniRoute** (npm), and optionally **Codex** (peer).

The exact tested versions live in the "Versions this setup was tested with" section of the [README](../README.en.md).

---

## 🧠 What you should already know

- Comfortable in a terminal and with basic bash.
- Basic git (clone, branch, commit).
- Basic tmux or terminal panes (you run OmniRoute, Ollama and the agents side by side).
- Comfortable editing config files (env, JSON, TOML).
- A basic mental model of LLM agents and API keys, and how a gateway/proxy routes a request to different providers.
- Understanding that free models can be wrong, so a human reviews the output.
- **NOT required:** machine-learning or model-training knowledge.

---

Ready to start? See [`SETUP.md`](SETUP.en.md) for the bootstrap and install steps.
