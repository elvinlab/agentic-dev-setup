# Contribuir

**Español** · [English](CONTRIBUTING.en.md)

Este es un repositorio personal de dotfiles y demostración. Otros son bienvenidos a reproducirlo, pero refleja un flujo de trabajo y configuración de hardware específicos. Se aceptan contribuciones e informes de configuración; cambios opinados o fuera de alcance pueden ser rechazados.

## Formas de contribuir

- **Abrir un issue** — reportes de errores, informes de configuración por distro/GPU, o ideas
- **Enviar un pull request** — correcciones de errores, correcciones de compatibilidad distro/GPU, documentación y scripts de configuración son especialmente bienvenidos

## Antes de empezar

No necesitas la pila completa de agentes para arreglar documentación o un script. Para probar cambios de shell localmente solo necesitas `bash` y `shellcheck`.

## Ejecutar las comprobaciones localmente

```bash
# Lint
shellcheck scripts/*.sh scripts/lib/*.sh tests/*.sh

# Tests
for t in tests/*.sh; do bash "$t"; done
```

## Convenciones

- **Commits**: Conventional Commits (`feat`, `fix`, `docs`, `chore`, …). Sin líneas de atribución a IA.
- **Tests y docs**: Mantenlos junto al código al que se refieren.
- **Idioma**: El español es el idioma predeterminado y canónico de la documentación; las versiones en inglés se mantienen en archivos `.en.md`. El código y los mensajes de commit se escriben en inglés.

## Pull requests

1. Haz fork del repositorio y crea una rama desde `main`.
2. Mantén el cambio enfocado.
3. Asegúrate de que el workflow de CI (`shellcheck` + tests) pase.
4. Describe qué hace el cambio y por qué.

## Configuración del entorno

Consulte [docs/REQUIREMENTS.md](docs/REQUIREMENTS.md) para las cuentas, hardware y conocimientos necesarios antes de empezar, y [docs/SETUP.md](docs/SETUP.md) para el procedimiento completo de arranque, restauración y verificación.
