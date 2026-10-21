# Seguridad

Documentación de seguridad y privacidad del Sistema de Matrícula. Se orienta por **OWASP** (Top 10:2025 y ASVS 5.0), la guía **NIST SP 800-63B-4** para autenticación y toma como referencia **ISO/IEC 27002:2022** e **ISO/IEC 25010:2023**, sin buscar certificación (RNF-15). Es proporcionada a un sistema de cinco usuarios que trata datos de personas, parte menores de edad, expuesto a Internet y a cargo de una entidad pública.

| Documento | Para qué sirve |
| :--- | :--- |
| [01 Modelo de amenazas](01-modelo-de-amenazas.md) | Activos, fronteras de confianza, amenazas `AM-01` a `AM-22` y casos de abuso. |
| [02 Lista de controles (ASVS 5.0)](02-controles-asvs.md) | Controles `CTL-01` a `CTL-40` con nivel, spec y estado. |
| [03 Autenticación y autorización](03-autenticacion-y-autorizacion.md) | Contraseñas, segundo factor, sesión, permisos y cuentas de servicio. |
| [04 Privacidad y datos personales](04-privacidad-y-datos-personales.md) | Inventario de datos, minimización, derechos, transferencias, retención e incidentes. |
| [05 Superficie expuesta e integraciones](05-api-e-integraciones.md) | Puntos HTTP, límites de uso y servicios de terceros. |
| [06 Seguridad del desarrollo con IA](06-seguridad-del-desarrollo-con-ia.md) | Qué puede y qué no puede ver una herramienta de IA; controles (AD-36). |
| [07 Operación segura](07-operacion-segura.md) | CI de seguridad, endurecimiento, registro y alertas, respaldo y respuesta a incidentes. |
| [08 Mapeo a estándares](08-mapeo-a-estandares.md) | Trazabilidad con OWASP, ISO, NIST y la normativa peruana. |

## Cómo se usa

1. Al escribir una spec que toca una frontera de confianza, se consulta el modelo de amenazas y se citan las `AM` relevantes.
2. Al planificar, se enlazan los controles `CTL` que aplican y se marcan los *Pendiente* que la spec resuelve.
3. Al verificar, `spec-verify` y el agente de seguridad contrastan el cambio con estos documentos.
4. Los identificadores `AM` y `CTL` no se renumeran; los nuevos se agregan al final.

## Fuera de alcance

Certificación ISO 27001, auditorías de terceros y pruebas de penetración externas. Tampoco se cubren ataques físicos, amenazas internas con acceso a los servidores de Oracle ni adversarios con recursos de un Estado.
