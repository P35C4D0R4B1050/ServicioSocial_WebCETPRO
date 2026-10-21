# Cambios

Registro de cambios por fase y por spec. Hasta la Fase 0 se anotan aquí los cambios de la documentación.

## 21-oct-2026 · Documentación

- **Reorganización de carpetas:** `Entregables/` (línea base y propuesta), `Contexto/Antecedentes/` y `Contexto/Referencia-de-formato/`; `README.md` en la raíz, `Entregables/` y `Contexto/`.
- **Auditoría de la documentación:** 36 hallazgos aplicados o registrados; ver [auditoría](log/2026-10-21-auditoria-de-la-documentacion.md).
- **Nuevo:** [matriz de trazabilidad hacia las specs](../docs/01-analisis-de-sistema/08-matriz-de-trazabilidad.md), catálogo de parámetros y brechas del esquema en el [modelo de datos](../docs/03-diseno-de-software/05-modelo-de-datos.md) (secciones 12 y 13).
- **Cambios de diseño en la documentación:** `web-base` pasa a la fase 1; RF-12 pasa de `periodos-ofertas` a `docs-reportes`; los módulos piden auditoría y alertas por puertos de `Compartido` (sin ciclos); el prefijo de los códigos de error es el de la spec.
- **Precisiones normativas:** el plazo del derecho de información no se amplía (DS art. 71.1); el encargado traslada las solicitudes en 3 días (art. 66.4); límite de 500 filas por archivo de AVANZA (por verificar para estudiantes).
- **Pendientes:** la lista de preguntas se reemplazó por «puntos por puntualizar» (10) y se retiraron o resolvieron P-06, P-07, P-12, P-13, P-14 y P-15.
## 21-oct-2026 · Repositorio y seguimiento de la auditoría

- **Git iniciado** y enlazado con `https://github.com/P35C4D0R4B1050/ServicioSocial_WebCETPRO` (rama `main`, basada en el primer commit existente). `.gitignore` y `.gitattributes` en la raíz; el repositorio es público, así que se excluyen secretos, claves, respaldos, datos reales, estado de OpenTofu, archivos de Office temporales, estado local de las herramientas de IA y el material de terceros o con nombres (ver `Contexto/README.md`).
- **Pendientes:** cada punto por puntualizar tiene ahora su comportamiento provisional en las specs ([docs/README.md](../docs/README.md#pendientes-y-puntos-por-puntualizar)); la portada de la propuesta se completó con la tutora y los integrantes del Informe 004.
- **Revisión de `docs/`:** 71 archivos sin problemas de forma (tablas, negritas, bloques de código); matriz de trazabilidad contrastada con `specs/README.md`, requisitos, controles y actores; catálogo de parámetros idéntico al SQL (26 claves). Corrección: la convención de dependencias de la matriz creaba un ciclo entre PAR e IDE; ahora AUD, PAR, WEB y OPS no dependen de IDE.
