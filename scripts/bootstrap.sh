#!/usr/bin/env bash
# Installs and configures the AI agent environment on a fresh Omarchy install.
# Usage: ./scripts/bootstrap.sh
# Safe to run more than once. Lines marked VERIFY use install commands that
# may change: check them against the official documentation.
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
step() { printf '\n\033[1;32m==> %s\033[0m\n' "$1"; }

# ---------------------------------------------------------------------------
step "1. System packages"
sudo pacman -S --needed --noconfirm git jq age sqlite ollama ollama-cuda

step "2. OpenCode (AUR)"
if command -v yay >/dev/null; then
  yay -S --needed --noconfirm opencode-bin
else
  echo "⚠ yay not found. Install OpenCode with: curl -fsSL https://opencode.ai/install | bash"
fi

step "3. Node (mise) + OmniRoute"
if command -v mise >/dev/null; then
  mise use -g node@lts
  eval "$(mise activate bash)"
else
  echo "⚠ mise not found: install Node yourself before continuing"
fi
npm i -g omniroute

step "4. Tools installed manually (VERIFY)"
command -v claude     >/dev/null && echo "✔ Claude Code already installed" \
  || echo "✘ Claude Code: curl -fsSL https://claude.ai/install.sh | bash   (VERIFY)"
command -v gentle-ai  >/dev/null && echo "✔ Gentle AI already installed" \
  || echo "✘ Gentle AI: see its official README (Gentleman-Programming/gentle-ai)"
command -v herdr      >/dev/null && echo "✔ herdr already installed" \
  || echo "✘ herdr: see its official README (herdrdev/herdr)"
echo "   Engram is installed by Gentle AI as a component (ends up in ~/.local/bin/engram)."

# ---------------------------------------------------------------------------
step "5. User configuration"
mkdir -p "$HOME/.config/agent-routing" "$HOME/.bashrc.d"
for example in "$REPO/home/.config/agent-routing/"*.env.example; do
  target="$HOME/.config/agent-routing/$(basename "$example" .example)"
  if [ -e "$target" ]; then
    echo "  – $target already exists, left untouched"
  else
    cp "$example" "$target"
    echo "  ✔ $target created from example"
  fi
done
[ -L "$HOME/.config/agent-routing/active.env" ] || ln -sf cloud.env "$HOME/.config/agent-routing/active.env"
cp "$REPO/home/.bashrc.d/ai.sh" "$HOME/.bashrc.d/ai.sh"
install -m 755 "$REPO/home/.config/agent-routing/restore.sh" "$HOME/.config/agent-routing/restore.sh"
echo "✔ restore.sh installed (run it AFTER Gentle AI: bash ~/.config/agent-routing/restore.sh)"

LOADER='for f in ~/.bashrc.d/*.sh; do [ -r "$f" ] && . "$f"; done'
grep -qF "$LOADER" "$HOME/.bashrc" || printf '\n# Personal modules\n%s\n' "$LOADER" >> "$HOME/.bashrc"
echo "✔ agent-routing, ai.sh and loader in ~/.bashrc"

mkdir -p "$HOME/.config/secrets" && chmod 700 "$HOME/.config/secrets"
if [ ! -f "$HOME/.config/secrets/ai.env" ]; then
  printf "# export OMNIROUTE_API_KEY='sk-...'\n" > "$HOME/.config/secrets/ai.env"
  chmod 600 "$HOME/.config/secrets/ai.env"
  echo "⚠ Create your OmniRoute key and put it in ~/.config/secrets/ai.env"
fi

# ---------------------------------------------------------------------------
step "6. Tuned on-demand Ollama + local model"
sudo install -D -m 644 "$REPO/system/etc/systemd/system/ollama.service.d/override.conf" \
  /etc/systemd/system/ollama.service.d/override.conf
sudo systemctl daemon-reload
sudo systemctl disable ollama 2>/dev/null || true   # no autostart
sudo systemctl start ollama && sleep 3
ollama pull qwen3:14b
sudo systemctl stop ollama
echo "✔ Ollama ready. Use it with: ollama-up / ollama-down"

# ---------------------------------------------------------------------------
step "7. OmniRoute: security"
if [ -f "$HOME/.omniroute/.env" ]; then
  grep -q '^OMNIROUTE_SERVER_HOST=' "$HOME/.omniroute/.env" || cat "$REPO/omniroute/env.additions.example" >> "$HOME/.omniroute/.env"
  echo "✔ OmniRoute .env with local host and required API key"
else
  echo "ℹ ~/.omniroute/.env does not exist yet: restore your backup (step 3 of docs/SETUP.md)"
  echo "  or start 'omniroute' once and run this script again."
fi

step "Done. Continue with docs/SETUP.md: restore data, Gentle AI and apply-patches.sh"
echo "   Then run: bash ~/.config/agent-routing/restore.sh  (caveman + RTK hooks, Gentleman style, opencode permission ceiling)"
