#!/usr/bin/env python3
"""Subset Fontsource fonts to the glyphs each SVG uses and embed them as base64 @font-face."""
import base64, html, io, re, sys
from pathlib import Path
from fontTools import subset
from fontTools.ttLib import TTFont

FONTS = Path(__file__).resolve().parent / "fonts"
FACES = [
    ("Space Grotesk", 400, "space-grotesk-latin-400-normal"),
    ("Space Grotesk", 500, "space-grotesk-latin-500-normal"),
    ("Space Grotesk", 700, "space-grotesk-latin-700-normal"),
    ("JetBrains Mono", 400, "jetbrains-mono-latin-400-normal"),
    ("JetBrains Mono", 600, "jetbrains-mono-latin-600-normal"),
    ("JetBrains Mono", 700, "jetbrains-mono-latin-700-normal"),
]


def subset_b64(name, text):
    font = TTFont(FONTS / f"{name}.woff2")
    opts = subset.Options(); opts.flavor = "woff2"; opts.layout_features = ["*"]
    sub = subset.Subsetter(opts); sub.populate(text=text); sub.subset(font)
    buf = io.BytesIO(); font.flavor = "woff2"; font.save(buf)
    return base64.b64encode(buf.getvalue()).decode()


def embed(path):
    svg = path.read_text()
    svg = re.sub(r"<style id=\"fonts\">.*?</style>\n?", "", svg, flags=re.S)
    text = html.unescape("".join(re.findall(r">([^<>]+)<", svg))) + " "
    faces = "".join(
        f"@font-face{{font-family:'{fam}';font-weight:{w};src:url(data:font/woff2;base64,{subset_b64(n, text)}) format('woff2');}}"
        for fam, w, n in FACES)
    svg = re.sub(r"(<svg[^>]*>)", r'\1\n<style id="fonts">' + faces.replace("\\", "\\\\") + "</style>", svg, count=1)
    path.write_text(svg)
    print(f"{path.name}: {path.stat().st_size // 1024} KB")


for p in sys.argv[1:]:
    embed(Path(p))
