# Customization guide + README documentation map

Repository locator: `odd/tasks/customization-and-doc-map.md`

## Objective
Make clear that nothing is locked to the author's names/profiles: the combo
names, routing profiles, Codex profiles, local model and GPU tuning are all
examples and fully customizable. Add a README documentation map ("I want X → go
here"). English now.

## Why
Newcomers should not feel married to `elvinlabCode`/`elvinlab-cloud`/`qwen3:14b`
or to one way of running locally. And the docs need a front-door index so people
find the right file fast.

## Customization surface (verified in-repo)
- Routing profiles: `~/.config/agent-routing/*.env` set `TIER1_MODEL` /
  `TIER2_MODEL` to `omniroute/<combo>`. `agent-profile` (in home/.bashrc.d/ai.sh)
  AUTO-DISCOVERS any `*.env`, so users can add their own profiles
  (e.g. `work.env`, `offline.env`) and switch with `agent-profile <name>`.
- OmniRoute combos + providers: user-defined in the dashboard (docs/OMNIROUTE.md);
  rename, reorder, swap providers freely.
- Codex profiles: `home/.config/codex-profiles/*.toml` (`model = "<combo>"`);
  launcher aliases `codex-cloud`/`codex-local` in home/.bashrc.d/codex.sh.
- Local model + GPU tuning: `qwen3:14b` is a default (any Ollama model works);
  VRAM/context tuning in system/etc/.../ollama.service.d/override.conf.
- Naming honesty: combo/profile/model/alias names are cosmetic and free to
  rename; the `<!-- elvinlab:delegation -->` / `elvinlab:delegation-codex`
  MARKER comments are functional (apply-patches.sh / install-codex-profiles.sh
  grep for them) — leave them or update the scripts too.

## Secrets surface (verified in-repo)
- `.gitignore` already blocks `*.env` (keeps `*.env.example`), `*.age`,
  `secrets/`, `*.sqlite`, `*.db`. No hardcoded secrets in tracked files (scanned).
- Only `OMNIROUTE_API_KEY` is needed locally, in `~/.config/secrets/ai.env`
  (chmod 600), loaded into env by ai.sh. Provider keys live inside OmniRoute
  (`~/.omniroute/.env` + storage.sqlite), backed up age-encrypted.
- Configs reference env vars, never literal keys: codex `env_key =
  "OMNIROUTE_API_KEY"`, opencode `{env:OMNIROUTE_API_KEY}`.
- Avoiding leaks to the AI: delegation sends the task + the code files the agent
  reads/edits — NOT your shell env or ~/.config/secrets/. Never paste keys into a
  prompt; don't ask an agent to read secret files/backups; OmniRoute injects
  provider keys server-side (not prompt content). Rotate at the provider if leaked.

## Scope (authorized)
- New `docs/CUSTOMIZATION.md`: "Make it yours" — what is an example vs required,
  and exactly where/how to change each thing above, keeping name/combo in sync.
- New `docs/SECRETS.md`: where secrets live, how .gitignore protects them, how to
  avoid pasting keys in the wrong place, and how to avoid secrets reaching the AI.
  Cross-link with SECURITY.md (which keeps the short policy note).
- README: a "Documentation" map section (task → doc) + pointers to CUSTOMIZATION
  and SECRETS.

## Out of scope
- Spanish translations (still a future slice).
- Renaming anything in the repo itself.

## Route / TDD
- Docs delegated to opencode elvinlabCode, Claude-reviewed. No TDD; verify links
  + factual accuracy (cosmetic vs functional names).

## Tasks
- [x] CDM-1 — docs/CUSTOMIZATION.md. DELEGATED to elvinlabCode. Accurate; the
      "What NOT to rename" section correctly flags the functional markers.
- [x] CDM-2 — docs/SECRETS.md. DELEGATED. Matches verified facts; links resolve.
- [x] CDM-3 — README "📚 Documentation" map + CUSTOMIZATION/SECRETS pointers.
      DELEGATED. Claude fix: added the missing table header-separator row (table
      would not have rendered on GitHub).
- [x] CDM-4 — Verify (inline): all doc-map links resolve, docs accurate, table
      renders. Delivery: pending user (merge/push).

## Acceptance criteria
- A reader understands every author-specific name is an example and knows the
  exact file to change for profiles, combos, Codex, and the local model.
- README has a scannable "task → doc" map covering all docs.
- No claim that functional marker comments are freely renameable.

## Next step
CDM-1..2: delegate to elvinlabCode.
