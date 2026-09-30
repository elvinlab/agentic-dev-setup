# Onboarding context (requirements, accounts, cost, knowledge)

Repository locator: `odd/tasks/onboarding-context.md`

## Objective
Give anyone who wants to try this setup the full context to reproduce it:
the cost (Claude Pro $20/mo, the only paid thing), every account needed, the
hardware/OS/software requirements, the knowledge they should already have, and
the environment it was tested on. English now (Spanish is a future task).

## Confirmed facts (user, 2026-09-30)
- Claude Code runs on **Claude Pro, US$20/mo**, logged in with the subscription
  (no Anthropic API key, no billing). It is the ONLY paid thing; everything else
  is free-tier or open-source.
- Framing: Claude Pro has usage limits; the delegation-to-cheaper-models
  architecture exists to stretch Pro — trivial/bounded work goes to free models
  so Claude's premium capacity is spent only on hard work.
- Codex needs **no OpenAI/ChatGPT account** — its profiles route through the
  local OmniRoute gateway (verified in home/.config/codex-profiles/*.toml).
- Cloud provider accounts (all free tiers) already documented in docs/OMNIROUTE.md:
  NVIDIA NIM, Mistral, Google AI Studio, Groq.

## Scope (authorized)
- New `docs/REQUIREMENTS.md`: cost & accounts, hardware, OS, software prereqs,
  knowledge, tested environment. Cross-link OMNIROUTE.md / SETUP.md, don't duplicate.
- README: add a cost highlight + a short "Requirements & accounts" pointer;
  mention "$20 Claude Pro + free models" framing in the intro/highlights.

## Out of scope
- Spanish translations (future).
- Changing scripts or provider config.
- Duplicating the full OMNIROUTE provider table (link to it).

## Route / TDD
- Route: delegated writer (Tier 2, opencode elvinlabCode), Claude-reviewed.
  Docs-only → no TDD; verification = fact check + link/anchor sanity.

## Tasks
- [x] OBC-1 — docs/REQUIREMENTS.md written from confirmed facts (cost, accounts,
      hardware, OS, software, knowledge). Route: DELEGATED to elvinlabCode.
- [x] OBC-2 — README: cost highlight ($20/month total) + REQUIREMENTS pointer.
      Route: DELEGATED (same run).
- [x] OBC-3 — Verify: facts match confirmed list (no invented accounts/plans/
      numbers). Claude fixes on top: corrected relative links (file lives in
      docs/, so OMNIROUTE.md/SETUP.md are siblings, README is ../README.md),
      removed a leaked brief instruction, dropped a dead <summary> anchor.
      All links resolve.

## Acceptance criteria
- A newcomer can read REQUIREMENTS.md and know exactly what to sign up for, what
  it costs ($20 Claude Pro only), what hardware/OS works, and what they should
  already know — without guessing.
- No fabricated accounts, plans, prices, RAM/disk figures beyond the known ones.

## Status: COMPLETE (on branch feat/onboarding-context)
All facts verified against the user-confirmed list. Docs-only; links resolve.
Delivery (merge/push) is the user's decision.
