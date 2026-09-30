# Lessons learned and troubleshooting

[Español](LESSONS.md) · **English**

## OmniRoute

**A provider always fails with 400 or 422 on real work, but works in the Playground.**
Open the error in *Logs*. It almost always says which parameter is extra (`Unsupported parameter(s): ...`). Add it to that provider's *Param Filters*. Known ones: `__managed_by` (added by Gentle AI), `_omnirouteSkipContextRelay` and `_omnirouteInternalRequest` (leaked by OmniRoute itself).

**Editing a connection's key does not update it (still returns 401).**
Create a new connection with "Add", test it in the Playground, redo the combo steps with the new account and delete the old one.

**"Check" says the key is valid, but the models return 401.**
Some validations query a public model list. The real test is the Playground.

**The combo jumps straight to the last step without trying the first ones.**
The circuit breakers marked those providers as "unhealthy" after many failures. Fix the cause and restart OmniRoute (Ctrl+C and `omniroute`).

**In the combo test, Ollama fails after ~15 s.**
That is the test's time limit; Qwen3 reasons before answering. It works in real use, just slowly. It is the last fallback.

**Error 429.** Free-tier rate limit. Wait 1–2 minutes.

**"system" models in the combo selector fail.** They come from OmniRoute's catalog, not from your account. Prefer the "imported" ones.

## OpenCode + Gentle AI

- Each request sends ~45–50k tokens (Gentle AI instructions + tools). It burns quotas quickly and does not fit in Ollama's 16k context (it arrives truncated).
- Free models sometimes make things up (e.g. they saved to Engram that a project used the Composition API when it used the Options API). That is why Claude always reviews.
- OpenCode always shows the combo name as the model; to see which real model answered, check *Logs* in OmniRoute.

## Claude Code

- `CLAUDE.md` is loaded when the session starts: after editing it, restart Claude Code (`/exit`).
- The herdr skill is only used if the user mentions herdr, or if `CLAUDE.md` authorizes it (the delegation block does).
- It must run inside herdr: `echo $HERDR_ENV` must print `1`.
- If Claude does not see Engram, check `/mcp`; if it is missing, run `engram setup` or `gentle-ai install --agent claude-code`.

## Ollama / GPU

- An empty `ollama ps` is not an error: it only lists models loaded at that moment.
- If `ollama ps` shows something like `31%/69% CPU/GPU`, the model does not fit in VRAM. Check `nvidia-smi`: **voxtype** was using ~3 GB. Close it with `pkill voxtype`.
- Do not start Ollama manually with `ollama serve`: it would look for models in `~/.ollama` (empty) and lose the override. Use `ollama-up` / `ollama-down`.
- The system service runs as the `ollama` user and stores models in `/var/lib/ollama`. Do not switch it to your user (it conflicts with `ProtectHome`).
- Right after restarting the service, `ollama` may say "could not connect": wait 2–3 seconds.

## Bash

- `!` inside double quotes triggers history expansion (`event not found`). Use single quotes.
- `read -s VAR` types nothing visible; paste the key on the next line.
- To copy a variable to the clipboard without printing it: `printf %s "$VAR" | wl-copy`.

## Security

- Never paste keys into chats, screenshots or plain-text files. Provider → OmniRoute → password manager.
- When rotating: get the new key working first, then revoke the old one.
