# Compatibility matrix

[Español](COMPATIBILITY.md) · **English**

This document tracks where the agentic-dev-setup has been confirmed to work. Reports are welcome — open a **Setup report** issue (see the repository's Issues area) with your distro and GPU result.

| OS / Distro | Package manager | GPU | Status |
|-------------|-----------------|-----|--------|
| Omarchy 4 (Arch Linux) | pacman | NVIDIA RTX 3060 12 GB | ✅ Tested (reference machine) |
| Arch Linux | pacman | — | 🟡 Should work — reports welcome |
| Debian / Ubuntu | apt | — | 🟡 Should work — reports welcome |
| Fedora | dnf | — | 🟡 Should work — reports welcome |
| Windows (WSL2 + Ubuntu) | apt | — | 🟡 Should work — reports welcome |

## Legend

- ✅ **Tested** — confirmed working on the author's reference machine
- 🟡 **Should work / unconfirmed** — bootstrap supports the package manager; no test report yet

## Add your result

Open a **Setup report** issue (see the repository's Issues) with:

- Your distro and version
- GPU (model and VRAM, or "none")
- Whether bootstrap completed and delegation works
- Any workaround needed

See also [`CONTRIBUTING.md`](../CONTRIBUTING.en.md) and [`SETUP.md`](SETUP.en.md) for context on bootstrap and WSL2.
