# ~/.bashrc.d/ai.sh — AI agent environment (elvinlab)
# Loaded from ~/.bashrc with:
#   for f in ~/.bashrc.d/*.sh; do [ -r "$f" ] && . "$f"; done

# --- Secrets (NOT in the repo) ------------------------------------------
# ~/.config/secrets/ai.env should contain, for example:
#   export OMNIROUTE_API_KEY='sk-...'
# Recommended permissions: chmod 600 ~/.config/secrets/ai.env
[ -r "$HOME/.config/secrets/ai.env" ] && . "$HOME/.config/secrets/ai.env"

# --- On-demand Ollama (service without autostart) -----------------------
alias ollama-up='sudo systemctl start ollama && journalctl -u ollama -f'
alias ollama-down='sudo systemctl stop ollama'

# --- Model profiles for Claude -> OpenCode delegation -------------------
agent-profile() {
  local d="$HOME/.config/agent-routing"
  if [ -z "$1" ]; then
    echo "Active: $(basename "$(readlink "$d/active.env")" .env)"
    echo "Available: $(ls "$d" | grep -v '^active' | sed 's/\.env$//' | tr '\n' ' ')"
    return
  fi
  [ -f "$d/$1.env" ] || { echo "Profile '$1' not found"; return 1; }
  ln -sf "$1.env" "$d/active.env" && echo "Switched to: $1"
}
