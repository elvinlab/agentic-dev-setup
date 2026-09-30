# Harden orchestrator hooks (routing + caveman + RTK survive gentle-ai)

Repository locator: `odd/tasks/harden-orchestrator-hooks.md`

## Objective
Reproduce the herdr tier-routing UserPromptSubmit hook in the repo, and make the
three orchestrator hooks (routing, caveman SessionStart, RTK PreToolUse) plus the
Gentleman style and opencode ceiling re-apply automatically after any gentle-ai
install/update — in one step — so they are present in every chat/repo.

## Review of the user's change (read-only, done)
- The user added a 3rd `UserPromptSubmit` hook in ~/.claude/settings.json: it
  sources ~/.config/agent-routing/active.env and emits the ROUTING CHECK
  additionalContext via `jq -cn`, injecting the real TIER1_MODEL/TIER2_MODEL
  (or "default"). matcher:"", type:command, timeout:10. VERDICT: sound — global
  hook → fires in every new chat/repo; reflects the active profile.
- Gap: restore.sh re-applies outputStyle (2a), caveman SessionStart (2b), RTK
  PreToolUse (2c), opencode ceiling (4) — but NOT this routing hook. And
  apply-patches.sh does not run restore.sh, so hooks are only restored when the
  user remembers to run restore.sh manually (step 6).

## Honesty note (documented, not overstated)
gentle-ai OWNS ~/.claude/settings.json and can overwrite these on reinstall.
There is no global Claude Code settings layer that gentle-ai cannot touch, so the
hooks cannot be made literally immune. The robust mitigation is reliable,
one-step re-application: chain restore.sh into apply-patches.sh.

## Scope (authorized)
- restore.sh: add block 2d (routing UserPromptSubmit hook, idempotent, mirroring
  2b/2c). Update the header comment enumeration.
- apply-patches.sh: call restore.sh at the end (guarded so a missing settings.json
  does not hard-fail apply-patches).
- docs/SETUP.md: note apply-patches now re-applies the hooks; add the routing hook
  to the description; state the re-application (not immunity) model.

## Route / TDD
- Inline (Tier 3): bash quoting + jq idempotency are correctness-critical. Verify
  with bash -n, shellcheck, and a real idempotency test against a temp copy of
  settings.json (produced command must byte-match the user's existing hook; a
  second run must NOT double-add).

## Tasks
- [x] HOH-1 — restore.sh block 2d (routing hook) + header comment + SC2016
      disable (the $VARS must stay literal for hook-run-time evaluation).
- [x] HOH-2 — apply-patches.sh chains restore.sh (prefers installed copy, falls
      back to repo copy; guarded so a missing settings.json only warns).
- [x] HOH-3 — docs/SETUP.md: step 5 notes it runs restore; step 6 adds the
      routing hook + the honest "re-applied, not immune" note.
- [x] HOH-4 — Verified: bash -n OK; apply-patches.sh shellcheck clean;
      restore.sh only pre-existing SC2012 (ls) + intentional SC2016 suppressed;
      ROUTING_CMD BYTE-MATCHES the live hook; idempotent (adds once, guard skips
      re-add, valid JSON).

## Acceptance criteria
- restore.sh adds the routing hook only if missing; re-running is a no-op; the
  injected command byte-matches the user's current settings.json hook.
- apply-patches.sh triggers restore.sh; a missing settings.json only warns.
- Docs explain one-step re-application after gentle-ai and its honest limit.

## Next step
HOH-1: edit restore.sh.
