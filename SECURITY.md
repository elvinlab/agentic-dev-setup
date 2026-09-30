# Política de seguridad

**Español** · [English](SECURITY.en.md)

## Reporte de una vulnerabilidad

Use el reporte privado de vulnerabilidades de GitHub:

1. Vaya a la pestaña **Security** del repositorio.
2. Haga clic en **Report a vulnerability** (GitHub Security Advisories).
3. Complete los detalles y envíe de forma privada.

**No abra un issue público** para problemas de seguridad.

Este repositorio no acepta reportes de seguridad por correo electrónico.

## Versiones soportadas

| Versión | Estado |
|---------|--------|
| 1.0.0 (`main`) | ✅ Soportada |
| Anteriores | ❌ No soportadas |

Solo la última versión en la rama por defecto recibe actualizaciones de seguridad.

## Manejo de secretos

Este es un repositorio personal de dotfiles. **No se cometen secretos a git.**

- Las claves API de proveedores y configuración sensible viven en variables de entorno.
- Los secretos y la memoria de agentes se respaldan en un archivo encriptado con `age` (consulte [`docs/SETUP.md`](docs/SETUP.md)).
- La puerta de enlace OmniRoute se enlaza solo a `127.0.0.1` y requiere clave API.