# Contribution pack (open the repo to the community)

Repository locator: `odd/tasks/contribution-pack.md`

## Objective
Make it safe and easy for anyone to suggest changes: a contributing guide,
issue templates (including a distro/GPU setup report), a PR template, and CI
that validates every PR (shellcheck + bash tests). English now.

## Why
The repo has only LICENSE + README — no community-health files, no CI. To be
"for everyone" and accept outside changes with a safety net, it needs the
standard contribution surface. User chose the contribution pack (items 1-4).

## Validated premises (checked before building)
- `shellcheck scripts/*.sh scripts/lib/*.sh tests/*.sh` → exit 0 (all clean),
  so CI can shellcheck everything and stay green.
- All three `tests/*.sh` are hermetic (they build a temp HOME), so CI can run
  them on a clean ubuntu-latest runner. Runner has bash/git/jq preinstalled.
- `actionlint` is available locally to lint the workflow before commit.

## Scope (authorized)
- `CONTRIBUTING.md` (root)
- `.github/ISSUE_TEMPLATE/bug_report.md`, `setup_report.md`,
  `feature_request.md`, `config.yml`
- `.github/PULL_REQUEST_TEMPLATE.md`
- `.github/workflows/ci.yml` (shellcheck + tests on push/PR)

## Out of scope (later slices)
- SECURITY.md, CODE_OF_CONDUCT.md (items 5-6).
- Spanish translations, support matrix, releases/CHANGELOG.

## Route / TDD
- Route: delegated writer (Tier 2, opencode elvinlabCode), Claude-reviewed.
  Config/docs-only → no TDD; verification = actionlint + rerun shellcheck +
  bash tests/*.sh + link/anchor sanity.

## Tasks
- [x] CTB-1 — CONTRIBUTING.md. Route: DELEGATED to elvinlabCode. Accurate check
      commands, correct links to REQUIREMENTS/SETUP, repo conventions match.
- [x] CTB-2 — Issue templates (bug, setup report by distro/GPU, feature) + config.
      Route: DELEGATED. Front matter valid YAML on all three.
- [x] CTB-3 — PULL_REQUEST_TEMPLATE.md (checklist). Route: DELEGATED.
- [x] CTB-4 — .github/workflows/ci.yml (shellcheck + tests on push/PR).
      Route: DELEGATED with verbatim spec.
- [x] CTB-5 — Verify (inline): actionlint exit 0, shellcheck exit 0, all 3 tests
      pass, template front matter valid, no leaked brief text.

## Acceptance criteria
- A contributor knows exactly how to propose a change and what CI will check.
- CI is green on this branch's state (workflow lints clean; the commands it runs
  pass locally).
- Issue/PR templates render (valid front matter).

## Next step
CTB-1..4: delegate to elvinlabCode with exact specs (ci.yml verbatim).
