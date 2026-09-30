# Contributing

This is a personal dotfile and showcase repository. Others are welcome to reproduce it, but it reflects a specific workflow and hardware setup. Contributions and setup reports are welcome; opinionated or out-of-scope changes may be declined.

## Ways to contribute

- **Open an issue** — bug reports, setup reports by distro/GPU, or ideas
- **Send a pull request** — bug fixes, distro/GPU compatibility fixes, documentation, and setup scripts are especially welcome

## Before you start

You do not need the full agent stack to fix documentation or a script. To test shell changes locally you only need `bash` and `shellcheck`.

## Run the checks locally

```bash
# Lint
shellcheck scripts/*.sh scripts/lib/*.sh tests/*.sh

# Tests
for t in tests/*.sh; do bash "$t"; done
```

## Conventions

- **Commits**: Conventional Commits (`feat`, `fix`, `docs`, `chore`, …). No AI attribution lines.
- **Tests and docs**: Keep them with the code they relate to.
- **Language**: English for code, documentation, and commit messages.

## Pull requests

1. Fork the repository and branch off `main`.
2. Keep the change focused.
3. Make sure the CI workflow (`shellcheck` + tests) passes.
4. Describe what the change does and why.

## Environment setup

See [docs/REQUIREMENTS.md](docs/REQUIREMENTS.md) for the accounts, hardware, and knowledge needed before starting, and [docs/SETUP.md](docs/SETUP.md) for the full bootstrap, restore, and verification procedure.