# Secrets guide

How secrets are handled and how to keep them out of git and out of the AI.

---

## Where secrets live

| Secret | Location | Notes |
|-------|----------|-------|
| `OMNIROUTE_API_KEY` | `~/.config/secrets/ai.env` | `chmod 600` |
| Provider API keys | OmniRoute (`~/.omniroute/.env` + `storage.sqlite`) | Backed up in an age-encrypted archive |

**Nothing is committed to git.** `.gitignore` already blocks `*.env`, `*.age`, `secrets/`, `*.sqlite`, and `*.db`.

---

## Why they can't end up in git

- `.gitignore` blocks `*.env` (but keeps `*.env.example`), `*.age`, `secrets/`, `*.sqlite`, and `*.db`
- Configs reference env vars, never literal keys: Codex `env_key = "OMNIROUTE_API_KEY"`, OpenCode provider `{env:OMNIROUTE_API_KEY}`
- The secrets file lives in `~/.config`, outside any repo

---

## Avoid pasting keys in the wrong place

- Never put a literal key in a tracked file, a prompt, a commit, or an issue
- Always use the env/secrets file (`~/.config/secrets/ai.env`)
- Always `chmod 600` the secrets file

---

## Avoid secrets reaching the AI

- Delegation sends your task + the code files the agent reads/edits, **not** your shell env or `~/.config/secrets/`
- Never paste keys/tokens into a prompt
- Don't ask an agent to read secret files, the age backup, or `~/.omniroute/.env`
- OmniRoute injects provider keys server-side, so they are not in prompt content

---

## Extra hardening (optional)

- A pre-commit secret scanner (e.g. `gitleaks`)
- GitHub secret scanning / push protection on your fork

---

## If a key leaks

- Rotate it at the provider immediately
- If it was ever committed, rotating is required (git history keeps it)

---

## See also

- [`SETUP.md`](SETUP.md) — install, rebuild, and verification
- [`../SECURITY.md`](../SECURITY.md) — short policy / how to report a vulnerability