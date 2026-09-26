#!/usr/bin/env bash
# Download the Fontsource font files used by embed_fonts.py.
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)/fonts"
mkdir -p "$DIR"
for f in space-grotesk/files/space-grotesk-latin-{400,500,700}-normal \
         jetbrains-mono/files/jetbrains-mono-latin-{400,600,700}-normal; do
  curl -sfL -o "$DIR/$(basename "$f").woff2" "https://cdn.jsdelivr.net/npm/@fontsource/$f.woff2"
done
echo "Fonts saved to $DIR"
