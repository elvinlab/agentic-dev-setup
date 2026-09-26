# Banner generator

`banner.py` generates `../assets/banner-{dark,light}.svg`. `embed_fonts.py` subsets Space Grotesk and JetBrains Mono (from [Fontsource](https://fontsource.org)) and embeds them, because SVGs rendered as images cannot load external fonts.

```sh
python3 -m venv tools/.venv && tools/.venv/bin/pip install -r tools/requirements.txt
./tools/fetch_fonts.sh
python3 tools/banner.py && tools/.venv/bin/python tools/embed_fonts.py assets/banner-*.svg
```
