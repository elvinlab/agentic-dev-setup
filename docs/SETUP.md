# Guía de instalación

**Español** · [English](SETUP.en.md)

Cómo respaldar el entorno y reconstruirlo en una instalación nueva de Linux (Arch, Debian/Ubuntu o Fedora) o Windows mediante WSL2. El entorno de referencia del autor es [Omarchy](https://omarchy.org), pero no es un requisito.

**Este repositorio no contiene secretos.** Los secretos y los datos se guardan en un respaldo cifrado independiente.

---

## Windows (WSL2)

- Se requiere Windows 10 21H2 o posterior, o Windows 11. En PowerShell (como administrador), `wsl --install` instala WSL2 con Ubuntu de forma predeterminada; reinicia si se solicita.
- Para usar la GPU, instala el controlador NVIDIA para Windows (incluye compatibilidad con WSL CUDA). NO instales un controlador NVIDIA de Linux dentro de WSL. Si no tienes una GPU NVIDIA, omite este paso: el modelo local se ejecutará en la CPU y las combinaciones en la nube seguirán funcionando.
- Habilita systemd en WSL2 para que funcione el servicio de Ollama optimizado y bajo demanda: crea o edita `/etc/wsl.conf` dentro de Ubuntu con lo siguiente:
  ```
  [boot]
  systemd=true
  ```
  Luego, desde Windows PowerShell, ejecuta `wsl --shutdown` y vuelve a abrir Ubuntu. Sin systemd, `bootstrap.sh` omite la configuración del servicio y tendrás que iniciar Ollama manualmente con `ollama serve`.
- A partir de ahí, clona el repositorio dentro del directorio personal de WSL2 y sigue los mismos pasos de abajo (`bootstrap.sh` detecta `apt` automáticamente).

---

## Antes de reinstalar (o una vez por semana)

Crea el respaldo cifrado:

```bash
sudo pacman -S --needed age sqlite
./scripts/backup.sh
```

El script genera `~/ai-backup-YYYYMMDD-HHMM.tar.gz.age` con:

- `~/.omniroute/.env` y `storage.sqlite`: proveedores, combinaciones, filtros y la clave que los descifra
- `~/.engram/engram.db`: la memoria de tus agentes
- `~/.config/secrets/`: la clave de OmniRoute
- La configuración de herdr, además de copias de referencia de `opencode.json`, `CLAUDE.md` y `.bashrc`

El respaldo **no** incluye nada relacionado con Codex. Las adiciones de Codex gestionadas por el repositorio (perfiles, lanzadores `codex.sh` y el bloque de delegación de `AGENTS.md`) se vuelven a generar al ejecutar `./scripts/apply-patches.sh`. La autenticación y configuración personal de `~/.codex` siguen bajo tu gestión: este repositorio nunca las copia, así que tendrás que iniciar sesión en Codex de nuevo en una máquina nueva.

**Copia ese archivo fuera del equipo** (en una unidad USB o en la nube) y guarda la contraseña en tu administrador de contraseñas. Sin el archivo no podrás restaurar los datos.

---

## Reconstruir el entorno en una instalación nueva de Linux (Arch, Debian/Ubuntu o Fedora) o WSL2

### 1. Obtener el repositorio y el respaldo

Clona el repositorio y copia el archivo `.age` en tu directorio `$HOME`.

### 2. Instalar y configurar

```bash
chmod +x scripts/*.sh
./scripts/bootstrap.sh
```

El script instala los paquetes, OpenCode, Node y OmniRoute; copia la configuración (crea `~/.config/agent-routing/*.env` a partir de los archivos `.example` si aún no existen); configura Ollama bajo demanda y descarga `qwen3:14b`.

> `bootstrap.sh` detecta automáticamente el gestor de paquetes (`pacman`/`apt`/`dnf`), ejecuta `apt-get update` en Debian/Ubuntu y recurre a los instaladores oficiales de Ollama/OpenCode en distribuciones que no son Arch. Finaliza con un error en distribuciones no compatibles.

Al finalizar, muestra qué debes instalar manualmente: **Claude Code**, **Gentle AI** y **herdr**. Instálalos siguiendo su documentación oficial.

Revisa `~/.config/agent-routing/cloud.env` y `local.env` y ajusta los nombres de los modelos si difieren de tus combinaciones.

### 3. Restaurar los datos

Con OmniRoute y OpenCode cerrados:

```bash
./scripts/restore-data.sh ~/ai-backup-YYYYMMDD-HHMM.tar.gz.age
```

Si no tienes un respaldo, vuelve a crear OmniRoute manualmente siguiendo [`OMNIROUTE.md`](OMNIROUTE.md).

### 4. Gentle AI (también instala Engram)

```bash
gentle-ai install --agent claude-code,opencode --dry-run   # review first
gentle-ai install --agent claude-code,opencode
```

### 5. Aplicar las adiciones personalizadas

```bash
./scripts/apply-patches.sh
```

Agrega el proveedor OmniRoute a OpenCode y el bloque de delegación a `CLAUDE.md` sin sobrescribir la configuración de Gentle AI. Es seguro volver a ejecutarlo después de cada `gentle-ai install`. Al final también ejecuta `restore.sh` (paso 6), así que una sola actualización después de instalar o actualizar Gentle AI vuelve a aplicar el estilo de salida y todos los hooks.

También configura **Codex** como orquestador par independiente (un cerebro de respaldo junto a Claude Code, no un agente delegado):

- Instala los perfiles `~/.codex/elvinlab-cloud.config.toml` y `elvinlab-local.config.toml` (OmniRoute en `127.0.0.1:20128`, `wire_api = "responses"`, clave de `OMNIROUTE_API_KEY`) mediante `scripts/install-codex-profiles.sh`.
- Instala los lanzadores `~/.bashrc.d/codex.sh`: `codex-cloud` (`codex --profile elvinlab-cloud`, combinación `elvinlabCode`) y `codex-local` (`codex --profile elvinlab-local`, combinación `elvinlabLocal`).
- Inserta el bloque de delegación por nivel en `~/.codex/AGENTS.md`, fuera de las regiones administradas por Gentle AI (marcadores `<!-- elvinlab:delegation-codex -->`). Codex debe estar instalado y haber creado `AGENTS.md`; si no, el script lo indica y tendrás que volver a ejecutarlo después.

La configuración y autenticación propias de `~/.codex` nunca se modifican. Si ya existe un perfil o lanzador con contenido distinto, el instalador se niega a sobrescribirlo: apártalo o compáralo manualmente y luego vuelve a ejecutar el instalador.

Codex comparte Engram y `~/.config/agent-routing/active.env` con Claude Code, de modo que `agent-profile cloud|local` cambia ambos cerebros, y Codex delega el trabajo trivial y acotado a OpenCode con los mismos niveles.

### 6. Restaurar los hooks de Claude Code y el límite de permisos de OpenCode

El paso 5 ya lo ejecuta. Ejecútalo por separado solo si quieres actualizar la configuración sin volver a aplicar los demás parches:

```bash
bash ~/.config/agent-routing/restore.sh
```

Vuelve a aplicar el estilo de salida Gentleman, el hook de sesión ULTRA de caveman, el hook RTK PreToolUse (compactación de la salida de Bash), el hook herdr UserPromptSubmit para enrutar por nivel (inyecta los modelos `TIER1_MODEL`/`TIER2_MODEL` activos para que el recordatorio de enrutamiento aparezca en cada chat y repositorio) y el límite de permisos autónomos de opencode (seguro de forma amplia: se permiten edit/bash/test; se deniegan push, deploy wrangler/pnpm, gh pr merge/release/auth, rm -rf, ssh/scp/rsync) en `~/.claude/settings.json` y `~/.config/opencode/opencode.json`. Es idempotente y **debe ejecutarse después del paso 4 (Gentle AI)** porque modifica `~/.claude/settings.json` (y falla si el archivo no existe).

> **¿Por qué volver a aplicarlo en lugar de «configurarlo una vez»?** Gentle AI administra `~/.claude/settings.json` y puede sobrescribir estos ajustes durante una reinstalación o actualización, por lo que no se pueden proteger de ese modo. Se vuelven a aplicar. Como `apply-patches.sh` ejecuta `restore.sh`, basta con volver a ejecutar `./scripts/apply-patches.sh` después de cualquier instalación o actualización de Gentle AI para restaurar todos los ajustes en un solo paso.

### 7. Skill de herdr para Claude Code

```bash
npx skills add herdrdev/herdr --skill herdr -g
```

### 8. Abrir una terminal nueva

Así se carga `~/.bashrc.d/ai.sh` y tus secretos.

---

## Verificación

```bash
# OmniRoute
omniroute                                   # in its own pane
ss -tlnp | grep 20128                       # → 127.0.0.1:20128
curl -s http://localhost:20128/v1/models    # → Authentication required

# Ollama
ollama-up                                   # in its own pane
ollama run qwen3:14b "hello" && ollama ps   # → 100% GPU, context 16384

# OpenCode
echo ${#OMNIROUTE_API_KEY}                  # → number > 0
opencode models omniroute                   # → elvinlabCode, elvinlabFast, elvinlabLocal
jq -e ".permission.bash" ~/.config/opencode/opencode.json >/dev/null && echo "opencode permission ceiling present"

# Delegation
agent-profile                               # → Active: cloud
grep -c '<!-- elvinlab:delegation -->' ~/.claude/CLAUDE.md   # → 1

# Codex (peer orchestrator; OmniRoute must be running, plus Ollama for codex-local)
ls ~/.codex/elvinlab-*.config.toml          # → elvinlab-cloud… and elvinlab-local…
grep -c '<!-- elvinlab:delegation-codex -->' ~/.codex/AGENTS.md   # → 1
codex-cloud "reply pong"                    # → pong (via elvinlabCode)
codex-local "reply pong"                    # → pong (via elvinlabLocal)
```

En Claude Code (dentro de herdr): `echo $HERDR_ENV` → `1`, `/mcp` → engram conectado. Luego pídele que escriba una prueba **sin mencionar herdr**: debería delegar el trabajo a OpenCode y revisar el diff.

En el panel de OmniRoute, prueba cada combinación con ▶ y confirma que se resuelva en el primer paso.

En WSL2 sin systemd, ejecuta `ollama serve` manualmente en lugar de `ollama-up`.

---

## Rutina diaria

1. Ejecuta `pkill voxtype` si está activo (libera unos 3 GB de VRAM).
2. Panel 1: `omniroute`.
3. Panel 2: `ollama-up`.
4. Inicia Claude Code y OpenCode en el proyecto (o `codex-cloud` / `codex-local` como cerebro de respaldo).
5. Al terminar: Ctrl+C en ambos paneles y `ollama-down`.

Perfiles de delegación: `agent-profile` (mostrar), `agent-profile cloud` / `agent-profile local` (cambiar).

Supervisión en OmniRoute: *Combos → elvinlabCode* (éxito por paso), *Combo Studio* (en vivo), *Logs* (errores), *Provider Quota* (cuota del proveedor).

---

## Hoja de ruta

- Configurar voxtype para que use la CPU o un modelo más pequeño
- Crear un script de herdr que abra todo el diseño con un solo comando
- Evaluar un preset más ligero de Gentle AI para OpenCode (unos 50k tokens por solicitud)
- Informar el error `_omnirouteInternalRequest` / `_omnirouteSkipContextRelay` a OmniRoute

Problemas conocidos y soluciones: [`LESSONS.md`](LESSONS.md).
