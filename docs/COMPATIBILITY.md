# Matriz de compatibilidad

**Español** · [English](COMPATIBILITY.en.md)

Este documento registra en qué entornos se ha confirmado que funciona agentic-dev-setup. Aceptamos reportes: abre un issue de **reporte de instalación** (Setup report; consulta la sección Issues del repositorio) e indica tu distribución y el resultado con la GPU.

| SO / distribución | Gestor de paquetes | GPU | Estado |
|-------------------|--------------------|-----|--------|
| Omarchy 4 (Arch Linux) | pacman | NVIDIA RTX 3060 12 GB | ✅ Probado (equipo de referencia) |
| Arch Linux | pacman | — | 🟡 Debería funcionar — se agradecen reportes |
| Debian / Ubuntu | apt | — | 🟡 Debería funcionar — se agradecen reportes |
| Fedora | dnf | — | 🟡 Debería funcionar — se agradecen reportes |
| Windows (WSL2 + Ubuntu) | apt | — | 🟡 Debería funcionar — se agradecen reportes |

## Leyenda

- ✅ **Probado** — confirmado en el equipo de referencia del autor
- 🟡 **Debería funcionar / sin confirmar** — el proceso de bootstrap es compatible con el gestor de paquetes; aún no hay reportes de pruebas

## Agregar tu resultado

Abre un issue de **reporte de instalación** (Setup report; consulta la sección Issues del repositorio) e incluye:

- Tu distribución y su versión
- GPU (modelo y VRAM, o «ninguna»)
- Si se completó el proceso de bootstrap y funciona la delegación
- Cualquier solución alternativa necesaria

Consulta también [`CONTRIBUTING.md`](../CONTRIBUTING.md) y [`SETUP.md`](SETUP.md) para obtener contexto sobre bootstrap y WSL2.
