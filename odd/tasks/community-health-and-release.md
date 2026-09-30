# Community health + first release (SECURITY, CoC, compatibility, CHANGELOG, v1.0.0)

Repository locator: `odd/tasks/community-health-and-release.md`

## Objective
Finish the community-readiness surface and cut the first public release:
SECURITY.md, CODE_OF_CONDUCT.md, a distro/GPU compatibility table, a CHANGELOG,
and a v1.0.0 tag/release. English now.

## Decisions (user, 2026-09-30)
- Contact: GitHub private vulnerability reporting (Security tab), NO email
  published. CoC reports route through GitHub (maintainer @elvinlab).
- Version: v1.0.0 as the first stable public release; create + push the tag,
  and a GitHub release.

## Scope (authorized)
- `SECURITY.md` (root): supported versions + report via GitHub private reporting.
- `CODE_OF_CONDUCT.md` (root): Contributor Covenant 2.1; enforcement via GitHub.
- `docs/COMPATIBILITY.md`: table seeded with the tested config (Omarchy/Arch +
  RTX 3060 12 GB = tested); others honestly "should work — reports welcome";
  link to the setup-report issue template. Pointer from README.
- `CHANGELOG.md` (root): Keep a Changelog format; [1.0.0] entry.
- Tag v1.0.0 + GitHub release (done by Claude after merge).

## Out of scope
- Spanish translations (still a future slice).

## Route / TDD
- Docs delegated to opencode elvinlabCode, Claude-reviewed. No TDD; verify links
  + that only tested config is marked tested. Tag/release done inline by Claude.

## Tasks
- [x] CHR-1 — SECURITY.md (GitHub private reporting; supported versions; secrets
      note). DELEGATED to elvinlabCode. Verified: no email.
- [x] CHR-2 — CODE_OF_CONDUCT.md (Contributor Covenant 2.1; GitHub contact).
      DELEGATED. Verified: no email, proper attribution.
- [x] CHR-3 — docs/COMPATIBILITY.md (only reference machine = Tested) + README
      pointer. DELEGATED. Links resolve.
- [x] CHR-4 — CHANGELOG.md [1.0.0] - 2026-09-30 (Keep a Changelog). DELEGATED.
- [ ] CHR-5 — Verify (done) → commit; merge; push.
- [ ] CHR-6 — Create + push annotated tag v1.0.0; create GitHub release.

## Acceptance criteria
- No email addresses published; security reporting points to GitHub's flow.
- Compatibility table marks ONLY the reference machine as tested.
- CHANGELOG follows Keep a Changelog; v1.0.0 dated today.
- Tag v1.0.0 exists on the release commit and is pushed; release created.

## Next step
CHR-1..4: delegate to elvinlabCode.
