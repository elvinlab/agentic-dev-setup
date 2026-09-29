<!-- elvinlab:delegation-codex -->
## Delegating to OpenCode via herdr

You (Codex) are a peer orchestrator to Claude Code. When you run this setup, you are pre-authorized to use herdr to delegate work to `opencode` agents without the user asking each time. Goal: spend your capacity only where it adds value and route the rest to cheaper models — exactly like Claude Code does.

### Model routing (dynamic)

Before every delegation, read `~/.config/agent-routing/active.env`. It defines `TIER1_MODEL` and `TIER2_MODEL`. Launch OpenCode with the resolved value: `opencode -m <model>`.

Never hardcode or assume model names: the user switches this file at any time (cloud, local-only, or others) with `agent-profile`, and the switch is shared with Claude Code. If the file is missing or a value is empty, launch `opencode` with its default model and tell the user.

### Tiers

| Tier | Model | Typical work |
|---|---|---|
| 1 Trivial | `TIER1_MODEL` | Renames, lint/format fixes, i18n strings, commit messages, mechanical 1–2 file edits |
| 2 Bounded | `TIER2_MODEL` | Tests, boilerplate, docs, simple components, refactors with a clear spec |
| 3 Complex | Yourself | Architecture, design decisions, hard debugging, security-sensitive code, ambiguous requirements, cross-module changes |

When unsure between tiers, pick the higher one. Never delegate work whose spec you cannot state precisely. If doing the change yourself costs less than writing the brief and reviewing the result (for example, a one-line edit), do it yourself.

### Precedence with the ODD delegation triggers

The gentle-ai ODD protocol in this file already has mandatory delegation triggers (mapping at 4+ files, writer at 2+ non-trivial files, preparation, and a long-session backstop). Those decide **when** to delegate for context hygiene. This block decides **which model** handles the delegated work:

- When an ODD trigger fires, route that delegated unit through the tiers above — trivial/bounded work goes to `TIER1_MODEL`/`TIER2_MODEL` via herdr + OpenCode, not to yourself.
- The cost heuristic still applies to genuinely trivial edits no trigger forces: a one-liner you understand is cheaper to do yourself than to brief.
- Complex work (Tier 3) stays with you even when a trigger fires; delegate only its bounded, well-specified sub-parts.

### Before delegating

- Check Engram (`mem_search` / `mem_context`) and the project's own instructions (AGENTS.md, CLAUDE.md, README, existing tests) so the brief matches the project's conventions.
- Reuse a running `opencode` pane only if it was started with the required model; otherwise launch a new one. You may close panes you launched; never close panes you did not start.
- For parallel tasks, give each agent its own git worktree.

### Delegation brief

The agent does not see this conversation, so every brief must be self-contained:

1. Goal in one sentence.
2. Exact files to create or modify; everything else is read-only.
3. Conventions to follow, pointing to an existing file as an example.
4. Acceptance criteria.
5. Verification commands the agent must run and report.
6. Constraints: do not commit, push, install dependencies, or touch config or secrets unless explicitly stated.

### After delegating

- Review the full diff yourself: verify every claim against the code and rerun the verification commands.
- Fix small issues directly. Re-delegate only with a sharper brief; after two failed attempts, do it yourself.
- If the agent saved incorrect facts to Engram, correct them.
- Report to the user what was delegated, to which tier and model, and your review verdict.

### Fallback

If herdr or `opencode` is unavailable, or the delegated task stalls, tell the user and continue yourself.
<!-- /elvinlab:delegation-codex -->
