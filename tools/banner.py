#!/usr/bin/env python3
"""Generate the animated pipeline banner for this repository (dark + light)."""
from pathlib import Path

OUT = Path(__file__).resolve().parent.parent / "assets"
OUT.mkdir(exist_ok=True)

VIOLET, CYAN, PINK = "#8b5cf6", "#06b6d4", "#ec4899"
MONO = "'JetBrains Mono', ui-monospace, SFMono-Regular, Menlo, Consolas, monospace"
SANS = "'Space Grotesk', -apple-system, 'Segoe UI', Helvetica, Arial, sans-serif"
THEMES = {
    "dark": dict(bg1="#07070f", bg2="#0f0b1f", box="#120e24", text="#e6edf3", muted="#8b949e", line="#30284d"),
    "light": dict(bg1="#fbfbff", bg2="#eef0ff", box="#ffffff", text="#0d1117", muted="#57606a", line="#c9c3ee"),
}

# Two peer brains share the entry column; the rest is the linear pipeline.
BRAINS = [("Claude Code", "the brain · tier 3", 2), ("Codex", "peer · fallback brain", 1.5)]
PIPE = [("herdr", "agent panes"), ("OpenCode", "Gentle AI · tier 1–2"), ("OmniRoute", "priority combos")]
TARGETS = [("NVIDIA NIM", CYAN), ("Mistral", CYAN), ("Gemini", CYAN), ("Groq", CYAN), ("qwen3:14b · local", PINK)]


def banner(t):
    w, h = 1200, 470
    bx, bw, gap, cy = 48, 190, 40, 300
    bh, bhb = 84, 66  # pipeline box height, brain box height
    boxes, links = [], []

    def colx(i):
        return bx + i * (bw + gap)

    def box(x, ycenter, height, name, sub, stroke, sw):
        boxes.append(f'''
  <rect x="{x}" y="{ycenter - height / 2}" width="{bw}" height="{height}" rx="14" fill="{t["box"]}" stroke="{stroke}" stroke-width="{sw}"/>
  <text x="{x + bw / 2}" y="{ycenter - 4}" class="stage" text-anchor="middle">{name}</text>
  <text x="{x + bw / 2}" y="{ycenter + 20}" class="sub" text-anchor="middle">{sub}</text>''')

    # Entry column: two stacked peer brains.
    x0 = colx(0)
    cyA, cyB = cy - 46, cy + 46
    box(x0, cyA, bhb, BRAINS[0][0], BRAINS[0][1], VIOLET, BRAINS[0][2])
    box(x0, cyB, bhb, BRAINS[1][0], BRAINS[1][1], VIOLET, BRAINS[1][2])
    links.append(f'<path d="M{x0 + bw / 2} {cyA + bhb / 2} V{cyB - bhb / 2}" stroke="{VIOLET}" stroke-width="1.5" stroke-dasharray="3 4"/>')

    # Both brains converge into herdr.
    hx = colx(1)
    for byc in (cyA, cyB):
        x1 = x0 + bw
        d = f"M{x1} {byc} C{x1 + 24} {byc} {hx - 24} {cy} {hx} {cy}"
        links.append(f'<path d="{d}" fill="none" stroke="{t["line"]}" stroke-width="2"/>'
                     f'<path d="{d}" fill="none" class="flow" stroke="url(#g)" stroke-width="3" stroke-dasharray="12 {gap}"/>')

    # Linear pipeline: herdr → OpenCode → OmniRoute.
    for k, (name, sub) in enumerate(PIPE):
        i = k + 1
        x = colx(i)
        box(x, cy, bh, name, sub, t["line"], 1.5)
        if k < len(PIPE) - 1:
            x1, x2 = x + bw, x + bw + gap
            links.append(f'<path d="M{x1} {cy} H{x2}" stroke="{t["line"]}" stroke-width="2"/>'
                         f'<path d="M{x1} {cy} H{x2}" class="flow" stroke="url(#g)" stroke-width="3" stroke-dasharray="12 {gap}" style="animation-delay:{k * .4}s"/>')

    # Fan-out from OmniRoute to providers.
    ox = colx(3) + bw
    px, pw, ph, pg = ox + 40, w - 48 - (ox + 40), 30, 8
    top = cy - (len(TARGETS) * ph + (len(TARGETS) - 1) * pg) / 2
    pills = []
    for j, (name, color) in enumerate(TARGETS):
        py = top + j * (ph + pg)
        mid = py + ph / 2
        d = f"M{ox} {cy} C{ox + 24} {cy} {px - 24} {mid} {px} {mid}"
        local = color == PINK
        links.append(f'<path d="{d}" fill="none" stroke="{t["line"]}" stroke-width="1.5"/>'
                     f'<path d="{d}" fill="none" class="flow" stroke="{color}" stroke-width="2.5" stroke-dasharray="10 60" style="animation-delay:{1.2 + j * .25}s"/>')
        pills.append(f'<rect x="{px}" y="{py}" width="{pw}" height="{ph}" rx="15" fill="{color}" fill-opacity="{.16 if local else .08}" stroke="{color}" stroke-opacity="{.9 if local else .45}" stroke-width="1.2"/>'
                     f'<text x="{px + pw / 2}" y="{mid + 5}" class="pill{" local" if local else ""}" text-anchor="middle">{name}</text>')

    # Shared memory rail under the brains, herdr and OpenCode.
    ry = 408
    rx0, rx1, rx2 = x0 + bw / 2, colx(1) + bw / 2, colx(2) + bw / 2
    rail = (f'<path d="M{rx0} {cyB + bhb / 2} V{ry} M{rx1} {cy + bh / 2} V{ry} M{rx2} {cy + bh / 2} V{ry}" stroke="{VIOLET}" stroke-width="1.5" stroke-dasharray="3 4"/>'
            f'<path d="M{rx0} {ry} H{rx2}" stroke="{VIOLET}" stroke-width="1.5" stroke-dasharray="3 4"/>'
            f'<text x="{(rx0 + rx2) / 2}" y="{ry + 22}" class="rail" text-anchor="middle">ENGRAM · SHARED MEMORY</text>')
    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}" role="img" aria-label="agentic-dev-setup: Claude Code and Codex are peer orchestrators that delegate through herdr to OpenCode, routed by OmniRoute to free cloud providers and a local qwen3:14b model, with Engram as shared memory">
<defs>
  <linearGradient id="g" x1="0" y1="0" x2="1" y2="0"><stop offset="0" stop-color="{VIOLET}"/><stop offset=".55" stop-color="{CYAN}"/><stop offset="1" stop-color="{PINK}"/></linearGradient>
  <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="{t["bg1"]}"/><stop offset="1" stop-color="{t["bg2"]}"/></linearGradient>
  <radialGradient id="glow1" cx=".85" cy=".1" r=".5"><stop offset="0" stop-color="{VIOLET}" stop-opacity=".25"/><stop offset="1" stop-color="{VIOLET}" stop-opacity="0"/></radialGradient>
  <radialGradient id="glow2" cx=".1" cy="1" r=".5"><stop offset="0" stop-color="{CYAN}" stop-opacity=".16"/><stop offset="1" stop-color="{CYAN}" stop-opacity="0"/></radialGradient>
  <pattern id="grid" width="32" height="32" patternUnits="userSpaceOnUse"><path d="M32 0H0V32" fill="none" stroke="{t["line"]}" stroke-width=".5" opacity=".35"/></pattern>
  <clipPath id="r"><rect width="{w}" height="{h}" rx="18"/></clipPath>
</defs>
<style>
  .hi {{ font: 400 19px {MONO}; fill: {t["muted"]}; }}
  .name {{ font: 700 58px {SANS}; letter-spacing: -1.5px; }}
  .tagline {{ font: 600 22px {MONO}; fill: {t["text"]}; }}
  .tag {{ font: 400 14px {MONO}; fill: {t["muted"]}; letter-spacing: 1px; }}
  .stage {{ font: 700 22px {SANS}; fill: {t["text"]}; }}
  .sub {{ font: 400 13px {MONO}; fill: {t["muted"]}; }}
  .pill {{ font: 600 13px {MONO}; fill: {t["text"]}; }}
  .pill.local {{ fill: {PINK}; }}
  .rail {{ font: 600 12px {MONO}; fill: {VIOLET}; letter-spacing: 1.5px; }}
  .cursor {{ fill: {PINK}; animation: blink 1s steps(1) infinite; }}
  .flow {{ animation: flow 2.4s linear infinite; }}
  @keyframes flow {{ from {{ stroke-dashoffset: 60; }} to {{ stroke-dashoffset: -60; }} }}
  @keyframes blink {{ 50% {{ opacity: 0; }} }}
  @media (prefers-reduced-motion: reduce) {{ .flow, .cursor {{ animation: none; }} }}
</style>
<g clip-path="url(#r)">
  <rect width="{w}" height="{h}" fill="url(#bg)"/>
  <rect width="{w}" height="{h}" fill="url(#grid)"/>
  <rect width="{w}" height="{h}" fill="url(#glow1)"/>
  <rect width="{w}" height="{h}" fill="url(#glow2)"/>
  <text x="48" y="64" class="hi">// my daily driver</text>
  <text x="44" y="126" class="name" fill="url(#g)">agentic-dev-setup</text>
  <text x="48" y="168" class="tagline">Claude thinks. Cheaper models type.<tspan class="cursor"> ▍</tspan></text>
  <text x="48" y="202" class="tag">OMARCHY · HYPRLAND · RTX 3060 · LOCAL QWEN3:14B · $0 DELEGATION</text>
  {"".join(links)}
  {"".join(boxes)}
  {"".join(pills)}
  {rail}
  <rect x="0" y="{h - 4}" width="{w}" height="4" fill="url(#g)"/>
</g>
</svg>'''


for mode, t in THEMES.items():
    (OUT / f"banner-{mode}.svg").write_text(banner(t))
print("ok")
