# Guía de secretos

**Español** · [English](SECRETS.en.md)

Cómo se gestionan los secretos y cómo evitar que lleguen a git o a la IA.

---

## Dónde se guardan los secretos

| Secreto | Ubicación | Notas |
|---------|-----------|-------|
| `OMNIROUTE_API_KEY` | `~/.config/secrets/ai.env` | `chmod 600` |
| Claves de API de proveedores | OmniRoute (`~/.omniroute/.env` + `storage.sqlite`) | Se incluyen en un archivo cifrado con age |

**No se confirma nada en git.** `.gitignore` ya excluye `*.env`, `*.age`, `secrets/`, `*.sqlite` y `*.db`.

---

## Por qué no pueden terminar en git

- `.gitignore` excluye `*.env` (pero conserva `*.env.example`), `*.age`, `secrets/`, `*.sqlite` y `*.db`.
- Las configuraciones hacen referencia a variables de entorno, nunca a claves literales: Codex usa `env_key = "OMNIROUTE_API_KEY"`; el proveedor de OpenCode, `{env:OMNIROUTE_API_KEY}`.
- El archivo de secretos está en `~/.config`, fuera de cualquier repositorio.

---

## Evita pegar claves en lugares equivocados

- Nunca incluyas una clave literal en un archivo bajo control de versiones, un prompt, una confirmación o un issue.
- Usa siempre el archivo de entorno/secretos (`~/.config/secrets/ai.env`).
- Ejecuta siempre `chmod 600` en el archivo de secretos.

---

## Evita que los secretos lleguen a la IA

- La delegación envía tu tarea y los archivos de código que el agente lee o edita, **no** el entorno de shell ni `~/.config/secrets/`.
- Nunca pegues claves o tokens en un prompt.
- No pidas a un agente que lea archivos de secretos, el respaldo de age ni `~/.omniroute/.env`.
- OmniRoute inyecta las claves de proveedor en el servidor; por eso no forman parte del contenido de los prompts.

---

## Protección adicional (opcional)

- Un detector de secretos pre-commit (por ejemplo, `gitleaks`).
- Activar la detección de secretos y la protección contra subidas en GitHub para tu fork.

---

## Si se filtra una clave

- Rótala de inmediato en el proveedor.
- Si alguna vez se confirmó en git, es obligatorio rotarla (el historial de git conserva la clave).

---

## Ver también

- [`SETUP.md`](SETUP.md) — instalación, reconstrucción y verificación.
- [`../SECURITY.md`](../SECURITY.md) — política breve e instrucciones para informar una vulnerabilidad.
