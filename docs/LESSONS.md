# Lecciones aprendidas y resolución de problemas

**Español** · [English](LESSONS.en.md)

## OmniRoute

**Un proveedor siempre falla con 400 o 422 en trabajo real, pero funciona en Playground.**
Abre el error en *Logs*. Casi siempre indica cuál parámetro sobra (`Unsupported parameter(s): ...`). Agrégalo a los *Param Filters* de ese proveedor. Algunos conocidos: `__managed_by` (agregado por Gentle AI), `_omnirouteSkipContextRelay` y `_omnirouteInternalRequest` (filtrados por la propia OmniRoute).

**Editar la clave de una conexión no la actualiza (sigue respondiendo 401).**
Crea una conexión nueva con "Add", pruébala en Playground, vuelve a configurar los pasos de las combinaciones con la cuenta nueva y elimina la conexión anterior.

**"Check" indica que la clave es válida, pero los modelos responden 401.**
Algunas validaciones consultan una lista pública de modelos. La prueba real es Playground.

**La combinación salta directamente al último paso sin probar los anteriores.**
Los interruptores automáticos marcaron esos proveedores como "unhealthy" después de muchos errores. Corrige la causa y reinicia OmniRoute (Ctrl+C y `omniroute`).

**En la prueba de la combinación, Ollama falla después de unos 15 s.**
Ese es el límite de tiempo de la prueba; Qwen3 razona antes de responder. En el uso real funciona, aunque con lentitud. Es la última alternativa.

**Error 429.** Límite de solicitudes del nivel gratuito. Espera entre 1 y 2 minutos.

**Fallan los modelos "system" del selector de combinaciones.** Provienen del catálogo de OmniRoute, no de tu cuenta. Prefiere los modelos "imported".

## OpenCode + Gentle AI

- Cada solicitud envía unos 45–50k tokens (instrucciones y herramientas de Gentle AI). Esto agota las cuotas rápidamente y no cabe en el contexto de 16k de Ollama (llega truncada).
- A veces los modelos gratuitos inventan información (por ejemplo, guardaron en Engram que un proyecto usaba la Composition API cuando en realidad usaba la Options API). Por eso Claude siempre revisa los resultados.
- OpenCode siempre muestra el nombre de la combinación como modelo; para ver qué modelo real respondió, consulta *Logs* en OmniRoute.

## Claude Code

- `CLAUDE.md` se carga al iniciar la sesión: después de editarlo, reinicia Claude Code (`/exit`).
- La skill de herdr solo se usa si la persona menciona herdr o si `CLAUDE.md` la autoriza (el bloque de delegación lo hace).
- Debe ejecutarse dentro de herdr: `echo $HERDR_ENV` debe imprimir `1`.
- Si Claude no ve Engram, revisa `/mcp`; si no aparece, ejecuta `engram setup` o `gentle-ai install --agent claude-code`.

## Ollama / GPU

- Que `ollama ps` no muestre resultados no es un error: solo enumera los modelos cargados en ese momento.
- Si `ollama ps` muestra algo como `31%/69% CPU/GPU`, el modelo no cabe en la VRAM. Revisa `nvidia-smi`: **voxtype** estaba usando unos 3 GB. Ciérralo con `pkill voxtype`.
- No inicies Ollama manualmente con `ollama serve`: buscaría modelos en `~/.ollama` (vacío) y perdería la configuración de override. Usa `ollama-up` / `ollama-down`.
- El servicio del sistema se ejecuta como el usuario `ollama` y guarda los modelos en `/var/lib/ollama`. No lo cambies para ejecutarlo con tu usuario (entra en conflicto con `ProtectHome`).
- Justo después de reiniciar el servicio, `ollama` puede mostrar "could not connect": espera 2–3 segundos.

## Bash

- `!` dentro de comillas dobles activa la expansión del historial (`event not found`). Usa comillas simples.
- `read -s VAR` no muestra lo que escribes; pega la clave en la línea siguiente.
- Para copiar una variable al portapapeles sin imprimirla: `printf %s "$VAR" | wl-copy`.

## Seguridad

- Nunca pegues claves en chats, capturas de pantalla ni archivos de texto sin cifrar. Proveedor → OmniRoute → administrador de contraseñas.
- Al rotar una clave, primero comprueba que la nueva funcione y luego revoca la anterior.
