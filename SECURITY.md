# Security policy

## Reporting a vulnerability

Use GitHub's private vulnerability reporting:

1. Go to the repository's **Security** tab.
2. Click **Report a vulnerability** (GitHub Security Advisories).
3. Fill in the details and submit privately.

**Do not open a public issue** for security problems.

This repository does not accept security reports by email.

## Supported versions

| Version | Status |
|---------|--------|
| 1.0.0 (`main`) | ✅ Supported |
| Older | ❌ Not supported |

Only the latest release on the default branch receives security updates.

## Secrets handling

This is a personal dotfile repository. **No secrets are committed to git.**

- Provider API keys and sensitive configuration live in environment variables.
- Secrets and agent memory are backed up in an `age`-encrypted archive (see [`docs/SETUP.md`](docs/SETUP.md)).
- The OmniRoute gateway binds to `127.0.0.1` only and requires an API key.