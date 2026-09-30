# Guía de personalización

**Español** · [English](CUSTOMIZATION.en.md)

Todo lo que aparece aquí es un ejemplo: adáptalo a tus necesidades.

---

## Perfiles de enrutamiento de modelos

Los perfiles de enrutamiento están en `~/.config/agent-routing/*.env`. Cada archivo define:

- `TIER1_MODEL` — la combinación para tareas triviales (renombrar, lint, i18n y mensajes de confirmación)
- `TIER2_MODEL` — la combinación para tareas acotadas (pruebas, código repetitivo, documentación y componentes sencillos)

El repositorio incluye dos ejemplos:

| Archivo | TIER1_MODEL | TIER2_MODEL |
|---------|-------------|-------------|
| `cloud.env.example` | `omniroute/elvinlabFast` | `omniroute/elvinlabCode` |
| `local.env.example` | `omniroute/elvinlabLocal` | `omniroute/elvinlabLocal` |

En la primera ejecución, `bootstrap.sh` copia estos archivos a `cloud.env` y `local.env` (sin el sufijo `.example`) si todavía no existen. Puedes crear perfiles adicionales —por ejemplo, `work.env`, `offline.env`— y cambiar entre ellos con:

```bash
agent-profile          # show active profile and list all available
agent-profile cloud    # activate cloud.env
agent-profile local    # activate local.env
agent-profile work     # activate work.env (if you created it)
```

La función de shell `agent-profile` (en `~/.bashrc.d/ai.sh`) **detecta automáticamente** todos los archivos `*.env` de `~/.config/agent-routing/`. No hace falta registrarlos.

---

## Proveedores y combinaciones de OmniRoute

Los nombres `elvinlabFast`, `elvinlabCode` y `elvinlabLocal` son solo identificadores de combinaciones de OmniRoute. Puedes:

- Cambiar los nombres de las combinaciones en el panel de OmniRoute (consulta [`OMNIROUTE.md`](OMNIROUTE.md)).
- Reordenar o reemplazar los pasos de proveedores dentro de una combinación.
- Agregar o quitar proveedores por completo.

**Si cambias el nombre de una combinación**, actualiza el archivo `*.env` correspondiente para que `TIER1_MODEL` o `TIER2_MODEL` apunte al nuevo nombre (por ejemplo, `omniroute/myFastCombo`).

---

## Perfiles de Codex

Los perfiles de Codex están en `~/.codex/elvinlab-*.config.toml` (se instalan desde `home/.config/codex-profiles/*.toml`). Cada archivo contiene:

```toml
model = "<combo>"
model_provider = "omniroute"
```

Los alias de los lanzadores `codex-cloud` y `codex-local` se definen en `~/.bashrc.d/codex.sh`:

| Comando | Perfil | Combinación |
|---------|--------|-------------|
| `codex-cloud` | `elvinlab-cloud` | `elvinlabCode` |
| `codex-local` | `elvinlab-local` | `elvinlabLocal` |

Los nombres de archivo de los perfiles, el valor interno de `model` y los nombres de alias de los lanzadores se pueden modificar. Cambia el nombre del archivo `.toml`, modifica el campo `model` y actualiza el alias en `codex.sh`: todos deben coincidir.

---

## Modelo local y ajuste de GPU

`qwen3:14b` es el valor **predeterminado**, no un requisito. Puedes usar cualquier modelo de Ollama. Cámbialo en el panel de OmniRoute: edita la combinación `elvinlabLocal` (o la combinación que apunte a Ollama) para usar la etiqueta de modelo que prefieras.

Los ajustes de GPU/VRAM y contexto están en `system/etc/systemd/system/ollama.service.d/override.conf`:

| Ajuste | Valor de ejemplo | Propósito |
|--------|-----------------|-----------|
| `OLLAMA_CONTEXT_LENGTH` | `16384` | Tamaño de la ventana de contexto |
| `OLLAMA_KV_CACHE_TYPE` | `q8_0` | Cuantización de la caché KV (reduce a la mitad el uso de memoria) |
| `OLLAMA_FLASH_ATTENTION` | `1` | Habilitar flash attention |
| `OLLAMA_NUM_PARALLEL` | `1` | Una solicitud a la vez |
| `OLLAMA_MAX_LOADED_MODELS` | `1` | Nunca cargar dos modelos simultáneamente |
| `OLLAMA_KEEP_ALIVE` | `30m` | Mantener el modelo listo durante la sesión |

Ajusta estos valores según tu VRAM y el modelo. También puedes ejecutar Ollama como prefieras (con `ollama serve` manual, Docker, etc.) y configurar el proveedor Ollama de OmniRoute para que use tu endpoint.

---

## Elementos que NO debes renombrar

Los siguientes **comentarios marcadores son funcionales**: los scripts los buscan para hacer que las operaciones sean idempotentes:

- `<!-- elvinlab:delegation -->` — marca el bloque de delegación que `scripts/apply-patches.sh` inserta en `~/.claude/CLAUDE.md`.
- `<!-- elvinlab:delegation-codex -->` — marca el bloque de delegación que `scripts/install-codex-profiles.sh` inserta en `~/.codex/AGENTS.md`.

**No cambies estos marcadores** a menos que también actualices los scripts correspondientes (`apply-patches.sh` e `install-codex-profiles.sh`). Son lo único que permite a los scripts encontrar el lugar correcto sin sobrescribir el resto de tu configuración.

---

## Ver también

- [`SETUP.md`](SETUP.md) — instalación, reconstrucción y verificación.
- [`OMNIROUTE.md`](OMNIROUTE.md) — proveedores, combinaciones, filtros y compresión.
