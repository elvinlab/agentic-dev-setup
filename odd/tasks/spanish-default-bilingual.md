# Spanish-default bilingual docs

Repository locator: `odd/tasks/spanish-default-bilingual.md`

## Objective
Make Spanish the DEFAULT (canonical) language for all prose docs, with English
available as `*.en.md`, and a language switcher on every file.

## Decision (user, 2026-09-30)
- Spanish is the default. Scope = FULL: README + all docs/*.md + CONTRIBUTING +
  SECURITY + CODE_OF_CONDUCT. CHANGELOG.md stays English (technical artifact, not
  in the requested set).
- Separate files per language (agreed earlier).

## Naming scheme (canonical = Spanish)
For each translated file `X`:
- `X.md` (or `X` at its path) = SPANISH content (canonical; README.md is the
  GitHub front page → Spanish).
- `X.en.md` = ENGLISH content (the current file, moved via `git mv` to keep
  history).

Translated set (11 files → 22):
- root: README, CONTRIBUTING, SECURITY, CODE_OF_CONDUCT
- docs/: SETUP, OMNIROUTE, LESSONS, REQUIREMENTS, COMPATIBILITY, CUSTOMIZATION,
  SECRETS

## Language switcher (first content line, after the README banner where present)
- On Spanish `X.md`:   `**Español** · [English](X.en.md)`
- On English `X.en.md`: `[Español](X.md) · **English**`
(Use the correct relative sibling name for each file's location.)

## Link rules (CRITICAL — verified at the end)
- Spanish canonical files link to canonical (Spanish) siblings — same names the
  current English files already use. No change needed to those link targets.
- English `.en.md` files link to `.en.md` siblings for every TRANSLATED file.
- Links to NON-translated files (CHANGELOG.md, scripts/*, system/*, code, and
  external URLs) stay unchanged in both languages.
- README repository-layout code block and anchors: keep as-is (not links).

## Spanish register
Neutral/professional Spanish for technical docs (NOT Rioplatense slang) — the
persona voice governs chat replies only, not artifacts. CODE_OF_CONDUCT uses the
official Contributor Covenant 2.1 Spanish translation.

## Route / TDD
Translation delegated to opencode elvinlabCode per slice; Claude reviews Spanish
quality + rewires/verifies every link. No TDD; verification = a link scan across
all .md confirming each per-language target exists. Docs are passive under RDD.

## Slices (one branch, verify links only after all slices land)
- [x] ES-A — root: README, CONTRIBUTING, SECURITY, CODE_OF_CONDUCT (ES + .en.md). Bounded review fixes applied to contributor language guidance in both languages and the omitted `casta, color` protected characteristics in the Spanish Code of Conduct. Root pairs and switchers verified; final cross-document link validation remains deferred to ES-D.
- [ ] ES-B — docs onboarding: REQUIREMENTS, SETUP, COMPATIBILITY.
- [ ] ES-C — docs deep: OMNIROUTE, CUSTOMIZATION, SECRETS, LESSONS.
- [ ] ES-D — final link scan (every relative .md link resolves per language) +
      confirm switchers present + README front page renders in Spanish.

## Acceptance criteria
- `README.md` is Spanish and is the GitHub front page; `README.en.md` is English.
- Every translated file has both language versions and a working switcher.
- No broken relative links in either language; non-translated targets unchanged.
- CHANGELOG stays English; code/scripts/comments stay English.

## Implementation route
This bounded review-fix task used the delegated route (writer trigger: two non-trivial documentation files). Only the three authorized file edits above plus this task-state update were in scope.

## Delivery strategy
- Strategy: `feature-branch-chain` (user-delegated, 2026-09-30). Keep a no-merge tracker PR for the feature branch; review slices accumulate there and integrate only after all translations are complete because root-document links refer to documents that are still untranslated. Merge the tracker only after ES-D passes.
- Forecast: **894 authored changed lines in ES-A** (observed across its three source commits), disproving the earlier estimate. Revised full-feature forecast: approximately **1,500–1,700 authored changed lines**, including the observed ES-A count, about 585 existing `docs/` prose lines to translate, and estimated switcher/link rewiring. This is an estimate; validate each PR from its actual diff. The 400-line limit guides PR slicing, not code-golf.
- Cohesive future PR slices (each target ≤400 authored changed lines; confirm against actual diffs before opening PRs):
  1. CONTRIBUTING + SECURITY, paired language files — 149 observed authored lines; target ≤400.
  2. CODE_OF_CONDUCT, paired language files — 267 observed authored lines; target ≤400.
  3. README, paired language files — 478 observed authored lines. This is the smallest coherent documentation unit after one honest split and exceeds the 400-line PR budget; do not code-golf. A standalone PR containing this commit requires a `size:exception` before creation.
  4. Docs SETUP + REQUIREMENTS (~261 Spanish source lines plus English link/switcher edits; target ≤400).
  5. Docs COMPATIBILITY + LESSONS + SECRETS (~139 Spanish source lines plus English link/switcher edits; target ≤400).
  6. Docs OMNIROUTE + CUSTOMIZATION (~185 Spanish source lines plus English link/switcher edits; target ≤400).
- Dependency/integration boundary: the slices may be reviewed in order on the feature-branch chain, but do not integrate them into the final target until every translation and the ES-D relative-link scan are complete. Keep the PR tracker draft/no-merge until then.

## ES-A evidence
- `3f7b66b` — contribution/security guides; 149 authored changed lines. Native risk was HIGH because the commit includes `SECURITY`; user explicitly declined review for this candidate.
- `5e76b47` — Code of Conduct; 267 authored changed lines; passive.
- `a3974ac` — Spanish-default README; 478 authored changed lines; passive.
- Verification: `git show --check` passed for all three commits. All four root Spanish/English file pairs exist and each has its expected language switcher. `README.md` has the Spanish switcher and Spanish-localized content at the GitHub front page. These checks do not replace ES-D's full relative-link scan.
- Delivery remains user-owned: no PR or push is authorized. The README commit requires explicit `size:exception` approval before any standalone PR containing it.

## Next step
ES-B — docs onboarding: REQUIREMENTS, SETUP, COMPATIBILITY. Final link validation remains deferred to ES-D.
