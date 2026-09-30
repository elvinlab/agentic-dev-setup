# Configuración de OmniRoute (referencia)

**Español** · [English](OMNIROUTE.en.md)

Si restauras `~/.omniroute/.env` y `storage.sqlite` desde el respaldo, ya tendrás toda esta configuración. Este documento explica cómo **recrearla manualmente** si perdiste el respaldo o cómo comprobar que todo esté configurado correctamente.

Panel: `http://localhost:20128`

## Seguridad

- Configura `~/.omniroute/.env` con `OMNIROUTE_SERVER_HOST=127.0.0.1` y `REQUIRE_API_KEY=true` (consulta [`omniroute/env.additions.example`](../omniroute/env.additions.example)).
- Verifica: `ss -tlnp | grep 20128` debe mostrar `127.0.0.1:20128`, y `curl -s http://localhost:20128/v1/models` sin una clave debe responder `Authentication required`.
- **Endpoints → "OmniRoute cloud": desactivado.** No uses túneles.
- **API manager:** una clave para OpenCode, **sin acceso de administración**. Guárdala en `~/.config/secrets/ai.env`.
- Cambia la contraseña del panel en Settings → Security.

## Proveedores (todos con una clave de API oficial y la opción "Import only free models" habilitada)

| Proveedor | Clave en | Notas |
|---|---|---|
| NVIDIA NIM | build.nvidia.com | Principal. Acceso para desarrolladores: ~40 solicitudes/min |
| Mistral | console.mistral.ai | Nivel gratuito con verificación telefónica |
| Gemini (Google AI Studio) | aistudio.google.com → API keys | Elige la opción **API key**, no Gemini CLI. **Nunca** habilites la facturación |
| Groq | console.groq.com | Límites por modelo |
| Ollama (local) | — | URL `http://localhost:11434` (o `/v1`). Sin clave |

Descartados: **Cerebras** (402, requiere pago), **OpenRouter** (50 solicitudes/día es insuficiente), **Zhipu** (registro complicado; GLM ya está en NIM). Evita proveedores basados en OAuth o sesiones (Antigravity, Kiro, OpenCode Free mediante proxy, Gemini CLI): implican riesgos relacionados con las condiciones del servicio y la suspensión de la cuenta.

**Prueba cada clave en el Playground del proveedor**, no con "Check" (puede dar falsos positivos).

## Filtros de parámetros (¡esenciales!)

En **Providers → NVIDIA / Mistral / Groq → Param Filters → Blocked parameters**:

```
__managed_by, _omnirouteSkipContextRelay, _omnirouteInternalRequest
```

Sin esto, NVIDIA responde 400 y Mistral 422 ante solicitudes reales de OpenCode + Gentle AI.

## Combinaciones (estrategia: **Priority** en todas)

### elvinlabCode — implementación y calidad
1. NVIDIA → `nvidia/nemotron-3-ultra-550b-a55b`
2. Mistral → `codestral` (2508 / latest)
3. Gemini → `gemini-3-flash-preview`
4. Ollama → `qwen3:14b`

### elvinlabFast — tareas cortas y velocidad
1. Groq → `openai/gpt-oss-120b`
2. Groq → `openai/gpt-oss-20b` (cuota independiente por modelo)
3. NVIDIA → `nvidia/nemotron-3.5-lightning-30b-a3b`
4. Ollama → `qwen3:14b`

### elvinlabLocal — solo IA local
1. Ollama → `qwen3:14b`

`elvinlabCode` prioriza la nube: solo llega a `qwen3:14b` local si fallan todos los proveedores gratuitos en la nube anteriores. `elvinlabLocal` siempre se conecta directamente al modelo local.

**Clientes.** Codex accede a las mismas combinaciones mediante `wire_api = "responses"` (el endpoint `/v1/responses`). OmniRoute ofrece `elvinlabCode` tanto en `/v1/chat/completions` como en `/v1/responses`, y las combinaciones se comportan igual sin importar el cliente.

**Verificar el enrutamiento real.** El registro está en `~/.omniroute/logs/application/app.log`. Busca el nombre de la combinación para ver qué proveedor atendió realmente la solicitud:

```bash
rg elvinlabCode ~/.omniroute/logs/application/app.log | tail
```

Por ejemplo, si `elvinlabCode` se resuelve en `nvidia/nemotron-3-ultra` con `0 fallbacks`, la solicitud llegó a la nube, no al respaldo local.

Al agregar cada paso, asegúrate de que **ACCOUNT** sea la conexión correcta. Si cambias o recreas una conexión, vuelve a configurar los pasos de las combinaciones que usaban la anterior.

Modelos que NO funcionaron (nivel gratuito, septiembre de 2026): Gemini 2.5 Flash / 2.5 Flash-Lite / Pro (retirados para cuentas nuevas), Kimi K3 en NIM (funciona, pero tarda unos 30 s por respuesta), y los modelos marcados como "system" en lugar de "imported", que normalmente no están disponibles.

## Compresión

**Compression Settings:**
- Interruptor principal **Prompt Compression: ON**
- **RTK: ON** en nivel **Minimal**
- **Session Dedup: ON**
- Todo lo demás desactivado (Lite, CCR, Headroom, Relevance, Caveman…)

RTK: Tool results ON, Code blocks OFF, Assistant messages OFF, raw output retention "never".

## Mantener desactivado

- La memoria propia de OmniRoute (Engram ya cumple esa función)
- El servidor MCP de OmniRoute
- MITM / TPROXY
- Fusion y Auto Combo (para más adelante)
