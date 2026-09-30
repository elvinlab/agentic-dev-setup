# Audience + model disclosure section (README, both languages)

Repository locator: `odd/tasks/audience-and-model-disclosure.md`

## Objective
Add a README section stating who this setup is for and which model/effort it
was built and run with.

## Why
The setup targets university students building personal projects who cannot or
do not want to pay for an expensive (ultra-tier) subscription. The project is
also developed running Claude Sonnet at medium effort, which sets expectations
for results and cost.

## Content to cover (user request, 2026-09-30)
- Audience: university students / learners building personal projects.
- Constraint: no budget (or no willingness) for a very expensive subscription;
  the setup leans on free cloud tiers + a local model.
- Disclosure: the orchestrator runs on Sonnet at medium effort.

## Scope (authorized: NONE yet, captured for later)
- `README.md` (Spanish, canonical) and `README.en.md`: new section, kept in sync.
- Possibly a one-line pointer in `docs/` if a doc map exists.

## Constraints
- Spanish is the default language; keep both READMEs aligned.
- Follow existing README tone and heading style; no email or claims beyond
  what the repo already documents.

## Tasks
- [x] AUD-1 — Section "Para quién es esto" / "Who this is for" added after the
      intro in both READMEs. INLINE (short prose, tone-sensitive).
- [x] AUD-2 — Verified: no anchors affected, claims match README (US$20, 12 GB
      GPU, idempotent scripts). Committed on docs/audience-disclosure.

## Acceptance criteria
- Both READMEs have the section, equivalent in meaning.
- States audience, budget constraint, and Sonnet-at-medium-effort disclosure.
- Existing anchors and cross-links still resolve.

## Next step
Done. Merge/push is the user's decision.
