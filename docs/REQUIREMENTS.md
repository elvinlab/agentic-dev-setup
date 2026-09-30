# Requisitos

**Español** · [English](REQUIREMENTS.en.md)

Lo que necesitas antes de comenzar: cuentas, hardware, sistema operativo, software y conocimientos. Sin sorpresas ni costos ocultos.

---

## 💰 Costos

**Lo ÚNICO de pago es Claude Pro: US$20 al mes.**

Claude Code funciona iniciando sesión con esa suscripción: **no necesitas una clave de API de Anthropic ni pagas por uso**. Todo lo demás es gratis: los proveedores en la nube tienen niveles gratuitos, el modelo local es gratuito y de código abierto, y todas las herramientas son gratuitas y de código abierto.

**Por qué esta arquitectura:** Claude Pro tiene límites de uso. Este entorno delega el trabajo trivial y acotado a modelos gratuitos (mediante OmniRoute + OpenCode) y reserva la capacidad premium limitada de Claude para el trabajo difícil y de alto valor. Ese es el objetivo.

---

## 🔑 Cuentas necesarias

| Cuenta | Costo | Motivo | Sitio |
|--------|-------|--------|-------|
| **Claude Pro** | US$20/mes | Ejecutar Claude Code (el cerebro principal) | [claude.ai](https://claude.ai) |
| **GitHub** | gratis | Clonar este repositorio (y subir tu propio fork) | [github.com](https://github.com) |
| **NVIDIA NIM** | nivel gratuito para desarrolladores | Proveedor de modelos en la nube | [build.nvidia.com](https://build.nvidia.com) |
| **Mistral** | nivel gratuito (verificación telefónica) | Proveedor de modelos en la nube | [console.mistral.ai](https://console.mistral.ai) |
| **Google AI Studio** | gratis (nunca habilites la facturación) | Proveedor de modelos en la nube | [aistudio.google.com](https://aistudio.google.com) |
| **Groq** | nivel gratuito | Proveedor de modelos en la nube | [console.groq.com](https://console.groq.com) |

**Notas:**
- **NO necesitas una cuenta de OpenAI/ChatGPT:** Codex (el cerebro par opcional) se enruta mediante la puerta de enlace local OmniRoute, no mediante OpenAI.
- **OmniRoute se ejecuta localmente** (autohospedado, sin cuenta); debes establecer una contraseña para el panel local.
- Para conocer la configuración exacta de las claves de proveedor y las combinaciones, consulta [`OMNIROUTE.md`](OMNIROUTE.md).

---

## 🖥 Hardware

**Equipo de referencia (probado):** AMD Ryzen 5 5600X, NVIDIA GeForce RTX 3060 de 12 GB. (Consulta la tabla [«Mi estación de trabajo» del README](../README.md)).

**Generalización:** cualquier equipo Linux x86_64. Se recomienda una GPU NVIDIA para ejecutar el modelo local; unos 12 GB de VRAM permiten usar `qwen3:14b` con un contexto de 16k. Con menos VRAM, usa un modelo más pequeño o un contexto más corto. Sin GPU NVIDIA, el modelo local funciona en la CPU (mucho más lento) y puedes apoyarte en las combinaciones gratuitas en la nube.

**Disco:** espacio suficiente para el modelo de Ollama (`qwen3:14b` ocupa unos 9 GB), además de las herramientas.

**RAM:** unos cuantos GB de RAM libre (no se conoce un requisito específico).

---

## 🐧 Sistema operativo

El equipo del autor usa Omarchy 4 (Arch + Hyprland), pero **NO es un requisito**.

**Sistemas compatibles:** Arch, Debian/Ubuntu, Fedora o Windows mediante WSL2.

Para los detalles de instalación y el procedimiento para Windows/WSL2, consulta [`SETUP.md`](SETUP.md).

---

## 🧰 Software

**Instalado por `bootstrap.sh`:** git, jq, age, sqlite, Node LTS (mediante mise), Ollama.

**Instalado manualmente** (según la documentación oficial correspondiente): **Claude Code**, **Gentle AI** (que también instala Engram), **herdr**, **OmniRoute** (npm) y, opcionalmente, **Codex** (par).

Las versiones exactas probadas se encuentran en la sección «Versions this setup was tested with» del [README](../README.md).

---

## 🧠 Conocimientos previos

- Comodidad usando una terminal y conocimientos básicos de bash.
- Conocimientos básicos de git (clonar, crear ramas y confirmar cambios).
- Conocimientos básicos de tmux o de los paneles de una terminal (OmniRoute, Ollama y los agentes se ejecutan en paralelo).
- Comodidad editando archivos de configuración (env, JSON, TOML).
- Un modelo mental básico de los agentes LLM y las claves de API, y de cómo una puerta de enlace o un proxy enruta solicitudes a distintos proveedores.
- Comprender que los modelos gratuitos pueden equivocarse y que una persona debe revisar sus resultados.
- **NO se requieren:** conocimientos de aprendizaje automático ni de entrenamiento de modelos.

¿Listo para comenzar? Consulta [`SETUP.md`](SETUP.md) para ver los pasos de preparación e instalación.
