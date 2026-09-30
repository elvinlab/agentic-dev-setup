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
- [x] ES-B — docs onboarding: REQUIREMENTS, SETUP, COMPATIBILITY. See ES-B evidence below; its three English links to ES-C files were pending at the time and are now resolved.
- [x] ES-C — docs deep: OMNIROUTE, CUSTOMIZATION, SECRETS, LESSONS. See ES-C evidence below.
- [x] ES-D — final link scan (every relative .md link resolves per language) +
      confirm switchers present + README front page renders in Spanish.

## Acceptance criteria
- `README.md` is Spanish and is the GitHub front page; `README.en.md` is English.
- Every translated file has both language versions and a working switcher.
- No broken relative links in either language; non-translated targets unchanged.
- CHANGELOG stays English; code/scripts/comments stay English.

## Implementation route
The bounded root review-fix task used the delegated route (writer trigger: two non-trivial documentation files). ES-B used delegated-direct writing (writer trigger: three non-trivial documentation files). ES-C used delegated-direct writing (writer trigger: four non-trivial documentation files). ES-D used independent read-only verification, followed by two narrowly scoped passive documentation corrections. TDD is not applicable to these passive documentation translations; no source tests apply.

## Delivery strategy
- Strategy: `feature-branch-chain` (user-delegated, 2026-09-30). Keep a no-merge tracker PR for the feature branch; review slices accumulate there and integrate only after all translations are complete because root-document links refer to documents that are still untranslated. Merge the tracker only after ES-D passes.
- Observed source count: **2,044 authored changed lines across ES-A, ES-B, ES-C, and ES-D corrections** (2,040 + 2 + 2). The ~400-line PR budget guides slicing; it is not a reason to omit docs, shorten translations, or code-golf.
- Cohesive future PR slices (each target ≤400 authored changed lines; confirm against actual diffs before opening PRs):
  1. CONTRIBUTING + SECURITY, paired language files — 149 observed authored lines; target ≤400.
  2. CODE_OF_CONDUCT, paired language files — 267 observed authored lines; target ≤400.
  3. README, paired language files — 478 observed authored lines. This is the smallest coherent documentation unit after one honest split and exceeds the 400-line PR budget; do not code-golf. A standalone PR containing this commit requires a `size:exception` before creation.
  4. ES-B REQUIREMENTS + COMPATIBILITY — commit `01ca9db`, 232 observed authored lines; target ≤400.
  5. ES-B SETUP — commit `0fbece7`, 312 observed authored lines; target ≤400.
  6. ES-C OMNIROUTE + CUSTOMIZATION — commit `30e6264`, 360 observed authored lines; target ≤400.
  7. ES-C LESSONS + SECRETS — commit `b0e0e9e`, 242 observed authored lines; target ≤400.
- Dependency/integration boundary: the slices may be reviewed in order on the feature-branch chain, but do not integrate them into the final target until every translation and the ES-D relative-link scan are complete. Keep the PR tracker draft/no-merge until then.

## ES-A evidence
- `3f7b66b` — contribution/security guides; 149 authored changed lines. Native risk was HIGH because the commit includes `SECURITY`; user explicitly declined review for this candidate.
- `5e76b47` — Code of Conduct; 267 authored changed lines; passive.
- `a3974ac` — Spanish-default README; 478 authored changed lines; passive.
- Verification: `git show --check` passed for all three commits. All four root Spanish/English file pairs exist and each has its expected language switcher. `README.md` has the Spanish switcher and Spanish-localized content at the GitHub front page. These checks do not replace ES-D's full relative-link scan.
- Delivery remains user-owned: no PR or push is authorized. The README commit requires explicit `size:exception` approval before any standalone PR containing it.

## ES-B evidence
- Route: delegated direct; the writer trigger was three non-trivial source documents.
- `01ca9db` — REQUIREMENTS + COMPATIBILITY; 232 authored changed lines; native passive.
- `0fbece7` — SETUP; 312 authored changed lines; native passive.
- Verification passed: all three Spanish/English pairs exist with switchers immediately after titles; SETUP's nine fenced blocks and inline command/path/identifier inventory are preserved; Spanish/English link-language routing is correct; `git diff --check` and `git diff --cached --check` both passed.
- Three English links were intentionally pending ES-C: `OMNIROUTE.en.md` from REQUIREMENTS, `OMNIROUTE.en.md` from SETUP, and `LESSONS.en.md` from SETUP; ES-C added those targets. This partial check was not the full ES-D target-existence scan.
- No PR exists; review-slice integration remains deferred until all translations and ES-D validation are complete.

## ES-C evidence
- Route: delegated direct; the writer trigger was four non-trivial source documents.
- `30e6264` — OMNIROUTE + CUSTOMIZATION; 360 authored changed lines; native passive.
- `b0e0e9e` — LESSONS + SECRETS; 242 authored changed lines; native passive.
- Verification passed: all four Spanish/English pairs and switchers exist; technical identifiers, commands, code snippets, and security details were preserved; Spanish/English link routing is correct; all relative targets referenced by the eight ES-C docs exist; `git diff --check` and `git diff --cached --check` passed.
- At ES-C completion, the full repository-wide relative-link scan, switcher inventory, and README front-page check were still pending; ES-D completion is recorded below.
- No PR or push is authorized. README commit `a3974ac` remains a 478-line cohesive slice and requires an explicit `size:exception` before any standalone PR containing it.

## ES-D evidence
- Independent verifier scanned 39 repository Markdown files, 110 rendered local destinations, and 2 fragments. All 11 Spanish/English pairs and switchers passed; there were zero missing targets, broken fragments, or wrong-language links.
- `README.md` is a substantive Spanish front page; `README.en.md` is English. `CHANGELOG.md`, code, and scripts remain unchanged.
- Semantic comparison of all seven `docs/` language pairs found no material technical or safety mismatch; all 12 fenced blocks matched byte-for-byte.
- `099ceea` — removed the stale English anchor from the Spanish REQUIREMENTS → README link; 2 authored changed lines; native passive.
- `b27a236` — aligned the Spanish REQUIREMENTS section label with the Spanish README heading; 2 authored changed lines; native passive.
- At verified source HEAD `b27a236`, `git status --short` was clean before this tracker-only update; `git show --check` passed for both correction commits.
- Local feature verification is complete. No push, PR, or merge was authorized, and no remote credentials or sessions were authorized. The 478-line README slice still requires explicit `size:exception` approval before standalone PR creation.

## Next step
Local feature work is complete. Await separate user authorization for any remote delivery; preserve the no-PR/no-push/no-merge boundary and obtain `size:exception` approval before a standalone PR containing the README slice.
